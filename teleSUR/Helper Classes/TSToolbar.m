//
//  TSToolbar.m
//  teleSUR
//
//  Created by Simkin on 29/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSToolbar.h"

@implementation TSToolbar

- (id)initWithFrame:(CGRect)frame {
    return [super initWithFrame:frame];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = [super sizeThatFits:size];
    result.height = 65;
    return result;
}

@end