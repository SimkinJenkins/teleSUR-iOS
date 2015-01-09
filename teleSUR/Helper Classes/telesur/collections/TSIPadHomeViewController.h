//
//  TSIPadHomeViewController.h
//  teleSUR
//
//  Created by Simkin on 23/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFQuiltLayout.h"
#import "TSBasicListViewController.h"

@interface TSIPadHomeViewController : TSBasicListViewController <RFQuiltLayoutDelegate, UICollectionViewDelegate> {

    BOOL isAnimating;

    @protected
        UIInterfaceOrientation currentOrientation;
}

@property (nonatomic) UICollectionView *collectionView;

@end