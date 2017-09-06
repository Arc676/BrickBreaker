//
//  Enums.swift
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 09/12/2016.
//  Copyright © 2016 Arc676. All rights reserved.
//

import Foundation

enum ColorIndex: Int{
    case green
    case red
    case blue
    case yellow
    case n_A
}

enum PowerUp: Int{
    case no_POWERUP
    case bomb
    case plus_50
    case plus_200
    case plus_2K
    case plus_5K
    case clear_ROW
    case clear_COLUMN
}

enum TileShape: Int{
    case circle
    case square
}

enum GenerationMode: Int{
    case new_GAME
    case regen_TILES
    case shuffle_TILES
}

let defaultRegenTime = 60
let defaultRegenClearings = 10
let defaultColorChangeTime = 60
let defaultTimeLimit = 10
