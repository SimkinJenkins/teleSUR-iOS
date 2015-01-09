//
//  UILabelMarginSet.h
//  teleSUR
//
//  Created by Simkin on 09/07/14.
//
//

#import <UIKit/UIKit.h>

@interface UILabelMarginSet : UILabel

@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat bottomMargin;
@property (nonatomic, assign) CGFloat rightMargin;

- (void)setPersistentBackgroundColor:(UIColor*)color;

@end
