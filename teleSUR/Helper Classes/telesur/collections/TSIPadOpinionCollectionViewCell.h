//
//  TSIPadOpinionCollectionViewCell.h
//  teleSUR
//
//  Created by Simkin on 01/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedItem.h"

@interface TSIPadOpinionCollectionViewCell : UICollectionViewCell

- (CGSize)finalSize;

- (void) setData:(MWFeedItem *)data;

@end