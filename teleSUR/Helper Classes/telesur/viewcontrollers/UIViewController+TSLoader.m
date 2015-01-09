//
//  UIViewController+TSLoader.m
//  teleSUR
//
//  Created by Simkin on 19/11/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "UIViewController+TSLoader.h"

@implementation UIViewController (TSLoader)

NSInteger const LOADING_VIEW_TAG = 1234;
CGFloat const LOADING_ANIMATION_TIME = 0.4;


- (void)showLoaderWithAnimation:(BOOL)animation cancelUserInteraction:(BOOL)userInteraction withInitialView:(BOOL)initial {
    
    if ( [self.view viewWithTag:LOADING_VIEW_TAG] ) {
        return;
    }
    
    self.view.hidden = NO;
    
    BOOL isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    BOOL isIphone5 = ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON );
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);

    if(isIpad) {

        BOOL isMultimediaAPP = [ [ [ [ [ NSBundle mainBundle ] infoDictionary ] valueForKey:@"Configuración" ] valueForKey:@"APPtype" ] isEqualToString:@"multimedia" ];

        screenBound.origin.y = (isMultimediaAPP ? 0 : -10) - (self.navigationController.navigationBarHidden ? 0 : self.navigationController.navigationBar.frame.size.height);
        
    }
    
    UIView *loader = [[UIView alloc] initWithFrame:screenBound];
    [loader setBackgroundColor:[UIColor clearColor]];
    
    if(initial) {

        NSString *imageID = isIpad ? (isLandscape ? @"Default-Landscape.png" : @"Default-Portrait.png") : (isIphone5 ? @"Default-568h.png" : @"Default.png");
        UIImage *image = [UIImage imageNamed:imageID];
        NSLog(@"%@", NSStringFromCGRect(screenBound));
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:screenBound];
        [imageView setImage:image];
        [loader addSubview:imageView];

    } else {
        
        loader.alpha = 0.0;
        
    }
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    CGFloat spinnerY = initial ? (isIpad ? (isLandscape ? 550 : 750) : (isIphone5 ? 410 : 380)) : (screenBound.size.height - 100) * .5;
    spinner.frame = CGRectMake((screenBound.size.width - 30) * .5, spinnerY, spinner.frame.size.width, spinner.frame.size.height);

    [loader addSubview:spinner];
    spinner.color = initial ? [UIColor whiteColor] : [UIColor redColor];
    [spinner startAnimating];
    
    [self.view addSubview:loader];

    loader.tag = LOADING_VIEW_TAG;
    
    if(userInteraction) {
        [self.view setUserInteractionEnabled:NO];
    }
    
    if (!animation) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:LOADING_ANIMATION_TIME];
        loader.alpha = 1;
        [UIView commitAnimations];
    } else {
        loader.alpha = 1;
    }
    
}

- (void)hideLoaderWithAnimation:(BOOL)animation {
    
    UIView *loader = [self.view viewWithTag:LOADING_VIEW_TAG];
    
    if (animation) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:LOADING_ANIMATION_TIME];
        [loader setAlpha:0];
        [loader removeFromSuperview];
        [UIView commitAnimations];
    } else {
        [loader removeFromSuperview];
    }
    
    [self.view setUserInteractionEnabled:YES];
}

@end
