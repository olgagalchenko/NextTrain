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
        self.arrivalTime = [df dateFromString:dict[@"arrival_time"]];
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
    [df setDateFormat:@"HH':'mm':'ss"];
    
    return [df stringFromDate:self.arrivalTime];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:@(self.trainNumber) forKey:@"train_number"];
    [encoder encodeObject:self.arrivalTime forKey:@"arrival_time"];
}


@end
