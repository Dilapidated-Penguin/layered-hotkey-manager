#Requires AutoHotkey v2.0
;Notation:
    ;variable name starting with lowercase k => key


;Object instantiation:
Class Key
{
    __New(kOriginal,kHotKey,strType){
        this.kOriginal := kOriginal
        this.kHotKey := kHotKey
        this.strType := strType
    }
}
Class Layer
{
    __New(kModifier, intLayerHeight){
        this.kModifier := kModifier
        this.intLayerHeight := intLayerHeight
        this.HotkeyRelation := Map()
        ;HotkeyRelation will in the form of a key-value pair,
        ;where the key is the original key and the value the new key
        this.strLayerData := ''
    }

    addHotKey(kOriginal,kHotKey,strType){
        this.HotkeyRelation.Set([String(kOriginal),new Key(kOriginal,kHotKey,strType)])
    }

    rmHotKey(kOriginal){
        RemovedValue := this.HotkeyRelation.Delete(kOriginal)
    }

    upDateLayerData(){
        ;some algorithm for changing the information
        this.strLayerData := ''
        for (key, val in this.HotkeyRelation){
            this.strLayerData := this.strLayerData String(key) ":" String(val) "\"
        }
    }

}
