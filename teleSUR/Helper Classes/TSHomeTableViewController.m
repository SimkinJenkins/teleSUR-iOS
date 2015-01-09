//
//  TSHomeTableViewController.m
//  teleSUR
//
//  Created by Simkin on 28/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSHomeTableViewController.h"
#import "DefaultTableViewCell.h"
#import "MWFeedItem.h"
#import "UILabelMarginSet.h"
#import "UIImageView+WebCache.h"
#import "UIViewController_Configuracion.h"

#import "TSDataRequest.h"
#import "TSDataManager.h"
#import "HiddenVideoPlayerController.h"
#import "TSClipDetallesViewController.h"
#import "UIViewController+TSLoader.h"

#import "UIView+TSBasicCell.h"

@implementation TSHomeTableViewController

- (void) initViewVariables {

    [super initViewVariables];
    defaultDataResultIndex = 1;

}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.navigationController.navigationBarHidden = YES;
    self.tableViewController.tableView.hidden = YES;

    if( [currentSection isEqualToString:@"home"]) {

        [self changeTableViewConfiguration];

    } else {

        [self configTopMenuWithCurrentConfiguration];

    }

    cancelNextHideLoader = NO;

}

- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

}
















#pragma mark - Custom Public Functions

- (void) loadHomeData {

    if ( ![self isAPIHostAvailable] ) {
        return;
    }

    TSDataRequest *clipCatReq = [[TSDataRequest alloc] initWithType:TS_TIPO_CLIP_SLUG  forSection:nil               forSubsection:nil];
    TSDataRequest *showCatReq = [[TSDataRequest alloc] initWithType:TS_PROGRAMA_SLUG   forSection:nil               forSubsection:nil];
    TSDataRequest *RSSReq     = [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG   forSection:@"noticias"       forSubsection:nil];
    TSDataRequest *videoReq   = [[TSDataRequest alloc] initWithType:TS_CLIP_SLUG       forSection:@"video-noticia"  forSubsection:@""];
    TSDataRequest *showReq    = [[TSDataRequest alloc] initWithType:TS_CLIP_SLUG       forSection:@"programa"       forSubsection:@""];

    clipCatReq.range = NSMakeRange(1, 300);
    showCatReq.range = NSMakeRange(1, 300);
    videoReq.range = NSMakeRange(1, TS_HOME_CLIPS_PER_PAGE);
    showReq.range = NSMakeRange(1, TS_HOME_CLIPS_PER_PAGE);

    [[[TSDataManager alloc] init] loadRequests:[NSArray arrayWithObjects:clipCatReq, showCatReq, RSSReq, videoReq, showReq, nil]
                            delegateResponseTo:self];

}

- (void) homeDataDidLoad {

    if ( horizontalView ) {
        [horizontalView removeFromSuperview];
        horizontalView = nil;
    }

    [self setupHorizontalView];
    [self showHeaderTable];
    [self hideLoaderWithAnimation:YES];

}

- (NSArray *) getHTableData {
    if ( ![currentData count] ) {
        return [NSArray array];
    }
    return ((TSDataRequest *)[currentData objectAtIndex:0]).result;
}

- (void) initTableVariables {
    
    [super initTableVariables];
    
    [self.tableViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    loadMoreCellDisabled = NO;
    
}

- (void) handleTSConnectionError {

    if( [ currentSection isEqualToString:@"home" ] ) {
        
        [self homeDataDidLoad];
        
    } else {

        [super handleTSConnectionError];

    }
    
    isAnInitialScreen = NO;

}










#pragma mark - Custom Functions

- (void)setupHorizontalView {

    if (horizontalView) {
        [horizontalView.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        return;
    }

	CGRect frameRect	= CGRectMake(0, 0, 320, 200);
	horizontalView = [[EasyTableView alloc] initWithFrame:frameRect numberOfColumns:[[self getHTableData] count] ofWidth:320];
	horizontalView.delegate						= self;
	horizontalView.tableView.backgroundColor	= [UIColor whiteColor];
	horizontalView.tableView.allowsSelection	= YES;
	horizontalView.tableView.separatorColor		= [UIColor clearColor];
    horizontalView.tableView.pagingEnabled      = YES;
	horizontalView.cellBackgroundColor			= [UIColor clearColor];
	[self.view addSubview:horizontalView];

    if( !pageControl ) {
        pageControl = [[UIPageControl alloc] initWithFrame: CGRectMake(frameRect.origin.x, frameRect.origin.y + frameRect.size.height - 25, frameRect.size.width, 20)];
    }

    pageControl.numberOfPages = [[self getHTableData] count];
    pageControl.currentPage = 0;
    pageControl.hidden = NO;
    pageControl.enabled = NO;
    [self.view addSubview:pageControl];

    [self configTopMenuWithCurrentConfiguration];

}

- (void)changeTableViewConfiguration {

    originTableFrame = CGRectMake(self.tableViewController.tableView.frame.origin.x, self.tableViewController.tableView.frame.origin.y, self.tableViewController.tableView.frame.size.width, self.tableViewController.tableView.frame.size.height);
    CGRect tableFrame = self.tableViewController.tableView.frame;
    tableFrame.origin.y = 200;
    tableFrame.size.height = originTableFrame.size.height - 200;
    self.tableViewController.tableView.frame = tableFrame;
    withHeaderTableFrame = self.tableViewController.tableView.frame;

}

- (void) showHeaderTable {
    horizontalView.hidden = NO;
    pageControl.hidden = NO;
    self.tableViewController.tableView.frame = withHeaderTableFrame;
}

- (void) hideHeaderTable {
    horizontalView.hidden = YES;
    pageControl.hidden = YES;
    self.tableViewController.tableView.frame = originTableFrame;
}

- (void) sectionSelected:(NSString *)section withTitle:(NSString *)title {
    [super sectionSelected:section withTitle:title];
    if(![section isEqualToString:@"home"] && horizontalView) {
        [self hideHeaderTable];
    }
}

















#pragma mark -
#pragma mark EasyTableViewDelegate

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {

    UITableViewCell *cell = [self getReuseCell:easyTableView.tableView withID:@"HomeTopTableViewCell"];
	return cell.contentView;

}

- (void) configureView:(UIView *)view withData:(NSDictionary *)data {

    UILabelMarginSet *title = (UILabelMarginSet *)[view viewWithTag:1];
    UILabelMarginSet *section = (UILabelMarginSet *)[view viewWithTag:3];

    [view setData:data];

    [view adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(300, 80)];

    title.frame = CGRectMake(title.frame.origin.x, view.frame.size.height - title.frame.size.height - 30, title.frame.size.width, title.frame.size.height);

    [view sizeToFitRedBackgroundLabel:section];

    section.frame = CGRectMake(section.frame.origin.x, title.frame.origin.y - section.frame.size.height, section.frame.size.width, section.frame.size.height);

}

- (void)easyTableView:(EasyTableView *)easyTableView scrolledToFraction:(CGFloat)fraction {
    pageControl.currentPage = round(fraction * ([[self getHTableData] count] - 1));
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath*)indexPath {

    [self configureView:view withData:[[self getHTableData] objectAtIndex:indexPath.row]];

    [(UIImageView *)[view viewWithTag:2] sd_setImageWithURL:[self getThumbURLForIndex:indexPath
                                                                      forceLargeImage:NO
                                                                      forDefaultTable:NO]
                                           placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];

}

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView {

    selectedIndexPath = indexPath;

    if (selectedIndexPath.row < [[self getHTableData] count] || loadMoreCellDisabled) {// Se trata de un video
        self.headerMenu.hidden = YES;
        [self showSelectedPost:[[self getHTableData] objectAtIndex:indexPath.row]];
    }

}


























#pragma mark - Custom Public Functions

- (void)loadData {

    [self showLoaderWithAnimation:YES cancelUserInteraction:cancelUserInteraction withInitialView:isAnInitialScreen];

    if ( [currentSection isEqualToString:@"home"] ) {

        defaultDataResultIndex = 1;
        [self loadHomeData];

    } else {

        defaultDataResultIndex = 0;
        [self loadCurrentSectionData];

    }

}

- (NSString *)getIDForCellAtIndexPath:(NSIndexPath *)indexPath {

    if ([currentSection isEqualToString:@"home"]) {

     return @"HomeVideoTableViewCell";

    }

    return [super getIDForCellAtIndexPath:indexPath];
    
}

- (NSArray *) getDataArrayForIndexPath:(NSIndexPath *)indexPath forDefaultTable:(BOOL)defaultTable {

    if ( !defaultTable ) {

        return [self getHTableData];

    } else if ( indexPath.section == 1 ) {

        return secondSectionElements;

    }

    return [ super getDataArrayForIndexPath:indexPath forDefaultTable:defaultTable ];

}













#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ( section == 1) {
        return secondSectionElements ? [secondSectionElements count] : 0;
    }

    return [super tableView:tableView numberOfRowsInSection:section];

}




























- (void)hideLoaderWithAnimation:(BOOL)animation {

    if ( ![ currentSection isEqualToString:@"buscar" ] ) {

        self.navigationController.navigationBarHidden = NO;

    }

    self.tableViewController.tableView.hidden = NO;

    if (animation) {
        [UIView beginAnimations:@"showHorizontalTable" context:nil];
        horizontalView.alpha = 1.0;
        [UIView commitAnimations];
    } else {
        horizontalView.alpha = 1.0;
    }
    
    [super hideLoaderWithAnimation:animation];

}

- (void)showLoaderWithAnimation:(BOOL)animation cancelUserInteraction:(BOOL)userInteraction withInitialView:(BOOL)initial {

    if (animation) {
        [UIView beginAnimations:@"hideHorizontalTable" context:nil];
        horizontalView.alpha = 0.3;
        [UIView commitAnimations];
    } else {
        horizontalView.alpha = 0.3;
    }

    [super showLoaderWithAnimation:animation cancelUserInteraction:userInteraction withInitialView:initial];
}
















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    uint dataIndex = 0;
    if( [requests count] > 2 ) {
        for( uint i = 0; i < 2; i++ ) {
            TSDataRequest *catalogRequest = [requests objectAtIndex:i];
            [self setCatalog:catalogRequest.result forKey:catalogRequest.type];
        }
        dataIndex = 2;
        secondSectionElements = [NSMutableArray arrayWithArray:((TSDataRequest *)[requests objectAtIndex:[requests count] - 1]).result];
    }

    [super TSDataManager:manager didProcessedRequests:[requests subarrayWithRange:NSMakeRange(dataIndex, [ requests count ] - dataIndex)]];

    if( [ currentSection isEqualToString:@"home" ] ) {

        [self homeDataDidLoad];

    }

    isAnInitialScreen = NO;

}






@end