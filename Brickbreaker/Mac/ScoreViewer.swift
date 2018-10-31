//
//  ScoreViewer.swift
//  BrickBreaker Mac
//
//  Created by Alessandro Vinciguerra on 13/08/2018.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2018 Arc676/Alessandro Vinciguerra

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

class ScoreViewer: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

	@IBOutlet weak var gameTable: NSTableView!
	@IBOutlet weak var gameDataTable: NSTableView!

	static var instance: ScoreViewer?
	static var scores: [Date : [String : Any]]?

	static let keys = [
		"Score",
		"Timed regen",
		"Clearings regen",
		"Color change",
		"Arcade mode",
		"Time limit"
	]

	var dateFmt = DateFormatter()
	var confirmAlert: NSAlert?
	var entries: [Date]?

	/**
	Obtain existing scores from disk, if present
	*/
	class func initializeScores() {
		ScoreViewer.scores = [:]
		if let existingData = UserDefaults.standard.object(forKey: "Scores") as? Data {
			ScoreViewer.scores = NSKeyedUnarchiver.unarchiveObject(with: existingData) as? [Date : [String : Any]]
		}
	}

	/**
	Adds a new score to the list

	- parameters:
	- data: Game data
	*/
	class func addScore(_ data: [String : Any]) {
		ScoreViewer.scores![Date()] = data
		ScoreViewer.saveScoresToDisk()
		instance?.refreshScoreData()
	}

	/**
	Writes player scores to disk
	*/
	class func saveScoresToDisk() {
		UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: ScoreViewer.scores!), forKey: "Scores")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		ScoreViewer.instance = self

		dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"

		if confirmAlert == nil {
			confirmAlert = NSAlert()
			confirmAlert?.messageText = "Confirm deletion"
			confirmAlert?.informativeText = "Are you sure you want to delete? This cannot be undone."
			confirmAlert?.addButton(withTitle: "Yes")
			confirmAlert?.addButton(withTitle: "Cancel")
		}

		refreshScoreData()
	}

	/**
	Refreshes the interface to show updated score set
	*/
	func refreshScoreData() {
		entries = Array(ScoreViewer.scores!.keys)
		entries?.sort { $1.compare($0) == .orderedDescending }
		gameTable.reloadData()
		gameDataTable.reloadData()
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		if notification.object as? NSTableView == gameTable {
			gameDataTable.reloadData()
		}
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		if tableView == gameTable {
			return ScoreViewer.scores!.count
		} else {
			return 6
		}
	}

	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		if tableView == gameTable {
			return dateFmt.string(from: entries![row])
		} else {
			if tableColumn?.title == "Value" {
				let entryRow = gameTable.selectedRow
				if entryRow != -1 {
					return ScoreViewer.scores![entries![entryRow]]![ScoreViewer.keys[row]]
				}
			} else {
				return ScoreViewer.keys[row]
			}
			return nil
		}
	}

	/**
	Deletes the selected score data from the list

	- parameters:
	- sender: Button clicked
	*/
	@IBAction func deleteSelected(_ sender: Any) {
		let row = gameTable.selectedRow
		if row != -1 && confirmAlert?.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
			ScoreViewer.scores?.removeValue(forKey: entries![row])
			ScoreViewer.saveScoresToDisk()
			refreshScoreData()
		}
	}

	/**
	Deletes all score data from the list

	- parameters:
	- sender: Button clicked
	*/
	@IBAction func deleteAll(_ sender: Any) {
		if confirmAlert?.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
			ScoreViewer.scores?.removeAll()
			ScoreViewer.saveScoresToDisk()
			refreshScoreData()
		}
	}
	
}
