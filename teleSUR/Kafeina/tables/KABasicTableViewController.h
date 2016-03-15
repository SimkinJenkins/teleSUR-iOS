//
//  KABasicTableViewController.h
//  La Jornada
//
//  Created by Simkin on 06/10/15.
//  Copyright © 2015 La Jornada. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UITableViewController+KAUtils.h"
#import "KABasicCellData.h"

#import "UIImageView+WebCache.h"

@interface KABasicTableViewController : UITableViewController {

    @protected
        NSMutableArray *tableItems;
        NSIndexPath *selectedIndex;
        UIRefreshControl *refresh;

}

- (UIView *) configureCell:(UIView *)cell forIndexPath:(NSIndexPath *)indexPath;
- (UIView *) configureCell:(UIView *)cell withData:(KABasicCellData *)data;

- (void) configureCellImage:(UIView *)cell forIndexPath:(NSIndexPath *)indexPath;
- (void) configureCellImage:(UIView *)cell withData:(KABasicCellData *)data;

- (void) configureImageVW:(UIImageView *)imageVW withData:(KABasicCellData *)data;

- (NSString *) getCellIDForIndex:(NSIndexPath *)indexPath;
- (NSString *) getPlaceholderImageName:(NSString *)cellID;
- (NSString *) getDefaultTableCellID;

- (void) didSelectRowWithData:(KABasicCellData *)item;

- (float) getDefaultTableCellHeight;
- (float) getDefaultImageTableCellHeight;

- (void) setupRefreshControl;
- (void) refresh:(UIRefreshControl *)sender;
- (void) loadData;

@end