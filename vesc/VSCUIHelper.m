//
//  VSCUIHelper.m
//  vesc
//
//  Created by Rene Sijnke on 02/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import "VSCUIHelper.h"

@implementation VSCUIHelper

+(CAGradientLayer *)createGradientFromColorA:(UIColor *)colorA andColorB:(UIColor *)colorB {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)colorA.CGColor, (id)colorB.CGColor];
    gradient.startPoint = CGPointZero;
    gradient.endPoint = CGPointMake(1, 1);
    return gradient;
}

@end
