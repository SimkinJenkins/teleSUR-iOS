//
//  TSiPhoneNavigationController.h
//  teleSUR
//
//  Created by Simkin on 23/03/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SlideNavigationController.h"
#import "LeftMenuViewController.h"

#import "UIDropDownMenu.h"

@interface TSiPhoneNavigationController : SlideNavigationController {
    
    @protected
        UIView *headerMenu;
        UITextField *textfield;
        UIDropDownMenu *textMenu;

}

- (void) configureMenu;

@end