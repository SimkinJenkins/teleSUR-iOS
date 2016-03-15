//
//  UITableViewController+Utils.h
//  Globovision
//
//  Created by Simkin on 09/09/15.
//  Copyright (c) 2015 Demos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewController (KAUtils)

- (UITableViewCell *) getReuseCell:(UITableView *)tableView withID:(NSString *)cellID;
- (void)showLoader:(BOOL)show;

@end