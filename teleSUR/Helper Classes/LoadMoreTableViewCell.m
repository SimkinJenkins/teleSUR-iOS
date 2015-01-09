//
//  LoadMoreTableViewCell.m
//  teleSUR
//
//  Created by Simkin on 28/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "LoadMoreTableViewCell.h"

@implementation LoadMoreTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;

}

- (void)awakeFromNib {

    ((UILabel *)[self viewWithTag:1]).text = [NSString stringWithFormat:NSLocalizedString(@"verMasCellText", nil)];

}

@end