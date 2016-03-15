//
//  UIViewController+UIViewController_KAUtils.h
//  LaJornada
//
//  Created by Simkin on 19/11/15.
//  Copyright © 2015 Kafeina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (KAUtils)

- (void)showLoader:(BOOL)show;
- (UILabel *) addMultilineLabelWithFont:(UIFont *)font andFontColor:(UIColor *)fontColor withFrame:(CGRect)frame withTag:(int)tag;
- (UILabel *) getMultilineLabelWithFont:(UIFont *)font andFontColor:(UIColor *)fontColor withFrame:(CGRect)frame;
- (void) sizeFrameForLabel:(UILabel *)label constriainedToSize:(CGSize)size;
- (void) moveView:(UIView *)a intoLowerSideAt:(UIView *)b withDelta:(float)delta;
-(CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
