//
//  TSIpadVideoHomeViewController.h
//  teleSUR
//
//  Created by Simkin on 27/02/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import "RFQuiltLayout.h"
#import "TSBasicListViewController.h"

@interface TSIpadVideoHomeViewController : TSBasicListViewController <RFQuiltLayoutDelegate, UICollectionViewDelegate> {
    
@protected
    UIInterfaceOrientation currentOrientation;
}

@property (nonatomic) UICollectionView *collectionView;

- (id) initWithSection:(NSString *)section;

@end