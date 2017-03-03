//
//  VSCViewController.m
//  vesc
//
//  Created by Rene Sijnke on 03/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import "VSCViewController.h"
#import "VSCUIHelper.h"

@interface VSCViewController ()

@end

@implementation VSCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    CAGradientLayer *gradient = [VSCUIHelper createGradientFromColorA:UIColorFromRGB(0x040736) andColorB:UIColorFromRGB(0x020420)];
    gradient.frame = self.view.bounds;
    [self.view.layer insertSublayer:gradient atIndex:0];
    
}

@end
