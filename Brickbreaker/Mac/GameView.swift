//
//  GameView.swift
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 12/12/2016.
//  Copyright © 2016 Arc676. All rights reserved.
//

import Cocoa

class GameView: NSView {

    let WIDTH = 22, HEIGHT = 28

    var points: [String]
    var regenTimer, gameTimer, colorChangeTimer, popUpTextTimer: NSTimer!
    var colors: [NSColor]
    var bgImage, bomb, plus50, plus200, plus2k, plus5k, clearRow, clearColumn: NSImage!
    var bgColor: NSColor!
    var popUpText: String

    var hasSelection, gameOver, isTimed, isImageBG, arcadeModeEnabled, popUpTextPresent: Bool
    var timeRegen, clearingsRegen, randomColorChange: Bool
    var score: UInt
    var clearings, clearingsLimit, regenTime, randomColorChangeTime, consecutive5s: Int
    var timeLimit: Float
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
        colors = []

        popUpText = ""

        shape = .CIRCLE

        bomb = NSImage(named: "bomb.png")
        plus50 = NSImage(named: "plus50.png")
        plus200 = NSImage(named: "plus200.png")
        plus2k = NSImage(named: "plus2k.png")
        plus5k = NSImage(named: "plus5k.png")
        clearRow = NSImage(named: "clearRow.png")
        clearColumn = NSImage(named: "clearColumn.png")

        bricks = [[ColorIndex]](count: WIDTH, repeatedValue: [ColorIndex](count: HEIGHT, repeatedValue: .N_A))
        powerups = [[PowerUp]](count: WIDTH, repeatedValue: [PowerUp](count: HEIGHT, repeatedValue: .NO_POWERUP))

        super.init(coder: coder)
    }

    override func drawRect(rect: NSRect) {
        super.drawRect(rect)
        if isImageBG {
            bgImage.drawAtPoint(NSZeroPoint, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1)
        } else {
            bgColor.set()
            NSRectFill(rect)
        }

        for x in 0...WIDTH {
            for y in 0...HEIGHT {
                if bricks[x][y] == .N_A {
                    continue
                }
                colors[bricks[x][y].rawValue].set()

                let xcoord: CGFloat = CGFloat(x * 20)
                let ycoord: CGFloat = CGFloat(y * 20)
                if shape == .CIRCLE {
                    let path = NSBezierPath()
                    path.appendBezierPathWithOvalInRect(NSMakeRect(xcoord, ycoord, 20, 20))
                    path.fill()
                } else {
                    NSRectFill(NSMakeRect(xcoord, ycoord, 20, 20))
                }

                if arcadeModeEnabled && powerups[x][y] != .NO_POWERUP {
                    let point = NSMakePoint(xcoord, ycoord)
                    switch powerups[x][y] {
                    case .BOMB:
                        bomb.drawAtPoint(point, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1)
                    case .PLUS_50:
                        plus50.drawAtPoint(point, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1)
                    case .PLUS_200:
                        plus200.drawAtPoint(point, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1)
                    case .PLUS_2K:
                        plus2k.drawAtPoint(point, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1)
                    case .PLUS_5K:
                        plus5k.drawAtPoint(point, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1)
                    case .CLEAR_ROW:
                        clearRow.drawAtPoint(point, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1)
                    case .CLEAR_COLUMN:
                        clearColumn.drawAtPoint(point, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1)
                    default:
                        break
                    }
                }

                if hasSelection {
                    for point in points {
                        NSColor.whiteColor().set()
                        let origin = NSPointFromString(point)
                        NSFrameRect(NSMakeRect(origin.x * 20, origin.y * 20, 20, 20))
                    }
                }

                NSColor.blackColor().set()
                let att: [String:AnyObject] = [
                    NSFontAttributeName : NSFont(name: "Helvetica", size: 30)!,
                    NSForegroundColorAttributeName : NSColor.whiteColor()
                ]

                if popUpTextPresent {
                    let str = NSAttributedString(string: popUpText.substringFromIndex(popUpText.startIndex.advancedBy(1)), attributes: att)
                    NSRectFill(NSMakeRect(0, 540 - str.size().height, 440, str.size().height + 10))
                    str.drawAtPoint(NSMakePoint(440/2 - str.size().width/2, 550 - str.size().height))
                }

                if gameOver {
                    NSRectFill(NSMakeRect(0, 250, 440, 50))
                    let str = NSAttributedString(string: "Game Over", attributes: att)
                    str.drawAtPoint(NSMakePoint(440/2 - str.size().width/2, 255))
                }
            }
        }
    }

    override func mouseUp(theEvent: NSEvent) {
        if gameOver {
            needsDisplay = true
            return
        }

        hasSelection = false;
        points.removeAll()
        let x = Int(theEvent.locationInWindow.x / 20)
        let y = Int(theEvent.locationInWindow.y / 20)

        if bricks[x][y] == .N_A {
            needsDisplay = true
            return
        }

        //findadjacentto
        if points.count == 1 {
            points.removeAll()
            window?.title = "BrickBreaker Score: \(score) Selection: 0"
        } else {
            hasSelection = true
            window?.title = "BrickBreaker Score: \(score) Selection: \(pow(Float(points.count - 1), 1)))"
        }

        needsDisplay = true
    }

    override func keyDown(theEvent: NSEvent) {
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

            bricks[xcoord][ycoord] = .N_A
            if arcadeModeEnabled {
                switch powerups[xcoord][ycoord] {
                case .BOMB:
                    var cleared = 0
                    for x in (xcoord - 2)...(xcoord + 2) {
                        for y in (ycoord - 2)...(ycoord + 2) {
                            if bricks[x][y] != .N_A {
                                bricks[x][y] = .N_A
                                cleared += 1
                            }
                        }
                    }
                    score += UInt(pow(Double(cleared), 4))
                    added += 4
                    low = max(0, low - 2)
                case .PLUS_50:
                    score += 50
                case .PLUS_200:
                    score += 200
                case .PLUS_2K:
                    score += 2000
                case .PLUS_5K:
                    score += 5000
                case .CLEAR_ROW:
                    var cleared = 0
                    for x in 0...WIDTH {
                        if bricks[x][ycoord] != .N_A {
                            bricks[x][ycoord] = .N_A
                            cleared += 1
                        }
                    }
                    score += UInt(pow(Double(cleared), 4))
                    added += 1
                    low = max(0, low - 1)
                case .CLEAR_COLUMN:
                    var cleared = 0
                    for y in 0...HEIGHT {
                        if bricks[xcoord][y] != .N_A {
                            bricks[xcoord][y] = .N_A
                            cleared += 1
                        }
                    }
                    score += UInt(pow(Double(cleared), 4))
                    low = 0
                default:
                    break
                }
                powerups[xcoord][ycoord] = .NO_POWERUP
            }
        }

        points.removeAll()
        for _ in 0...(high + added - low + 1) {
            for x in left...right {
                for y in max(0, low)...HEIGHT {
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
                //generate tiles
            }
        }

        if shouldShowPopUp {
            popUpTextPresent = true
            if (popUpTextTimer != nil) {
                popUpTextTimer.invalidate()
                popUpTextTimer = nil
            }
            popUpTextTimer = NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: #selector(GameView.hidePopUpText(_:)), userInfo: nil, repeats: false)
        }

        needsDisplay = true
    }

    func endGame() {
        gameOver = true
        needsDisplay = true
    }

    func hidePopUpText(timer: NSTimer) {
        popUpTextPresent = false
        popUpText = ""
        needsDisplay = true
    }
    
}