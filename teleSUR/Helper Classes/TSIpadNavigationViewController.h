//
//  TSIpadNavigationViewController.h
//  teleSUR
//
//  Created by Simkin on 29/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDropDownMenu.h"
#import "NavigationBarsManager.h"

#import "TSClipPlayerViewController.h"

@interface TSIpadNavigationViewController : UINavigationController <UITextFieldDelegate, UIDropDownMenuDelegate, NavigationBarsManagerDelegate> {

    UIDropDownMenu *leftMenu;
    UIDropDownMenu *videoMenu;

    @protected
        NSArray *videoSections;
        NSArray *videoSectionsSlug;
        NSArray *sectionsTitle;
        NSArray *sectionsSlug;
        NSArray *newsSectionsSlugs;
        NSArray *newsSectionsTitles;

        UIView *livestreamLabelView;

        UIButton *videoButton;

        NSMutableDictionary *catalogs;

        UIViewController *currentVC;

        MPMoviePlaybackState lastPlaybackStatus;
}

@property (nonatomic, strong) TSClipPlayerViewController *playerController;

@property (nonatomic, strong) NSDictionary *currentTopMenuConfig;
@property (nonatomic, strong) NSString *section;

@property (nonatomic, retain) UITextField *headerTxf;
@property (nonatomic, retain) UIView *headerVw;

@property (nonatomic, retain) UITextField *menuTxf;
@property (nonatomic, retain) UIView *leftMenuVw;

@property (nonatomic, retain) UIView *livestreamMenu;

@property (nonatomic, strong) UIViewController *topView;

- (void)setNavigationTitle:(NSString *)title;

- (void)setCurrentSection:(NSString *)slug;

- (void) addTopViewController:(UIViewController *)viewController;
- (void) removeTopViewController;

- (void) launchSectionWithIndex:(NSInteger)index animated:(BOOL)animated;

- (void) setNavigationItemsHidden:(BOOL)hidden;

@end
