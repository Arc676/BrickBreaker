//
//  Enums.swift
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 09/12/2016.
//  Copyright © 2016 Arc676. All rights reserved.
//

import Foundation

enum ColorIndex: Int{
    case GREEN
    case RED
    case BLUE
    case YELLOW
    case N_A
}

enum PowerUp: Int{
    case NO_POWERUP
    case BOMB
    case PLUS_50
    case PLUS_200
    case PLUS_2K
    case PLUS_5K
    case CLEAR_ROW
    case CLEAR_COLUMN
}

enum TileShape: Int{
    case CIRCLE
    case SQUARE
}

enum GenerationMode: Int{
    case NEW_GAME
    case REGEN_TILES
    case SHUFFLE_TILES
}

let defaultRegenTime = 60
let defaultRegenClearings = 10
let defaultColorChangeTime = 60
let defaultTimeLimit = 10