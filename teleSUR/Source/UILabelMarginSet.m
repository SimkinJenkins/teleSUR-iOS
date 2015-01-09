//
//  UILabelMarginSet.m
//  teleSUR
//
//  Created by Simkin on 09/07/14.
//
//

#import "UILabelMarginSet.h"

@implementation UILabelMarginSet

@synthesize topMargin, leftMargin, bottomMargin, rightMargin;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        topMargin = 0.0;
        leftMargin = 0.0;
        bottomMargin = 0.0;
        rightMargin = 0.0;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {topMargin, leftMargin, bottomMargin, rightMargin};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (void)setPersistentBackgroundColor:(UIColor*)color {
    super.backgroundColor = color;
}

- (void)setBackgroundColor:(UIColor *)color {
    // do nothing - background color never changes
}

@end
