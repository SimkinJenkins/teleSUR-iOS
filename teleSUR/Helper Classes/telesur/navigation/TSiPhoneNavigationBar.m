//
//  TSiPhoneNavigationBar.m
//  teleSUR
//
//  Created by Simkin on 23/03/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import "TSiPhoneNavigationBar.h"

@implementation TSiPhoneNavigationBar

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = [super sizeThatFits:size];
    result.height = 27;
    return result;
}

@end