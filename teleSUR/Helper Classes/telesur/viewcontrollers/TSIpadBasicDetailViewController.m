//
//  TSIpadBasicDetailViewController.m
//  teleSUR
//
//  Created by Simkin on 29/12/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSIpadBasicDetailViewController.h"

#import "DefaultIPadTableViewCell.h"
#import "UILabelMarginSet.h"
#import "UIImageView+WebCache.h"

#import "UIViewController+TSLoader.h"
#import "TSIpadNavigationViewController.h"

NSInteger const TS_DETAIL_ASYNC_IMAGE_TAG = 106;

@implementation TSIpadBasicDetailViewController



#pragma mark - View lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];

    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

}

- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

}



















#pragma mark - Custom Functions

- (void) loadData {
    
    [super loadData];
    [self elementsHidden:YES];
    
}

- (void) elementsHidden:(BOOL)hidden {
    
    UILabel *title = (UILabel *)[self.view viewWithTag:1001];
    UILabel *date = (UILabel *)[self.view viewWithTag:112];
    UILabel *download = (UILabel *)[self.view viewWithTag:113];
    UILabel *description = (UILabel *)[self.view viewWithTag:2004];
    UILabelMarginSet *section = (UILabelMarginSet *)[self.view viewWithTag:107];
    UIImageView *image = (UIImageView *)[self.view viewWithTag:TS_DETAIL_ASYNC_IMAGE_TAG];

    title.hidden = hidden;
    date.hidden = hidden;
    description.hidden = hidden;
    download.hidden = hidden;
    section.hidden = hidden;
    image.hidden = hidden;
    
}

- (void) configLeftButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 23, 23);
    [button setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
}

- (void) configRightButton {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"share.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(shareButtonClicked)];
}

- (void) configRefreshRightButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"refresh.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(refreshButtonClicked)];
}

- (void) refreshButtonClicked {
    
    [self initTableVariables];
    [self loadData];
    
}
- (void) shareButtonClicked {}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url {
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    activityController.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    [self presentViewController:activityController animated:YES completion:nil];
    
}

- (void) deviceOrientationDidChangeNotification:(NSNotification *)notification {}

- (void) sendTSConnectionErrorWithWiFiFailure:(BOOL)isWiFiError internetFailure:(BOOL)isInternetError serverFailure:(BOOL)isServerError {

    [super sendTSConnectionErrorWithWiFiFailure:isWiFiError internetFailure:isInternetError serverFailure:isServerError];

    refreshButtonEnabled = YES;

    [self configRefreshRightButton];

}

- (void) handleTSConnectionError {
    
    [self elementsHidden:YES];
    
    [super handleTSConnectionError];
    
}
















#pragma mark -
#pragma mark EasyTableViewDelegate

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {
    
    UITableViewCell *cell = [self getReuseCell:easyTableView.tableView withID:@"RelatedVideoTableViewCell"];
    return cell.contentView;
    
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath*)indexPath {

    [((DefaultIPadTableViewCell *)[view viewWithTag:99]) setData:[tableElements objectAtIndex:indexPath.row]];
    
    // Here we use the new provided setImageWithURL: method to load the web image
    [(UIImageView *)[view viewWithTag:101] sd_setImageWithURL:[self getThumbURLForIndex:indexPath
                                                                        forceLargeImage:NO
                                                                        forDefaultTable:YES]
                                             placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];
    
}



















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    [super TSDataManager:manager didProcessedRequests:requests];

    if ( refreshButtonEnabled ) {

        [self configRefreshRightButton];
        refreshButtonEnabled = NO;

    }

}



















#pragma mark -
#pragma mark UIViewController+TSLoader

- (void) showLoaderWithAnimation:(BOOL)animation cancelUserInteraction:(BOOL)userInteraction withInitialView:(BOOL)initial {
    
    [super showLoaderWithAnimation:animation cancelUserInteraction:userInteraction withInitialView:initial];

    ((TSIpadNavigationViewController *)self.navigationController).menuTxf.enabled = NO;
    ((TSIpadNavigationViewController *)self.navigationController).menuTxf.alpha = 0.7;
    self.navigationItem.rightBarButtonItem.enabled = NO;

}

- (void) hideLoaderWithAnimation:(BOOL)animation {

    [super hideLoaderWithAnimation:animation];

    ((TSIpadNavigationViewController *)self.navigationController).menuTxf.enabled = YES;
    ((TSIpadNavigationViewController *)self.navigationController).menuTxf.alpha = 1.0;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}




@end
