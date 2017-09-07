//
//  Enums.swift
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 09/12/2016.
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
