//
//  UIView+TSBasicCell.h
//  teleSUR
//
//  Created by Simkin on 23/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedItem.h"
#import "UILabelMarginSet.h"


@interface UIView (TSBasicCell)

- (NSInteger) getTitleLabelTag;
- (NSInteger) getSectionLabelTag;

- (UIFont *) getTitleFont;
- (CGRect) getVideoIconRect;

- (void) setVideoIcon;

- (void) initializeCell;

- (void) setData:(NSDictionary *)data;

- (void) setDataForVideoItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section withType:(NSString *)clipType;
- (void) setDataForShowItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section;
- (void) setDataForInfographItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section;
- (void) setDataForRSSItem:(MWFeedItem *)data forTitle:(UILabel *)title andSection:(UILabel *)section;


- (void) setLabel:(UILabel *)label atBottomsView:(UIView *)view withSeparation:(CGFloat)indent;
- (void) setLabel:(UILabel *)label aboveView:(UIView *)view withSeparation:(CGFloat)indent;
- (void) setLabel:(UILabel *)label underView:(UIView *)view withSeparation:(CGFloat)indent;
- (void) alignLabel:(UILabel *)label atTopsView:(UIView *)view withSeparation:(CGFloat)indent;

- (void) adjustSizeFrameForLabel:(UILabel *)label constriainedToSize:(CGSize)size;
- (CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (void) configRedBackgroundSectionLabel;
- (void) sizeToFitRedBackgroundLabel:(UILabelMarginSet *)section;

- (NSString *) getLongFormatDateFromData:(NSDictionary *)data;
- (NSString *) getLongFormatDateFromRSS:(MWFeedItem *)data;

//- (void) fitSizesForRSSItemTitle:(UILabel *)title andSection:(UILabel *)section;

@end