//
//  Enums.swift
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 09/12/2016.
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
