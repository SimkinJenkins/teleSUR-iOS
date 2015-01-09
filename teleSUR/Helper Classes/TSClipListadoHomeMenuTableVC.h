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
        NSArray *newsSectionsSlugs;
        NSArray *newsSectionsTitles;

        UITextField *textfield;
        UIDropDownMenu *textMenu;

        CGRect beforeSearchSectionTableFrame;

}

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSDictionary *currentTopMenuConfig;

@property (nonatomic, retain) UIView *headerMenu;

- (void) configTopMenuWithCurrentConfiguration;
- (void) sectionSelected:(NSString *)section withTitle:(NSString *)title;

@end