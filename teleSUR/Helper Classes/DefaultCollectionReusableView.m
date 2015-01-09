//
//  DefaultCollectionReusableView.m
//  teleSUR
//
//  Created by Simkin on 05/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "DefaultCollectionReusableView.h"
#import "UIView+TSBasicCell.h"
#import "UILabelMarginSet.h"
#import "AlphaGradientView.h"
#import "MWFeedItem.h"
#import "NSString+HTML.h"

@implementation DefaultCollectionReusableView

- (void)awakeFromNib {

    videoIconRect = CGRectMake(100, 75, 45, 45);
    [self initializeCell];

}

- (void) initializeCell {

    UIView *gView = [self viewWithTag:100];

    AlphaGradientView* gradient = [[AlphaGradientView alloc] initWithFrame:
                                   CGRectMake(0, gView.frame.size.height * 0.3, gView.frame.size.width, gView.frame.size.height * 0.7)];

    gradient.direction = GRADIENT_DOWN;
    gradient.color = [UIColor blackColor];
    gradient.tag = 2828;
    [gView addSubview:gradient];
    [gView sendSubviewToBack:gradient];

}

- (void) initializeElements {

    UIView *gView = [self viewWithTag:100];

    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag: [self getTitleLabelTag]];

    BOOL isBigThumb = gView.frame.size.width > 300;
    title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y, isBigThumb ? 470 : gView.frame.size.width - (title.frame.origin.x * 2), 80);

    title.font = [UIFont fontWithDescriptor:title.font.fontDescriptor size:17];

    [self setGradientDirectionUP:NO];

    if ( !isBigThumb ) {
        UIView *image = [self viewWithTag:101];
        image.frame = CGRectMake(0, 0, 245, 210);
    }

    [self viewWithTag:2829].hidden = YES;

    UILabel *date = (UILabel *)[self viewWithTag:105];
    date.hidden = YES;

}

- (void) setData:(NSDictionary *)data {

    [self initializeElements];

    [super setData:data];

}

- (void) setDataForShowItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section {

    [super setDataForShowItem:data forTitle:nil andSection:title];

    section.font = [UIFont fontWithDescriptor:title.font.fontDescriptor size:12];
    section.textColor = [UIColor whiteColor];

    section.text = @"PROGRAMAS";

}

- (void) fitSizesForShowItemTitle:(UILabel *)title andSection:(UILabel *)section {

    section.frame = CGRectMake(section.frame.origin.x, section.frame.origin.y, 100, section.frame.size.height);

    UIView *containerView = [self viewWithTag:100];
    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(containerView.frame.size.width - (title.frame.origin.x * 2), 80)];

    [self setLabel:title atBottomsView:containerView.superview withSeparation:10];
    [self setLabel:section aboveView:title withSeparation:3];

    videoIconRect = CGRectMake(100, (section.frame.origin.y * .5) - 22, 45, 45);
    [super setVideoIcon];

}

- (void) setDataForVideoItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section withType:(NSString *)clipType {

    [super setDataForVideoItem:data forTitle:title andSection:section withType:clipType];

    section.text = @"VIDEO";
    section.font = [UIFont fontWithDescriptor:section.font.fontDescriptor size:16];
    section.textColor = [UIColor blackColor];

}

- (void) fitSizesForVideoItemTitle:(UILabel *)title andSection:(UILabel *)section {

    UIView *containerView = [self viewWithTag:100];

    [self alignLabel:section atTopsView:containerView withSeparation:-1];

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(containerView.frame.size.width - (title.frame.origin.x * 2), 80)];
    [self setLabel:title atBottomsView:containerView withSeparation:8];

    UIView *image = [self viewWithTag:101];
    CGFloat imageH = self.frame.size.height - (section.frame.origin.y + section.frame.size.height + 1);
    image.frame = CGRectMake(0, self.frame.size.height - imageH, self.frame.size.width, imageH);

    videoIconRect = CGRectMake(100, image.frame.origin.y + (image.frame.size.height * .5) - 30, 45, 45);
    [self setVideoIcon];

}

- (void) setDataForRSSItem:(MWFeedItem *)data forTitle:(UILabel *)title andSection:(UILabel *)section {

    [super setDataForRSSItem:data forTitle:title andSection:section];

    UILabel *date = (UILabel *)[self viewWithTag:105];
    date.text = [self getLongFormatDateFromRSS:(MWFeedItem *)data];
    date.hidden = NO;

    UILabel *summaryLabel = ((UILabelMarginSet *)[self viewWithTag:102]);
    if( summaryLabel ) {
        summaryLabel.text = [((MWFeedItem *)data).summary stringByDecodingHTMLEntities];
    }

    section.text = @"";

}

- (void) fitSizesForRSSItemTitle:(UILabel *)title andSection:(UILabel *)section {

    UIView *containerView = [self viewWithTag:100];
    UILabel *summaryLabel = ((UILabelMarginSet *)[self viewWithTag:102]);
    UILabel *date = (UILabel *)[self viewWithTag:105];

    if( summaryLabel ) {

        [self setLabel:date atBottomsView:containerView withSeparation:12];

        [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(470, 300)];
        [self adjustSizeFrameForLabel:summaryLabel constriainedToSize:CGSizeMake(230, 300)];

        [self setLabel:summaryLabel atBottomsView:containerView withSeparation:20];
        [self setLabel:title aboveView:date withSeparation:5];

        if ( summaryLabel.frame.origin.y > title.frame.origin.y ) {
            [self alignLabel:summaryLabel atTopsView:title withSeparation:5];
        } else {
            [self alignLabel:title atTopsView:summaryLabel withSeparation:-2];
        }

    } else {

        [self setLabel:date atBottomsView:containerView withSeparation:5];

        [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(containerView.frame.size.width - (title.frame.origin.x * 2), 80)];
        [self setLabel:title aboveView:date withSeparation:0];

    }
    
}

- (void) setDataForInfographItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section {

    section.hidden = YES;

    title.font = [UIFont fontWithDescriptor:title.font.fontDescriptor size:18];
    title.text = [data valueForKey:@"titulo"];

}

- (void) fitSizesForInfographItemTitle:(UILabel *)title andSection:(UILabel *)section {

    UIView *containerView = [self viewWithTag:100];

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(containerView.frame.size.width - (title.frame.origin.x * 2), 80)];
    [self alignLabel:title atTopsView:containerView withSeparation:20];

    [self setGradientDirectionUP:YES];

    videoIconRect = CGRectMake(100, (containerView.frame.size.height * .5) - 20, 45, 45);
    [self setVideoIcon];

}




- (void) setGradientDirectionUP:(BOOL)up {

    AlphaGradientView *gradient = (AlphaGradientView *)[self viewWithTag:2828];

    if ( up ) {

        gradient.direction = GRADIENT_UP;
        gradient.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height * 0.7);

    } else {

        gradient.direction = GRADIENT_DOWN;
        gradient.frame = CGRectMake(0, self.frame.size.height * 0.3, self.frame.size.width, self.frame.size.height * 0.7);
        
    }

}

- (CGRect) getVideoIconRect {
    return videoIconRect;
}

- (NSInteger) getTitleLabelTag {
    return 103;
}

- (NSInteger) getSectionLabelTag {
    return 104;
}

@end