#Requires Autohotkey v2
#SingleInstance
#Warn All, Off
;AutoGUI creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;EasyAutoGUI-AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2

SetWorkingDir A_ScriptDir

global LayerDir := A_WorkingDir . "\layers\"

#include %A_WorkingDir%\midi-scripts\json-read-write.ahk
#include %A_WorkingDir%\midi-scripts\layer.ahk

global layer_to_edit
global mid_edit
global previously_checked := ""

;GUI pages
#include %A_WorkingDir%\gui\Layer-toggleGUI.ahk
#include %A_WorkingDir%\gui\modifier-promptGUI.ahk
#include %A_WorkingDir%\gui\hotkey-creationGUI.ahk
#include %A_WorkingDir%\gui\midi-hotkeyGUI.ahk

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

	myGui.SetFont("s12 Bold cYellow")
	global layer_label := myGui.Add("Text", "x160 y337 w120 h23 +0x200 BackgroundTrans","Unselected")
	return myGui
}
;Context menu callback functions@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
standard_Hotkey(ItemName, ItemPos, MyMenu){
	global mid_edit
	if(mid_edit){
		if(!layer_to_edit.isMidiLayer){
			hotkey_selector := hotkey_select_constr()
			hotkey_selector.Show("w188 h279")
		}else{
			midi_prompt_GUI := midi_hotkeyGUI()
			midi_prompt_GUI.Show("w224 h136")
		}
		render_updated_layer := renderListViewGen(layer_to_edit)
		render_updated_layer()
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

	;directory := LayerDir . layer_to_edit.name . ".json"
	writeLayer(layer_to_edit,LayerDir)
}
editHotkey(ItemName, ItemPos, MyMenu){
	global listview_row_value
	row_data := get_LV_row(listview_row_value)
	msgBox(LightJson.Stringify(row_data,"	"))
	Hotkey_select_gui := hotkey_select_constr(row_data[1],row_data[2],row_data[3],row_data[4],1)
	Hotkey_select_gui.show("w188 h279")
}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
renderLayerMenu(){
    layerMenu := Menu()
	layerMenu.Add()
	global seperator_location := 1
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
		;check the correct layer entry:
		updateLayerMenuCheck(layer.name)
	}
	return callback
}
updateLayerMenuCheck(layer_name){
	global previously_checked
	if(previously_checked != ""){
		ExistingLayerMenu.UnCheck(previously_checked)
	}
	ExistingLayerMenu.Check(layer_name)
	previously_checked := layer_name

	;Change layer labal
	layer_label.Text := layer_name
}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
CreateCallback(ItemName, ItemPos, MyMenu){
	isMidiLayer := (ItemName = "Create new MIDI layer")
	objLayer_name := InputBox("Layer name:","Enter","W300 H99",A_Now)
	if(objLayer_name.Result != "Cancel"){
		global layer_to_edit
		global mid_edit
		mid_edit := true

		if(!isMidiLayer){
			modifier_GUI := prompt_modifier_GUI(objLayer_name)
			modifier_GUI.show("w220 h230")

		}else{
			layer_to_edit := LayerInstance("",objLayer_name.value,true,true)
			writeLayer(layer_to_edit,LayerDir)
			msgBox("add to midi layer")
			
			;Add to ExistingLayerMenu:
			global ExistingLayerMenu
			callback := renderListViewGen(layer_to_edit)
			ExistingLayerMenu.Add(layer_to_edit.name, callback)
			
			callback()
			;update LayerCheck:
			updateLayerMenuCheck(layer_to_edit.name)
		}
		ListViewKeyHotkeyHotkeytypeSecondKey.Delete()
	}
}