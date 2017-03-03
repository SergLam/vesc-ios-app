//
//  VSCUIHelper.h
//  vesc
//
//  Created by Rene Sijnke on 02/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface VSCUIHelper : NSObject

+(CAGradientLayer *)createGradientFromColorA:(UIColor *)colorA andColorB:(UIColor *)colorB;

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@end
