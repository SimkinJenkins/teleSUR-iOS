//
//  HomeTopTableViewCell.m
//  teleSUR
//
//  Created by Simkin on 28/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "HomeTopTableViewCell.h"
#import "UILabelMarginSet.h"

@implementation HomeTopTableViewCell

- (void)awakeFromNib {

    UILabelMarginSet *title = (UILabelMarginSet *)[ self viewWithTag: [self getTitleLabelTag ] ];
    title.font = [UIFont fontWithName:@"Roboto-Black" size:20];

    [self configRedBackgroundSectionLabel];

}

@end