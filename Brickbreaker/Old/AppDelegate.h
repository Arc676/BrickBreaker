//
//  AppDelegate.h
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 4/16/15.
//  Copyright (c) 2015 Arc676. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GameView.h"

#define defaultRegenTime 60
#define defaultRegenClearings 10
#define defaultColorChangeTime 60

#define defaultTimeLimit 10

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

//windows
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet GameView *view;
@property (weak) IBOutlet NSPanel *helpWindow;
@property (weak) IBOutlet NSWindow *settingsWindow;

//game settings
//game modes and settings
//timed regen
@property (weak) IBOutlet NSButton *enableTimeRegen;
@property (weak) IBOutlet NSTextField *time;
//clearings regen
@property (weak) IBOutlet NSButton *enableClearingsRegen;
@property (weak) IBOutlet NSTextField *clearings;
//random color change
@property (weak) IBOutlet NSButton *enableRandomColorChange;
@property (weak) IBOutlet NSTextField *colorChangeTime;
//endlessness
@property (weak) IBOutlet NSTextField *timeLimit;
@property (assign) BOOL endlessModeEnabled;
//tile colors
@property (weak) IBOutlet NSColorWell *tileColor1;
@property (weak) IBOutlet NSColorWell *tileColor2;
@property (weak) IBOutlet NSColorWell *tileColor3;
@property (weak) IBOutlet NSColorWell *tileColor4;
//tile shape
@property (weak) IBOutlet NSPopUpButton *tileShapeSelection;
//arcade
@property (weak) IBOutlet NSButton *enableArcadeMode;
//background options
@property (weak) IBOutlet NSMatrix *backgroundStyle;
@property (weak) IBOutlet NSButtonCell *colorBGMode;
@property (weak) IBOutlet NSButtonCell *imageBGMode;
@property (weak) IBOutlet NSColorWell *bgColor;
@property (weak) IBOutlet NSImageView *bgImage;
//music settings
@property (weak) IBOutlet NSPathControl *pathToMusic;
@property (weak) IBOutlet NSButton *loopMusic;
@property (retain) NSSound *music;
//interface settings
@property (weak) IBOutlet NSButton *quitOnClose;
//high scores
@property (weak) IBOutlet NSPathControl *pathToFile;

//windows
- (IBAction)newGame:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)showSettings:(id)sender;
//settings
- (IBAction)toggleEndless:(id)sender;
//music
- (IBAction)chooseMusic:(id)sender;
- (IBAction)playMusic:(id)sender;
- (IBAction)pauseMusic:(id)sender;
- (IBAction)restartMusic:(id)sender;
//high scores
- (IBAction)changePathToFile:(id)sender;
- (IBAction)saveScore:(id)sender;
- (IBAction)newFile:(id)sender;

@end