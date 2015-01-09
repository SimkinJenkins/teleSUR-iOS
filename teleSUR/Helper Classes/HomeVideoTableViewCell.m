//
//  HomeVideoTableViewCell.m
//  teleSUR
//
//  Created by Simkin on 28/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "HomeVideoTableViewCell.h"
#import "UILabelMarginSet.h"

@implementation HomeVideoTableViewCell

- (void)awakeFromNib {

    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:1];

    title.font = [UIFont fontWithName:@"Roboto-Bold" size:13];

    [self configRedBackgroundSectionLabel];

}

- (void) setLabelSizeToFit {

    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:[self getTitleLabelTag]];
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:[self getSectionLabelTag]];

    [self sizeToFitRedBackgroundLabel:section];

    [self alignLabel:title atTopsView:section withSeparation:16];

}

@end
