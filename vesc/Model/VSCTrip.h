//
//  Trip+CoreDataProperties.h
//  vesc
//
//  Created by Rene Sijnke on 03/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSCLocation;

@interface VSCTrip : NSManagedObject

@property (nonatomic) float distance;
@property (nonatomic) int16_t duration;
@property (nullable, nonatomic, copy) NSDate *timestamp;
@property (nullable, nonatomic, retain) NSOrderedSet<VSCLocation *> *locations;

NS_ASSUME_NONNULL_BEGIN
+(VSCTrip *)newObject;
+(VSCTrip *)newObject:(NSManagedObjectContext *)context;
NS_ASSUME_NONNULL_END

@end

