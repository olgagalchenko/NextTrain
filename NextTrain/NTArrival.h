//
//  NTArrival.h
//  NextTrain
//
//  Created by Olga on 9/1/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTArrival : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSDate* arrivalTime;
@property (nonatomic, assign) NSInteger trainNumber;

- (id)initWithDictionary:(NSDictionary*)dict;
- (NSString*)arrivalTimeString;
- (NSComparisonResult)compare:(NTArrival*)obj;
@end
