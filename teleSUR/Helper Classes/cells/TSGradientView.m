//
//  TSGradientView.m
//  teleSUR
//
//  Created by Simkin on 23/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSGradientView.h"

@implementation TSGradientView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGGradientRef gradient;
    CGColorSpaceRef colorspace;
    CGFloat locations[2] = { 0.0, 1.0 };
    
    NSArray *colors = @[(id)[UIColor clearColor].CGColor,
                        (id)[UIColor blackColor].CGColor];
    
    colorspace = CGColorSpaceCreateDeviceRGB();
    
    gradient = CGGradientCreateWithColors(colorspace,
                                          (CFArrayRef)colors, locations);
    
    CGPoint startPoint, endPoint;
    startPoint.x = 0.0;
    startPoint.y = 0.0;
    
    endPoint.x = 0;
    endPoint.y = 300;
    
    CGContextDrawLinearGradient(context, gradient,
                                startPoint, endPoint, 0);

//    self.layer.colors = gradientColors;
//    self.layer.locations = gradientLocations; // But this time as `NSArray`
    self.layer.startPoint = startPoint; // From 0 to 1
    self.layer.endPoint = endPoint; // From 0 to 1
}

+ (Class)layerClass {
    return [CAGradientLayer class];
}

@end
