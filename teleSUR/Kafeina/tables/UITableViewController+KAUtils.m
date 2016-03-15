//
//  UITableViewController+Utils.m
//  Globovision
//
//  Created by Simkin on 09/09/15.
//  Copyright (c) 2015 Demos. All rights reserved.
//

#import "UITableViewController+KAUtils.h"

@implementation UITableViewController (KAUtils)






- (UITableViewCell *)getReuseCell:(UITableView *)tableView withID:(NSString *)cellID {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    return cell == nil ? (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil] lastObject] : cell;
}

- (void)showLoader:(BOOL)show {
    UIView *view = [self.view viewWithTag:1234];
    UIActivityIndicatorView *spinner = [self.view viewWithTag:1235];
    if ( !view ) {
        view = [[UIView alloc] initWithFrame:self.view.frame];
        view.tag = 1234;
        view.backgroundColor = [UIColor clearColor];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [spinner setColor:[UIColor redColor]];
        spinner.frame = CGRectMake((view.frame.size.width - spinner.frame.size.width) * 0.5, (view.frame.size.height - spinner.frame.size.height) * 0.5, spinner.frame.size.width, spinner.frame.size.height);
        spinner.tag = 1235;
        [self.view addSubview:view];
        [view addSubview:spinner];
    }
    if ( show ) {
        [spinner startAnimating];
    } else {
        [spinner stopAnimating];
    }
    if ( show ) {
//        self.tableView.alpha = 0.0;
        view.alpha =1.0;
    } else {
        [UIView animateWithDuration:0.5 delay:0.0 options: UIViewAnimationCurveEaseOut animations:^{
//            self.tableView.alpha = 1.0;
            view.alpha = 0.0;
        } completion:nil];
    }
}



@end