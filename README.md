<h3 align="center">Layered-Hotkey Manager</h3>

## About this project:

This project provides a rudimentary interface for creating and managing layers of hotkeys accessed using different combinations of the keyboard modifiers. Just as the Ctrl modifier changes the function of a given key to a shortcut funcitonality, this projects aims to allow user to, using a combinations of the modifiers keys create custom keyboard layers of shortcuts.


![AHK logo][logo_ahk]
##### Midi Device functionality
To provide additional hotkey utility the project also allows for the assigning of shortcuts to a midi device
##### Built with

The GUI of this project were made in large part using ["Easy Auto GUI for AHK v2"](https://github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2).

#### Getting started

##### Prerequisites
The majority of the project is written in autohotkey version 2 however in order to make use of the midi device functionality autohotkey v1.1 will also be required 

##### Installation and usage
In order to run the project on startup place the contents of this folder in a convenient location and create a shortcut of the midi-functionality and keyboard-functionality scripts and place them in the Windows Startup folder, which you can access by typing "shell:startup" in the Run dialog (Win + R) on your computer.

#### Credit
The code responsible for reading incoming MIDI messages was sourced from [RudyB24's AutoHotKey_Bome_MIDI_2_Key](https://github.com/RudyB24/AutoHotKey_Bome_MIDI_2_Key).

#### License
Distributed under the MIT License. See LICENSE for more information.


[logo_ahk]: https://autohotkey.com/static/ahk_logo_no_text.svg
