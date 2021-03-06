//
//  SettingsController.swift
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 07/09/2017.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2017-8 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3)

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

import Cocoa

class SettingsController: NSViewController {

	static var instance: SettingsController?
	
	//game settings
	//game modes and settings
	//timed regen
	@IBOutlet weak var enableTimeRegen: NSButton!
	@IBOutlet weak var time: NSTextField!
	//clearings regen
	@IBOutlet weak var enableClearingsRegen: NSButton!
	@IBOutlet weak var clearings: NSTextField!
	//random color change
	@IBOutlet weak var enableRandomColorChange: NSButton!
	@IBOutlet weak var colorChangeTime: NSTextField!
	//endlessness
	@IBOutlet weak var timeLimit: NSTextField!
	var endlessModeEnabled: Bool = false
	//tile colors
	@IBOutlet weak var tileColor1: NSColorWell!
	@IBOutlet weak var tileColor2: NSColorWell!
	@IBOutlet weak var tileColor3: NSColorWell!
	@IBOutlet weak var tileColor4: NSColorWell!
	//tile shape
	@IBOutlet weak var tileShapeSelection: NSPopUpButton!
	//arcade
	@IBOutlet weak var enableArcadeMode: NSButton!
	//background options
	@IBOutlet weak var backgroundStyle: NSMatrix!
	@IBOutlet weak var colorBGMode: NSButtonCell!
	@IBOutlet weak var imageBGMode: NSButtonCell!
	@IBOutlet weak var bgColor: NSColorWell!
	@IBOutlet weak var bgImage: NSImageView!
	var music: NSSound?
	//interface settings
	@IBOutlet weak var quitOnClose: NSButton!

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		SettingsController.instance = self
	}

	/**
	Toggles whether the game should have a time limit

	- parameters:
	- sender: Button clicked
	*/
	@IBAction func toggleEndless(_ sender: AnyObject) {
		endlessModeEnabled = (sender.state == NSControl.StateValue.on)
		timeLimit.isEnabled = !endlessModeEnabled
	}

	/**
	Obtain the current game settings

	- returns:
	Dictionary containing all the current game settings
	*/
	func getCurrentSettings() -> [String : Any] {
		return [
			"Color1" : tileColor1.color,
			"Color2" : tileColor2.color,
			"Color3" : tileColor3.color,
			"Color4" : tileColor4.color,
			"TimeRegenEnabled" : enableTimeRegen.state == NSControl.StateValue.on,
			"RegenTime" : time.integerValue,
			"ClearingsRegenEnabled" : enableClearingsRegen.state == NSControl.StateValue.on,
			"ClearingsCount" : clearings.integerValue,
			"ColorChangeEnabled" : enableRandomColorChange.state == NSControl.StateValue.on,
			"ColorChangeTime" : colorChangeTime.integerValue,
			"IsTimed" : !endlessModeEnabled,
			"TimeLimit" : timeLimit.integerValue,
			"TileShape" : TileShape(rawValue: tileShapeSelection.indexOfSelectedItem) ?? .CIRCLE,
			"ArcadeModeEnabled" : enableArcadeMode.state == NSControl.StateValue.on,
			"ImageBGEnabled" : backgroundStyle.selectedCell() == imageBGMode,
			"BGImage" : bgImage.image ?? "",
			"BGColor" : bgColor.color,
			"QuitOnClose" : quitOnClose.state == NSControl.StateValue.on
		]
	}

	/**
	Class function to obtain the current game settings

	- returns:
	Dictionary containing all the current game settings
	*/
	static func getSettings() -> [String : Any]? {
		return instance?.getCurrentSettings()
	}

}
