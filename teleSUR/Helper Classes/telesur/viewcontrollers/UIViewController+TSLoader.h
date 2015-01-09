//
//  UIViewController+TSLoader.h
//  teleSUR
//
//  Created by Simkin on 19/11/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (TSLoader)

- (void) showLoaderWithAnimation:(BOOL)animation cancelUserInteraction:(BOOL)userInteraction withInitialView:(BOOL)initial;
- (void) hideLoaderWithAnimation:(BOOL)animation;

@end
