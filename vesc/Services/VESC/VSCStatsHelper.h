//
//  VSCStatsHelper.h
//  vesc
//
//  Created by Rene Sijnke on 26/02/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSCStatsHelper : NSObject

+ (VSCStatsHelper *) sharedInstance;

@property (nonatomic) float amps;
@property (nonatomic) float maxAmps;

@property (nonatomic) float ampHours;
@property (nonatomic) float maxAmpHours;

@property (nonatomic) float celcius;
@property (nonatomic) float maxCelcius;

@property (nonatomic) int speed;
@property (nonatomic) int maxSpeed;

+(int)calculateSpeed:(long)rpm;
+(int)calculateBatteryStatusWithVoltage:(float)voltage;

+(int)wheelDiameter;
+ (float) mmToFeet: (int)mm;

+(int)batteryCellsCount;

+ (NSString *)stringifyDistance:(float)meters;
+ (NSString *)stringifySecondCount:(int)seconds usingLongFormat:(BOOL)longFormat;
+ (NSString *)stringifyAvgPaceFromDist:(float)meters overTime:(int)seconds;

@end
