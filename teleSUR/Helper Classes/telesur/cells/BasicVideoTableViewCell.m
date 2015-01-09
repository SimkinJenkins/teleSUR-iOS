//
//  BasicVideoTableViewCell.m
//  teleSUR
//
//  Created by Simkin on 01/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "BasicVideoTableViewCell.h"
#import "UILabelMarginSet.h"

@implementation BasicVideoTableViewCell

- (void)awakeFromNib {
    
    [self initializeCell];
    
}

- (void) initializeCell {
    
    UILabelMarginSet *titleLabel = (UILabelMarginSet *)[self viewWithTag: [self getTitleLabelTag]];
    UILabelMarginSet *sectionLabel = (UILabelMarginSet *)[self viewWithTag: [self getSectionLabelTag]];
//    UIView *gView = [self viewWithTag:100];
    
    titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, 175, 80);
    titleLabel.font = [UIFont fontWithName:@"Roboto-Light" size:14];
    sectionLabel.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:11];

/*
    UIView *image = [self viewWithTag:101];
    
    // Create a mask layer and the frame to determine what will be visible in the view.
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGRect maskRect = CGRectMake(0, 0, gView.frame.size.width, gView.frame.size.height);
    
    // Create a path with the rectangle in it.
    CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
    
    // Set the path to the mask layer.
    maskLayer.path = path;
    
    // Release the path since it's not covered by ARC.
    CGPathRelease(path);
    
    // Set the mask of the view.
    image.layer.mask = maskLayer;
*/
}

- (void) initTitleLabelSize {
    
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag: [self getTitleLabelTag]];
    title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y, 175, 80);
    
}

- (void) setLabelSizeToFit {

    UILabelMarginSet *titleLabel = (UILabelMarginSet *)[self viewWithTag: [self getTitleLabelTag]];
    UILabelMarginSet *sectionLabel = (UILabelMarginSet *)[self viewWithTag: [self getSectionLabelTag]];

    sectionLabel.frame = CGRectMake(sectionLabel.frame.origin.x, -2, sectionLabel.frame.size.width, sectionLabel.frame.size.height);
    [self setLabel:titleLabel underView:sectionLabel withSeparation:0];

}

- (CGRect) getVideoIconRect {
    return CGRectMake(50, 35, 45, 45);
}

@end
