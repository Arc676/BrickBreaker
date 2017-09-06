//
//  GameView.m
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 4/16/15.
//  Copyright (c) 2015 Arc676. All rights reserved.
//  View Size: 440x540

#import "GameView.h"
#import "AppDelegate.h"
#import "Brickbreaker-Swift.h"

@implementation GameView

ColorIndex bricks[WIDTH][HEIGHT];
PowerUp powerups[WIDTH][HEIGHT];

- (void) initialize {
    self.points = [NSMutableArray array];
    self.popUpText = [NSMutableString string];
    self.hasSelection = NO;
    self.gameOver = YES;
    self.bomb = [NSImage imageNamed:@"bomb.png"];
    self.plus50 = [NSImage imageNamed:@"plus50.png"];
    self.plus200 = [NSImage imageNamed:@"plus200.png"];
    self.plus2k = [NSImage imageNamed:@"plus2k.png"];
    self.plus5k = [NSImage imageNamed:@"plus5k.png"];
    self.clearRow = [NSImage imageNamed:@"clearRow.png"];
    self.clearColumn = [NSImage imageNamed:@"clearColumn.png"];
}

- (BOOL) acceptsFirstResponder {
    return YES;
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    if (self.isImageBG) {
        [self.bgImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
    }else {
        [self.bgColor set];
        NSRectFill(rect);
    }
    for (int x = 0; x < WIDTH; x++) {
        for (int y = 0; y < HEIGHT; y++) {
            if (bricks[x][y] == N_A) {
                continue;
            }
            [(NSColor*)[self.colors objectAtIndex:(int)bricks[x][y]] set];
            if (self.shape == CIRCLE) {
                NSBezierPath *path = [NSBezierPath bezierPath];
                [path appendBezierPathWithOvalInRect:NSMakeRect(x * 20, y * 20, 20, 20)];
                [path fill];
            }else if (self.shape == SQUARE) {
                NSRectFill(NSMakeRect(x * 20, y * 20, 20, 20));
            }
            if (self.arcadeModeEnabled && powerups[x][y] != NO_POWERUP) {
                if (powerups[x][y] == BOMB) {
                    [self.bomb drawAtPoint:NSMakePoint(x * 20, y * 20) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
                }else if (powerups[x][y] == PLUS_50) {
                    [self.plus50 drawAtPoint:NSMakePoint(x * 20, y * 20) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
                }else if (powerups[x][y] == PLUS_200) {
                    [self.plus200 drawAtPoint:NSMakePoint(x * 20, y * 20) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
                }else if (powerups[x][y] == PLUS_2K) {
                    [self.plus2k drawAtPoint:NSMakePoint(x * 20, y * 20) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
                }else if (powerups[x][y] == PLUS_5K) {
                    [self.plus5k drawAtPoint:NSMakePoint(x * 20, y * 20) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
                }else if (powerups[x][y] == CLEAR_ROW) {
                    [self.clearRow drawAtPoint:NSMakePoint(x * 20, y * 20) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
                }else if (powerups[x][y] == CLEAR_COLUMN) {
                    [self.clearColumn drawAtPoint:NSMakePoint(x * 20, y * 20) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
                }
            }
        }
    }
    if (self.hasSelection) {
        for (int i = 0; i < [self.points count]; i++) {
            [[NSColor whiteColor] set];
            NSPoint origin = NSPointFromString([self.points objectAtIndex:i]);
            NSFrameRect(NSMakeRect(origin.x * 20, origin.y * 20, 20, 20));
        }
    }
    [[NSColor blackColor] set];
    NSDictionary *att = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:30], NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, nil];
    if (self.popUpTextPresent) {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:[self.popUpText substringFromIndex:1] attributes:att];
        NSRectFill(NSMakeRect(0, 540 - str.size.height, 440, str.size.height + 10));
        [str drawAtPoint:NSMakePoint(440/2 - str.size.width/2, 550 - str.size.height)];
    }
    if (self.gameOver) {
        NSRectFill(NSMakeRect(0, 250, 440, 50));
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Game Over" attributes:att];
        [str drawAtPoint:NSMakePoint(440/2 - str.size.width/2, 255)];
    }
}

- (void) mouseUp:(NSEvent *)theEvent {
    if (self.gameOver) {
        [self setNeedsDisplay:YES];
        return;
    }
    self.hasSelection = NO;
    [self.points removeAllObjects];
    int x = theEvent.locationInWindow.x / 20;
    int y = theEvent.locationInWindow.y / 20;
    if (bricks[x][y] == N_A) {
        [self setNeedsDisplay:YES];
        return;
    }
    [self findAdjacentToX:x Y:y color:bricks[x][y]];
    if ([self.points count] == 1) {
        [self.points removeAllObjects];
        [self.window setTitle:[NSString stringWithFormat:@"Brickbreaker Score:%lld Selection:0",self.score]];
    }else {
        self.hasSelection = YES;
        [self.window setTitle:[NSString stringWithFormat:@"Brickbreaker Score:%lld Selection:%lld",self.score,(unsigned long long int)powl([self.points count] - 1, 4)]];
    }
    [self setNeedsDisplay:YES];
}

- (void) keyDown:(NSEvent *)theEvent {
    if ([self.points count] == 0) {
        return;
    }
    if ([self.points count] > 5) {
        self.consecutive5s++;
    }else {
        self.consecutive5s = 0;
    }
    if (self.consecutive5s > 0 && self.consecutive5s % 5 == 0) {
        [self.popUpText appendFormat:@"\nCombo (%d)! +%d",self.consecutive5s,self.consecutive5s * 100];
        self.popUpTextPresent = YES;
        self.score += self.consecutive5s * 100;
        if (self.popUpTextTimer) {
            [self.popUpTextTimer invalidate];
            self.popUpTextTimer = nil;
        }
        self.popUpTextTimer = [NSTimer scheduledTimerWithTimeInterval:2.5
                                                               target:self
                                                             selector:@selector(hidePopUpText)
                                                             userInfo:nil
                                                              repeats:NO];
    }
    self.score += powl([self.points count] - 1, 4);
    int low = HEIGHT, high = -1, added = 0;
    for (NSString *str in self.points) {
        @autoreleasepool {
            NSPoint point = NSPointFromString(str);
            if (point.y < low) {
                low = point.y;
            }
            if (point.y > high) {
                high = point.y;
            }
            bricks[(int)point.x][(int)point.y] = N_A;
            if (self.arcadeModeEnabled) {
                if (powerups[(int)point.x][(int)point.y] == BOMB) {
                    int cleared = 0;
                    for (int x = point.x - 2; x < point.x + 2; x++) {
                        for (int y = point.y - 2; y < point.y + 2; y++) {
                            if (bricks[x][y] != N_A) {
                                bricks[x][y] = N_A;
                                cleared++;
                            }
                        }
                    }
                    self.score += powl(cleared, 4);
                    added += 4;
                }else if (powerups[(int)point.x][(int)point.y] == PLUS_50) {
                    self.score += 50;
                }else if (powerups[(int)point.x][(int)point.y] == PLUS_200) {
                    self.score += 200;
                }else if (powerups[(int)point.x][(int)point.y] == PLUS_2K) {
                    self.score += 2000;
                }else if (powerups[(int)point.x][(int)point.y] == PLUS_5K) {
                    self.score += 5000;
                }else if (powerups[(int)point.x][(int)point.y] == CLEAR_ROW) {
                    int cleared = 0;
                    for (int x = 0; x < WIDTH; x++) {
                        if (bricks[x][(int)point.y] != N_A) {
                            bricks[x][(int)point.y] = N_A;
                            cleared++;
                        }
                    }
                    self.score += powl(cleared, 4);
                    added++;
                }else if (powerups[(int)point.x][(int)point.y] == CLEAR_COLUMN) {
                    int cleared = 0;
                    for (int y = 0; y < HEIGHT; y++) {
                        if (bricks[(int)point.x][y] != N_A) {
                            bricks[(int)point.x][y] = N_A;
                            cleared++;
                        }
                    }
                    self.score += powl(cleared, 4);
                    added++;
                }
                powerups[(int)point.x][(int)point.y] = NO_POWERUP;
            }
        }
    }
    [self.points removeAllObjects];
    for (int i = 0; i <= (high + added - low); i++) {
        for (int x = 0; x < WIDTH; x++) {
            for (int y = 1; y < HEIGHT; y++) {
                if (bricks[x][y] == N_A) {
                    continue;
                }
                if (bricks[x][y - 1] == N_A) {
                    bricks[x][y - 1] = bricks[x][y];
                    bricks[x][y] = N_A;
                    if (self.arcadeModeEnabled && powerups[x][y] != NO_POWERUP) {
                        powerups[x][y - 1] = powerups[x][y];
                        powerups[x][y] = NO_POWERUP;
                    }
                }
            }
        }
    }
    if (arc4random_uniform(100) < 7) {
        [self.popUpText appendString:@"\nCritical! +500 pts"];
        self.popUpTextPresent = YES;
        self.score += 500;
        if (self.popUpTextTimer){
            [self.popUpTextTimer invalidate];
            self.popUpTextTimer = nil;
        }
        self.popUpTextTimer = [NSTimer scheduledTimerWithTimeInterval:2.5
                                                               target:self
                                                             selector:@selector(hidePopUpText)
                                                             userInfo:nil
                                                              repeats:NO];
    }
    [self.window setTitle:[NSString stringWithFormat:@"Brickbreaker Score:%lld Selection:0",self.score]];
    if (self.clearingsRegen) {
        self.clearings++;
        if (self.clearings >= self.clearingsLimit) {
            self.clearings = 0;
            [self generateTiles:REGEN_TILES];
        }
    }
    [self setNeedsDisplay:YES];
}

- (void) findAdjacentToX:(int)x Y:(int)y color:(ColorIndex)ci {
    [self.points addObject:[NSString stringWithFormat:@"%d %d",x,y]];
    if (y < HEIGHT - 1) {
        if (bricks[x][y + 1] == ci && ![self.points containsObject:[NSString stringWithFormat:@"%d %d",x,y + 1]]) {
            [self findAdjacentToX:x Y:y + 1 color:ci];
        }
    }
    if (y > 0) {
        if (bricks[x][y - 1] == ci  && ![self.points containsObject:[NSString stringWithFormat:@"%d %d",x,y - 1]]) {
            [self findAdjacentToX:x Y:y - 1 color:ci];
        }
    }
    if (x < WIDTH - 1) {
        if (bricks[x + 1][y] == ci  && ![self.points containsObject:[NSString stringWithFormat:@"%d %d",x + 1,y]]) {
            [self findAdjacentToX:x + 1 Y:y color:ci];
        }
    }
    if (x > 0) {
        if (bricks[x - 1][y] == ci  && ![self.points containsObject:[NSString stringWithFormat:@"%d %d",x - 1,y]]) {
            [self findAdjacentToX:x - 1 Y:y color:ci];
        }
    }
}

- (void) generateTiles:(GenerationMode)mode {
    for (int x = 0; x < WIDTH; x++) {
        for (int y = 0; y < HEIGHT; y++) {
            if (mode == NEW_GAME) {
                bricks[x][y] = arc4random_uniform(4);
            }
            if (mode == REGEN_TILES && bricks[x][y] == N_A) {
                bricks[x][y] = arc4random_uniform(4);
            }
            if (mode == SHUFFLE_TILES && bricks[x][y] != N_A) {
                bricks[x][y] = arc4random_uniform(4);
            }
        }
    }
    self.hasSelection = NO;
    [self.points removeAllObjects];
    [self setNeedsDisplay:YES];
}

- (void) addTiles {
    [self generateTiles:REGEN_TILES];
}

- (void) shuffleTiles {
    [self generateTiles:SHUFFLE_TILES];
}

- (void) endGame {
    self.gameOver = YES;
    [self setNeedsDisplay:YES];
}

- (void) hidePopUpText {
    self.popUpTextPresent = NO;
    [self.popUpText replaceCharactersInRange:NSMakeRange(0, [self.popUpText length] - 1) withString:@""];
    [self setNeedsDisplay:YES];
}

- (void) startGame {
    if (self.clearingsLimit <= 0) {
        self.clearingsLimit = defaultRegenClearings;
    }
    if (self.timeLimit <= 0) {
        self.timeLimit = defaultTimeLimit;
    }
    if (self.regenTime <= 0) {
        self.regenTime = defaultRegenTime;
    }
    if (self.randomColorChangeTime <= 0) {
        self.randomColorChangeTime = defaultColorChangeTime;
    }
    if (self.timeRegen) {
        self.regenTimer = [NSTimer scheduledTimerWithTimeInterval:self.regenTime
                                                      target:self
                                                    selector:@selector(addTiles)
                                                    userInfo:nil
                                                     repeats:YES];
    }else {
        if (self.regenTimer) {
            [self.regenTimer invalidate];
            self.regenTimer = nil;
        }
    }
    if (self.isTimed) {
        self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeLimit * 60
                                                          target:self
                                                        selector:@selector(endGame)
                                                        userInfo:nil
                                                         repeats:NO];
    }else {
        if (self.gameTimer) {
            [self.gameTimer invalidate];
            self.gameTimer = nil;
        }
    }
    if (self.randomColorChange) {
        self.colorChangeTimer = [NSTimer scheduledTimerWithTimeInterval:self.randomColorChangeTime
                                                                 target:self
                                                               selector:@selector(shuffleTiles)
                                                               userInfo:nil
                                                                repeats:YES];
    }else {
        if (self.colorChangeTimer) {
            [self.colorChangeTimer invalidate];
            self.colorChangeTimer = nil;
        }
    }
    [self generateTiles:NEW_GAME];
    memset(powerups,0,sizeof(powerups));
    self.consecutive5s = 0;
    if (self.arcadeModeEnabled) {
        @autoreleasepool {
            for (int i = 0; i < 15; i++) {
                if (arc4random_uniform(100) < 60) {
                    powerups[arc4random_uniform(WIDTH)][arc4random_uniform(HEIGHT)] = arc4random_uniform(7) + 1;
                }
            }
        }
    }
    [self.points removeAllObjects];
    self.score = 0;
    self.gameOver = NO;
    self.hasSelection = NO;
    [self.window setTitle:@"Brickbreaker Score:0 Selection:0"];
    [self setNeedsDisplay:YES];
}

@end