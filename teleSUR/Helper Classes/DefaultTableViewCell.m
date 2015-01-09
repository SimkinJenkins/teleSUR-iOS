//
//  DefaultTableViewCell.m
//  teleSUR
//
//  Created by Simkin on 28/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "DefaultTableViewCell.h"
#import "UILabelMarginSet.h"
#import "UIView+TSBasicCell.h"

@implementation DefaultTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;

}

- (void)awakeFromNib {

    [self initializeCell];

}

@end