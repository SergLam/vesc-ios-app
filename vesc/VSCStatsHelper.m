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


+ (VSCStatsHelper *) sharedInstance {
    static VSCStatsHelper *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
        
    });
    
    return sharedInstance;
}

#pragma mark - Properties

-(void)setAmps:(float)amps {
    _amps = amps;
    
    if (amps >= _maxAmps) {
        _maxAmps = amps;
    }
}

-(void)setCelcius:(float)celcius {
    _celcius = celcius;
    
    if (celcius >= _maxCelcius) {
        _maxCelcius = celcius;
    }
}

-(void)setSpeed:(int)speed {
    _speed = speed;
    
    if (speed >= _maxSpeed) {
        _maxSpeed = speed;
    }
}

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

+(int)calculateBatteryStatusWithVoltage:(float)voltage {
    
    float maxBatteryVoltage = [VSCStatsHelper batteryCellsCount] * 4.2;
    float minBatteryVoltage = [VSCStatsHelper batteryCellsCount] * 3.3;
    float batteryVoltageRange = maxBatteryVoltage - minBatteryVoltage;
  
    return ((voltage - minBatteryVoltage)/batteryVoltageRange)*100;
}

#pragma mark - Input

+(int)wheelDiameter {
    return 80;
}

+(int)batteryMah {
    return 7500 * 0.8;
}

+(int)batteryCellsCount {
    return 10;
}

@end
