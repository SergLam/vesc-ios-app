//
//  TripDetailViewController.h
//  vesc
//
//  Created by Rene Sijnke on 03/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

@class VSCTrip;

#import <UIKit/UIKit.h>
#import "VSCTrip.h"
#import "VSCLocation.h"
#import "VSCViewController.h"

typedef NS_ENUM(NSInteger, VSCTripStatus) {
    VSCTripStatusWaiting,
    VSCTripStatusStopped,
    VSCTripStatusRunning,
    VSCTripStatusReview
};

@interface TripDetailViewController : VSCViewController

@property (nonatomic) VSCTripStatus status;
@property (strong, nonatomic) VSCTrip *trip;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
