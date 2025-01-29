prompt_modifier_GUI(layer_name)
{	
	
	myGui := Gui()
	myGui.SetFont("s9 Bold Underline")
	myGui.Add("Text", "x24 y8 w176 h42 +Left +0x200", "Choose modifier combination")
	ButtonConfirmselection := myGui.Add("Button", "x64 y187 w80 h39", "Confirm selection")
	ButtonConfirmselection.Enabled := false

	Radio_LCtrl := myGui.Add("Radio", "x16 y48 w66 h23 Group", "Left Ctrl")
	Radio_RCtrl := myGui.Add("Radio", "x128 y48 w70 h23", "Right Ctrl")
	Radio_LCtrl.Name := "ctrl_pos"

	Radio_LShift := myGui.Add("Radio", "x16 y72 w66 h30 Group", "Left shift")
	Radio_RShift := myGui.Add("Radio", "x128 y72 w75 h30", "Right shift")
	Radio_LShift.Name := "shift_pos"

	Radio_LAlt := myGui.Add("Radio", "x16 y104 w62 h23 Group", "Left Alt")
	Radio_RAlt := myGui.Add("Radio", "x128 y104 w62 h23", "Right Alt")
	Radio_LAlt.Name := "alt_pos"

	Radio_LWin := myGui.Add("Radio", "x16 y128 w69 h32 Group", "Left window")
	Radio_RWin := myGui.Add("Radio", "x128 y128 w73 h39", "Right Window")
	Radio_LWin.Name := "win_pos"
	ButtonConfirmselection.OnEvent("Click", button_confirm)
	Radio_LCtrl.OnEvent("Click", radio_update)
	Radio_LShift.OnEvent("Click", radio_update)
	Radio_RShift.OnEvent("Click", radio_update)
	Radio_RCtrl.OnEvent("Click", radio_update)
	Radio_LAlt.OnEvent("Click", radio_update)
	Radio_RAlt.OnEvent("Click", radio_update)
	Radio_LWin.OnEvent("Click",radio_update)
	Radio_RWin.OnEvent("Click",radio_update)
	;myGui.OnEvent('Close', (*) => ExitApp())
	myGui.Title := "Modifier"
	button_confirm(*){
		;when the button is clicked
		modifier_results := myGui.Submit()
		modifier_string := ''
		;use modifier results to make the modifier key
		if(modifier_results.win_pos != 0){
			modifier_string .= (modifier_results.win_pos = 2) ? ">" : "<"
			modifier_string .= "#"
		}
		if(modifier_results.ctrl_pos != 0){
			modifier_string .= (modifier_results.ctrl_pos = 2) ? ">" : "<"
			modifier_string .= "^"
		}
		if(modifier_results.alt_pos != 0){
			modifier_string .= (modifier_results.alt_pos = 2) ? ">" : "<"
			modifier_string .= "!"
		}
		if(modifier_results.shift_pos != 0){
			modifier_string .= (modifier_results.shift_pos = 2) ? ">" : "<"
			modifier_string .= "+"
		}
		msgBox("modifier string: " . modifier_string . "`nRight click on the listview to add a new button `nNew Layer Instance created")
		global layer_to_edit := LayerInstance(modifier_string,layer_name.value)
		;msgBox(LightJson.Stringify(layer_to_edit,"	"))
		writeLayer(layer_to_edit,LayerDir)
		global mid_edit := true

		;Add to ExistingLayerMenu:
		global ExistingLayerMenu
        global seperator_location
    
        callback := renderListViewGen(layer_to_edit)
        ExistingLayerMenu.Insert(seperator_location . "&", layer_to_edit.name,callback)
        seperator_location++

		;update LayerCheck
		updateLayerMenuCheck(layer_to_edit.name)
		;Render layer:
		callback()

	}
	radio_update(radio_button_clicked,*)
	{
		ButtonConfirmselection.Enabled := true
	}
	
	return myGui
}