//
//  GWTAppDelegate.m
//  Tize
//
//  Created by Joseph Pecoraro on 6/17/14.
//  Copyright (c) 2014 GrayWolfTechnologies. All rights reserved.
//

#import "GWTAppDelegate.h"
#import "GWTEvent.h"
#import "GWTLoginViewController.h"
#import "GWTBasePageViewController.h"
#import "GWTEventsViewController.h"
#import "GWTViewFactorySingleton.h"
#import <Parse/Parse.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation GWTAppDelegate {
    GWTBasePageViewController *baseViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GWTEvent registerSubclass];
    
    [Parse setApplicationId:@"YHvE8hQzcbqHfpDD29rO2hq0Xwn3fMOFm366KyGD"
                  clientKey:@"YxtmXQBBjrxHMeEEmOFNzdks7VcJ1Ct1HPXhLxpj"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [Fabric with:@[CrashlyticsKit]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([PFUser currentUser]) {
        self.window.rootViewController = [self setupMainView];
        [self registerForNotifications];
    }
    else {
        GWTLoginViewController *login = [[GWTLoginViewController alloc] init];
        self.window.rootViewController = login;
    }
    
    [self.window makeKeyAndVisible];    
    return YES;
}

-(UIViewController*)setupMainView {
    baseViewController = [[GWTBasePageViewController alloc] init];
    GWTEventsViewController *events = [[GWTViewFactorySingleton viewManager] eventsViewController];
    baseViewController.mainEventsView = events;
    baseViewController.currentViewController = events;
    return baseViewController;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [PFInstallation currentInstallation][@"badge"] = @(0);
    [[PFInstallation currentInstallation] saveEventually];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Tize Push

-(void)registerForNotifications {
    NSLog(@"Registering For Push");
    // Register for Push Notitications, if running iOS 8
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [[UIApplication sharedApplication]  registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication]  registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [[UIApplication sharedApplication]  registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                                UIRemoteNotificationTypeAlert |
                                                                                UIRemoteNotificationTypeSound)];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Push Accepted, save device token");
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation[@"userID"] = [[PFUser currentUser] objectId];
    currentInstallation[@"user"] = [PFUser currentUser];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Push Notification Recieved: %@", userInfo);
    //[PFPush handlePush:userInfo];
}

@end
