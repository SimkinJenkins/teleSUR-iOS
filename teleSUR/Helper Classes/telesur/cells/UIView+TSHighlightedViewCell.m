//
//  UITableViewCell+TSHighlightedViewCell.m
//  teleSUR
//
//  Created by Simkin on 07/03/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import "UIView+TSHighlightedViewCell.h"

@implementation UIView (TSHighlightedViewCell)

- (void) setupHighlightedViewCell:(BOOL)itsPair {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:10002];
    title.font = [UIFont fontWithName:@"OpenSans-Bold" size:16];
    title.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    title.layer.masksToBounds = NO;
    title.layer.shadowRadius = 1.0;
    title.layer.shadowOpacity = 0.6;
    section.font = [UIFont fontWithName:@"PTSerif-Regular" size:7];
    section.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    section.layer.masksToBounds = NO;
    section.layer.shadowRadius = 1.0;
    section.layer.shadowOpacity = 2.0;
    if ( [self viewWithTag:10123] ) {       [[self viewWithTag:10123] removeFromSuperview];        }
    UIImageView *iView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:itsPair ? @"highlighted-color-shadow" : @"highlighted-color-shadow-bis"]];
    iView.tag = 10123;
    iView.frame = self.frame;
    [self addSubview:iView];
    [self bringSubviewToFront:section];
    [self bringSubviewToFront:title];
}

- (void) fitSizesHighlightedViewCell {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:10002];
    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(240, 300)];
    title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y, title.frame.size.width + 10, title.frame.size.height);
    [self setLabel:title atBottomsView:self withSeparation:5];
    [self setLabel:section aboveView:title withSeparation:-8];
    [self bringSubviewToFront:title];
}

- (void) setupVideoViewCell {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
    title.font = [UIFont fontWithName:@"Roboto-Bold" size:13];
    title.frame = CGRectMake(157, title.frame.origin.y, 155, 70);
    UITableViewCell *selfCell = (UITableViewCell *)self;
    if ( selfCell ) {
        selfCell.backgroundColor = [UIColor clearColor];
        selfCell.backgroundView = [UIView new];
        selfCell.selectedBackgroundView = [UIView new];
    }
}

- (void) fitSizesVideoViewCell {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:10002];
    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(155, 300)];
    [self setLabel:title underView:section withSeparation:2];
}

- (void) configRedBackgroundSectionTo:(UILabelMarginSet *)label {
    label.font = [UIFont fontWithName:@"Roboto-Black" size:8];
    label.leftMargin = 5;
    [label setPersistentBackgroundColor:[UIColor colorWithRed:255/255.0 green:2/255.0 blue:2/255.0 alpha:1.0]];
}

- (void) setupDoubleViewCellWithColor:(UIColor *)lineColor {
    UILabelMarginSet *titleA = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabelMarginSet *sectionA = (UILabelMarginSet *)[self viewWithTag:10002];
    UILabelMarginSet *titleB = (UILabelMarginSet *)[self viewWithTag:10101];
    UILabelMarginSet *sectionB = (UILabelMarginSet *)[self viewWithTag:10102];
    UIView *backA = [self viewWithTag:9500];
    UIView *backB = [self viewWithTag:9600];
    UIView *lineA = [self viewWithTag:9501];
    UIView *lineB = [self viewWithTag:9601];
    lineA.backgroundColor = lineB.backgroundColor = [lineColor copy];
    titleA.font = titleB.font = [UIFont fontWithName:@"OpenSans-Bold" size:11];
    sectionB.font = sectionA.font = [UIFont fontWithName:@"PTSerif-Regular" size:6];
    backB.layer.masksToBounds = backA.layer.masksToBounds = NO;
    backB.layer.shadowOffset = backA.layer.shadowOffset = CGSizeMake(0, 0);
    backB.layer.shadowRadius = backA.layer.shadowRadius = 3;
    backB.layer.shadowOpacity = backA.layer.shadowOpacity = 0.5;
}

- (void) fitSizesDoubleViewCell {
    UILabelMarginSet *titleA = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabelMarginSet *sectionA = (UILabelMarginSet *)[self viewWithTag:10002];
    UILabelMarginSet *titleB = (UILabelMarginSet *)[self viewWithTag:10101];
    UILabelMarginSet *sectionB = (UILabelMarginSet *)[self viewWithTag:10102];
    
    [self adjustSizeFrameForLabel:sectionA constriainedToSize:CGSizeMake(80, 100)];
    [self adjustSizeFrameForLabel:titleA constriainedToSize:CGSizeMake(125, 200)];
    [self setLabel:titleA underView:sectionA withSeparation:-1];
    
    if ( !sectionB ) {
        return;
    }
    
    [self adjustSizeFrameForLabel:sectionB constriainedToSize:CGSizeMake(80, 100)];
    [self adjustSizeFrameForLabel:titleB constriainedToSize:CGSizeMake(125, 200)];
    [self setLabel:titleB underView:sectionB withSeparation:-1];
    
    [self bringSubviewToFront:[self viewWithTag:9100]];
}

- (void) setupSingleImageViewCellWithColor:(UIColor *)lineColor {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:10002];
    UIView *back = [self viewWithTag:9500];
    UIView *line = [self viewWithTag:9501];
    line.backgroundColor = [lineColor copy];
    title.font = [UIFont fontWithName:@"OpenSans-Bold" size:14];
    section.font = [UIFont fontWithName:@"PTSerif-Regular" size:8];
    back.layer.masksToBounds = NO;
    back.layer.shadowOffset = CGSizeMake(0, 0);
    back.layer.shadowRadius = 3;
    back.layer.shadowOpacity = 0.5;
}

- (void) fitSizesSingleImageViewCell {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:10002];
    [self adjustSizeFrameForLabel:section constriainedToSize:CGSizeMake(80, 100)];
    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(280, 400)];
    [self setLabel:title underView:section withSeparation:1];
}

- (void) setupVideoCarrouselViewCell:(BOOL)itsPair {
    UILabel *title = (UILabel *)[self viewWithTag:10001];
    UILabel *section = (UILabel *)[self viewWithTag:10002];
    title.font = [UIFont fontWithName:@"OpenSans-Bold" size:12];
    title.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    title.layer.masksToBounds = NO;
    title.layer.shadowRadius = 1.0;
    title.layer.shadowOpacity = 0.7;
    section.font = [UIFont fontWithName:@"PTSerif-Regular" size:6];
    section.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    section.layer.masksToBounds = NO;
    section.layer.shadowRadius = 1.0;
    section.layer.shadowOpacity = 2.0;
    if ( [self viewWithTag:10123] ) {       [[self viewWithTag:10123] removeFromSuperview];        }
    UIImageView *iView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:itsPair ? @"video-carrusel-0" : @"video-carrusel-1"]];
    iView.tag = 10123;
    iView.frame = self.frame;
    [self addSubview:iView];
    [self bringSubviewToFront:section];
    [self bringSubviewToFront:title];
}

- (void) setupVideoIcon:(CGRect)rect {
    if ( [self viewWithTag:10124] ) {       [[self viewWithTag:10124] removeFromSuperview];        }
    UIImageView *jView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video-icon"]];
    jView.tag = 10124;
    jView.frame = rect;
    [self addSubview:jView];
}

- (void) fitSizesVideoCarrouselViewCell {
    UILabel *title = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabel *section = (UILabelMarginSet *)[self viewWithTag:10002];
    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(self.frame.size.width - 20, 200)];
    [self adjustSizeFrameForLabel:section constriainedToSize:CGSizeMake(100, 100)];
    [self setLabel:title atBottomsView:self withSeparation:5];
    [self setLabel:section aboveView:title withSeparation:1];
}

- (void) setupShowCarrouselViewCell:(int)delta {
    UILabel *title = (UILabel *)[self viewWithTag:10001];
    title.font = [UIFont fontWithName:@"OpenSans-Bold" size:10];
    title.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    title.layer.masksToBounds = NO;
    title.layer.shadowRadius = 1.0;
    title.layer.shadowOpacity = 0.7;
    if ( [self viewWithTag:9500] ) {
        [self viewWithTag:9500].backgroundColor = delta == 0 ? [TSUtils colorShowPink] : ( delta == 1 ? [TSUtils colorShowBlue] : [TSUtils colorShowYellow]);
    }
    if ( [self viewWithTag:10124] ) {       [[self viewWithTag:10124] removeFromSuperview];        }
    UIImageView *jView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video-icon"]];
    jView.tag = 10124;
    jView.frame = CGRectMake(62, 19, 17, 17);
    [self addSubview:jView];

}

- (void) setupVideoHomeViewCell {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:10002];
    section.hidden = YES;
    UIView *back = [self viewWithTag:9500];
    title.font = [UIFont fontWithName:@"OpenSans-Bold" size:12];
//    section.font = [UIFont fontWithName:@"PTSerif-Regular" size:8];
    back.layer.masksToBounds = NO;
    back.layer.shadowOffset = CGSizeMake(0, 0);
    back.layer.shadowRadius = 3;
    back.layer.shadowOpacity = 0.5;
}

- (void) fitSizesVideoHomeViewCell {
    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag:10001];
//    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:10002];
//    [self adjustSizeFrameForLabel:section constriainedToSize:CGSizeMake(80, 100)];
    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(230, 200)];
    title.frame = CGRectMake(title.frame.origin.x, 105 + ((56 - title.frame.size.height) / 2), title.frame.size.width, title.frame.size.height);
//    [self setLabel:title underView:section withSeparation:-3];
}

@end