//
//  Location+CoreDataProperties.h
//  vesc
//
//  Created by Rene Sijnke on 03/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSCTrip;

@interface VSCLocation : NSManagedObject

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nullable, nonatomic, copy) NSDate *timestamp;
@property (nullable, nonatomic, retain) VSCTrip *trip;

NS_ASSUME_NONNULL_BEGIN
+(VSCLocation *)newObject;
+(VSCLocation *)newObject:(NSManagedObjectContext *)context;
NS_ASSUME_NONNULL_END

@end
