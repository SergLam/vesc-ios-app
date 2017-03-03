//
//  Location+CoreDataProperties.m
//  vesc
//
//  Created by Rene Sijnke on 03/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "VSCLocation.h"
#import "VSCDataStore.h"

@implementation VSCLocation

@dynamic latitude;
@dynamic longitude;
@dynamic timestamp;
@dynamic trip;

+(VSCLocation *)newObject {
    return [self newObject:[VSCDataStore sharedInstance].managedObjectContext];
}

+(VSCLocation *)newObject:(NSManagedObjectContext *)context {
    VSCLocation *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
    //    photo.userId = [UKUser sharedInstance].userId;
    return location;
}

@end
