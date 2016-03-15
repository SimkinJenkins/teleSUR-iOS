//
//  UITableViewCell+TSHighlightedViewCell.h
//  teleSUR
//
//  Created by Simkin on 07/03/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+TSBasicCell.h"

@interface UIView (TSHighlightedViewCell)

- (void) setupHighlightedViewCell;
- (void) fitSizesHighlightedViewCell;

- (void) setupVideoViewCell;
- (void) fitSizesVideoViewCell;

@end