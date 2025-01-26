
#Requires Autohotkey v2
#SingleInstance
#Warn All, Off

#include %A_WorkingDir%\json-read-write.ahk

flag := EnvGet("HOTKEY_OPERATION")
hotkeyVal := EnvGet("HOTKEY_VALUE")
midiKeyNum := EnvGet("NOTE_NUMBER")

;It seems that using the Working directory parameter of RunWait doesn't work between versions.
working_directory := EnvGet("WORKING_DIRECTORY")
layer_name := EnvGet("MIDI_LAYER_NAME")
global layer_dir := working_directory . "\layers\"
;msgBox(layer_dir)
;#####################################################################################
switch(flag){
    case "w":
        write_midi_key(layer_name,midiKeyNum,hotkeyVal)
    case "rm":
        rm_midi_key(layer_name,midiKeyNum)
}

ExitApp
;msgBox("Edit made")

;#####################################################################################
rm_midi_key(layer_name,note_num){
    global layer_dir
    read_dir := layer_dir . layer_name . ".json"
    midi_layer := readLayer(read_dir)
    midi_layer.rmHotKey(note_num)
    writeLayer(midi_layer,layer_dir)
}

write_midi_key(layer_name,note_num,assigned_hotkey){
    global layer_dir
    read_dir := layer_dir . layer_name . ".json"
    midi_layer := readLayer(read_dir)

    options := {
        stacked_key: false
    }
    midi_layer.addHotKey(note_num,assigned_hotkey,options)
    writeLayer(midi_layer,layer_dir)
}