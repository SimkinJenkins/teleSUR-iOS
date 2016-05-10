//
//  UITableViewCell+TSHighlightedViewCell.h
//  teleSUR
//
//  Created by Simkin on 07/03/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+TSBasicCell.h"

#import "TSUtils.h"

@interface UIView (TSHighlightedViewCell)

- (void) setupHighlightedViewCell:(BOOL)itsPair;
- (void) fitSizesHighlightedViewCell;

- (void) setupVideoViewCell;
- (void) fitSizesVideoViewCell;

- (void) setupDoubleViewCellWithColor:(UIColor *)lineColor;
- (void) fitSizesDoubleViewCell;

- (void) setupSingleImageViewCellWithColor:(UIColor *)lineColor;
- (void) fitSizesSingleImageViewCell;

- (void) setupVideoCarrouselViewCell:(BOOL) itsPair;
- (void) fitSizesVideoCarrouselViewCell;

- (void) setupShowCarrouselViewCell:(int)delta;

- (void) setupVideoHomeViewCell;
- (void) fitSizesVideoHomeViewCell;


- (void) setupVideoIcon:(CGRect)rect;


@end