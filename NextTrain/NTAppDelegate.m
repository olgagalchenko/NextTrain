//
//  NTAppDelegate.m
//  NextTrain
//
//  Created by Olga on 8/27/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "NTAppDelegate.h"
#import "FMDatabase.h"
#import "NTArrival.h"
#import "NTPreferencesWC.h"

@interface NTAppDelegate ()
{
    NSStatusItem* statusItem;
    NSMenu* nextTrainMenu;
    
    NTPreferencesWC* preferencesWC;
}
@end

@implementation NTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self activateStatusMenu];
    
    [self fetchRelevantArrivals];
    
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
    [menu removeAllItems];
    
    NSArray* arrivalsAtHomeStation = [[NSUserDefaults standardUserDefaults] objectForKey:@"table"];
    for (NSData* arrivalData in arrivalsAtHomeStation)
    {
        NTArrival* arrival = [NSKeyedUnarchiver unarchiveObjectWithData:arrivalData];
        NSString* arrivalStr = [arrival arrivalTimeString];
        if (arrivalStr != nil)
            [menu addItemWithTitle:arrivalStr action:nil keyEquivalent:@""];
    }
    
}

- (void)fetchRelevantArrivals
{
    NSString *documents_dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *db_path = [documents_dir stringByAppendingPathComponent:[NSString stringWithFormat:@"train_schedule.db"]];
    NSString *template_path = [[NSBundle mainBundle] pathForResource:@"train_schedule" ofType:@"db"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:db_path])
        [fm copyItemAtPath:template_path toPath:db_path error:nil];
    
    FMDatabase *db = [FMDatabase databaseWithPath:db_path];
    if (![db open])
    {
        NSLog(@"failed to open database");
        return;
    }
    
    NSMutableArray* homeStationArrivals = [NSMutableArray array];
    
    NSString* endStationQuery = [NSString stringWithFormat:@"SELECT train_number FROM new_trips WHERE trip_name LIKE  \"%%12OCT%%Weekday%%\" AND stop_name = \"San Carlos Caltrain\""];
    NSString* queryString = [NSString stringWithFormat:@"SELECT stop_name, train_number, arrival_time FROM new_trips WHERE trip_name LIKE  \"%%12OCT%%Weekday%%\" AND stop_name = \"Hillsdale Caltrain\" AND train_number IN (%@) AND train_number%%2 = 0", endStationQuery];
    FMResultSet *resultSet = [db executeQuery:queryString];
    while ([resultSet next])
    {
        NTArrival* arrival = [[NTArrival alloc] initWithDictionary:[resultSet resultDictionary]];
        NSData* encodedArrival = [NSKeyedArchiver archivedDataWithRootObject:arrival];
        [homeStationArrivals addObject:encodedArrival];
    }
    
    [db close];
    
    [[NSUserDefaults standardUserDefaults] setObject:homeStationArrivals forKey:@"table"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)preferencedClicked:(id)sender
{
    preferencesWC = [[NTPreferencesWC alloc] initWithWindowNibName:@"NTPreferencesWC"];
    [preferencesWC showWindow:self];
}

@end
