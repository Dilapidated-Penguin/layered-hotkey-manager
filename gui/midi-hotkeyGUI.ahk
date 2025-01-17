midi_hotkeyGUI()
{	
myGui := Gui()
ButtonAssigntomidikey := myGui.Add("Button", "x72 y72 w80 h35", "Assign to midi key")
ButtonAssigntomidikey.Enabled := false
ButtonAssigntomidikey.OnEvent("Change",(*)=> ButtonAssigntomidikey.Enabled := true)
myGui.Add("Hotkey", "x24 y40 w120 h21")
myGui.Add("Text", "x24 y16 w156 h23 +0x200", "Enter the hotkey for the midi key")
ButtonAssigntomidikey.OnEvent("Click", OnEventHandler)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Window"

OnEventHandler(*)
{
    ;Run midi keyboard script(hotkey)=>
}

return myGui
}

;myGui := midi_hotkeyGUI()
;myGui.Show("w224 h136")