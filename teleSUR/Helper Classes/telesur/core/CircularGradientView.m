//
//  CircularGradientView.m
//  teleSUR
//
//  Created by Simkin on 05/05/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import "CircularGradientView.h"

@implementation CircularGradientView
{
    CGPoint startPoint;
    CGPoint endPoint;
    float _alpha;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _alpha = 1.0;
        self.userInteractionEnabled = false;
        self.backgroundColor = [UIColor clearColor];
        self.color = [UIColor blackColor];
    }
    
    return self;
}


-(void) setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
    [self setNeedsDisplay];
}

-(void) setColor:(UIColor *)value
{
    _color = value;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [self drawGradient:rect];
}

-(void) drawGradient:(CGRect)rect
{
    CGFloat maskColors[] =
    {
        0.0f, 0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 1.0f,
    };

    // Set up the start and end points for the gradient
//    [self calculateStartAndEndPoints];
    startPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    endPoint = CGPointMake(0, 0);
    
    // Create an image of a solid slab in the desired color
    CGRect frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:_alpha].CGColor);
    CGContextFillRect( UIGraphicsGetCurrentContext(), frame);
    CGImageRef colorRef = UIGraphicsGetImageFromCurrentImageContext().CGImage;
    
    // Create an image of a gradient from black to white
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradientRef = CGGradientCreateWithColorComponents(rgb, maskColors, NULL, sizeof(maskColors) / (sizeof(maskColors[0]) * 4));
    CGColorSpaceRelease(rgb);

//    CGContextDrawLinearGradient( context, gradientRef, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

    CGContextDrawRadialGradient( context, gradientRef, startPoint, 0, startPoint, 50, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);

    CGImageRef maskRef = UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
    
    // Blend the solid image and the gradient to produce the final gradient.
    CGImageRef tmpMask = CGImageMaskCreate(
                                           CGImageGetWidth(maskRef),
                                           CGImageGetHeight(maskRef),
                                           CGImageGetBitsPerComponent(maskRef),
                                           CGImageGetBitsPerPixel(maskRef),
                                           CGImageGetBytesPerRow(maskRef),
                                           CGImageGetDataProvider(maskRef),
                                           NULL,
                                           false);
    
    // Draw the resulting mask.
    context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, rect, CGImageCreateWithMask(colorRef, tmpMask));
    UIGraphicsEndImageContext();
}

@end
