//
//  Trip+CoreDataProperties.m
//  vesc
//
//  Created by Rene Sijnke on 03/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "VSCTrip.h"
#import "VSCDataStore.h"

@implementation VSCTrip

@dynamic distance;
@dynamic duration;
@dynamic timestamp;
@dynamic locations;
@dynamic amphours;

+(VSCTrip *)newObject {
    return [self newObject:[VSCDataStore sharedInstance].managedObjectContext];
}

+(VSCTrip *)newObject:(NSManagedObjectContext *)context {
    VSCTrip *trip = [NSEntityDescription insertNewObjectForEntityForName:@"Trip" inManagedObjectContext:context];
    //    photo.userId = [UKUser sharedInstance].userId;
    return trip;
}

@end
