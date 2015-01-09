//
//  TSIPadBlogHomeCollectionViewCell.m
//  teleSUR
//
//  Created by Simkin on 01/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSIPadBlogHomeCollectionViewCell.h"
#import "UILabelMarginSet.h"
#import "MWFeedItem.h"
#import "NSString+HTML.h"

@implementation TSIPadBlogHomeCollectionViewCell

- (CGSize)finalSize {

    UILabelMarginSet *summary = (UILabelMarginSet *)[self viewWithTag:112];
    return CGSizeMake(1, ceil((summary.frame.origin.y + summary.frame.size.height + 10) / 100));

}

- (void)awakeFromNib {

    [self initializeCell];

}

- (void) initializeCell {

    UILabelMarginSet *author = (UILabelMarginSet *)[self viewWithTag:110];
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:111];
    UILabelMarginSet *summary = (UILabelMarginSet *)[self viewWithTag:112];
    
    author.frame = CGRectMake(author.frame.origin.x, 15, 220, 200);
    title.frame = CGRectMake(author.frame.origin.x, 5, 220, 200);
    summary.frame = CGRectMake(author.frame.origin.x, 5, 220, 200);

}

- (void) setData:(MWFeedItem *)data {

    // Elementos de celda
    UILabelMarginSet *author = (UILabelMarginSet *)[self viewWithTag:110];
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:111];
    UILabelMarginSet *summary = (UILabelMarginSet *)[self viewWithTag:112];
    UIView *containerView = [self viewWithTag:100];

    [self setDataForRSSItem:data forTitle:title andSection:author];
    summary.text = data.summary;

    [self adjustSizeFrameForLabel:author constriainedToSize:CGSizeMake(220, 220)];
    [self setLabel:title underView:author withSeparation:7];

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(220, 220)];
    [self setLabel:summary underView:title withSeparation:10];

    [self adjustSizeFrameForLabel:summary constriainedToSize:CGSizeMake(220, 480)];

    if(summary.frame.origin.y + summary.frame.size.height + 10 > 489) {
        summary.frame = CGRectMake(summary.frame.origin.x, summary.frame.origin.y, summary.frame.size.width, (489 - summary.frame.origin.y));
    }

    containerView.frame = CGRectMake(0, 0, containerView.frame.size.width, ceil((summary.frame.origin.y + summary.frame.size.height + 10) / 100) * 100);
}

- (NSInteger) getTitleLabelTag {
    return 110;
}

- (NSInteger) getSectionLabelTag {
    return 111;
}

@end
