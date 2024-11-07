
#Requires Autohotkey v2
;AutoGUI creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;EasyAutoGUI-AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2
global LayerDir := A_ScriptDir . "\layers\"


if A_LineFile = A_ScriptFullPath && !A_IsCompiled
{
    global ExistingLayerMenu := renderLayerMenu()
	myGui := Constructor()
	myGui.Show("w384 h360")
}

Constructor()
{	
	MenuBar_Storage := MenuBar()
	MenuBar_Storage.Add("Create New Layer", CreateNewLayerMenu)
	MenuBar_Storage.Add("Edit Existing Layer", EditExistingLayerMenu)
	MenuBar_Storage.Add("Toggle Active Layers", ToggleActiveLayersMenu)
	myGui := Gui()
	myGui.MenuBar := MenuBar_Storage
	ListViewKeyHotkeyHotkeytypeSecondKey := myGui.Add("ListView", "x0 y0 w242 h338 +LV0x4000", ["Key", "Hotkey", "Hotkey type", "Second Key"])
	ListViewKeyHotkeyHotkeytypeSecondKey.Add(,"Sample1")
	ListViewKeyHotkeyHotkeytypeSecondKey.OnEvent("DoubleClick", LV_DoubleClick)
	myGui.OnEvent('Close', (*) => ExitApp())
	myGui.Title := "Window"
	
	LV_DoubleClick(LV, RowNum)
	{
		if not RowNum
			return
		ToolTip(LV.GetText(RowNum), 77, 277)
		SetTimer () => ToolTip(), -3000
	}
	
	return myGui
}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
renderLayerMenu(){
    layerMenu := Menu()
    Loop Files, LayerDir . "*.json"{
        layerMenu.Add(A_LoopFileName, callback)
    }
    return layerMenu
}
;loads the selected layer into the listview to modify
callback(ItemName, ItemPos, MyMenu){
    
}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
CreateNewLayerMenu(ItemName, ItemPos, MyMenu){

}
EditExistingLayerMenu(ItemName, ItemPos, MyMenu){

}
ToggleActiveLayersMenu(ItemName, ItemPos, MyMenu){

}
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
