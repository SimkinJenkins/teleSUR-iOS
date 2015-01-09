//
//  AppDelegate.m
//  teleSUR
//
//  Created by Simkin on 7/15/14.
//  Copyright (c) 2014 TeleSUR. All rights reserved.
//

#import "AppDelegate.h"
//#import <Pushwoosh/PushNotificationManager.h>

#import "TSBasicListViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                 bundle: nil];

        LeftMenuViewController *leftMenu = (LeftMenuViewController*)[mainStoryboard
													   instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];

        HiddenVideoPlayerController *hiddenView = (HiddenVideoPlayerController *) [mainStoryboard instantiateViewControllerWithIdentifier:@"HiddenVideoPlayerController"];

        [SlideNavigationController sharedInstance].leftMenu = leftMenu;
        [SlideNavigationController sharedInstance].rightMenu = hiddenView;
    }
/*
    //lots of your initialization code
    
    //-----------PUSHWOOSH PART-----------
    // set custom delegate for push handling, in our case - view controller
    PushNotificationManager * pushManager = [PushNotificationManager pushManager];
    pushManager.delegate = self;

    // handling push on app start
    [[PushNotificationManager pushManager] handlePushReceived:launchOptions];
    
    // make sure we count app open in Pushwoosh stats
    [[PushNotificationManager pushManager] sendAppOpen];
    
    // register for push notifications!
    [[PushNotificationManager pushManager] registerForPushNotifications];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCurrentViewController) name:@"CurrentViewController" object:nil];
*/
    // Override point for customization after application launch.
    return YES;
}







/*


// system push notification registration success callback, delegate to pushManager
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

// system push notifications callback, delegate to pushManager
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
}

- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification {

    NSLog(@"Push notification received");
//    UINavigationController *navCtrl = (UINavigationController *)self.window.rootViewController;
//    TSBasicListViewController *currentViewController = (TSBasicListViewController *)[navCtrl presentedViewController];

//    [currentViewController showNews];

}

*/











- (void)handleCurrentViewController:(NSNotification *)notification {

    if([[notification userInfo] objectForKey:@"lastViewController"]) {
        lastViewController = [[notification userInfo] objectForKey:@"lastViewController"];
    }

}



- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    NSLog(@"last view controller is %@", [(UIViewController *)lastViewController class]);

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
