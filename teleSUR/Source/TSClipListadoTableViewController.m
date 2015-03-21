//
//  TSClipListadoTableViewController.m
//  teleSUR
//
//  Created by David Regla on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSClipListadoTableViewController.h"
#import "TSClipPlayerViewController.h"
#import "TSClipDetallesViewController.h"
#import "NSDate_Utilidad.h"
#import "UILabelMarginSet.h"
#import "HiddenVideoPlayerController.h"
#import "SlideNavigationController.h"
#import "MWFeedItem.h"
#import "TSNewsViewController.h"
#import "DefaultTableViewCell.h"
#import "UIImageView+WebCache.h"


#import "UIViewController+TSLoader.h"
#import "NavigationBarsManager.h"
#import "SlideNavigationController.h"

#define kTHUMBNAIL_IMAGE_VIEW_TAG 2

@implementation TSClipListadoTableViewController

@synthesize tableViewController;

#pragma mark - View lifecycle

- (void) loadView {

    [super loadView];

    if(self.tableViewController == nil) {
        [self createControllerFromNib];
    }

}

- (void)createControllerFromNib {

    [[NSBundle mainBundle] loadNibNamed:@"TSClipListadoTableViewController" owner:self options: nil];

}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self.view addSubview:self.tableViewController.tableView];
    self.tableViewController.tableView.scrollsToTop = YES;

    [self setTableViewConfiguration];
}

- (void)viewWillAppear:(BOOL)animated {
    // Si ya había un clip seleccionado, asegurar que esté marcado 
    if (selectedIndexPath && animated) {
        [self.tableViewController.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    // Si ya había un clip seleccionado, desmarcarlo con animación
    if (selectedIndexPath && animated) {
        [self.tableViewController.tableView deselectRowAtIndexPath:selectedIndexPath animated:animated];
    }

}


















#pragma mark - Custom Public Functions

- (void)playSelectedClip:(NSIndexPath *)indexPath {
    
    if(((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying) {
        ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying = NO;
        [((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).currentPlayer.moviePlayer stop];
        [((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).currentPlayer.view removeFromSuperview];
        ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).currentPlayer = nil;
    }

    NSDictionary *item = [ [ self getDataArrayForIndexPath:indexPath forDefaultTable:YES ] objectAtIndex:indexPath.row];

    if ( [SlideNavigationController sharedInstance].topView ) {
        [((TSClipDetallesViewController *)[SlideNavigationController sharedInstance].topView) setData:item andSection:[self getSectionTitleWith:currentSection]];
    } else {
        TSClipDetallesViewController *detailView = [[TSClipDetallesViewController alloc] initWithData:item andSection:[self getSectionTitleWith:currentSection]];
        [[SlideNavigationController sharedInstance] addTopViewController:detailView];
    }

}

- (void)showSelectedPost:(MWFeedItem *)post {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];

    TSNewsViewController *detailView = [mainStoryboard instantiateViewControllerWithIdentifier: @"TSNewsViewController"];

    [detailView initWithData:post];
    [self.navigationController pushViewController:detailView animated:YES];

}

- (NSString *)getIDForCellAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {

        return @"FirstTableCellView";

    } else if (indexPath.row == [tableElements count]) {

        return @"VerMasClipsTableCellView";

    }

    return @"ClipEstandarTableCellView";
    
}

- (void)configureImageInCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath forceLargeImage:(BOOL)largeImage {

    [(UIImageView *)[cell viewWithTag:kTHUMBNAIL_IMAGE_VIEW_TAG] sd_setImageWithURL:[ self getThumbURLForIndex:indexPath
                                                                                               forceLargeImage:indexPath.row == 0
                                                                                               forDefaultTable:YES ]
                                                                   placeholderImage:[ UIImage imageNamed:@"SinImagen.png" ] ];

}














#pragma mark - Custom Functions

- (void)setTableViewConfiguration {

    self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    CGRect tableFrame = self.tableViewController.tableView.frame;
    CGRect navRect = self.navigationController.navigationBar.frame;
    tableFrame.size.height -= navRect.size.height + 20;
    self.tableViewController.tableView.frame = tableFrame;

    NSLog(@"%@", NSStringFromCGRect(self.tableViewController.tableView.frame));

    self.tableViewController.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
}

- (void)liveAudioEnd:(NSNotification *)notification {
    
    [self playSelectedClip:selectedIndexPath];
    
}



















#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ( [currentData count] == 0 || section > 0 ) {
        return 0;
    }

    return [tableElements count] + ( loadMoreCellDisabled ? 0 : 1 );

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *nombreNib = [self getIDForCellAtIndexPath:indexPath];
    UITableViewCell *cell = [self getReuseCell:tableView withID:nombreNib];

    // Si estamos en la última fila, entonces devolver celda para "Ver más"
    if ([nombreNib isEqualToString:@"VerMasClipsTableCellView"] || [tableElements count] == 0) {
        return cell;
    }

    NSDictionary *item = [ [ self getDataArrayForIndexPath:indexPath forDefaultTable:YES ] objectAtIndex:indexPath.row];

    [ ((DefaultTableViewCell *)cell) setData:item];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if ( (indexPath.row != [tableElements count] || loadMoreCellDisabled ) && indexPath.row < [tableElements count] ) {

        [self configureImageInCell:cell forRowAtIndexPath:indexPath forceLargeImage:NO];

    }

}















#pragma mark -
#pragma mark Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat *cacheVar;

    if([currentSection isEqualToString:@"home"])            cacheVar = &homeCellHeight;
    else if (indexPath.row == 0)                            cacheVar = &standardCellHeight;
    else if (indexPath.row < [tableElements count])         cacheVar = &bigCellHeight;
    else if (indexPath.row == [tableElements count])        cacheVar = &loadMoreCellHeight;
    else                                                    cacheVar = nil;

    if (*cacheVar) return *cacheVar;

    UITableViewCell *cell = [ self getReuseCell:tableView withID:[self getIDForCellAtIndexPath:indexPath] ];

    *cacheVar = cell.frame.size.height;

    return *cacheVar;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    selectedIndexPath = indexPath;

    NSArray *elements = [ self getDataArrayForIndexPath:indexPath forDefaultTable:YES ];

    if (selectedIndexPath.row < [elements count] || loadMoreCellDisabled) {

        NSDictionary *clipData = [elements objectAtIndex:indexPath.row];
        BOOL isRSS = [clipData isKindOfClass:[MWFeedItem class]];

        if (isRSS) {

            [self showSelectedPost:(MWFeedItem *)clipData];

        } else {

            [self playSelectedClip:indexPath];

        }

    } else {// Se trata de la celda "Ver Más"

        addAtListEnd = YES;
        [self loadData];

    }

}



















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    [super TSDataManager:manager didProcessedRequests:requests];

    if ( [currentSection isEqualToString:@"home"] || [self isRSSSection:currentSection] || [[self getResultDataAtIndex:defaultDataResultIndex] count] < TS_ITEMS_PER_PAGE) {
        loadMoreCellDisabled = YES;
    }

    [self.tableViewController.tableView reloadData];

}
















#pragma mark -
#pragma mark UIViewController+TSLoader.h

- (void)hideLoaderWithAnimation:(BOOL)animation {

    if (animation) {
        [UIView beginAnimations:@"mostrarTableView" context:nil];
        self.tableViewController.tableView.alpha = 1.0;
        [UIView commitAnimations];
    } else {
        self.tableViewController.tableView.alpha = 1.0;
    }
    
    [super hideLoaderWithAnimation:animation];
}

- (void)showLoaderWithAnimation:(BOOL)animation cancelUserInteraction:(BOOL)userInteraction withInitialView:(BOOL)initial {

    if (animation) {
        [UIView beginAnimations:@"opacarTableView" context:nil];
        self.tableViewController.tableView.alpha = 0.3;
        [UIView commitAnimations];
    } else {
        self.tableViewController.tableView.alpha = 0.3;
    }
    
    [super showLoaderWithAnimation:animation cancelUserInteraction:userInteraction withInitialView:initial];
}







@end