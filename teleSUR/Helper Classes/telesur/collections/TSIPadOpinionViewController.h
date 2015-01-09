//
//  TSIPadOpinionViewController.h
//  teleSUR
//
//  Created by Simkin on 01/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBasicListViewController.h"
#import "RFQuiltLayout.h"

@interface TSIPadOpinionViewController : TSBasicListViewController <RFQuiltLayoutDelegate, UICollectionViewDelegate> {

    @protected
        NSMutableArray *secondSectionElements;
        NSMutableArray *rowSizes;
}

@property (nonatomic) UICollectionView *collectionView;

- (void) configureWithSection:(NSString *)section;

@end
