//
//  TSSplitViewController.m
//  teleSUR
//
//  Created by Simkin on 29/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSSplitViewController.h"
#import "NavigationBarsManager.h"

@implementation TSSplitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLayoutSubviews {

    const CGFloat kMasterViewWidth = 342;

    UIViewController *masterViewController = [self.viewControllers objectAtIndex:0];
    UIViewController *detailViewController = [self.viewControllers objectAtIndex:1];

    [[NavigationBarsManager sharedInstance] setMasterView:self.view];
    [[NavigationBarsManager sharedInstance] setDetailViewController:detailViewController];
    [[NavigationBarsManager sharedInstance] setSplitController:self];

    if (detailViewController.view.frame.origin.x > 0.0) {
        // Adjust the width of the master view
        CGRect masterViewFrame = masterViewController.view.frame;
        CGFloat deltaX = masterViewFrame.size.width - kMasterViewWidth;
        masterViewFrame.size.width -= deltaX;
        masterViewController.view.frame = masterViewFrame;
        masterViewController.view.backgroundColor = [UIColor colorWithRed:(226 / 255.0) green:(226 / 255.0) blue:(226 / 255.0) alpha:1];
        
        // Adjust the width of the detail view
        CGRect detailViewFrame = detailViewController.view.frame;
        detailViewFrame.origin.x -= deltaX;
        detailViewFrame.size.width += deltaX;
        detailViewController.view.frame = detailViewFrame;
        
        [masterViewController.view setNeedsLayout];
        [detailViewController.view setNeedsLayout];
    }
}

@end
