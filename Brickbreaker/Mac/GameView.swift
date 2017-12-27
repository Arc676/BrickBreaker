//
//  GameView.swift
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 12/12/2016.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2016-7 Arc676/Alessandro Vinciguerra

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

        shape = .circle

        bomb = NSImage(named: NSImage.Name(rawValue: "bomb.png"))
        plus50 = NSImage(named: NSImage.Name(rawValue: "plus50.png"))
        plus200 = NSImage(named: NSImage.Name(rawValue: "plus200.png"))
        plus2k = NSImage(named: NSImage.Name(rawValue: "plus2k.png"))
        plus5k = NSImage(named: NSImage.Name(rawValue: "plus5k.png"))
        clearRow = NSImage(named: NSImage.Name(rawValue: "clearRow.png"))
        clearColumn = NSImage(named: NSImage.Name(rawValue: "clearColumn.png"))

        bricks = [[ColorIndex]](repeating: [ColorIndex](repeating: .n_A, count: HEIGHT), count: WIDTH)
        powerups = [[PowerUp]](repeating: [PowerUp](repeating: .no_POWERUP, count: HEIGHT), count: WIDTH)

        super.init(coder: coder)
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)
        if isImageBG {
            bgImage.draw(at: NSZeroPoint, from: NSZeroRect, operation: .sourceOver, fraction: 1)
        } else {
            bgColor.set()
            rect.fill()
        }

        for x in 0..<WIDTH {
            for y in 0..<HEIGHT {
                if bricks[x][y] == .n_A {
                    continue
                }
                colors[bricks[x][y].rawValue].set()

                let xcoord: CGFloat = CGFloat(x * 20)
                let ycoord: CGFloat = CGFloat(y * 20)
                if shape == .circle {
                    let path = NSBezierPath()
                    path.appendOval(in: NSMakeRect(xcoord, ycoord, 20, 20))
                    path.fill()
                } else {
                    NSMakeRect(xcoord, ycoord, 20, 20).fill()
                }

                if arcadeModeEnabled && powerups[x][y] != .no_POWERUP {
                    let point = NSMakePoint(xcoord, ycoord)
                    switch powerups[x][y] {
                    case .bomb:
                        bomb.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
                    case .plus_50:
                        plus50.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
                    case .plus_200:
                        plus200.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
                    case .plus_2K:
                        plus2k.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
                    case .plus_5K:
                        plus5k.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
                    case .clear_ROW:
                        clearRow.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
                    case .clear_COLUMN:
                        clearColumn.draw(at: point, from: NSZeroRect, operation: .sourceOver, fraction: 1)
                    default:
                        break
                    }
                }

                if hasSelection {
                    for point in points {
                        NSColor.white.set()
                        let origin = NSPointFromString(point)
                        NSMakeRect(origin.x * 20, origin.y * 20, 20, 20).frame()
                    }
                }

                NSColor.black.set()
                let att: [NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.font : NSFont(name: "Helvetica", size: 30)!,
                    NSAttributedStringKey.foregroundColor : NSColor.white
                ]

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
		selectBricks(theEvent.locationInWindow.x, theEvent.locationInWindow.y)
    }

	func selectBricks(_ x: CGFloat, _ y: CGFloat) {
		hasSelection = false
		points.removeAll()
		let x = Int(x / 20)
		let y = Int(y / 20)

		if x < 0 || x >= WIDTH || y < 0 || y >= HEIGHT || bricks[x][y] == .n_A {
			needsDisplay = true
			window?.title = "BrickBreaker Score: \(score) Selection: 0"
			return
		}

		findAdjacentTo(x, y, bricks[x][y])
		if points.count == 1 {
			points.removeAll()
			window?.title = "BrickBreaker Score: \(score) Selection: 0"
		} else {
			hasSelection = true
			window?.title = "BrickBreaker Score: \(score) Selection: \(pow(Float(points.count - 1), 4))"
		}

		needsDisplay = true
	}

	func clearBricks() {
		if points.count == 0 {
			return
		}

		if points.count > 5 {
			consecutive5s += 1
		} else {
			consecutive5s = 0
		}

		var shouldShowPopUp = false

		if consecutive5s > 0 && consecutive5s % 5 == 0 {
			popUpText += "\nCombo (\(consecutive5s))! +\(consecutive5s * 100)"
			score += UInt(consecutive5s * 100)
			shouldShowPopUp = true
		}

		score += UInt(pow(Double(points.count - 1), 4))

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

			bricks[xcoord][ycoord] = .n_A
			if arcadeModeEnabled {
				var cleared = 0
				switch powerups[xcoord][ycoord] {
				case .bomb:
					for x in (xcoord - 2)...(xcoord + 2) {
						if x < 0 || x >= WIDTH {
							continue
						}
						for y in (ycoord - 2)...(ycoord + 2) {
							if y < 0 || y >= HEIGHT {
								continue
							}
							if bricks[x][y] != .n_A {
								bricks[x][y] = .n_A
								cleared += 1
							}
						}
					}
					added += 4
					low = max(0, low - 2)
					left = max(0, left - 2)
					right = min(WIDTH - 1, right + 2)
				case .plus_50:
					score += 50
				case .plus_200:
					score += 200
				case .plus_2K:
					score += 2000
				case .plus_5K:
					score += 5000
				case .clear_ROW:
					for x in 0..<WIDTH {
						if bricks[x][ycoord] != .n_A {
							bricks[x][ycoord] = .n_A
							cleared += 1
						}
					}
					added += 1
					low = max(0, low - 1)
					left = 0
					right = WIDTH - 1
				case .clear_COLUMN:
					for y in 0..<HEIGHT {
						if bricks[xcoord][y] != .n_A {
							bricks[xcoord][y] = .n_A
							cleared += 1
						}
					}
					low = 0
				default:
					break
				}
				score += UInt(pow(Double(cleared), 4))
				powerups[xcoord][ycoord] = .no_POWERUP
			}
		}

		points.removeAll()
		for _ in 0...(high + added - low + 1) {
			for x in left...right {
				for y in max(1, low)..<HEIGHT {
					if bricks[x][y] == .n_A {
						continue
					}
					if bricks[x][y - 1] == .n_A {
						bricks[x][y - 1] = bricks[x][y]
						bricks[x][y] = .n_A
						if arcadeModeEnabled && powerups[x][y] != .no_POWERUP {
							powerups[x][y - 1] = powerups[x][y]
							powerups[x][y] = .no_POWERUP
						}
					}
				}
			}
		}

		if arc4random_uniform(100) < 7 {
			popUpText += "\nCritical! +500 pts"
			score += 500
			shouldShowPopUp = true
		}

		window?.title = "BrickBreaker Score: \(score) Selection: 0"

		if clearingsRegen {
			clearings += 1
			if clearings >= clearingsLimit {
				clearings = 0
				addTiles()
			}
		}

		if shouldShowPopUp {
			popUpTextPresent = true
			if (popUpTextTimer != nil) {
				popUpTextTimer.invalidate()
				popUpTextTimer = nil
			}
			popUpTextTimer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(GameView.hidePopUpText(_:)), userInfo: nil, repeats: false)
		}

		needsDisplay = true
	}

    override func keyUp(with theEvent: NSEvent) {
		clearBricks()
    }

    @objc func endGame() {
        gameOver = true
        needsDisplay = true
    }

    @objc func hidePopUpText(_ timer: Timer) {
        popUpTextPresent = false
        popUpText = ""
        needsDisplay = true
    }

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

	func generateTiles(_ mode: GenerationMode) {
		for x in 0..<WIDTH {
			for y in 0..<HEIGHT {
				let val = ColorIndex(rawValue: Int(arc4random_uniform(4)))!
				if (mode == .new_GAME) ||
					(mode == .regen_TILES && bricks[x][y] == .n_A) ||
					(mode == .shuffle_TILES && bricks[x][y] != .n_A) {
					bricks[x][y] = val
				}
			}
		}
		hasSelection = false
		points.removeAll()
		needsDisplay = true
	}

	@objc func addTiles() {
		generateTiles(.regen_TILES)
	}

	@objc func shuffleTiles() {
		generateTiles(.shuffle_TILES)
	}

	func startGame() {
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
		}

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
		if timeRegen {
			regenTimer = Timer.scheduledTimer(
				timeInterval: TimeInterval(regenTime),
				target: self,
				selector: #selector(addTiles),
				userInfo: nil,
				repeats: true)
		} else {
			if regenTimer != nil {
				regenTimer.invalidate()
				regenTimer = nil
			}
		}
		if isTimed {
			gameTimer = Timer.scheduledTimer(
				timeInterval: TimeInterval(self.timeLimit * 60),
				target: self,
				selector: #selector(endGame),
				userInfo: nil,
				repeats: false)
		} else {
			if gameTimer != nil {
				gameTimer.invalidate()
				gameTimer = nil
			}
		}

		if colorChangeTimer != nil {
			colorChangeTimer.invalidate()
			colorChangeTimer = nil
		}
		if randomColorChange {
			colorChangeTimer = Timer.scheduledTimer(
				timeInterval: TimeInterval(randomColorChangeTime),
				target: self,
				selector: #selector(shuffleTiles),
				userInfo: nil,
				repeats: true)
		}
		generateTiles(.new_GAME)
		powerups = [[PowerUp]](repeating: [PowerUp](repeating: .no_POWERUP, count: HEIGHT), count: WIDTH)
		consecutive5s = 0
		if arcadeModeEnabled {
				for _ in 0..<15  {
					if arc4random_uniform(100) < 60 {
						powerups[Int(arc4random_uniform(UInt32(WIDTH)))][Int(arc4random_uniform(UInt32(HEIGHT)))] =
							PowerUp(rawValue: Int(arc4random_uniform(7)) + 1)!
					}
				}
		}
		points.removeAll()
		score = 0
		gameOver = false
		hasSelection = false
//		[self.window setTitle:@"Brickbreaker Score:0 Selection:0"]
		needsDisplay = true
	}
	
}
