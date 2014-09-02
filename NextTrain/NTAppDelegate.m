//
//  NTAppDelegate.m
//  NextTrain
//
//  Created by Olga on 8/27/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "NTAppDelegate.h"
#import "FMDatabase.h"

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
    nextTrainMenu.delegate = self;
    [nextTrainMenu addItemWithTitle:@"Next train is: " action:nil keyEquivalent:@""];
    
    [statusItem setMenu:nextTrainMenu];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    FMDatabase *db = [FMDatabase databaseWithPath:@"train_schedule.db"];
    if (![db open])
    {
        NSLog(@"database didn't open");
    }

    
    [db close];
}

@end
