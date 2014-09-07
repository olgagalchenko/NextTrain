//
//  NTArrival.m
//  NextTrain
//
//  Created by Olga on 9/1/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "NTArrival.h"

@implementation NTArrival

- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self)
    {
        self.name = dict[@"stop_name"];
        self.trainNumber = [dict[@"train_number"] integerValue];
        
        NSDateFormatter* df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"HH':'mm':'ss"];
        NSString* arrivalTimeStr = dict[@"arrival_time"];
        if ([arrivalTimeStr hasPrefix:@"24"])
            arrivalTimeStr = [arrivalTimeStr stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@"00"];
        
        self.arrivalTime = [df dateFromString:arrivalTimeStr];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super init]))
    {
        //decode properties, other class vars
        self.name = [decoder decodeObjectForKey:@"name"];
        self.trainNumber = [[decoder decodeObjectForKey:@"train_number"] integerValue];
        self.arrivalTime = [decoder decodeObjectForKey:@"arrival_time"];
    }
    return self;
}

- (NSString*)arrivalTimeString
{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"hh:mm a"];
    
    return [df stringFromDate:self.arrivalTime];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:@(self.trainNumber) forKey:@"train_number"];
    [encoder encodeObject:self.arrivalTime forKey:@"arrival_time"];
}

- (NSComparisonResult)compare:(NTArrival*)obj
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.arrivalTime];
    NSInteger lhsHour = [components hour];
    
    components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:obj.arrivalTime];
    NSInteger rhsHour = [components hour];
    if (lhsHour < 3)
        lhsHour+=24;
    if (rhsHour < 3)
        rhsHour+=24;
    
    return [@(lhsHour) compare:@(rhsHour)];
}
@end
