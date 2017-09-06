//
//  GameView.h
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 4/16/15.
//  Copyright (c) 2015 Arc676. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AppDelegate;
#define WIDTH 22
#define HEIGHT 28

typedef enum ColorIndex{
    GREEN,
    RED,
    BLUE,
    YELLOW,
    N_A
}ColorIndex;

typedef enum PowerUp{
    NO_POWERUP,
    BOMB,
    PLUS_50,
    PLUS_200,
    PLUS_2K,
    PLUS_5K,
    CLEAR_ROW,
    CLEAR_COLUMN
}PowerUp;

typedef enum TileShape{
    CIRCLE,
    SQUARE
}TileShape;

typedef enum GenerationMode{
    NEW_GAME,
    REGEN_TILES,
    SHUFFLE_TILES
}GenerationMode;

@interface GameView : NSView

@property (retain) NSMutableArray *points;
@property (retain) NSTimer *regenTimer, *gameTimer, *colorChangeTimer, *popUpTextTimer;
@property (retain) NSArray *colors;
@property (retain) NSImage *bgImage, *bomb, *plus50, *plus200, *plus2k, *plus5k, *clearRow, *clearColumn;
@property (retain) NSColor *bgColor;
@property (retain) NSMutableString *popUpText;

@property (assign) BOOL hasSelection, gameOver, isTimed, isImageBG, arcadeModeEnabled, popUpTextPresent;
@property (assign) BOOL timeRegen, clearingsRegen, randomColorChange;
@property (assign) unsigned long long int score;
@property (assign) int clearings, clearingsLimit, regenTime, randomColorChangeTime, consecutive5s;
@property (assign) float timeLimit;
@property (assign) TileShape shape;

- (void) initialize;

- (void) addTiles;
- (void) shuffleTiles;
- (void) generateTiles:(GenerationMode)mode;
- (void) findAdjacentToX:(int)x Y:(int)y color:(ColorIndex)ci;

- (void) startGame;
- (void) endGame;

- (void) hidePopUpText;

@end