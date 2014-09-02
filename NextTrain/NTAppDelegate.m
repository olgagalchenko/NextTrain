//
//  NTAppDelegate.m
//  NextTrain
//
//  Created by Olga on 8/27/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "NTAppDelegate.h"

@interface NTAppDelegate ()
{
    NSStatusItem* statusItem;
    NSMenu* nextTrainMenu;
}
@end

@implementation NTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self activateStatusMenu];
}

- (void)activateStatusMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    
    statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    
    [statusItem setImage:[NSImage imageNamed:@"train"]];
    [statusItem setHighlightMode:YES];
    
    nextTrainMenu = [[NSMenu alloc] init];
    [nextTrainMenu addItemWithTitle:@"Next train is: " action:nil keyEquivalent:@""];
    
    [statusItem setMenu:nextTrainMenu];
}



@end
