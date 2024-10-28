#Requires AutoHotkey v2.0
#SingleInstance
#Warn All, Off


global LayerDir := A_ScriptDir . "\layers\"
Class Key
{
    __New(kOriginal,kHotKey,objOptions){
        this.kOriginal := kOriginal
        this.kHotKey := kHotKey
        this.options := objOptions
    }
}
Class LayerInstance
{
    __New(kModifier,name,active := true){
        this.kModifier := kModifier
        this.name := name
        this.HotkeyRelation := Map()
        this.Active := active
        ;HotkeyRelation will in the form of a key-value pair,
        ;where the key is the original key and the value the new key
    }

    addHotKey(kOriginal,kHotKey,objOptions){
        options := objOptions
        KeyInst := Key(kOriginal,kHotKey,options)
        this.HotkeyRelation.Set(kOriginal, KeyInst)
    }

    rmHotKey(kOriginal){
        RemovedValue := this.HotkeyRelation.Delete(kOriginal)
    }
}
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
    text := FileRead(dir)
    return LightJson.parse(text,false)
}

writeLayer(LayerInput){
    output := LightJson.Stringify(LayerInput, '    ')
    outputDir := LayerDir
    if(!DirExist(outputDir)){
        DirCreate(outputDir)
    }
    outputDir .=  LayerInput.name . ".json"
    if(FileExist(outputDir)){
        FileDelete(outputDir)
    }
    FileAppend output, outputDir
}

;Loop through folder and seetup the hotkeys based on if the layers are active
;options format
;{
;   stacked_key := true false
;   second_key := 'seperate key'
;}
ActivateLayers(){
    Loop Files, LayerDir . "*.json"{
        currentLayer := readLayer(A_LoopFilePath)
        if(currentLayer.Active){
            for k,v in currentLayer.HotkeyRelation.OwnProps(){

                keyNameConc := currentLayer.kModifier . k
                callback := callbackGen(v)
                Hotkey(keyNameConc,callback)
            }        
        }
    
    }
}
;Custom callbackGenerator(returns callback)
callBackGen(hotkeyValue){

    if(!hotkeyValue.options.stacked_key){
        standardHotkeyCallback(*){
            Send hotkeyValue.kHotKey
        }
        return standardHotkeyCallback
    }else{
        stackedHotkeyCallback(*){
            if(KeyWait(hotkeyValue.kOriginal,'T0.3')){
                ;do or say the thing that we want to say on click
                Send hotkeyValue.kHotkey
            }Else{
                Send hotkeyValue.options.second_key
            }
        }
        return stackedHotkeyCallback
    }
}

;Callback functions for defining different hotkeys



update := LayerInstance('^','something')

update.addHotKey('d','t',{
    stacked_key : true,
    second_key : 'r'
})
update.addHotKey('p','q',{
    stacked_key : false
})
update.addHotKey('z','x',{
    stacked_key : true,
    second_key : 'u'
})
;writeLayer(update)
ActivateLayers()