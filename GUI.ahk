#Requires Autohotkey v2
#SingleInstance
#Warn All, Off
;AutoGUI creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;EasyAutoGUI-AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2
global LayerDir := A_ScriptDir . "\layers\"
#include %A_ScriptDir%\json-read-write.ahk
#include %A_ScriptDir%\layer.ahk

global layer_to_edit
global mid_edit

if A_LineFile = A_ScriptFullPath && !A_IsCompiled
{
	;Creating the menus at the top of main GUI
    global ExistingLayerMenu := renderLayerMenu()
	global CreateLayerMenu := Menu()
	CreateLayerMenu.Add("Create New keyboard layer",CreateCallback)
	CreateLayerMenu.Add("Create new MIDI layer",CreateCallback)

	global mid_edit := false
	
	global Main_Gui := Constructor()
	Main_Gui.Show("w280 h360")
}

Constructor()
{	
	MenuBar_Storage := MenuBar()
	MenuBar_Storage.Add("Create New Layer", CreateLayerMenu)
	MenuBar_Storage.Add("Edit Existing Layer", ExistingLayerMenu)
	MenuBar_Storage.Add("Toggle Active Layers", ToggleActiveLayersMenu)
	myGui := Gui()
	myGui.MenuBar := MenuBar_Storage
	global ListViewKeyHotkeyHotkeytypeSecondKey := myGui.Add("ListView", "x0 y0 w345 h360 +LV0x4000 Backgroundblack cyellow Count10 vIn1", ["Key", "Hotkey", "Hotkey type", "Second Key"])
	;ListViewKeyHotkeyHotkeytypeSecondKey.Add(,"Sample1")
	;ListViewKeyHotkeyHotkeytypeSecondKey.OnEvent("DoubleClick", LV_DoubleClick)
	ListViewKeyHotkeyHotkeytypeSecondKey.OnEvent("ContextMenu", LV_RightClick)
	myGui.OnEvent('Close', (*) => ExitApp())
	myGui.Title := "Window"
	
	;LV_DoubleClick(LV, RowNum)
	;{
	;    rowArray := get_LV_row(RowNum) ; Get the text from the row's first field.
    ;	ToolTip("You double-clicked row number " RowNumber ". Text: '" RowText "'")
	;}
	;Context Menu @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	global RightClickMenu := Menu()
	global listview_row_value := 0
	global keyTypeMenu := Menu()
	keyTypeMenu.Add("Standard key",standard_Hotkey)

	RightClickMenu.Add("Add new hotkey",keyTypeMenu)
	RightClickMenu.Add("Remove Hotkey",rmHotkey)
	RightClickMenu.Add("Edit Selected Key",editHotkey)
	LV_RightClick(LV,itemRowNumber,isRightClick,x,y){
		if(itemRowNumber = 0){
			;disable the row dependant options. rm and edit
			RightClickMenu.Disable("Remove Hotkey")
			RightClickMenu.Disable("Edit Selected Key")
		}else{
			RightClickMenu.Enable("Remove Hotkey")
			RightClickMenu.Enable("Edit Selected Key")
		}
		listview_row_value := itemRowNumber
		RightClickMenu.Show(x,y)
	}

	return myGui
}
;Context menu callback functions@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
standard_Hotkey(ItemName, ItemPos, MyMenu){
	;create a gui to throw input hooks
	global mid_edit
	if(mid_edit){
		hotkey_selector := hotkey_select_constr()
		hotkey_selector.Show("w188 h279")
	}else{
		ToolTip("Select or create a layer to add a hotkey")
		SetTimer((*)=>ToolTip(), -2000)
	}

}

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
get_LV_row(row_number){
	row_array := []
	col_count := ListViewKeyHotkeyHotkeytypeSecondKey.GetCount("Col")
	Loop col_count {
		row_array.push(ListViewKeyHotkeyHotkeytypeSecondKey.GetText(row_number,A_Index))
	}
	return row_array
}
rmHotkey(ItemName, ItemPos, MyMenu){
	global listview_row_value
	row_data := get_LV_row(listview_row_value)
	layer_to_edit.rmHotKey(row_data[1])

	ListViewKeyHotkeyHotkeytypeSecondKey.Delete(listview_row_value)
	writeLayer(layer_to_edit)
}
editHotkey(ItemName, ItemPos, MyMenu){
	global listview_row_value
	row_data := get_LV_row(listview_row_value)
	msgBox(LightJson.Stringify(row_data,"	"))
	gui := hotkey_select_constr(row_data[1],row_data[2],row_data[3],row_data[4],1)
	gui.show("w188 h279")
}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
renderLayerMenu(){
    layerMenu := Menu()
	layerMenu.Add()
	seperator_location := 1
    Loop Files, LayerDir . "*.json"{
		layer := readLayer(A_LoopFilePath)
		callback := renderListViewGen(layer)

		layer_name := RegExReplace(A_LoopFileName,".json","")
		if(!layer.isMidiLayer){
			layerMenu.Insert(seperator_location . "&", layer_name,callback)
			seperator_location++
		}else{
			layerMenu.Add(layer_name, callback)
		}
    }
    return layerMenu
}
;loads the selected layer into the listview to modify

renderListViewGen(layer){
	callback(*){
		global ListViewKeyHotkeyHotkeytypeSecondKey
		ListViewKeyHotkeyHotkeytypeSecondKey.Delete()
		global layer_to_edit := layer
		global mid_edit := true
		for(k,v in layer_to_edit.HotkeyRelation){
			key_type := v.options.stacked_key ? "stacked key" : "traditional"
			second_key := v.options.stacked_key ? v.options.second_key : "N/A"
			
			ListViewKeyHotkeyHotkeytypeSecondKey.Add(,k,v.kHotKey,key_type,second_key)
		}
	}
	return callback
}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
CreateCallback(ItemName, ItemPos, MyMenu){
	isMidiLayer := (ItemName = "Create new MIDI layer")
	objLayer_name := InputBox("Layer name:","Enter","W300 H99",A_Now)
	if(objLayer_name.Result != "Cancel"){
		if(!isMidiLayer){
			modifier_GUI := prompt_modifier_GUI(objLayer_name)
			modifier_GUI.show("w220 h230")
		}else{
			; 
		}
		;Create global layerInstance to update to until some submit button is clicked
		ListViewKeyHotkeyHotkeytypeSecondKey.Delete()
	}


}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
ToggleActiveLayersMenu(ItemName, ItemPos, MyMenu){
	toggle_return := toggle_menu_constructor()
	toggle_return.Gooey.show("w200 h" . toggle_return.screen_height)
	toggle_menu_constructor()
	{	
		toggle_GUI := Gui()
		toggle_GUI.SetFont("s11 Bold")
		toggle_GUI.Add("Text", "x16 y64 w178 h23 +0x200", "Toggle layers on and off:")

		checkbox_Map := Map()
		radio_index := 0
		incr_height := 96
		midi_Scan := false
		Loop 2{
			Loop Files, LayerDir . "*.json"{
				layer := readLayer(A_LoopFilePath)
				if(layer.isMidiLayer = midi_Scan){
					radio_index++
					checkbox_options := "x16 y" . incr_height . " w120 h23"
					checkbox_options .= layer.Active ? " Checked" : ""
					checkbox_Map.Set(radio_index, toggle_GUI.Add("CheckBox", checkbox_options , layer.name))
					checkbox_Map[radio_index].name := layer.name
					incr_height += 32
				}
			}
			if(!midi_Scan){
				radio_index++
				checkbox_Map.Set(radio_index, toggle_GUI.Add("Text", "x16 y" . incr_height . " w170 h2 +0x10"))
				incr_height += 32
			}
			midi_Scan := true
		}
		submit_Button := toggle_GUI.Add("Button", "x72 y" . incr_height . " w80 h23", "Update")
		incr_height += 40

		submit_Button.OnEvent("Click",ActiveLayersSubmit)
		ActiveLayersSubmit(*){
			active_layers := toggle_GUI.submit()
			;Loop through the object instead
			for layerName, active_state in active_layers.OwnProps(){
				file_to_update := LayerDir . layerName . ".json"
				layer := readLayer(file_to_update)
				if(layer.Active != active_state){
					layer.Active := active_state
					writeLayer(layer)
				}
			}
			msgBox("Updated!")
			toggle_GUI.Destroy()
		}

;		toggle_GUI.OnEvent('Close', (*) => ExitApp())
		toggle_GUI.Title := "Toggle Layers"
		
		return {
			gooey : toggle_GUI,
			screen_height : incr_height
		}
	}
}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

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
		writeLayer(layer_to_edit)
		global mid_edit := true
		;Gotta get the layer menu to update when a new one is created


		;callback := renderListViewGen(layer_to_edit)
		;global layerMenu
		;layerMenu.Add(layer_name, callback)
		;Main_Gui.Show("w280 h360")
	}
	radio_update(radio_button_clicked,*)
	{
		ButtonConfirmselection.Enabled := true
	}
	
	return myGui
}

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
	;myGui.OnEvent('Close', (*) => ExitApp())


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
		if(inStr("abcdefghijklmnopqrstuvwxyz123456789[]\;',./-=*-+",submitted_hotkey.key)){
			options := {
				stacked_key: submitted_hotkey.is_layered,
			}
			if(submitted_hotkey.is_layered){
				options.second_key := submitted_hotkey.second_key
			}
			global layer_to_edit

			layer_to_edit.addHotKey(submitted_hotkey.key, submitted_hotkey.hotkey,options)
			writeLayer(layer_to_edit)
			render_updated_layer := renderListViewGen(layer_to_edit)
			render_updated_layer()
			myGUI.Destroy()
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