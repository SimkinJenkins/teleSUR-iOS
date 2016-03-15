//
//  TSClipListadoHomeMenuTableVC.h
//  teleSUR
//
//  Created by Simkin on 13/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSClipListadoTableViewController.h"
#import "Slidenavigationcontroller.h"
#import "UIDropDownMenu.h"

@interface TSClipListadoHomeMenuTableVC : TSClipListadoTableViewController <SlideNavigationControllerDelegate, UIDropDownMenuDelegate> {

    IBOutlet UISearchBar *searchBar;

    @protected
        NSArray *submenuNewsSectionsSlugs;
        NSArray *submenuVideoSectionsSlugs;
        NSArray *submenuNewsSectionsTitles;
        NSArray *submenuVideosSectionsTitles;

        UITextField *textfield;
        UIDropDownMenu *textMenu;

        CGRect beforeSearchSectionTableFrame;
        UIView *headerMenu;

}

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSDictionary *currentTopMenuConfig;

- (void) configTopMenuWithCurrentConfiguration;
- (void) sectionSelected:(NSString *)section withTitle:(NSString *)title;

@end