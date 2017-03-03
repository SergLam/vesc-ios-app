//
//  VSCDataStore.m
//  vesc
//
//  Created by Rene Sijnke on 03/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import "VSCDataStore.h"

@implementation VSCDataStore

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static VSCDataStore *sharedInstance = nil;

+ (VSCDataStore *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] init];
        // observe the ParseOperation's save operation with its managed object context
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                 selector:@selector(mergeChanges:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
        
        
        
    });
    return sharedInstance;
}

-(void)setup {
    //Call managedobject again, so that if it's deleted (from failed migration), it will be re-initialized
    id _ = [VSCDataStore sharedInstance].managedObjectContext; //retry setting up context
    _ = nil;
    _ = [VSCDataStore sharedInstance].managedObjectContext; //retry setting up context
    _ = nil;
}

- (void)saveContext {
    //    NSLog(@"[UKDatastore] saveContext");
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            
            NSLog(@"error is %@",error);
            
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// this is called via observing "NSManagedObjectContextDidSaveNotification"
- (void)mergeChanges:(NSNotification *)notification {
    
    if (notification.object != self.managedObjectContext) {
        [self performSelectorOnMainThread:@selector(updateMainContext:) withObject:notification waitUntilDone:NO];
    }
}

- (void)updateMainContext:(NSNotification *)notification {
    
    assert([NSThread isMainThread]);
    
    __weak VSCDataStore *weakSelf = self;
    
    [self.managedObjectContext performBlockAndWait:^{
        [weakSelf.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }];
    
    //old way
    //    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [_managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        
        //#warning adding change observer
        //        [[NSNotificationCenter defaultCenter]
        //    addObserver:self
        //    selector:@selector(handleDataModelChange:)
        //    name:NSManagedObjectContextObjectsDidChangeNotification
        //    object:_managedObjectContext];
    }
    
    
    
    return _managedObjectContext;
}

/*
 - (void)handleDataModelChange:(NSNotification *)notification
 {
 if ([notification.object isEqual:self.managedObjectContext]) {
 NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
 NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
 NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
 NSLog(@"%%%%%%%%%% CONTEXT CHANGE");
 NSLog(@"updated objects %@",updatedObjects);
 NSLog(@"deleted objects %@",deletedObjects);
 NSLog(@"inserted objects  %@",insertedObjects);
 
 }
 }
 */

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
static int setupFailedCount = 0;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil && _persistentStoreCoordinator.persistentStores.count > 0 ) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Vesc.sqlite"];
    
    // handle db upgrade
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    
    NSError *error = nil;
    
    NSManagedObjectModel *moModel = [self managedObjectModel];
    if (moModel == nil) {
        NSLog(@"Managed object model could not be set up, still nil");
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:moModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        
        if (error!=nil) {
            NSLog(@"Persistent store could not be set up, exception %@", [error userInfo]);
        } else {
            NSLog(@"Persistent store could not be set up, error is nil, setupFailedCount is %i", setupFailedCount);
        }
        
        setupFailedCount++;
        
        if (setupFailedCount >= 2) {
            //Todo: Maybe show message to user to reinstall app? Highly unlikely (if ever?) that this happens.
            NSLog(@"[VSCDataStore] failed to setup NSPersistentStoreCoordinator, AFTER deleting the store. Hard crash");
            abort();
        } else {
            //Caught failure to set up psc, deleting local store.
            [[VSCDataStore sharedInstance] deleteStore];
        }
        NSLog(@"[VSCDataStore] PSC set up failed, error is %@, setupFailedCount is %i", [error userInfo], setupFailedCount);
        
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        //        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //        abort();
        
        
    } else {
        NSLog(@"[VSCDataStore] PSC set up properly");
    }
    
    return _persistentStoreCoordinator;
}

-(void)deleteStoreRemains {
    NSLog(@"----- [VSCDataStore delete coredata remains --- START----");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSLog(@"[VSCDataStore] document dir is %@", documentsPath);
    
    //        NSString *fileName = @"Bundle.sqlite-shm";
    NSArray *filePaths = @[@"Vesc.sqlite", @"Vesc.sqlite-shm", @"Vesc.sqlite-wal"];
    for (NSString *fileName in filePaths) {
        NSString *filePath = [documentsPath.path stringByAppendingPathComponent:fileName];
        NSLog(@"[VSCDataStore] filepath is %@", filePath);
        NSError *error;
        if (![fileManager removeItemAtPath:filePath error:&error]) {
            NSLog(@"[VSCDataStore] Couldn't delete file %@", error);
        }
        
    }
    
    NSLog(@"----- [VSCDataStore delete coredata remains ---- ENDED -----");
}

-(void)deleteStore {
    [self deleteStoreRemains];
    if (_persistentStoreCoordinator == nil || _persistentStoreCoordinator.persistentStores.count == 0) {
        _persistentStoreCoordinator = nil;
        _managedObjectContext = nil;
        _managedObjectModel = nil;
        return;
    }
    
    NSPersistentStore *store = [_persistentStoreCoordinator.persistentStores firstObject];
    NSError *error;
    NSURL *storeURL = store.URL;
    
    NSPersistentStoreCoordinator *storeCoordinator = _persistentStoreCoordinator;
    [storeCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
    _managedObjectModel = nil;
}

@end
