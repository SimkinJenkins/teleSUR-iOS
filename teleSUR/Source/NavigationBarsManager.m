//
//  NavigationDropDownMenuController.m
//  teleSUR
//
//  Created by Simkin on 18/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "NavigationBarsManager.h"

@implementation NavigationBarsManager

@synthesize topNavigationInstance, masterViewController, masterView, delegate, detailViewController, splitController, masterNavigationInstance, playerController, livestreamON, audioLivestreamON;

#pragma mark Singleton Methods

+ (NavigationBarsManager *)sharedInstance {
    static NavigationBarsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark Lifecycle Methods

- (id)init {
    if(self = [super init]) {}
    return self;
}

- (void)setMasterNavigationController:(UINavigationController *)navigationController {
    if(!self.masterNavigationInstance) {
        self.masterNavigationInstance = navigationController;
    }
}

- (void)setTopNavigationController:(UINavigationController *)navigationController {
    if(!self.topNavigationInstance) {
        self.topNavigationInstance = navigationController;
    }
}

- (void)setDetailViewController:(UIViewController *)viewController {
    if(!detailViewController) {
        detailViewController = viewController;
    }
}

- (void)setMasterViewController:(UIViewController *)viewController {
    if(!masterViewController) {
        masterViewController = viewController;
    }
}

- (void)setSplitViewController:(UISplitViewController *)viewController {
    if(!splitController) {
        splitController = viewController;
    }
}

- (void)setMasterView:(UIView *)view {
    if(!masterView) {
        masterView = view;
        if ([delegate respondsToSelector:@selector(navigationManagerViewSet:)]) {
            [delegate navigationManagerViewSet:view];
        }
    }
}

- (void)setCurrentPlayer:(TSIPadVideoDetailViewController *)playerVC {

    playerController = playerVC;

}

@end
