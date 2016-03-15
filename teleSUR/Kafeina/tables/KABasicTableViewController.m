//
//  KABasicTableViewController.m
//  La Jornada
//
//  Created by Simkin on 06/10/15.
//  Copyright © 2015 La Jornada. All rights reserved.
//

#import "KABasicTableViewController.h"

@implementation KABasicTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setupRefreshControl];
}





























#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableItems count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (UITableViewCell *)[self configureCell:(UIView *)[self getReuseCell:tableView withID:[self getCellIDForIndex:indexPath]] forIndexPath:indexPath];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCellImage:cell forIndexPath:indexPath];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KABasicCellData *data = [tableItems objectAtIndex:indexPath.row];
    if ( !CGSizeEqualToSize(CGSizeZero, data.cellSize) ) {
        return data.cellSize.height;
    } else if ( data.images && [data.images count] != 0 ) {
        return [self getDefaultImageTableCellHeight];
    }
    return [self getDefaultTableCellHeight];
}










- (UIView *) configureCell:(UIView *)cell forIndexPath:(NSIndexPath *)indexPath {
    return [self configureCell:cell withData:[tableItems objectAtIndex:indexPath.row]];
}

- (UIView *) configureCell:(UIView *)cell withData:(KABasicCellData *)data {
    UILabel *title = (UILabel *)[cell viewWithTag:10001];
    UILabel *summary = (UILabel *)[cell viewWithTag:10002];
    title.text = data.title;
    summary.text = data.summary;
    cell.userInteractionEnabled = !data.cancelUserInteraction;
    return cell;
}

- (void) configureCellImage:(UIView *)cell forIndexPath:(NSIndexPath *)indexPath {
    [self configureCellImage:cell withData:[tableItems objectAtIndex:indexPath.row]];
}

- (void) configureCellImage:(UIView *)cell withData:(KABasicCellData *)data {
    UIImageView *imageVW = (UIImageView *)[cell viewWithTag:9000];
    [self configureImageVW:imageVW withData:data];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGRect maskRect = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
    maskLayer.path = path;
    CGPathRelease(path);
    imageVW.layer.mask = maskLayer;
}

- (void) configureImageVW:(UIImageView *)imageVW withData:(KABasicCellData *)data {
    if ( !imageVW ) {
        return;
    }
    if ( data.images && [data.images count] != 0 ) {
        KABasicImageData *imageData = [data.images objectAtIndex:[data.images count] - 1];
        if ( imageData && imageData.thumbURL ) {
            imageVW.clipsToBounds = YES;
            [imageVW sd_setImageWithURL:[NSURL URLWithString:imageData.thumbURL]
                       placeholderImage:[UIImage imageNamed:[self getPlaceholderImageName:data.cellID]]
                                options:SDWebImageRetryFailed | SDWebImageCacheMemoryOnly];
        } else {
            imageVW.image = [UIImage imageNamed:[self getPlaceholderImageName:data.cellID]];
        }
    } else {
        imageVW.image = [UIImage imageNamed:[self getPlaceholderImageName:data.cellID]];
    }
}


- (NSString *) getPlaceholderImageName:(NSString *)cellID {
    return @"SinImagen.png";
}

- (NSString *) getCellIDForIndex:(NSIndexPath *)indexPath {
    KABasicCellData *data = [tableItems objectAtIndex:indexPath.row];
    if ( data.cellID ) {
        return data.cellID;
    }
    if ( data.images && [data.images count] > 0 ) {
        return [self getDefaultImageTableCellID];
    }
    return [self getDefaultTableCellID];
}

- (NSString *) getDefaultTableCellID {
    return @"KABasicTableCellView";
}

- (NSString *) getDefaultImageTableCellID {
    return @"KABasicTableCellView";
}

- (float) getDefaultTableCellHeight {
    return 34;
}

- (float) getDefaultImageTableCellHeight {
    return 200;
}

- (void) didSelectRowWithData:(KABasicCellData *)item {
    NSLog(@"didSelectRowWithData:%@", item);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath == selectedIndex ) {
        return;
    }
    selectedIndex = indexPath;
    [self didSelectRowWithData:[tableItems objectAtIndex:indexPath.row]];
}

- (void) setupRefreshControl {
    refresh = (UIRefreshControl *)[super.view viewWithTag:2010];
    if ( refresh ) {
        [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void) refresh:(UIRefreshControl *)sender {
    [self loadData];
}

- (void) loadData {}

@end
