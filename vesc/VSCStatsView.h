//
//  VSCStatsView.h
//  vesc
//
//  Created by Rene Sijnke on 01/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSCStatsView : UIView

@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *subLabel;

@property (nonatomic) BOOL hasSubLabel;

@end
