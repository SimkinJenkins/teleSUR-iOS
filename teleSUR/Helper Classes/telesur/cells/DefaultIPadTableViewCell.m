//
//  DefaultIPadTableViewCell.m
//  teleSUR
//
//  Created by Simkin on 24/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "DefaultIPadTableViewCell.h"
#import "UILabelMarginSet.h"
#import "AlphaGradientView.h"
#import "MWFeedItem.h"
#import "UIView+TSBasicCell.h"
#import "NSString+HTML.h"

@implementation DefaultIPadTableViewCell

- (void)awakeFromNib {
    
    [self initializeCell];
    
}

- (void) initializeCell {

    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag: [self getSectionLabelTag]];
    UIView *gView = [self viewWithTag:100];

    section.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:11];

    AlphaGradientView* gradient = [[AlphaGradientView alloc] initWithFrame:
                                   CGRectMake(0, gView.frame.size.height * 0.3, gView.frame.size.width, gView.frame.size.height * 0.7)];
    gradient.direction = GRADIENT_DOWN;
    gradient.color = [UIColor blackColor];
    [gView addSubview:gradient];
    [gView sendSubviewToBack:gradient];

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

}

- (void) fitSizesForRSSItemTitle:(UILabel *)title andSection:(UILabel *)section {

    UIView *view = [self viewWithTag:101];

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(198, 100)];
    [self setLabel:title atBottomsView:view withSeparation:8];
    [self setLabel:section aboveView:title withSeparation:-2];

}

- (NSInteger) getTitleLabelTag {
    return 103;
}

- (NSInteger) getSectionLabelTag {
    return 104;
}

@end
