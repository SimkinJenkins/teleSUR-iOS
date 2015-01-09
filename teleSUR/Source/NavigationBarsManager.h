//
//  NavigationDropDownMenuController.h
//  teleSUR
//
//  Created by Simkin on 18/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIDropDownMenu.h"

#import "TSIPadVideoDetailViewController.h"

@protocol NavigationBarsManagerDelegate <NSObject>

    - (void) navigationManagerViewSet:(UIView *)masterView;

@end

@interface NavigationBarsManager : NSObject {

    id <NavigationBarsManagerDelegate> delegate;

    UINavigationController *masterNavigationInstance;
    UINavigationController *topNavigationInstance;
    UIViewController *masterViewController;
    UIView *masterView;
    UIViewController *detailViewController;
    UISplitViewController *splitController;

}

@property (nonatomic, strong) UINavigationController *masterNavigationInstance;
@property (nonatomic, strong) UINavigationController *topNavigationInstance;
@property (nonatomic, strong) UIViewController *masterViewController;
@property (nonatomic, strong) UIViewController *detailViewController;
@property (nonatomic, strong) UISplitViewController *splitController;
@property (nonatomic, strong) UIView *masterView;

@property (nonatomic, strong) TSIPadVideoDetailViewController *playerController;

@property (nonatomic) BOOL livestreamON;
@property (nonatomic) BOOL audioLivestreamON;

@property (strong) id <NavigationBarsManagerDelegate> delegate;

+ (NavigationBarsManager *)sharedInstance;

- (void)setMasterNavigationController:(UINavigationController *)navigationController;
- (void)setTopNavigationController:(UINavigationController *)navigationController;

- (void)setDetailViewController:(UIViewController *)viewController;
- (void)setMasterViewController:(UIViewController *)viewController;
- (void)setSplitViewController:(UISplitViewController *)viewController;
- (void)setMasterView:(UIView *)view;

@end