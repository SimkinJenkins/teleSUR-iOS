//
//  UIViewController+UIViewController_KAUtils.m
//  LaJornada
//
//  Created by Simkin on 19/11/15.
//  Copyright © 2015 Kafeina. All rights reserved.
//

#import "UIViewController+KAUtils.h"

@implementation UIViewController (UIViewController_KAUtils)

- (void)showLoader:(BOOL)show {
    UIView *view = [self.view viewWithTag:1234];
    UIActivityIndicatorView *spinner = [self.view viewWithTag:1235];
    if ( !view ) {
        view = [[UIView alloc] initWithFrame:self.view.frame];
        view.tag = 1234;
        view.backgroundColor = [UIColor clearColor];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [spinner setColor:[UIColor redColor]];
        spinner.frame = CGRectMake((view.frame.size.width - spinner.frame.size.width) * 0.5, (view.frame.size.height - spinner.frame.size.height) * 0.5, spinner.frame.size.width, spinner.frame.size.height);
        spinner.tag = 1235;
        [self.view addSubview:view];
        [view addSubview:spinner];
    }
    if ( show ) {
        [spinner startAnimating];
    } else {
        [spinner stopAnimating];
    }
    if ( show ) {
        [self.view bringSubviewToFront:view];
        view.alpha = 1.0;
    } else {
        [UIView animateWithDuration:1.5 delay:0.0 options: UIViewAnimationOptionCurveEaseIn animations:^{
            view.alpha = 0.0;
        } completion:nil];
    }
}

- (UILabel *) addMultilineLabelWithFont:(UIFont *)font andFontColor:(UIColor *)fontColor withFrame:(CGRect)frame withTag:(int)tag {
    UILabel *label = [self getMultilineLabelWithFont:font andFontColor:fontColor withFrame:frame];
    label.tag = tag;
    [self.view addSubview:label];
    return label;
}

- (UILabel *) getMultilineLabelWithFont:(UIFont *)font andFontColor:(UIColor *)fontColor withFrame:(CGRect)frame {
    UILabel *label = [ [ UILabel alloc ] initWithFrame:frame ];
    label.font = font;
    label.textColor = fontColor;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    return label;
}

- (void) moveView:(UIView *)a intoLowerSideAt:(UIView *)b withDelta:(float)delta {
    a.frame = CGRectMake(a.frame.origin.x, (b.frame.origin.y + b.frame.size.height) - delta, a.frame.size.width, a.frame.size.height);
}

- (void) sizeFrameForLabel:(UILabel *)label constriainedToSize:(CGSize)size {
    CGSize labelSize = [self frameForText:label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    [label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, labelSize.width, labelSize.height)];
}

-(CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSDictionary * attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
    CGRect textRect = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return textRect.size;
}

@end
