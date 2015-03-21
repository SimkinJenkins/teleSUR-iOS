//
//  TSConfigurationTableViewController.h
//  teleSUR
//
//  Created by Simkin on 20/02/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SlideNavigationController.h"

@interface TSConfigurationTableViewController : UITableViewController <SlideNavigationControllerDelegate> {

    @protected
        NSString *currentPushConfig;

}

@end