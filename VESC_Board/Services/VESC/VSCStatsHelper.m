//
//  VSCStatsHelper.m
//  vesc
//
//  Created by Rene Sijnke on 26/02/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import "VSCStatsHelper.h"

static bool const isMetric = YES;
static float const metersInKM = 1000;
static float const metersInMile = 1609.344;

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

-(void)setAmpHours:(float)ampHours {
    _ampHours = ampHours;
    
    if (ampHours >= _maxAmpHours) {
        _maxAmpHours = ampHours;
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

+ (int) mphToKph: (int)mph {
    return 1.609344*(mph);
}

+ (float) FToC: (float *)F {
    return (*F-32)/1.8;
}

+ (float) CToF: (float *)C {
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

#pragma mark - Trip helpers

+ (NSString *)stringifyDistance:(float)meters {
    float unitDivider;
    NSString *unitName;
    
    // metric
    if (isMetric) {
        unitName = @"km";
        // to get from meters to kilometers divide by this
        unitDivider = metersInKM;
        // U.S.
    } else {
        unitName = @"mi";
        // to get from meters to miles divide by this
        unitDivider = metersInMile;
    }
    
    return [NSString stringWithFormat:@"%.2f %@", (meters / unitDivider), unitName];
}

+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat {
    int remainingSeconds = seconds;
    int hours = remainingSeconds / 3600;
    remainingSeconds = remainingSeconds - hours * 3600;
    int minutes = remainingSeconds / 60;
    remainingSeconds = remainingSeconds - minutes * 60;
    
    if (longFormat) {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%ihr %imin %isec", hours, minutes, remainingSeconds];
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%imin %isec", minutes, remainingSeconds];
        } else {
            return [NSString stringWithFormat:@"%isec", remainingSeconds];
        }
    } else {
        if (hours > 0) {
            return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, remainingSeconds];
        } else if (minutes > 0) {
            return [NSString stringWithFormat:@"%02i:%02i", minutes, remainingSeconds];
        } else {
            return [NSString stringWithFormat:@"00:%02i", remainingSeconds];
        }
    }
}

+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds {
    if (seconds == 0 || meters == 0) {
        return @"0";
    }
    
    float avgPaceSecMeters = seconds / meters;
    
    float unitMultiplier;
    NSString *unitName;
    
    // metric
    if (isMetric) {
        unitName = @"min/km";
        unitMultiplier = metersInKM;
        // U.S.
    } else {
        unitName = @"min/mi";
        unitMultiplier = metersInMile;
    }
    
    int paceMin = (int) ((avgPaceSecMeters * unitMultiplier) / 60);
    int paceSec = (int) (avgPaceSecMeters * unitMultiplier - (paceMin*60));
    
    return [NSString stringWithFormat:@"%i:%02i %@", paceMin, paceSec, unitName];
}

@end
