hotkey_select_constr(default_key := "",default_hotkey := "", default_layered_status := false, default_second_key := "",set_to_edit := false)
{	
	myGui := Gui()
	buttonConfirm := myGui.Add("Button", "x48 y224 w80 h23", "Confirm")
	buttonConfirm.Enabled := set_to_edit
	key_entered := hotkey_entered := false
	second_hotkey_entered := true

	myGui.Add("Text", "x32 y88 w120 h23 +0x200", "Hotkey")
	myGui.Add("Text", "x32 y24 w120 h23 +0x200", "key")

	is_layered := myGui.Add("CheckBox", "x16 y160 w120 h23", "Hotkey when held")
	is_layered.Name := "is_layered"
	LayeredHotkeyEdit := myGui.Add("Hotkey", "x32 y184 w120 h21")
	LayeredHotkeyEdit.Name := "second_key"


	keyEdit := myGui.Add("Edit", "Limit1 Lowercase x32 y48 w120 h21")
	keyEdit.Name := "key"
	hotkeyEdit := myGui.Add("Hotkey", "x32 y112 w120 h21")
	hotkeyEdit.Name := "hotkey"

	;setting the default inputs
	default_layered_status := default_layered_status == "stacked key"
	keyEdit.Value := default_key
	hotkeyEdit.Value := default_hotkey
	LayeredHotkeyEdit.Enabled := default_layered_status
	LayeredHotkeyEdit.Value := default_second_key
	is_layered.Value := default_layered_status

	buttonConfirm.OnEvent("Click", onButtonClick)

	keyEdit.OnEvent("Change", OnEventHandler)
	hotkeyEdit.OnEvent("Change",OnEventHandler)
	LayeredHotkeyEdit.OnEvent("Change",OnEventHandler)

	is_layered.OnEvent("Click",onlayeredCheck)

	myGui.Title := ":)"
	onlayeredCheck(GuiCtrlObj, Info){
		LayeredHotkeyEdit.Enabled := GuiCtrlObj.Value
		second_hotkey_entered := !GuiCtrlObj.Value
		if(GuiCtrlObj.Value && (LayeredHotkeyEdit.Value != "")){
			second_hotkey_entered := true
		}

		OnEventHandler(GuiCtrlObj,Info)
	}

	OnEventHandler(GuiCtrlObj, Info){
		switch GuiCtrlObj.Name
		{
			case "key": key_entered := true
			case "hotkey": hotkey_entered := true
			case "second_key": second_hotkey_entered := true
		}
		buttonConfirm.Enabled := set_to_edit || (key_entered && hotkey_entered && second_hotkey_entered)
	}
	onButtonClick(*){
		submitted_hotkey := myGUI.Submit(0)
		if(verify_key_input(submitted_hotkey.key)){
			options := {
				stacked_key: submitted_hotkey.is_layered,
			}
			if(submitted_hotkey.is_layered){
				options.second_key := submitted_hotkey.second_key
			}
			global layer_to_edit

			layer_to_edit.addHotKey(submitted_hotkey.key, submitted_hotkey.hotkey,options)
			writeLayer(layer_to_edit,LayerDir)
			myGUI.Destroy()
			
			;rerender listview
			render_layer := renderListViewGen(layer_to_edit)
			render_layer()
		}else{
			msgBox("Invalid Key")
			keyEdit.Value := default_key
			hotkeyEdit.Value := default_hotkey
			buttonConfirm.Enabled := key_entered := hotkey_entered := false
			second_hotkey_entered := true
			LayeredHotkeyEdit.Value := default_second_key
			LayeredHotkeyEdit.Enabled := default_layered_status
			is_layered.Value := default_layered_status
		}
	}
	return myGui
}

verify_key_input(input){
	valid_keys := "abcdefghijklmnopqrstuvwxyz123456789[]\;',./-=*-+"
	return inStr(valid_keys,input)
}