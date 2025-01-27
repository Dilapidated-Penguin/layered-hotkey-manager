midi_hotkeyGUI()
{	
    myGui := Gui()
    ButtonAssigntomidikey := myGui.Add("Button", "x72 y72 w80 h35", "Assign to midi key")
    ButtonAssigntomidikey.Enabled := false

    hotkeyEdit := myGui.Add("Hotkey", "x24 y40 w120 h21")
    hotkeyEdit.OnEvent("Change",(*)=>
        ButtonAssigntomidikey.Enabled := true
    )

    myGui.Add("Text", "x24 y16 w156 h23 +0x200", "Enter the hotkey for the midi key")
    ButtonAssigntomidikey.OnEvent("Click", button_click)
    button_click(*){
        EnvSet "HOTKEY_OPERATION", "w"
        EnvSet "HOTKEY_VALUE", hotkeyEdit.value
        EnvSet "MIDI_LAYER_NAME", layer_to_edit.name
        EnvSet "WORKING_DIRECTORY", A_WorkingDir

        RunWait("`"midi-functionality.ahk`"", A_WorkingDir)


        myGUI.Destroy()
    }

    myGui.Title := "midi hotkey"

    return myGui
}

