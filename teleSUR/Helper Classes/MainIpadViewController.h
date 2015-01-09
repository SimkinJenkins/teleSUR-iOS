//
//  MainiPadViewController.h
//  teleSUR
//
//  Created by Simkin on 25/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDropDownMenu.h"
#import "TSBasicListViewController.h"
#import "RFQuiltLayout.h"
#import "MWFeedItem.h"

@protocol ClipSelectionDelegate <NSObject>

- (void) selectedClip:(NSDictionary *)clip;
- (void) selectedPost:(MWFeedItem *)post;

@end

@interface MainIpadViewController : TSBasicListViewController <UITextFieldDelegate, UIDropDownMenuDelegate, RFQuiltLayoutDelegate, UICollectionViewDelegate> {

    id <ClipSelectionDelegate> clipDelegate;

    BOOL isAnimating;
//    IBOutlet UISearchBar *searchBar;

}

@property (strong) id <ClipSelectionDelegate> clipDelegate;
@property (nonatomic) UICollectionView *collectionView;

//@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

- (void) configureWithSection:(NSString *)section;

@end