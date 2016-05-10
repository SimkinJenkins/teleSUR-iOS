//
//  KABasicHTableViewController.h
//  La Jornada
//
//  Created by Simkin on 09/10/15.
//  Copyright © 2015 La Jornada. All rights reserved.
//

#import "KABasicTableViewController.h"

#import "KABasicHCellData.h"
#import "KAQueueLoaderTableViewController.h"
#import "EasyTableView.h"

@interface KABasicHTableViewController : KAQueueLoaderTableViewController <EasyTableViewDelegate> {

    @protected
        NSMutableArray *htables;

}


- (UITableViewCell *) setHTableAtCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath withID:(NSString *)cellID;
- (BOOL) isTableItemHCellAtIndex:(NSIndexPath *)indexPath;
- (NSString *) getHTableCellViewID;
- (KABasicHCellData *) getDataForHTable:(EasyTableView *)tableView;



@end