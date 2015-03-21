//
//  TSVideoCollectionViewCell.m
//  teleSUR
//
//  Created by Simkin on 27/02/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import "TSVideoCollectionViewCell.h"

@implementation TSVideoCollectionViewCell

- (void) initializeElements {

    [super initializeElements];

    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag: [self getTitleLabelTag]];
    UILabel *summaryLabel = ((UILabelMarginSet *)[self viewWithTag:102]);
    title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y, 100, 80);
    title.font = [UIFont fontWithDescriptor:title.font.fontDescriptor size:30];
    summaryLabel.hidden = YES;

}

- (void) fitSizesForVideoItemTitle:(UILabel *)title andSection:(UILabel *)section {

    UIView *containerView = [self viewWithTag:100];

    [self alignLabel:section atTopsView:containerView withSeparation:-1];

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(700, 80)];
    [self setLabel:title atBottomsView:containerView withSeparation:12];

    UIView *image = [self viewWithTag:101];
    CGFloat imageH = self.frame.size.height - (section.frame.origin.y + section.frame.size.height + 1);
    image.frame = CGRectMake(0, self.frame.size.height - imageH, self.frame.size.width, imageH);

    videoIconRect = CGRectMake(330, image.frame.origin.y + (image.frame.size.height * .5) - 45, 80, 75);
    [self setVideoIcon];

}

- (void) setDataForInfographItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section {
    
    section.hidden = YES;
    
    title.font = [UIFont fontWithDescriptor:title.font.fontDescriptor size:30];
    title.text = [data valueForKey:@"titulo"];
    
}

- (void) fitSizesForInfographItemTitle:(UILabel *)title andSection:(UILabel *)section {
    
    UIView *containerView = [self viewWithTag:100];
    
    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(containerView.frame.size.width - (title.frame.origin.x * 2), 80)];
    [self alignLabel:title atTopsView:containerView withSeparation:15];
    
    [self setGradientDirectionUP:YES];

    UIView *image = [self viewWithTag:101];
    CGFloat imageH = self.frame.size.height - (section.frame.origin.y + section.frame.size.height + 1);
    image.frame = CGRectMake(0, self.frame.size.height - imageH, self.frame.size.width, imageH);

    videoIconRect = CGRectMake(330, image.frame.origin.y + (image.frame.size.height * .5) - 45, 80, 75);

    [self setVideoIcon];
    
}

- (void) setDataForShowItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section {

    [super setDataForShowItem:data forTitle:title andSection:nil];

    UILabel *date = (UILabel *)[self viewWithTag:105];
    date.hidden = NO;
    date.text = [self getLongFormatDateFromData:data];
    section.hidden = YES;

}

- (void) fitSizesForShowItemTitle:(UILabel *)title andSection:(UILabel *)section {
    
    section.frame = CGRectMake(section.frame.origin.x, section.frame.origin.y, 100, section.frame.size.height);
    
    UIView *containerView = [self viewWithTag:100];
    UILabel *date = (UILabel *)[self viewWithTag:105];

    [self setLabel:date atBottomsView:containerView withSeparation:5];
    
    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(containerView.frame.size.width - (title.frame.origin.x * 2), 80)];
    [self setLabel:title aboveView:date withSeparation:0];

    videoIconRect = CGRectMake(330, 150, 80, 75);

    [super setVideoIcon];
    
}

@end