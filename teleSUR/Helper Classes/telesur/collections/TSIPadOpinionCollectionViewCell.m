//
//  TSIPadOpinionCollectionViewCell.m
//  teleSUR
//
//  Created by Simkin on 01/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSIPadOpinionCollectionViewCell.h"
#import "UILabelMarginSet.h"
#import "MWFeedItem.h"
#import "NSString+HTML.h"
#import "UIView+TSBasicCell.h"

@implementation TSIPadOpinionCollectionViewCell

- (CGSize)finalSize {

    UIView *containerView = [self viewWithTag:100];
    return CGSizeMake(1, ceil(containerView.frame.size.height/ 100));

}

- (void)awakeFromNib {

    [self initializeCell];

}

- (void) initializeCell {

    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:109];
    UILabelMarginSet *author = (UILabelMarginSet *)[self viewWithTag:110];
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:111];
    UILabelMarginSet *summary = (UILabelMarginSet *)[self viewWithTag:112];

    section.leftMargin = 5;
    section.topMargin = 2;
    section.font = [UIFont fontWithName:@"Roboto-Regular" size:8];

    author.frame = CGRectMake(section.frame.origin.x, 35, 220, 200);
    title.frame = CGRectMake(section.frame.origin.x, 5, 220, 200);
    summary.frame = CGRectMake(section.frame.origin.x, 5, 220, 300);

}

- (void) setData:(MWFeedItem *)data {

    // Elementos de celda
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:109];
    UILabelMarginSet *author = (UILabelMarginSet *)[self viewWithTag:110];
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:111];
    UILabelMarginSet *summary = (UILabelMarginSet *)[self viewWithTag:112];

    author.frame = CGRectMake(section.frame.origin.x, 35, 220, 200);
    title.frame = CGRectMake(section.frame.origin.x, 5, 220, 200);
    summary.frame = CGRectMake(section.frame.origin.x, 5, 220, 300);

    UIView *image = [self viewWithTag:113];

    UIView *containerView = [self viewWithTag:100];

    NSString *localizeID = [NSString stringWithFormat:@"%@Section", data.type];

    section.text = [[NSString stringWithFormat:NSLocalizedString(localizeID, nil)] uppercaseString];

    if ( [ data.type isEqualToString:@"op-entrevistas" ] ) {
        [section setPersistentBackgroundColor:[UIColor colorWithRed:237/255.0 green:7/255.0 blue:7/255.0 alpha:1.0]];
    } else {
        [section setPersistentBackgroundColor:[UIColor colorWithRed:10/255.0 green:40/255.0 blue:100/255.0 alpha:1.0]];
    }

    [self sizeToFitRedBackgroundLabel:section];

    [self setDataForRSSItem:data forTitle:title andSection:author];

    [self adjustSizeFrameForLabel:author constriainedToSize:CGSizeMake(220, 220)];

    [self setLabel:title underView:author withSeparation:4];

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(220, 220)];

    image.frame = CGRectMake(image.frame.origin.x, title.frame.origin.y + title.frame.size.height + 8, image.frame.size.width, image.frame.size.height);

    summary.text = data.summary;

    [self adjustSizeFrameForLabel:summary constriainedToSize:CGSizeMake(220, 300)];
    [self setLabel:summary underView:image withSeparation:10];

    if(summary.frame.origin.y + summary.frame.size.height + 10 > 489) {
        summary.frame = CGRectMake(summary.frame.origin.x, summary.frame.origin.y, summary.frame.size.width,
                                        (489 - summary.frame.origin.y));
    }

    containerView.frame = CGRectMake(0, 0, containerView.frame.size.width, summary.frame.origin.y + summary.frame.size.height + 10);
}

- (NSInteger) getTitleLabelTag {
    return 110;
}

- (NSInteger) getSectionLabelTag {
    return 109;
}




@end
