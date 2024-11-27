#Requires AutoHotkey v2.0
#SingleInstance
#Warn All, Off



global LayerDir := A_ScriptDir . "\layers\"
global long_key_pressed := false

#include %A_ScriptDir%\json-read-write.ahk
#include %A_ScriptDir%\layer.ahk
;*******************

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

                if(v.options.stacked_key){
                    Hotkey(keyNameConc . ' Up',callbackLift)
                }
            }        
        }
    }
}
callbackLift(*){
    global long_key_pressed := false
}

;Custom callbackGenerator(returns callback)
callBackGen(hotkeyValue){

    if(!hotkeyValue.options.stacked_key){
        standardHotkeyCallback(*){
            Send hotkeyValue.kHotKey
        }
        return standardHotkeyCallback
    }else{
        stackedHotkeyCallback(hotKey_name){
            ;msgbox(long_key_pressed)
            if(long_key_pressed){
                return
            }else{
                global long_key_pressed := true
                keyArray := StrSplit(hotKey_name)
                checked_Key := keyArray[-1]
                isHeldDown := keyWait(checked_Key,"T0.2")
                key_to_Send := isHeldDown ? hotkeyValue.options.second_key : hotkeyValue.kHotKey
                
                Send(key_to_Send)
                  
            }
        }
        return stackedHotkeyCallback
    }
}
HoldTimerGen(checked_Key,hotkeyValue){
    timerCallback(){

    }
    return timerCallback
    ;returns the function that is run on setTImer
}


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
writeLayer(update)
ActivateLayers()