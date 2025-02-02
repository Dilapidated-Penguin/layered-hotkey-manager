#Requires AutoHotkey v2.0
#SingleInstance
#Warn All, Off

#include layer.ahk

;JSON parsing code by
class LightJson
{
    static JS := LightJson.GetJS(), true := {}, false := {}, null := {}

    static Parse(json, objIsMap := true, _rec?) {
        if !IsSet(_rec)
            obj := this.Parse(this.JS.JSON.parse(json), objIsMap, true)
        else if !IsObject(json)
            obj := json
        else if this.JS.Object.prototype.toString.call(json) == '[object Array]' {
            obj := []
            Loop json.length
                obj.Push(this.Parse(json.%A_Index - 1%, objIsMap, true))
        }
        else {
            obj := objIsMap ? Map() : {}
            keys := this.JS.Object.keys(json)
            Loop keys.length {
                k := keys.%A_Index - 1%
                ( objIsMap && obj[k]  := this.Parse(json.%k%, true , true))
                (!objIsMap && obj.%k% := this.Parse(json.%k%, false, true))
            }
        }
        return obj
    }

    static Stringify(obj, indent := '') {
        if indent = true {
            for k, v in ['true', 'false', 'null']
                if (obj = this.%v%)
                    return v

            if IsObject(obj) {
                isArray := Type(obj) = 'Array'
                enumerable := (Type(obj) = 'LayerInstance')||(Type(obj) = 'Object')||(Type(obj)='Key') ? obj.OwnProps() : obj

                str := ''
                for k, v in enumerable{
                    str .= (A_Index = 1 ? '' : ',') . (isArray ? '' : this.Stringify(k, true) . ':') . this.Stringify(v, true)
                }
                return isArray ? '[' str ']' : '{' str '}'
            }
            if IsNumber(obj) && Type(obj) != 'String'
                return obj

            for k, v in [['\', '\\'], [A_Tab, '\t'], ['"', '\"'], ['/', '\/'], ['`n', '\n'], ['`r', '\r'], [Chr(12), '\f'], [Chr(8), '\b']]
                obj := StrReplace(obj, v[1], v[2])

            return '"' obj '"'
        }
        sObj := this.Stringify(obj, true)
        return this.JS.eval('JSON.stringify(' . sObj . ',"","' . indent . '")')
    }

    static Beautify(json, indent) => this.JS.eval('JSON.stringify(' . json . ',"","' . indent . '")')

    static GetJS() {
        static document := '', JS
        if !document {
            document := ComObject('HTMLFILE')
            document.write('<meta http-equiv="X-UA-Compatible" content="IE=9">')
            JS := document.parentWindow
            (document.documentMode < 9 && JS.execScript())
        }
        return JS
    }
}

;Reading and writing to jsons
readLayer(dir){
    i := LightJson.parse(FileRead(dir),false)
    result := LayerInstance(i.kModifier,i.name,i.active,i.isMidiLayer)
    ;populating the hotkeyrelation
    for k,v in i.HotkeyRelation.OwnProps(){
        result.HotkeyRelation[k] := v   
    }
    return result
}

writeLayer(LayerInput,layer_dir){
    output := LightJson.Stringify(LayerInput, '    ')
    outputDir := layer_dir
    if(!DirExist(outputDir)){
        DirCreate(outputDir)
    }
    outputDir .=  LayerInput.name . ".json"
    if(FileExist(outputDir)){
        FileDelete(outputDir)
    }
    FileAppend output, outputDir
}