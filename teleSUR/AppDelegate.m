//
//  AppDelegate.m
//  teleSUR
//
//  Created by Simkin on 7/15/14.
//  Copyright (c) 2014 TeleSUR. All rights reserved.
//

#import "AppDelegate.h"
#import <Pushwoosh/PushNotificationManager.h>

#import "TSConfigurationTableViewController.h"
#import "TSIpadNavigationViewController.h"
#import "TSBasicListViewController.h"
#import "TSClipListadoHomeMenuTableVC.h"

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

    if ( [[[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Configuración"] valueForKey:@"APPtype"] isEqualToString:@"multimedia"] ) {
        return YES;
    }

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }

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

    return YES;
}










// system push notification registration success callback, delegate to pushManager
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];

    BOOL *isRegister = [[NSUserDefaults standardUserDefaults] boolForKey:@"PUSHNotificationsIsRegister"];

    if (!isRegister) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PUSHNotificationsIsRegister"];
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
            TSConfigurationTableViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"TSConfigurationTableViewController"];
            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:YES andCompletion:nil];
            TSClipListadoHomeMenuTableVC *view = [self getVideoHomeView];
            if(view) {
                [view sectionSelected:@"config" withTitle:@"Configuración"];
            }
        } else {
            ((TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance).navigationBarHidden = NO;
            ((TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance).toolbarHidden = NO;
            [((TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance) launchSectionWithIndex:7 animated:YES];
        }
    }

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

    TSBasicListViewController *vc = UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ? (TSBasicListViewController *)[SlideNavigationController sharedInstance].topViewController : (TSBasicListViewController *)((TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance).topViewController;

    NSError *jsonError;
    NSData *objectData = [[pushNotification objectForKey:@"u"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];

    [vc loadNotificationRSSNewsWithURL:[json objectForKey:@"link"] andSection:[json objectForKey:@"section"]];

}



















- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

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









- (TSClipListadoHomeMenuTableVC *) getVideoHomeView {
    NSArray *views = [[SlideNavigationController sharedInstance] viewControllers];
    for(uint i = 0; i < [views count]; i++) {
        if([[views objectAtIndex:i] isKindOfClass:[TSClipListadoHomeMenuTableVC class]]) {
            return [views objectAtIndex:i];
        }
    }
    return nil;
}

@end
