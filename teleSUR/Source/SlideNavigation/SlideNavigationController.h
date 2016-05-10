//
//  SlideNavigationController.h
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//
// https://github.com/aryaxt/iOS-Slide-Menu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@protocol SlideNavigationControllerDelegate <NSObject>
@optional
- (BOOL)slideNavigationControllerShouldDisplayRightMenu;
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu;
- (BOOL)slideNavigationControllerShouldDisplayTopMenu;
- (BOOL)slideNavigationControllerShouldDisplayBottomMenu;
@end

typedef  enum{
	MenuLeft = 1,
	MenuRight = 2,
    MenuTop = 3,
    MenuBottom = 4
}Menu;

@protocol SlideNavigationContorllerAnimator;
@interface SlideNavigationController : UINavigationController <UINavigationControllerDelegate> {

    @protected
        BOOL isCurrentGestureVertical;
        BOOL isCurrentGestureHorizontal;

}

extern NSString * const SlideNavigationControllerDidOpen;
extern NSString  *const SlideNavigationControllerDidClose;
extern NSString  *const SlideNavigationControllerDidReveal;

@property (nonatomic, assign) BOOL avoidSwitchingToSameClassViewController;
@property (nonatomic, assign) BOOL enableSwipeGesture;
@property (nonatomic, assign) BOOL enableShadow;
@property (nonatomic, assign) BOOL adPresented;
@property (nonatomic, assign) BOOL firstAdDismiss;
@property (nonatomic, assign) BOOL enableAutorotate;
@property (nonatomic, assign) int currentSection;

@property (nonatomic, strong) UIViewController *rightMenu;
@property (nonatomic, strong) UIViewController *leftMenu;
@property (nonatomic, strong) UIViewController *topMenu;
@property (nonatomic, strong) UIViewController *bottomMenu;
@property (nonatomic, strong) UIViewController *topView;

@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, assign) CGFloat portraitSlideXOffset;
@property (nonatomic, assign) CGFloat landscapeSlideXOffset;
@property (nonatomic, assign) CGFloat portraitSlideYOffset;
@property (nonatomic, assign) CGFloat landscapeSlideYOffset;
@property (nonatomic, assign) CGFloat panGestureSideOffset;
@property (nonatomic, assign) CGFloat menuRevealAnimationDuration;
@property (nonatomic, assign) UIViewAnimationOptions menuRevealAnimationOption;
@property (nonatomic, strong) id <SlideNavigationContorllerAnimator> menuRevealAnimator;

@property (nonatomic, strong) NSDate *currentDate;

- (void)setup;
+ (SlideNavigationController *)sharedInstance;
- (void)switchToViewController:(UIViewController *)viewController withCompletion:(void (^)())completion __deprecated;
- (void)popToRootAndSwitchToViewController:(UIViewController *)viewController withSlideOutAnimation:(BOOL)slideOutAnimation andCompletion:(void (^)())completion;
- (void)popToRootAndSwitchToViewController:(UIViewController *)viewController withCompletion:(void (^)())completion;
- (void)popAllAndSwitchToViewController:(UIViewController *)viewController withSlideOutAnimation:(BOOL)slideOutAnimation andCompletion:(void (^)())completion;
- (void)popAllAndSwitchToViewController:(UIViewController *)viewController withCompletion:(void (^)())completion;
- (void)bounceMenu:(Menu)menu withCompletion:(void (^)())completion;
- (void)openMenu:(Menu)menu withCompletion:(void (^)())completion;
- (void)closeMenuWithCompletion:(void (^)())completion;
- (void)toggleLeftMenu;
- (void)toggleRightMenu;
- (BOOL)isMenuOpen;

- (BOOL)shouldDisplayMenu:(Menu)menu forViewController:(UIViewController *)vc;

- (void) setRightMenuButtonAction:(UIButton *)button;
- (void)addTopViewController:(UIViewController *)viewController;
- (void) removeTopViewController;

@end
