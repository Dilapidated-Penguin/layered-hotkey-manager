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