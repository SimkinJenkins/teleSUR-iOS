//
//  AppDelegate.h
//  teleSUR
//
//  Created by Simkin on 7/15/14.
//  Copyright (c) 2014 TeleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "LeftMenuViewController.h"
#import "HiddenVideoPlayerController.h"
//#import <Pushwoosh/PushNotificationManager.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate/*, PushNotificationDelegate*/> {

    @protected
    UIViewController *lastViewController;
}

@property (strong, nonatomic) UIWindow *window;

@end