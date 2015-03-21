//
//  TSDefaultVideoCollectionViewCell.m
//  teleSUR
//
//  Created by Simkin on 05/03/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import "TSDefaultVideoCollectionViewCell.h"

@implementation TSDefaultVideoCollectionViewCell

- (void) setDataForShowItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section {
    
    [super setDataForShowItem:data forTitle:title andSection:nil];
    
    UILabel *date = (UILabel *)[self viewWithTag:105];
    date.hidden = NO;
    date.text = title.text;
    title.text = [self getLongFormatDateFromData:data];
    section.hidden = YES;
    
}

- (void) setDataForVideoItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section withType:(NSString *)clipType {
    
    [super setDataForVideoItem:data forTitle:title andSection:section withType:clipType];

    UILabel *date = (UILabel *)[self viewWithTag:105];
    date.hidden = NO;
    date.text = [self getLongFormatDateFromData:data];
    section.hidden = YES;

}

- (void) fitSizesForVideoItemTitle:(UILabel *)title andSection:(UILabel *)section {

    UIView *containerView = [self viewWithTag:100];
    UILabel *date = (UILabel *)[self viewWithTag:105];

    [self setLabel:date atBottomsView:containerView withSeparation:5];

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(containerView.frame.size.width - (title.frame.origin.x * 2), 60)];
    [self setLabel:title aboveView:date withSeparation:0];

    videoIconRect = CGRectMake(100, 60, 45, 45);
    [self setVideoIcon];

}

- (void) fitSizesForShowItemTitle:(UILabel *)title andSection:(UILabel *)section {
    
    section.frame = CGRectMake(section.frame.origin.x, section.frame.origin.y, 100, section.frame.size.height);
    
    UIView *containerView = [self viewWithTag:100];
    UILabel *date = (UILabel *)[self viewWithTag:105];

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(containerView.frame.size.width - (title.frame.origin.x * 2), 80)];
    [self setLabel:title atBottomsView:containerView withSeparation:5];

    [self adjustSizeFrameForLabel:date constriainedToSize:CGSizeMake(containerView.frame.size.width - (title.frame.origin.x * 2), 80)];
    [self setLabel:date aboveView:title withSeparation:0];
    
    videoIconRect = CGRectMake(100, 65, 45, 45);

    [super setVideoIcon];

}

- (void) fitSizesForInfographItemTitle:(UILabel *)title andSection:(UILabel *)section {

    UIView *containerView = [self viewWithTag:100];

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(containerView.frame.size.width - (title.frame.origin.x * 2), 80)];
    [self alignLabel:title atTopsView:containerView withSeparation:5];

    [self setGradientDirectionUP:YES];

    videoIconRect = CGRectMake(100, (containerView.frame.size.height * .5) - 20, 45, 45);
    [self setVideoIcon];

}

@end