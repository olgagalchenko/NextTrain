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

@property (nonatomic) NSString *departingStation;
@property (nonatomic) NSString *arrivingStation;
@property NSMenuItem *departingStationsMenu;
@property NSMenuItem *arrivingStationsMenu;

@end

@implementation NTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self activateStatusMenu];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"stationList"])
        [self setStationList];
    
    _departingStationsMenu = [self stationMenuItemWithTitle:@"Departing"];
    _arrivingStationsMenu = [self stationMenuItemWithTitle:@"Arriving"];
    
    _departingStation = @"Hillsdale";
    _arrivingStation = @"San Carlos";
    [self fetchRelevantArrivalsWithOrigin:_departingStation destination:_arrivingStation];
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
    [menu addItem:_departingStationsMenu];
    [menu addItem:_arrivingStationsMenu];
    
    NSArray* arrivalsAtHomeStation = [[NSUserDefaults standardUserDefaults] objectForKey:@"table"];
    for (NSData* arrivalData in arrivalsAtHomeStation)
    {
        NTArrival* arrival = [NSKeyedUnarchiver unarchiveObjectWithData:arrivalData];
        NSString* arrivalStr = [arrival arrivalTimeString];
        if (arrivalStr != nil)
            [menu addItemWithTitle:arrivalStr action:nil keyEquivalent:@""];
    }
    
}

- (NSMenuItem *)stationMenuItemWithTitle:(NSString *)title
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"stationList"])
        [self setStationList];
    NSArray *stations = [[NSUserDefaults standardUserDefaults] objectForKey:@"stationList"];
    NSMenuItem *menu = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
    NSMenu *stationMenu = [[NSMenu alloc] init];
    for (NSString *station in stations) {
        [stationMenu addItemWithTitle:station action:@selector(setStation:) keyEquivalent:@""];
    }
    [menu setSubmenu:stationMenu];
    return menu;
}

- (void)setStationList
{
    
    NSString* stationQuery = [NSString stringWithFormat:@"SELECT DISTINCT stop_name FROM new_trips"];
    NSArray *fetchedItems = [self fetchWithQuery:stationQuery];
    
    NSMutableArray *stationList = [NSMutableArray array];
    
    for (NSDictionary *dict in fetchedItems) {
        NSString *stationName = [[dict objectForKey:@"stop_name"] stringByReplacingOccurrencesOfString:@" Caltrain" withString:@""];
        [stationList addObject:stationName];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:stationList forKey:@"stationList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)fetchRelevantArrivalsWithOrigin:(NSString *)origin destination:(NSString *)destination
{
    NSString* endStationQuery = [NSString stringWithFormat:@"SELECT train_number FROM new_trips WHERE trip_name LIKE  \"%%12OCT%%Weekday%%\" AND stop_name = \"%@ Caltrain\"", destination];
    NSString* queryString = [NSString stringWithFormat:@"SELECT stop_name, train_number, arrival_time FROM new_trips WHERE trip_name LIKE  \"%%12OCT%%Weekday%%\" AND stop_name = \"%@ Caltrain\" AND train_number IN (%@) AND train_number%%2 = 0", origin, endStationQuery];
    
    NSArray *fetchedItems = [self fetchWithQuery:queryString];
    NSMutableArray* homeStationArrivals = [NSMutableArray array];
    
    for (NSDictionary *dict in fetchedItems) {
        NTArrival* arrival = [[NTArrival alloc] initWithDictionary:dict];
        NSData* encodedArrival = [NSKeyedArchiver archivedDataWithRootObject:arrival];
        [homeStationArrivals addObject:encodedArrival];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:homeStationArrivals forKey:@"table"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)fetchWithQuery:(NSString *)query
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
        return nil;
    }
    
    NSMutableArray* results = [NSMutableArray array];
    
    FMResultSet *resultSet = [db executeQuery:query];
    while ([resultSet next])
    {
        [results addObject:[resultSet resultDictionary]];
    }
    
    [db close];
    return results;
}

- (void)setStation:(id)sender
{
    NSMenuItem *clickedItem = (NSMenuItem *)sender;
    NSMenu *parentMenu = [clickedItem menu];
    NSString *parent = [[clickedItem parentItem] title];
    if ([parent isEqualToString:@"Arriving"]) {
        [[parentMenu itemWithTitle:_arrivingStation] setState:NSOffState];
        _arrivingStation = [clickedItem title];
    }
    else if ([parent isEqualToString:@"Departing"]) {
        [[parentMenu itemWithTitle:_departingStation] setState:NSOffState];
        _departingStation = [clickedItem title];
    }
    [clickedItem setState:NSOnState];
    [self fetchRelevantArrivalsWithOrigin:_departingStation destination:_arrivingStation];
}

- (IBAction)preferencedClicked:(id)sender
{
    preferencesWC = [[NTPreferencesWC alloc] initWithWindowNibName:@"NTPreferencesWC"];
    [preferencesWC showWindow:self];
}

@end
