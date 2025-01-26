#Requires AutoHotkey v2.0
#SingleInstance
#Warn All, Off

Class Key
{
    __New(kOriginal,kHotKey,objOptions := 0){
        this.kOriginal := kOriginal
        this.kHotKey := kHotKey
        this.options := objOptions
    }
}
Class LayerInstance
{
    __New(kModifier,name,active := true,isMidiLayer := false){
        this.kModifier := kModifier
        this.name := name
        this.HotkeyRelation := Map()
        this.Active := active
        this.isMidiLayer := isMidiLayer
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