//
//  AppDelegate.swift
//  BrickBreaker Mac
//
//  Created by Alessandro Vinciguerra on 12/12/2016.
//  Copyright © 2016 Arc676. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    //UI
    @IBOutlet weak var window: NSWindow!
//    var view: GameView
    @IBOutlet weak var helpWindow: NSPanel!
    @IBOutlet weak var settingsWindow: NSWindow!

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
    var endlessModeEnabled: Bool
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
    //music settings
    @IBOutlet weak var pathToMusic: NSPathControl!
    @IBOutlet weak var loopMusic: NSButton!
    var music: NSSound
    //interface settings
    @IBOutlet weak var quitOnClose: NSButton!
    //high scores
    @IBOutlet weak var pathToFile: NSPathControl!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        endlessModeEnabled = false
        window.delegate = self
        timeLimit.isEnabled = false
        newGame(NSNull())
    }

    override init() {
        music = NSSound()
        endlessModeEnabled = false
    }

    func windowWillClose(_ notification: Notification) {
        if quitOnClose.state == NSOnState {
            NSApplication.shared().terminate(self)
        }
    }

    @IBAction func newGame(_ sender: AnyObject) {
        //
    }

	@IBAction func saveScore(_ sender: Any) {
	}
	
    @IBAction func showHelp(_ sender: AnyObject) {
        helpWindow.setIsVisible(true)
    }

    @IBAction func showSettings(_ sender: AnyObject) {
        settingsWindow.setIsVisible(true)
    }

    @IBAction func toggleEndless(_ sender: AnyObject) {
        endlessModeEnabled = (sender.state == NSOnState)
        timeLimit.isEnabled = !endlessModeEnabled
    }

    @IBAction func chooseMusic(_ sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["aiff","mp3","m4a","wav"]
        panel.allowsMultipleSelection = false
        if panel.runModal() == NSFileHandlingPanelOKButton {
            pathToMusic.url = panel.url!
            music = NSSound(contentsOf: panel.url!, byReference: true)!
            music.loops = (loopMusic.state == NSOnState)
        }
    }

}
