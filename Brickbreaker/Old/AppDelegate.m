//
//  AppDelegate.m
//  Brickbreaker
//
//  Created by Alessandro Vinciguerra on 4/16/15.
//  Copyright (c) 2015 Arc676. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.endlessModeEnabled = YES;
    [self.view initialize];
    [self.window setDelegate:self];
    [self.timeLimit setEnabled:NO];
    [self newGame:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {}

- (void) windowWillClose:(NSNotification *)notification {
    if ([self.quitOnClose floatValue]) {
        [[NSApplication sharedApplication] terminate:self];
    }
}

- (IBAction)newGame:(id)sender {
    //mode
    BOOL classic = YES;
    if ([self.enableTimeRegen floatValue]) {
        [self.view setTimeRegen:YES];
        [self.view setRegenTime:[self.time intValue]];
        classic = NO;
    }else {
        [self.view setTimeRegen:NO];
    }
    if ([self.enableClearingsRegen floatValue]) {
        [self.view setClearingsRegen:YES];
        [self.view setClearingsLimit:[self.clearings intValue]];
        classic = NO;
    }else { [self.view setClearingsRegen:NO]; }
    if ([self.enableRandomColorChange floatValue]) {
        [self.view setRandomColorChange:YES];
        [self.view setRandomColorChangeTime:[self.colorChangeTime intValue]];
    }else {
        [self.view setRandomColorChange:NO];
    }
    [self.view setArcadeModeEnabled:[self.enableArcadeMode floatValue]];
    if (!self.endlessModeEnabled && !classic) {
        [self.view setIsTimed:YES];
        [self.view setTimeLimit:[self.timeLimit floatValue]];
    }else {
        [self.view setIsTimed:NO];
    }
    //colors
    [self.view setColors:@[[self.tileColor1 color],[self.tileColor2 color],[self.tileColor3 color],[self.tileColor4 color]]];
    //tile shape
    [self.view setShape:(TileShape)[self.tileShapeSelection indexOfSelectedItem]];
    //bg
    [self.view setIsImageBG:([self.backgroundStyle selectedCell] == self.imageBGMode)];
    [self.view setBgColor:[self.bgColor color]];
    [self.view setBgImage:[self.bgImage image]];
    //start
    [self.window setIsVisible:YES];
    [self.view startGame];
}

- (IBAction)showHelp:(id)sender {
    [self.helpWindow setIsVisible:YES];
}

- (IBAction)toggleEndless:(id)sender {
    self.endlessModeEnabled = [sender floatValue];
    [self.timeLimit setEnabled:!self.endlessModeEnabled];
}

- (IBAction)showSettings:(id)sender {
    [self.settingsWindow setIsVisible:YES];
}

- (IBAction)chooseMusic:(id)sender {
    NSOpenPanel *panel = [[NSOpenPanel alloc] init];
    [panel setAllowedFileTypes:@[@"aiff",@"mp3",@"m4a",@"wav"]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        [self.pathToMusic setURL:[panel URL]];
        self.music = [[NSSound alloc] initWithContentsOfURL:[panel URL] byReference:YES];
        [self.music setLoops:[self.loopMusic floatValue]];
    }
}

- (IBAction)playMusic:(id)sender {
    if (self.music) {
        if (![self.music play]) {
            [self.music resume];
        }
    }
}

- (IBAction)pauseMusic:(id)sender {
    if (self.music) {
        [self.music pause];
    }
}

- (IBAction)restartMusic:(id)sender {
    if (self.music) {
        [self.music setCurrentTime:0];
        [self playMusic:nil];
    }
}

- (IBAction)changePathToFile:(id)sender {
    NSOpenPanel *panel = [[NSOpenPanel alloc] init];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"txt",@""]];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        [self.pathToFile setURL:[panel URL]];
    }
}

- (IBAction)saveScore:(id)sender {
    NSNumber *num;
    BOOL s = [[self.pathToFile URL] getResourceValue:&num forKey:NSURLIsDirectoryKey error:nil];
    if (s && [num boolValue]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No file"];
        [alert setInformativeText:@"Where to save high score?"];
        [alert addButtonWithTitle:@"Select file"];
        [alert addButtonWithTitle:@"Create new file"];
        [alert addButtonWithTitle:@"Cancel"];
        NSInteger clicked = [alert runModal];
        if (clicked == NSAlertFirstButtonReturn) {
            [self changePathToFile:nil];
        }else if (clicked == NSAlertSecondButtonReturn) {
            [self newFile:nil];
        }else if (clicked == NSAlertThirdButtonReturn) {
            return;
        }
        [self saveScore:nil];
        return;
    }
    BOOL classic = YES;
    NSMutableString *str = [NSMutableString stringWithContentsOfURL:[self.pathToFile URL] usedEncoding:nil error:nil];
    if (!str) {
        str = [NSMutableString string];
    }
    [str appendFormat:@"\n%lld",self.view.score];
    if (self.view.timeRegen) {
        [str appendString:@" (Timed regeneration)"];
        classic = NO;
    }
    if (self.view.clearingsRegen) {
        [str appendString:@" (Clearings regeneration)"];
        classic = NO;
    }
    if (self.view.randomColorChange) {
        [str appendString:@" (Random color change)"];
    }
    if (self.view.arcadeModeEnabled) {
        [str appendString:@" (Arcade mode)"];
    }
    if (self.view.isTimed) {
        [str appendFormat:@" (Timed game: %f minutes)",self.view.timeLimit];
    }else if (!classic) {
        [str appendString:@" (Endless mode)"];
    }
    [str writeToURL:[self.pathToFile URL] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (IBAction)newFile:(id)sender {
    NSSavePanel *panel = [[NSSavePanel alloc] init];
    [panel setAllowedFileTypes:@[@"txt",@""]];
    [panel setCanCreateDirectories:YES];
    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        [self.pathToFile setURL:[panel URL]];
    }
}

@end