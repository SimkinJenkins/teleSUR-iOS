//
//  TSIPadHomeViewController.h
//  teleSUR
//
//  Created by Simkin on 23/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "RFQuiltLayout.h"
#import "TSBasicListViewController.h"
#import "EasyTableView.h"

#import "MarqueeLabel.h"

@interface TSIPadHomeViewController : TSBasicListViewController <RFQuiltLayoutDelegate, UICollectionViewDelegate, EasyTableViewDelegate> {

    @protected
        UIInterfaceOrientation currentOrientation;
        EasyTableView *header;

        NSArray *currentHeaderData;

        MarqueeLabel *breakingNewsMarquee;

}

@property (nonatomic) UICollectionView *collectionView;

@end