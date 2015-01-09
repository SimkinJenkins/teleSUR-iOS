//
//  AcercaDeViewController.m
//  teleSUR
//
//  Created by Simkin on 16/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "AcercaDeViewController.h"

@implementation AcercaDeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}


@end
