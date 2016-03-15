//
//  MenuViewController.h
//  teleSUR
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "CollapsableTableViewDelegate.h"

#import "TSUtils.h"

@interface LeftMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CollapsableTableViewDelegate> {

    @protected
        NSArray *videoSections;
        NSArray *videoSectionsSlug;
        NSArray *sectionsTitle;
        NSArray *sectionsSlug;
        BOOL *isLiveAudioON;
        UIButton *audioLiveButton;

}

@property (nonatomic, strong) IBOutlet CollapsableTableView *tableView;
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

@end