//
//  UITableViewCell+TSHighlightedViewCell.m
//  teleSUR
//
//  Created by Simkin on 07/03/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import "UIView+TSHighlightedViewCell.h"

@implementation UIView (TSHighlightedViewCell)

- (void) setupHighlightedViewCell {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:10002];
    title.leftMargin = 5;
    title.font = [UIFont fontWithName:@"Roboto-Black" size:20];
    section.leftMargin = 5;
    section.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:11];
    [section setPersistentBackgroundColor:[UIColor colorWithRed:255/255.0 green:2/255.0 blue:2/255.0 alpha:1.0]];
    [self bringSubviewToFront:title];
}

- (void) fitSizesHighlightedViewCell {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:10002];
    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(300, 300)];
    title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y, title.frame.size.width + 10, title.frame.size.height);
    [self sizeToFitRedBackgroundLabel:(UILabelMarginSet *)section];
    [self setLabel:title atBottomsView:self withSeparation:35];
    [self setLabel:section aboveView:title withSeparation:0];
}

- (void) setupVideoViewCell {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
    title.font = [UIFont fontWithName:@"Roboto-Bold" size:13];
    title.frame = CGRectMake(157, title.frame.origin.y, 155, 70);
    [self configRedBackgroundSectionTo:(UILabelMarginSet *)[self viewWithTag:10002]];
}

- (void) fitSizesVideoViewCell {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:10002];
    [self sizeToFitRedBackgroundLabel:section];
    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(155, 300)];
    [self setLabel:title underView:section withSeparation:2];
}

- (void) configRedBackgroundSectionTo:(UILabelMarginSet *)label {
    label.font = [UIFont fontWithName:@"Roboto-Black" size:8];
    label.leftMargin = 5;
    [label setPersistentBackgroundColor:[UIColor colorWithRed:255/255.0 green:2/255.0 blue:2/255.0 alpha:1.0]];
}

@end