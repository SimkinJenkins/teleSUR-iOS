//
//  HighlightTableViewCell.m
//  teleSUR
//
//  Created by Simkin on 28/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "HighlightTableViewCell.h"
#import "UILabelMarginSet.h"

@implementation HighlightTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;

}

- (void)awakeFromNib {

    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:1];
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:3];

    title.leftMargin = 5;
    title.font = [UIFont fontWithName:@"Roboto-Black" size:20];
    section.leftMargin = 5;
    section.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:11];
    [title setPersistentBackgroundColor:[UIColor blackColor]];
    [section setPersistentBackgroundColor:[UIColor colorWithRed:255/255.0 green:2/255.0 blue:2/255.0 alpha:1.0]];

    [self bringSubviewToFront:title];

}

- (void) fitSizesForRSSItemTitle:(UILabel *)title andSection:(UILabel *)section {

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(300, 300)];
    title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y, title.frame.size.width + 10, title.frame.size.height);
    [self sizeToFitRedBackgroundLabel:(UILabelMarginSet *)section];

    [self setLabel:title atBottomsView:self withSeparation:2];

    [self setLabel:section aboveView:title withSeparation:0];

}

- (void) fitSizesForVideoItemTitle:(UILabel *)title andSection:(UILabel *)section {

    [self fitSizesForRSSItemTitle:title andSection:section];

    [self setVideoIcon];

}

- (void) fitSizesForShowItemTitle:(UILabel *)title andSection:(UILabel *)section {

    [self fitSizesForVideoItemTitle:title andSection:section];

}

- (void) fitSizesForInfographItemTitle:(UILabel *)title andSection:(UILabel *)section {

    [self fitSizesForVideoItemTitle:title andSection:section];

}

- (CGRect) getVideoIconRect {
    
    return CGRectMake(110, 60, 93, 93);
    
}

- (void) setDataForInfographItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section {

    section.hidden = YES;
    title.text = [data valueForKey:@"titulo"];

}

@end