//
//  VSCDataStore.h
//  vesc
//
//  Created by Rene Sijnke on 03/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface VSCDataStore : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (VSCDataStore *)sharedInstance;

-(void)setup;
-(void)saveContext;

@end
