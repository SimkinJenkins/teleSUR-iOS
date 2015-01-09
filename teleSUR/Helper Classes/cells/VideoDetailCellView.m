//
//  VideoDetailCellView.m
//  teleSUR
//
//  Created by Simkin on 06/11/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "VideoDetailCellView.h"
#import "NSDictionary_Datos.h"

@implementation VideoDetailCellView

- (void)awakeFromNib {

    UILabel *section = (UILabel *)[self viewWithTag:[self getSectionLabelTag]];
    UILabel *date = (UILabel *)[self viewWithTag:102];
    UIButton *download = (UIButton *)[self viewWithTag:103];
    UILabel *description = (UILabel *)[self viewWithTag:104];
    UILabel *loadMore = (UILabel *)[self viewWithTag:106];

    //Setear fuentes custom
    section.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:8];//2e2e2e
    date.font = [UIFont fontWithName:@"Roboto-Bold" size:12];//696969

    download.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:16];//white
    [download setTitle:[NSString stringWithFormat:NSLocalizedString(@"descarga", nil)] forState:UIControlStateNormal];

    description.font = [UIFont fontWithName:@"Roboto-Light" size:12];//black
    loadMore.font = [UIFont fontWithName:@"Roboto-Regular" size:14];//fe4141
    loadMore.text = [NSString stringWithFormat:NSLocalizedString(@"masArchivos", nil)];

}

- (NSInteger) getTitleLabelTag {
    return 101;
}

- (NSInteger) getSectionLabelTag {
    return 100;
}


- (void) setData:(NSDictionary *)data {

    [super setData:data];

    UILabel *date = (UILabel *)[self viewWithTag:102];
    UILabel *description = (UILabel *)[self viewWithTag:104];

    date.text = [data obtenerFechaLargaParaEsteClip];

    NSString *clipType = [[data valueForKey:@"tipo"] valueForKey:@"slug"];

    description.text = ![clipType isEqualToString:@"programa"] ? [data obtenerDescripcion] : @"";

    [self configDetailCell];

}

- (void) configDetailCell {

    UILabel *title = (UILabel *)[self viewWithTag:[self getTitleLabelTag]];
    UILabel *date = (UILabel *)[self viewWithTag:102];
    UIButton *download = (UIButton *)[self viewWithTag:103];
    UILabel *desc = (UILabel *)[self viewWithTag:104];
    UIView *separator = (UIView *)[self viewWithTag:105];
    UILabel *loadMoreLabel = (UILabel *)[self viewWithTag:106];

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(300, 300)];

    date.frame = CGRectMake(date.frame.origin.x, title.frame.origin.y + title.frame.size.height + 8, date.frame.size.width, date.frame.size.height);
    download.frame = CGRectMake(download.frame.origin.x, date.frame.origin.y - 3, download.frame.size.width, download.frame.size.height);
    CGSize descSize = [self frameForText:desc.text sizeWithFont:desc.font constrainedToSize:CGSizeMake(desc.frame.size.width, 100000) lineBreakMode:NSLineBreakByWordWrapping];
    desc.frame = CGRectMake(desc.frame.origin.x, date.frame.origin.y + date.frame.size.height + 8, descSize.width, descSize.height);
    separator.frame = CGRectMake(separator.frame.origin.x, desc.frame.origin.y + desc.frame.size.height + 8, separator.frame.size.width, separator.frame.size.height);
    loadMoreLabel.frame = CGRectMake(loadMoreLabel.frame.origin.x, separator.frame.origin.y + 9, loadMoreLabel.frame.size.width, loadMoreLabel.frame.size.height);

}

- (CGRect) getVideoIconRect {
    
    return CGRectMake(110, 60, 93, 93);
    
}

@end
