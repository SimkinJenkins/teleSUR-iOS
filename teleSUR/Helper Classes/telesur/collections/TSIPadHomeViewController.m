//
//  TSIPadHomeViewController.m
//  teleSUR
//
//  Created by Simkin on 23/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSIPadHomeViewController.h"
#import "TSIpadNavigationViewController.h"
#import "TSIPadRSSDetailViewController.h"
#import "TSIPadVideoDetailViewController.h"

#import "MWFeedItem.h"
#import "DefaultCollectionReusableView.h"
#import "UIImageView+WebCache.h"

#import "TSDataRequest.h"
#import "TSDataManager.h"
#import "UIViewController+TSLoader.h"

#import "TSWebViewController.h"
#import "MarqueeLabel.h"

NSString* const HOME_FIRST_CELL_REUSE_ID = @"NewsFirstCollectionCell";
NSString* const HOME_DEFAULT_CELL_REUSE_ID = @"NewsDefaultCollectionCell";

@implementation TSIPadHomeViewController







#pragma mark - View lifecycle

- (void)viewDidLoad {

    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

    [super viewDidLoad];

    currentOrientation = [[ UIApplication sharedApplication ] statusBarOrientation];

    NSString *APPType = [ [ [ [ NSBundle mainBundle ] infoDictionary ] valueForKey:@"Configuración" ] valueForKey:@"APPtype" ];
    if ( [ APPType isEqualToString:@"multimedia" ] ) {
        return;
    }

    [self setSection:[self getHomeSection]];

    self.collectionView = (UICollectionView *)[self.view viewWithTag:101];

    [self.collectionView registerNib:[UINib nibWithNibName:HOME_FIRST_CELL_REUSE_ID bundle:nil] forCellWithReuseIdentifier:HOME_FIRST_CELL_REUSE_ID];
    [self.collectionView registerNib:[UINib nibWithNibName:HOME_DEFAULT_CELL_REUSE_ID bundle:nil] forCellWithReuseIdentifier:HOME_DEFAULT_CELL_REUSE_ID];

    [self configureCollectionLayout];

    [self configRightButton];

}

- (void) viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [[NavigationBarsManager sharedInstance] setMasterView:[ [ self.view superview] superview] ];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

}

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    if( currentOrientation != [[ UIApplication sharedApplication ] statusBarOrientation] ) {

        [self deviceOrientationDidChangeNotification:nil];

    }

    if ( isNotificationWebViewLastView ) {

        isNotificationWebViewLastView = NO;
        [(TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance setNavigationItemsHidden:NO];

    }

}

- (void) viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

}



















#pragma mark - Custom Public Functions

- (void)loadData {

    [self showLoaderWithAnimation:YES cancelUserInteraction:cancelUserInteraction withInitialView:isAnInitialScreen];

    [self loadHomeData];

}

- (void) loadHomeData {

    if ( ![self isAPIHostAvailable] ) {
        return;
    }

    TSDataRequest *clipCatReq = [[TSDataRequest alloc] initWithType:TS_TIPO_CLIP_SLUG  forSection:nil               forSubsection:nil];
    TSDataRequest *RSSReq     = [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG   forSection:@"noticias"       forSubsection:nil];
    TSDataRequest *videoReq   = [[TSDataRequest alloc] initWithType:TS_CLIP_SLUG       forSection:@"video-noticia"  forSubsection:@""];
    TSDataRequest *showReq    = [[TSDataRequest alloc] initWithType:TS_CLIP_SLUG       forSection:@"programa"       forSubsection:@""];
    TSDataRequest *infoReq    = [[TSDataRequest alloc] initWithType:TS_CLIP_SLUG       forSection:@"infografia"     forSubsection:@""];
    TSDataRequest *breaknewsReq = [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG forSection:@"noticias"       forSubsection:@"ultimas"];

    clipCatReq.range = NSMakeRange(1, 300);
    videoReq.range = NSMakeRange(1, 1);
    showReq.range = NSMakeRange(1, 1);
    infoReq.range = NSMakeRange(1, 1);

    [[[TSDataManager alloc] init] loadRequests:[NSArray arrayWithObjects:clipCatReq, RSSReq, videoReq, showReq, infoReq, breaknewsReq, nil]
                            delegateResponseTo:self];

}

- (void) handleTSConnectionError {

    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;

    [super handleTSConnectionError];

}

- (void)showNotificationPost:(MWFeedItem *)post {

    [self showPost:post inSection:@"noticias" andSubsection:[self getNotificationSubsection]];

}

- (void) showUnlocatedNotification:(NSString *)URL {

    [super showUnlocatedNotification:URL];

    [(TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance setNavigationItemsHidden:YES];

}


















#pragma mark - Custom Functions

- (void) configureCollectionLayout {

    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;

    layout.blockPixels = CGSizeMake(255, UIInterfaceOrientationIsLandscape(currentOrientation) ? 191 : 208 );

//    self.collectionView.frame = CGRectMake(0, 60, self.collectionView.frame.size.width, self.collectionView.frame.size.height - 60);

}

- (NSString *) getHomeSection {

    NSArray *sections = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"principalMenuSections"];
    NSMutableArray *sectionsAllOptions = [NSMutableArray array];
    for (uint i = 0; i < [sections count]; i++) {
        NSString *slug = [sections objectAtIndex:i];
        if(![slug isEqualToString:@"buscar"]) {
            [sectionsAllOptions addObject:slug];
        }
    }
    NSString *home = [sectionsAllOptions objectAtIndex:0];
    currentSection = home;
    return home;

}

- (void) setSection:(NSString *)slug {

    TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;
    [topMenu setCurrentSection:slug];

}

- (void) liveStreamMenuButtonSelect {

    ((UIView *)[self.view viewWithTag:300]).hidden = !((UIView *)[self.view viewWithTag:300]).hidden;

}

- (NSString *) getSection:(NSInteger)index {

    BOOL isLandscape = UIInterfaceOrientationIsLandscape(currentOrientation);

    if( ( index == 1 && isLandscape ) || ( index == 4 && !isLandscape ) ) {
        return @"programa";
    } else if ( ( index == 2 && isLandscape ) || ( index == 5 && !isLandscape ) ) {
        return @"video-noticia";
    } else if( index == 6 ) {
        return @"infografia";
    }

    return @"noticias";

}

- (void) showPostAtIndex:(NSIndexPath *)indexPath {

    MWFeedItem *item = [ [ self getDataArrayForIndexPath:selectedIndexPath forDefaultTable:YES ] objectAtIndex:selectedIndexPath.row];
    [self showPost:item inSection:[self getSection:indexPath.row ] andSubsection:currentSubsection];

}

- (void) showPost:(MWFeedItem *)item inSection:(NSString *)section andSubsection:(NSString *)subsection {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle: nil];
    
    TSIPadRSSDetailViewController *vc = [[mainStoryboard instantiateViewControllerWithIdentifier:@"TSIPadRSSDetailViewController"]
                                         initWithRSSData:item inSection:section andSubsection:subsection];
    
    [self.navigationController pushViewController:vc animated:YES];

}

- (void) playSelectedClip:(NSInteger)index {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle: nil];

    NSDictionary *item = [ [ self getDataArrayForIndexPath:selectedIndexPath forDefaultTable:YES ] objectAtIndex:selectedIndexPath.row];

    TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;

    if ( topMenu.topView && ((TSIPadVideoDetailViewController *)topMenu.topView).isLiveStream ) {
        [((TSIPadVideoDetailViewController *)topMenu.topView) removeCurrentPlayer];
        topMenu.topView = nil;
    }
    if ( topMenu.topView ) {
        [((TSIPadVideoDetailViewController *)topMenu.topView) setData:item withSection:[self getSection:index]];
    } else {
        TSIPadVideoDetailViewController *vc = [[mainStoryboard instantiateViewControllerWithIdentifier:@"TSIPadVideoDetailViewController"]
                                               initWithVideoData:item
                                               inSection:[self getSection:index]];
        [topMenu addTopViewController:vc];
    }

}

- (void) deviceOrientationDidChangeNotification:(NSNotification *)notification {

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown) {
        return;
    }

    currentOrientation = [[ UIApplication sharedApplication ] statusBarOrientation];

    if ( ![currentData count] ) {
        return;
    }

    [self configureCollectionLayout];

    [self setColletionData:currentData];

}

- (void) setColletionData:(NSArray *)requests {

    TSDataRequest *RSSRequest = [requests objectAtIndex:1];
    TSDataRequest *videoRequest = [requests objectAtIndex:2];
    TSDataRequest *showRequest = [requests objectAtIndex:3];
    TSDataRequest *infoRequest = [requests objectAtIndex:4];
    TSDataRequest *breakNewsRequest = [requests objectAtIndex:5];
    
    tableElements = [ NSMutableArray arrayWithArray:[ RSSRequest.result subarrayWithRange:NSMakeRange(0, 1) ] ];

    currentHeaderData = [NSArray arrayWithArray:breakNewsRequest.result];

    if (  UIInterfaceOrientationIsLandscape( currentOrientation ) ) {
        
        [ tableElements addObjectsFromArray: showRequest.result ];
        [ tableElements addObjectsFromArray: videoRequest.result ];
        [ tableElements addObjectsFromArray: [ RSSRequest.result subarrayWithRange:NSMakeRange(1, 3) ] ];
        [ tableElements addObjectsFromArray: infoRequest.result ];
        
    } else {
        
        [ tableElements addObjectsFromArray: [ RSSRequest.result subarrayWithRange:NSMakeRange(1, 3) ] ];
        [ tableElements addObjectsFromArray: showRequest.result ];
        [ tableElements addObjectsFromArray: videoRequest.result ];
        [ tableElements addObjectsFromArray: infoRequest.result ];
        
    }

    [self.collectionView reloadData];

    [self setupHeader];

}

- (void) configRightButton {

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"refresh.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(refreshButtonClicked)];

}

- (void) refreshButtonClicked {

    [self initTableVariables];
    [self loadData];

}



















#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return MIN([tableElements count], 7);

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellID = indexPath.row == 0 ? HOME_FIRST_CELL_REUSE_ID : HOME_DEFAULT_CELL_REUSE_ID;
    UICollectionViewCell *cell = (UICollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell = cell == nil ? (UICollectionViewCell *)[[[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil] lastObject] : cell;

    [cell viewWithTag:100].frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    [cell viewWithTag:100].superview.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);

    [((DefaultCollectionReusableView *)cell) setData:[tableElements objectAtIndex:indexPath.row]];

    [(UIImageView *)[cell viewWithTag:101] sd_setImageWithURL:[ self getThumbURLForIndex:indexPath
                                                                         forceLargeImage:indexPath.row == 0
                                                                         forDefaultTable:YES ]
                                             placeholderImage:[ UIImage imageNamed:@"SinImagen.png" ] ];

    return cell;

}


















#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    selectedIndexPath = indexPath;

    BOOL isRSS = [[tableElements objectAtIndex:indexPath.row] isKindOfClass:[MWFeedItem class]];

    if( isRSS ) {

        [self showPostAtIndex:indexPath];

    } else {

        [self playSelectedClip:indexPath.row];

    }

}



















#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.row == 0) {
        return CGSizeMake(3, 2);
    }
    return CGSizeMake(1, 1);

}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {

    return UIEdgeInsetsMake(9, 5, 3, 5);

}



















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    [super TSDataManager:manager didProcessedRequests:requests];

    TSDataRequest *catalogRequest = [requests objectAtIndex:0];
    [self setCatalog:catalogRequest.result forKey:catalogRequest.type];

    [self setColletionData:requests];

    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;

}








- (void)setupHeader {

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frameRect	= CGRectMake(0, -60, screenRect.size.width, 60);

    if ( breakingNewsMarquee ) {
        breakingNewsMarquee.frame = frameRect;
        return;
    }

    breakingNewsMarquee = [[MarqueeLabel alloc] initWithFrame:frameRect duration:8.0 andFadeLength:10.0f];
    breakingNewsMarquee.backgroundColor = [UIColor blackColor];
    breakingNewsMarquee.textColor = [UIColor whiteColor];
    NSString *text = [NSString stringWithFormat:@"    %@: ", NSLocalizedString(@"ultimasSection", nil)];

    [self.view addSubview:breakingNewsMarquee];

    if ( !currentHeaderData || [currentHeaderData count] == 0 ) {
        breakingNewsMarquee.text = text;
        return;
    }

    for ( int i = 0; i < [currentHeaderData count]; i++ ) {
        MWFeedItem *rowData = [currentHeaderData objectAtIndex:i];
        text = [ NSString stringWithFormat:@"%@%@%@%@", text, i != 0 ? @"   |   " : @"", rowData.title, i == [currentHeaderData count] - 1 ? @"    " : @"" ];
    }

    breakingNewsMarquee.text = text;

    breakingNewsMarquee.scrollDuration = text.length / 4.0;
    breakingNewsMarquee.textAlignment = NSTextAlignmentRight;

}



















#pragma mark -
#pragma mark EasyTableViewDelegate

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {
    
    UITableViewCell *cell = [self getReuseCell:easyTableView.tableView withID:@"IpadBreakingNewsTableViewCell"];
    return cell.contentView;
    
}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath*)indexPath {

    [self configureHeaderCellView:view withData:[currentHeaderData objectAtIndex:indexPath.row]];

}

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView {}

- (void) configureHeaderCellView:(UIView *)view withData:(NSDictionary *)data {

    UILabelMarginSet *title = (UILabelMarginSet *)[view viewWithTag:1];

    [view setData:data];

    [view adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(250, 60)];

    title.frame = CGRectMake(title.frame.origin.x, ((60 - title.frame.size.height) * 0.5) + 0, title.frame.size.width, title.frame.size.height);

}

@end