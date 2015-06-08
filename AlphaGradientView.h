//
//  GradientView.h
//  AssetGrid
//
//  Created by Joe Andolina on 10/18/12.
//
//

#import <UIKit/UIKit.h>

@interface AlphaGradientView : UIView

typedef enum gradientDirections
{
    GRADIENT_UP,
    GRADIENT_DOWN,
    GRADIENT_LEFT,
    GRADIENT_RIGHT
} GradientDirection;

@property (nonatomic) UIColor* color;
@property (nonatomic) GradientDirection direction;

@end
