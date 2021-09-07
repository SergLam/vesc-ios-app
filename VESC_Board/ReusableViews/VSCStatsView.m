//
//  VSCStatsView.m
//  vesc
//
//  Created by Rene Sijnke on 01/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import "VSCStatsView.h"

@implementation VSCStatsView

-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

-(void)setup {
    
    self.backgroundColor = [UIColor clearColor];
    
    self.mainLabel = [[UILabel alloc] init];
    self.mainLabel.text = @"0.0";
    self.mainLabel.backgroundColor = [UIColor clearColor];
    self.mainLabel.textColor = [UIColor whiteColor];
    self.mainLabel.font = [UIFont fontWithName:@"Helvetica" size:36];
    self.mainLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.mainLabel];
    
    [self layoutSubviews];
}

-(void)setHasSubLabel:(BOOL)hasSubLabel {
    _hasSubLabel = hasSubLabel;
    
    if (self.subLabel == nil && hasSubLabel) {
        self.subLabel = [[UILabel alloc] init];
        self.subLabel.text = @"0.0";
        self.subLabel.backgroundColor = [UIColor clearColor];
        self.subLabel.textColor = [UIColor whiteColor];
        self.subLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
        self.subLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.subLabel];
    }
    
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.mainLabel.frame = CGRectMake(0, self.frame.size.height/2 - 15, self.frame.size.width, 30);
    
    if (self.subLabel != nil) {
        self.subLabel.frame = CGRectMake(0, self.mainLabel.frame.origin.y + self.mainLabel.frame.size.height, self.frame.size.width, 30);
    }
}

@end
