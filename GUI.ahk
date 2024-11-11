#Requires Autohotkey v2
#SingleInstance
#Warn All, Off
;AutoGUI creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;EasyAutoGUI-AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2
global LayerDir := A_ScriptDir . "\layers\"
#include %A_ScriptDir%\json-read-write.ahk


if A_LineFile = A_ScriptFullPath && !A_IsCompiled
{
	;Creating the menus at the top of main GUI
    global ExistingLayerMenu := renderLayerMenu()
	global CreateLayerMenu := Menu()
	CreateLayerMenu.Add("Create New keyboard layer",CreateCallback)
	CreateLayerMenu.Add("Create new MIDI layer",CreateCallback)


	myGui := Constructor()
	myGui.Show("w345 h360")
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
	ListViewKeyHotkeyHotkeytypeSecondKey.Add(,"Sample1")
	; ListViewKeyHotkeyHotkeytypeSecondKey.OnEvent("DoubleClick", LV_DoubleClick)
	ListViewKeyHotkeyHotkeytypeSecondKey.OnEvent("ContextMenu", LV_RightClick)
	myGui.OnEvent('Close', (*) => ExitApp())
	myGui.Title := "Window"
	
	; LV_DoubleClick(LV, RowNum)
	; {
	; 	if not RowNum
	; 		return
	; 	ToolTip(LV.GetText(RowNum), 77, 277)
	; 	SetTimer () => ToolTip(), -3000
	; }
	;Context Menu @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	global RightClickMenu := Menu()
	global listview_row_value := 0
	global keyTypeMenu := Menu()
	keyTypeMenu.Add("Standard key",standard_Hotkey)
	keyTypeMenu.Add("Staggered key",staggered_hotkey)

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
	global listview_row_value
	msgBox(listview_row_value)
}
staggered_hotkey(ItemName, ItemPos, MyMenu){
	global listview_row_value
	msgBox(listview_row_value)
}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
rmHotkey(ItemName, ItemPos, MyMenu){
	global listview_row_value
	msgBox(listview_row_value)
}
editHotkey(ItemName, ItemPos, MyMenu){
	global listview_row_value
	msgBox(listview_row_value)
}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
renderLayerMenu(){
    layerMenu := Menu()
	layerMenu.Add()
	seperator_location := 1
    Loop Files, LayerDir . "*.json"{
		layer := readLayer(A_LoopFilePath)
		callback := renderCallbackGenerator(layer)
		if(!layer.isMidiLayer){
			layerMenu.Insert(seperator_location . "&", A_LoopFileName,callback)
			seperator_location++
		}else{
			layerMenu.Add(A_LoopFileName, callback)
		}
    }
    return layerMenu
}
;loads the selected layer into the listview to modify

renderCallbackGenerator(layer){

	callback(ItemName, ItemPos, MyMenu){
		global ListViewKeyHotkeyHotkeytypeSecondKey
		ListViewKeyHotkeyHotkeytypeSecondKey.Delete()

		for(k,v in layer.HotkeyRelation.OwnProps()){
			key_type := v.options.stacked_key ? "stacked key" : "traditional"
			second_key := v.options.stacked_key ? v.options.second_key : "N/A"
			
			ListViewKeyHotkeyHotkeytypeSecondKey.Add(,k,v.kHotKey,key_type,second_key)
		}
	}
	return callback
}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
CreateCallback(ItemName, ItemPos, MyMenu){
	isMidiLayer := (ItemName = "Create new MIDI layer")
	;Create global layerInstance to update to until some submit button is clicked
	ListViewKeyHotkeyHotkeytypeSecondKey.Delete()

}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
ToggleActiveLayersMenu(ItemName, ItemPos, MyMenu){

}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
