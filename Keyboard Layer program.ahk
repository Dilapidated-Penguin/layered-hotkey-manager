#Requires AutoHotkey v2.0
#SingleInstance
#Warn All, Off

Class Key
{
    __New(kOriginal,kHotKey,strType){
        this.kOriginal := kOriginal
        this.kHotKey := kHotKey
        this.strType := strType
    }
}
Class LayerInstance
{
    __New(kModifier, intLayerHeight,name,active := true){
        this.kModifier := kModifier
        this.name := name
        this.intLayerHeight := intLayerHeight
        this.HotkeyRelation := Map()
        this.Active := active
        ;HotkeyRelation will in the form of a key-value pair,
        ;where the key is the original key and the value the new key
    }

    addHotKey(kOriginal,kHotKey,strType){
        KeyInst := Key(kOriginal,kHotKey,strType)
        this.HotkeyRelation.Set(kOriginal, KeyInst)
    }

    rmHotKey(kOriginal){
        RemovedValue := this.HotkeyRelation.Delete(kOriginal)
    }
}
;JSON parsing code
;mapObj := LightJson.Parse(json)
;MsgBox LightJson.Stringify(mapObj, '    ')
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

;Object instantiation:

global layerInst := LayerInstance('^',3,'something',false)
layerInst.addHotKey('d','k','tap-Hold')
layerINst.addHotkey('a','z','typical')
output := LightJson.Stringify(layerInst, '    ')
outputDir := A_ScriptDir "\layers\"
if(!DirExist(outputDir)){
    DirCreate(outputDir)
}
outputDir .=  layerInst.name . ".json"
if(FileExist(outputDir)){
    FileDelete(outputDir)
}
FileAppend output, outputDir
