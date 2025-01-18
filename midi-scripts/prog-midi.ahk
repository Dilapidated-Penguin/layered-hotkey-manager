;%1%: the flag designating whether the user is attempting to store a hotkey(w), remove a hotkey(rm)
;%2%: contains data1, the Note # or CC #. In effect the ID for the note/button/knob used
;%3%: will contain the name of the layer being edited
;%4%: contains the hotkey the user would like to assign the key to send.

#Requires Autohotkey v2
#SingleInstance
#Warn All, Off

#include %A_WorkingDir%\json-read-write.ahk
;#include %A_WorkingDir%\layer.ahk

global dir := A_WorkingDir . "layers\" . layer_name . ".json"

switch(%1%){
    case "w":
        write_midi_key(%3%,%2%,%4%)
    case "rm":
        rm_midi_key(%3%,%2%)
}

rm_midi_key(layer_name,note_num){
    global dir
    midi_layer := readLayer(dir)
    midi_layer.rmHotKey(note_num)
    writeLayer(midi_layer)
}

write_midi_key(layer_name,note_num,assigned_hotkey){
    global dir
    midi_layer := readLayer(dir)
    midi_layer.addHotKey(note_num,assigned_hotkey)
    writeLayer(midi_layer)
}


