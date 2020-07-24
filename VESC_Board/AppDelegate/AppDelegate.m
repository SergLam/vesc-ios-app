//
//  AppDelegate.m
//  vesc
//
//  Created by Rene Sijnke on 26/02/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import "AppDelegate.h"
#import "VSCBluetoothHelper.h"
#import "VSCUIHelper.h"
#import "TripsViewController.h"
#import "VSCDataStore.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self updateTabBarAppearance];
    
    [[VSCDataStore sharedInstance] setup];
    [VSCBluetoothHelper sharedInstance];
    
    TripsViewController *tripsVc = [[((UITabBarController *)self.window.rootViewController) viewControllers] objectAtIndex:1];
    tripsVc.managedObjectContext = self.managedObjectContext;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [VSCBluetoothHelper sharedInstance];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
}

-(void)updateTabBarAppearance {
    UITabBarController *tabController = (UITabBarController*)self.window.rootViewController;
    tabController.tabBar.barTintColor =  UIColorFromRGB(0xFBD250);
}


@end
