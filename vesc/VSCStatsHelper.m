//
//  VSCStatsHelper.m
//  vesc
//
//  Created by Rene Sijnke on 26/02/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import "VSCStatsHelper.h"

@interface VSCStatsHelper();
@property (nonatomic) int wheelDiameter;
@end

@implementation VSCStatsHelper


#pragma mark - Convert Functions

+ (float) mmToFeet: (int )mm {
    return 0.00328084*(mm);
}

- (int) mphToKph: (int)mph {
    return 1.609344*(mph);
}

- (float) FToC: (float *)F {
    return (*F-32)/1.8;
}

- (float) CToF: (float *)C {
    return (*C*1.8)+32;
}

#pragma mark - Calculation Functions

+ (int) calculateSpeed:(long)rpm {
    int curRpm = (int)rpm/7;
    float diameter = [VSCStatsHelper mmToFeet: [VSCStatsHelper wheelDiameter]];
    return (diameter*3.14*curRpm*60)/5280;
}

#pragma mark - Input

+(int)wheelDiameter {
    return 80;
}

@end
