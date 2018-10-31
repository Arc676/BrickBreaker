//
//  GameView.swift
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 12/12/2016.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2016-8 Arc676/Alessandro Vinciguerra

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

class GameView: NSView {

	let WIDTH = 22, HEIGHT = 28
	var lastCol = 21 // WIDTH - 1

	var points: [String]
	var regenTimer, gameTimer, colorChangeTimer, popUpTextTimer: Timer!
	var colors: [NSColor]
	var bgImage, bomb, plus50, plus200, plus2k, plus5k, clearRow, clearColumn: NSImage!
	var bgColor: NSColor! = NSColor.black
	var popUpText: String

	var hasSelection, gameOver, isTimed, isImageBG, arcadeModeEnabled, popUpTextPresent: Bool
	var timeRegen, clearingsRegen, randomColorChange: Bool
	var score: UInt
	var clearings, clearingsLimit, regenTime, randomColorChangeTime, consecutive5s: Int
	var timeLimit: Int
	var shape: TileShape

	var bricks: [[ColorIndex]]
	var powerups: [[PowerUp]]

	let att: [NSAttributedStringKey : Any] = [
		NSAttributedStringKey.font : NSFont(name: "Helvetica", size: 30)!,
		NSAttributedStringKey.foregroundColor : NSColor.white
	]

	required init?(coder: NSCoder) {
		hasSelection = false
		gameOver = true
		isTimed = false
		isImageBG = false
		arcadeModeEnabled = false
		popUpTextPresent = false
		timeRegen = false
		clearingsRegen = false
		randomColorChange = false

		score = 0

		clearings = 0
		clearingsLimit = 0
		regenTime = 0
		randomColorChangeTime = 0
		consecutive5s = 0

		timeLimit = 0

		points = []
		colors = [NSColor.red, NSColor.green, NSColor.blue, NSColor.yellow]

		popUpText = ""

		shape = .CIRCLE

		bomb = NSImage(named: NSImage.Name(rawValue: "bomb.png"))
		plus50 = NSImage(named: NSImage.Name(rawValue: "plus50.png"))
		plus200 = NSImage(named: NSImage.Name(rawValue: "plus200.png"))
		plus2k = NSImage(named: NSImage.Name(rawValue: "plus2k.png"))
		plus5k = NSImage(named: NSImage.Name(rawValue: "plus5k.png"))
		clearRow = NSImage(named: NSImage.Name(rawValue: "clearRow.png"))
		clearColumn = NSImage(named: NSImage.Name(rawValue: "clearColumn.png"))

		bricks = [[ColorIndex]](repeating: [ColorIndex](repeating: .N_A, count: HEIGHT), count: WIDTH)
		powerups = [[PowerUp]](repeating: [PowerUp](repeating: .NO_POWERUP, count: HEIGHT), count: WIDTH)

		super.init(coder: coder)

		NotificationCenter.default.addObserver(self,
											   selector: #selector(startGame),
											   name: newGameKey,
											   object: nil)
	}

	override func draw(_ rect: NSRect) {
		super.draw(rect)
		if isImageBG {
			bgImage.draw(at: NSZeroPoint, from: NSZeroRect, operation: .sourceOver, fraction: 1)
		} else {
			bgColor.set()
			rect.fill()
		}

		// draw bricks
		for x in 0..<WIDTH {
			for y in 0..<HEIGHT {
				// ignore empty spaces
				if bricks[x][y] == .N_A {
					continue
				}

				// draw current brick
				colors[bricks[x][y].rawValue].set()
				let xcoord: CGFloat = CGFloat(x * 20)
				let ycoord: CGFloat = CGFloat(y * 20)
				if shape == .CIRCLE {
					let path = NSBezierPath()
					path.appendOval(in: NSMakeRect(xcoord, ycoord, 20, 20))
					path.fill()
				} else {
					NSMakeRect(xcoord, ycoord, 20, 20).fill()
				}

				// draw powerups, if present
				if arcadeModeEnabled && powerups[x][y] != .NO_POWERUP {
					let point = NSMakePoint(xcoord, ycoord)
					switch powerups[x][y] {
					case .BOMB:
						bomb.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
					case .PLUS_50:
						plus50.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
					case .PLUS_200:
						plus200.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
					case .PLUS_2K:
						plus2k.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
					case .PLUS_5K:
						plus5k.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
					case .CLEAR_ROW:
						clearRow.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
					case .CLEAR_COLUMN:
						clearColumn.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
					default:
						break
					}
				}

				// highlight the player's selection, if present
				if hasSelection {
					for point in points {
						NSColor.white.set()
						let origin = NSPointFromString(point)
						NSMakeRect(origin.x * 20, origin.y * 20, 20, 20).frame()
					}
				}

				// draw text, if needed
				NSColor.black.set()
				if popUpTextPresent {
					let str = NSAttributedString(string:
						String(popUpText[popUpText.index(popUpText.startIndex, offsetBy: 1)...]),
												 attributes: att)
					NSMakeRect(0, 540 - str.size().height, 440, str.size().height + 10).fill()
					str.draw(at: NSMakePoint(440/2 - str.size().width/2, 550 - str.size().height))
				}
				if gameOver {
					NSMakeRect(0, 250, 440, 50).fill()
					let str = NSAttributedString(string: "Game Over", attributes: att)
					str.draw(at: NSMakePoint(440/2 - str.size().width/2, 255))
				}
			}
		}
	}

	override func mouseUp(with theEvent: NSEvent) {
		if gameOver {
			needsDisplay = true
			return
		}
		selectBricks(Int(theEvent.locationInWindow.x / 20), Int(theEvent.locationInWindow.y / 20))
	}

	/**
	Selects adjacent bricks of the same color

	- parameters:
		- x: Horizontal index of clicked brick
		- y: Vertical index of clicked brick
		- byUser: Whether the call was made because the user clicked (defaults to true)
	*/
	func selectBricks(_ x: Int, _ y: Int, _ byUser: Bool = true) {
		// clear current selection
		hasSelection = false
		points.removeAll()

		// do nothing if the index is out of bounds
		if x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT || bricks[x][y] == .N_A {
			needsDisplay = true
			window?.title = "BrickBreaker Score: \(score) Selection: 0"
			return
		}

		findAdjacentTo(x, y, bricks[x][y])
		// selection must exceed 1 brick, then update window title
		if points.count <= 1 {
			points.removeAll()
			if byUser {
				window?.title = "BrickBreaker Score: \(score) Selection: 0"
			}
		} else {
			hasSelection = true
			if byUser {
				window?.title = "BrickBreaker Score: \(score) Selection: \(pow(Float(points.count - 1), 4))"
			}
		}

		needsDisplay = true
	}

	/**
	Clear the selected bricks
	*/
	func clearBricks() {
		// do nothing if nothing is selected
		if points.count == 0 {
			return
		}

		// track consecutive clearings of 5+ bricks
		if points.count > 5 {
			consecutive5s += 1
		} else {
			consecutive5s = 0
		}

		var shouldShowPopUp = false

		// check if a combo has been reached
		if consecutive5s > 0 && consecutive5s % 5 == 0 {
			popUpText += "\nCombo (\(consecutive5s))! +\(consecutive5s * 100)"
			score += UInt(consecutive5s * 100)
			shouldShowPopUp = true
		}

		// get points from clearing selection
		score += UInt(pow(Double(points.count - 1), 4))

		// determine the area of the grid that needs updating by finding
		// the extremities of the affected space
		var low = HEIGHT, high = -1, left = WIDTH, right = -1, added = 0
		for str in points {
			let point = NSPointFromString(str)
			let xcoord = Int(point.x), ycoord = Int(point.y)

			if ycoord < low {
				low = ycoord
			}
			if ycoord > high {
				high = ycoord
			}

			if xcoord < left {
				left = xcoord
			}
			if xcoord > right {
				right = xcoord
			}

			// clear the brick
			bricks[xcoord][ycoord] = .N_A
			// check for powerups
			if arcadeModeEnabled {
				var cleared = 0
				switch powerups[xcoord][ycoord] {
				case .BOMB:
					// clear the surrounding blocks
					for x in (xcoord - 2)...(xcoord + 2) {
						if x < 0 || x >= WIDTH {
							continue
						}
						for y in (ycoord - 2)...(ycoord + 2) {
							if y < 0 || y >= HEIGHT {
								continue
							}
							if bricks[x][y] != .N_A {
								bricks[x][y] = .N_A
								cleared += 1
							}
						}
					}
					// update affected region
					added += 4
					low = max(0, low - 2)
					left = max(0, left - 2)
					right = min(WIDTH - 1, right + 2)
				case .PLUS_50:
					score += 50
				case .PLUS_200:
					score += 200
				case .PLUS_2K:
					score += 2000
				case .PLUS_5K:
					score += 5000
				case .CLEAR_ROW:
					// clear the entire row
					for x in 0..<WIDTH {
						if bricks[x][ycoord] != .N_A {
							bricks[x][ycoord] = .N_A
							cleared += 1
						}
					}
					// update affected region
					added += 1
					low = max(0, low - 1)
					left = 0
					right = WIDTH - 1
				case .CLEAR_COLUMN:
					// clear entire column
					for y in 0..<HEIGHT {
						if bricks[xcoord][y] != .N_A {
							bricks[xcoord][y] = .N_A
							cleared += 1
						}
					}
					// update affected region
					low = 0
				default:
					break
				}
				// obtain score from additional cleared bricks
				// and clear powerup
				score += UInt(pow(Double(cleared), 4))
				powerups[xcoord][ycoord] = .NO_POWERUP
			}
		}

		// clear selection
		hasSelection = false
		points.removeAll()

		// fall vertically
		for _ in 0...(high + added - low + 1) {
			for x in left...right {
				for y in max(1, low)..<HEIGHT {
					if bricks[x][y] == .N_A {
						continue
					}
					if bricks[x][y - 1] == .N_A {
						bricks[x][y - 1] = bricks[x][y]
						bricks[x][y] = .N_A
						if arcadeModeEnabled && powerups[x][y] != .NO_POWERUP {
							powerups[x][y - 1] = powerups[x][y]
							powerups[x][y] = .NO_POWERUP
						}
					}
				}
			}
		}

		// fall horizontally
		var x = left
		while x < WIDTH {
			var colIsEmpty = true
			for y in 0..<HEIGHT {
				if bricks[x][y] != .N_A {
					colIsEmpty = false
					break
				}
			}
			if colIsEmpty && x < lastCol {
				for x1 in x..<WIDTH - 1 {
					bricks[x1] = bricks[x1 + 1]
				}
				if bricks[lastCol][0] != .N_A {
					for y1 in 0..<HEIGHT {
						bricks[lastCol][y1] = .N_A
					}
				}
				lastCol -= 1
			} else {
				x += 1
			}
		}

		// random criticals
		if arc4random_uniform(100) < 7 {
			popUpText += "\nCritical! +500 pts"
			score += 500
			shouldShowPopUp = true
		}

		window?.title = "BrickBreaker Score: \(score) Selection: 0"

		// check if tiles should regenerate
		if clearingsRegen {
			clearings += 1
			if clearings >= clearingsLimit {
				clearings = 0
				addTiles()
			}
		}

		// show text, if present
		if shouldShowPopUp {
			popUpTextPresent = true
			if (popUpTextTimer != nil) {
				popUpTextTimer.invalidate()
				popUpTextTimer = nil
			}
			popUpTextTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(GameView.hidePopUpText(_:)), userInfo: nil, repeats: false)
		}

		// check if there are any more available bricks to pop
		if isGameOver() {
			endGame()
		}

		needsDisplay = true
	}

	/**
	Determines if the game is over

	- returns:
	If there are no more possible brick selections
	*/
	func isGameOver() -> Bool {
		for y in 0..<HEIGHT {
			for x in 0..<WIDTH {
				selectBricks(x, y, false)
				if hasSelection {
					hasSelection = false
					return false
				}
			}
		}
		return true
	}

	override func keyDown(with event: NSEvent) {}

	override func keyUp(with theEvent: NSEvent) {
		clearBricks()
	}

	/**
	Terminates the game
	*/
	@objc func endGame() {
		clearTimers()
		gameOver = true
		needsDisplay = true
		saveScore()
	}

	/**
	Hides the popup text after the specified delay

	- parameters:
		- timer: Timer object
	*/
	@objc func hidePopUpText(_ timer: Timer) {
		popUpTextPresent = false
		popUpText = ""
		needsDisplay = true
	}

	/**
	Recursively search for bricks that share a color with the selected brick and
	are all adjacent to each other

	- parameters:
		- x: Horizontal index of original brick
		- y: Vertical index of original brick
		- color: Color of original brick
	*/
	func findAdjacentTo(_ x: Int, _ y: Int, _ color: ColorIndex) {
		points.append("\(x) \(y)")
		if y < HEIGHT - 1 {
			if bricks[x][y + 1] == color &&
				!points.contains("\(x) \(y + 1)") {
				findAdjacentTo(x, y + 1, color)
			}
		}
		if y > 0 {
			if bricks[x][y - 1] == color &&
				!points.contains("\(x) \(y - 1)") {
				findAdjacentTo(x, y - 1, color)
			}
		}
		if x < WIDTH - 1 {
			if bricks[x + 1][y] == color &&
				!points.contains("\(x + 1) \(y)") {
				findAdjacentTo(x + 1, y, color)
			}
		}
		if x > 0 {
			if bricks[x - 1][y] == color &&
				!points.contains("\(x - 1) \(y)") {
				findAdjacentTo(x - 1, y, color)
			}
		}
	}

	/**
	Generates bricks

	- parameters:
		- mode: Desired brick generation algorithm
	*/
	func generateTiles(_ mode: GenerationMode) {
		for x in 0..<WIDTH {
			for y in 0..<HEIGHT {
				let val = ColorIndex(rawValue: Int(arc4random_uniform(4)))!
				// the brick at the given position should become a new random brick if
				// - a new game is being started
				// - bricks are being regenerated and there is currently no brick at this position
				// - bricks are being shuffled and there currently is a brick at this position
				if (mode == .NEW_GAME) ||
					(mode == .REGEN_TILES && bricks[x][y] == .N_A) ||
					(mode == .SHUFFLE_TILES && bricks[x][y] != .N_A) {
					bricks[x][y] = val
				}
			}
		}
		hasSelection = false
		points.removeAll()
		needsDisplay = true
	}

	/**
	Regenerates the grid
	*/
	@objc func addTiles() {
		generateTiles(.REGEN_TILES)
	}

	/**
	Randomizes the colors of the bricks on the grid
	*/
	@objc func shuffleTiles() {
		generateTiles(.SHUFFLE_TILES)
	}

	/**
	Invalidates all timers
	*/
	func clearTimers() {
		if regenTimer != nil {
			regenTimer.invalidate()
			regenTimer = nil
		}
		if gameTimer != nil {
			gameTimer.invalidate()
			gameTimer = nil
		}
		if colorChangeTimer != nil {
			colorChangeTimer.invalidate()
			colorChangeTimer = nil
		}
	}

	/**
	Starts a new game
	*/
	@objc func startGame() {
		// obtain game settings
		if let settings = SettingsController.getSettings() {
			colors = [
				settings["Color1"] as! NSColor,
				settings["Color2"] as! NSColor,
				settings["Color3"] as! NSColor,
				settings["Color4"] as! NSColor
			]
			timeRegen = settings["TimeRegenEnabled"] as! Bool
			regenTime = settings["RegenTime"] as! Int

			clearingsRegen = settings["ClearingsRegenEnabled"] as! Bool
			clearingsLimit = settings["ClearingsCount"] as! Int

			randomColorChange = settings["ColorChangeEnabled"] as! Bool
			randomColorChangeTime = settings["ColorChangeTime"] as! Int

			isTimed = settings["IsTimed"] as! Bool
			timeLimit = settings["TimeLimit"] as! Int

			shape = settings["TileShape"] as! TileShape
			arcadeModeEnabled = settings["ArcadeModeEnabled"] as! Bool

			isImageBG = settings["ImageBGEnabled"] as! Bool
			if isImageBG {
				bgImage = settings["BGImage"] as? NSImage
			} else {
				bgColor = settings["BGColor"] as? NSColor
			}
		}

		// initialize time sensitive game properties
		if clearingsLimit <= 0 {
			clearingsLimit = defaultRegenClearings
		}
		if timeLimit <= 0 {
			timeLimit = defaultTimeLimit
		}
		if regenTime <= 0 {
			regenTime = defaultRegenTime
		}
		if randomColorChangeTime <= 0 {
			randomColorChangeTime = defaultColorChangeTime
		}
		clearTimers()
		if timeRegen {
			regenTimer = Timer.scheduledTimer(
				timeInterval: TimeInterval(regenTime),
				target: self,
				selector: #selector(addTiles),
				userInfo: nil,
				repeats: true)
		}
		if isTimed {
			gameTimer = Timer.scheduledTimer(
				timeInterval: TimeInterval(self.timeLimit * 60),
				target: self,
				selector: #selector(endGame),
				userInfo: nil,
				repeats: false)
		}
		if randomColorChange {
			colorChangeTimer = Timer.scheduledTimer(
				timeInterval: TimeInterval(randomColorChangeTime),
				target: self,
				selector: #selector(shuffleTiles),
				userInfo: nil,
				repeats: true)
		}
		// generate grid and powerups, if enabled
		generateTiles(.NEW_GAME)
		lastCol = WIDTH - 1
		powerups = [[PowerUp]](repeating: [PowerUp](repeating: .NO_POWERUP, count: HEIGHT), count: WIDTH)
		consecutive5s = 0
		if arcadeModeEnabled {
			for _ in 0..<15  {
				if arc4random_uniform(100) < 60 {
					let x = Int(arc4random_uniform(UInt32(WIDTH)))
					let y = Int(arc4random_uniform(UInt32(HEIGHT)))
					powerups[x][y] = PowerUp(rawValue: Int(arc4random_uniform(7)) + 1)!
				}
			}
		}
		points.removeAll()
		score = 0
		gameOver = false
		hasSelection = false
		self.window?.title = "Brickbreaker Score: 0 Selection: 0"
		needsDisplay = true
	}

	/**
	Save score to disk
	*/
	func saveScore() {
		let gameData: [String : Any] = [
			"Score" : score,
			"Timed regen" : timeRegen,
			"Clearings regen" : clearingsRegen,
			"Color change" : randomColorChange,
			"Arcade mode" : arcadeModeEnabled,
			"Time limit" : isTimed ? timeLimit : "None"
		]
		ScoreViewer.addScore(gameData)
	}
	
}
