//
//  VSCStatsHelper.h
//  vesc
//
//  Created by Rene Sijnke on 26/02/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSCStatsHelper : NSObject

+(int)calculateSpeed:(long)rpm;
+(int)wheelDiameter;
+ (float) mmToFeet: (int)mm;

@end
