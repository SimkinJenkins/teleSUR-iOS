//
//  TSIPadVideoDetailViewController.m
//  teleSUR
//
//  Created by Simkin on 30/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "TSIPadVideoDetailViewController.h"
#import "UILabelMarginSet.h"
#import "UIViewController_Configuracion.h"
#import "UIImageView+WebCache.h"
#import "DefaultIPadTableViewCell.h"
#import "TSClipPlayerViewController.h"
#import "NSDictionary_Datos.h"
#import "NavigationBarsManager.h"
#import "TSClipDetallesViewController.h"

#import "UIView+TSBasicCell.h"
#import "TSIpadNavigationViewController.h"

#import "TSDataManager.h"
#import "TSDataRequest.h"

NSInteger const TS_VD_DETAIL_VIEW_TAG = 9001;
NSInteger const TS_VD_DETAIL_ASYNC_IMAGE_TAG = 106;

NSInteger const TS_LIST_WIDTH = 346;
NSInteger const VD_SIDE_MARGIN = 30;

NSInteger const TS_DETAIL_VIEW_HEIGHT = 870;

CGFloat const IPAD_VIEW_Y_POSITION = 23;

@implementation TSIPadVideoDetailViewController

@synthesize playerController, player, isLiveStream;

- (id) initWithVideoData:(NSDictionary *)data inSection:(NSString *)section {

    isAnInitialScreen = data == nil;

    if ( data != nil ) {
        [self configLeftButton];
    }

    currentItem = data;
    currentSection = section;
    currentSubsection = @"";

    [self configRightButton];

    return self;

}

- (id) initWithURL:(NSString *)URL andTitle:(NSString *)title {

    isAnInitialScreen = NO;

    liveURL = URL;
    liveURLTitle = title;
    isDownloading = NO;
    isLiveStream = YES;

    catalogs = [NSMutableDictionary dictionary];

    return self;

}


















- (void)viewWillAppear:(BOOL)animated {
/*
    if ( viewStatus == TS_VIEW_STATUS_MINIMIZED ) {
        return;
    }
*/
    [super viewWillAppear:animated];

    [self reset];
    [self showView];

}

- (void) viewDidAppear:(BOOL)animated {
/*
    if ( viewStatus == TS_VIEW_STATUS_MINIMIZED ) {
        return;
    }
*/
    [super viewDidAppear:animated];

    [[NavigationBarsManager sharedInstance] setMasterView:[ [ self.view superview] superview] ];

    [NavigationBarsManager sharedInstance].playerController = self;

}

- (void) viewDidDisappear:(BOOL)animated {
/*
    if ( viewStatus == TS_VIEW_STATUS_MINIMIZED ) {
        return;
    }
*/
    [super viewDidDisappear:animated];

    [self removeCurrentPlayer];

    if ( ![NavigationBarsManager sharedInstance].livestreamON ) {

        [NavigationBarsManager sharedInstance].playerController.playerController = nil;

    }

}

- (void)viewWillDisappear:(BOOL)animated {
/*
    if ( viewStatus == TS_VIEW_STATUS_MINIMIZED ) {
        return;
    }
*/
    [super viewWillDisappear:animated];

    if( isDownloading ) {
        
        [self resetDownloadButton];
        
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.view.autoresizesSubviews = NO;

    minimizeVideoFrame = CGRectMake(0, 0, 300, 210);

    [self configCustomBackground];

    [self.view setBackgroundColor:[UIColor clearColor]];

    [self setVideoPlayerFrame];

    [self setupVideoView];

    if ( !isLiveStream ) {

        [self sectionSelected:currentSection withTitle:[self getSectionTitleWith:currentSection]];

        [self setupCurrentVideoData];

    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:UIApplicationWillEnterForegroundNotification object:nil];

}



















#pragma mark -
#pragma mark Custom Public Functions

- (void) setData:(NSDictionary *)itemData {

    [self restoreView];

    if (currentItem == itemData ) {
        return;
    }

    currentItem = itemData;
    [self initTableVariables];

    [self setupCurrentVideoData];
    [self playVideoFromClip:currentItem];

}

- (void) setData:(NSDictionary *)itemData withSection:(NSString *)section {

    if ( currentSection != section ) {
        currentSection = section;
        [self loadData];
    }
    [self setData:itemData];

}

- (void) setURL:(NSString *)URL andTitle:(NSString *)title {

    [self restoreView];

    currentItem = nil;

    liveURL = URL;
    liveURLTitle = title;
    isLiveStream = YES;

    [self initTableVariables];
    [self removeCurrentPlayer];

}



















- (void)configCustomBackground {
    customBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    customBackground.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:customBackground];
}

- (void)configVideo {

    if ( !playerController ) {
        playerController = [[TSClipPlayerViewController alloc] initWithData:currentItem andSection:[self getSectionTitleWith:currentSection]];
    }

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    [playerController playAtView:self.view withFrame:CGRectMake(0, 0, screenBound.size.width, screenBound.size.width * 0.7) withObserver:self playbackFinish:nil];

}

- (void) sectionSelected:(NSString *)section withTitle:(NSString *)title {

    if(currentSection == section) {
        return;
    }

    currentSection = section;
    currentSubsection = @"";

    [self loadData];

}

- (void)setupRelatedVideoTableView {

    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);

    if (relatedRSSTableView) {
        relatedRSSTableView.numberOfCells = [tableElements count];
        [relatedRSSTableView reloadData];
        currentItem = nil;
        return;
    }

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frameRect	= isLandscape ? CGRectMake( 0, 0, TS_LIST_WIDTH, 745 ) : ( isLiveStream ? CGRectMake( 0, playerFrame.origin.y + playerFrame.size.height, screenRect.size.width, 72 ) : CGRectMake( 0, TS_DETAIL_VIEW_HEIGHT + 11, screenRect.size.width, 120 ) );

    relatedRSSTableView = isLandscape ? [[EasyTableView alloc] initWithFrame:frameRect numberOfRows:[tableElements count] ofHeight:isLiveStream ? 72 : 120]
                                    : [[EasyTableView alloc] initWithFrame:frameRect numberOfColumns:[tableElements count] ofWidth:TS_LIST_WIDTH];

    relatedRSSTableView.delegate						= self;
    relatedRSSTableView.tableView.layer.borderColor     = [UIColor darkGrayColor].CGColor;
    relatedRSSTableView.tableView.layer.borderWidth     = 1.0f;
    relatedRSSTableView.tableView.backgroundColor       = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    relatedRSSTableView.tableView.allowsSelection       = YES;
    relatedRSSTableView.tableView.separatorColor		= [UIColor clearColor];
    relatedRSSTableView.cellBackgroundColor             = [UIColor clearColor];
    //	horizontalView.autoresizingMask                 = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [customBackground addSubview:relatedRSSTableView];

}

- (void) setupVideoView {

    wrapper = [[UIScrollView  alloc] init];

    [wrapper addSubview:[self.view viewWithTag:TS_VD_DETAIL_VIEW_TAG]];
    [customBackground addSubview:wrapper];

    UILabel *title = (UILabel *)[self.view viewWithTag:1001];
    UILabel *date = (UILabel *)[self.view viewWithTag:112];
    UILabel *description = (UILabel *)[self.view viewWithTag:2004];
    UILabelMarginSet *section = (UILabelMarginSet *)[self.view viewWithTag:107];
    UIButton *download = (UIButton *)[self.view viewWithTag:113];

    section.frame = CGRectMake(VD_SIDE_MARGIN, VD_SIDE_MARGIN, 100, section.frame.size.height);
    title.frame = CGRectMake(VD_SIDE_MARGIN, title.frame.origin.y, title.frame.size.width, title.frame.size.height);
    date.frame = CGRectMake(VD_SIDE_MARGIN, date.frame.origin.y, date.frame.size.width, date.frame.size.height);
    description.frame = CGRectMake(VD_SIDE_MARGIN, description.frame.origin.y, description.frame.size.width, description.frame.size.height);

    [section setPersistentBackgroundColor:[UIColor colorWithRed:255/255.0 green:2/255.0 blue:2/255.0 alpha:1.0]];

    section.leftMargin = 10;
    section.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:11];//2e2e2e
    date.font = [UIFont fontWithName:@"Roboto-Bold" size:16];//696969
    description.font = [UIFont fontWithName:@"Roboto-Regular" size:16];//black

    [download removeFromSuperview];
    [download setTitle:NSLocalizedString(@"descarga", nil) forState:UIControlStateNormal];
    download.hidden = YES;
    [download addTarget:self action:@selector(downloadClip:) forControlEvents:UIControlEventTouchUpInside];

    thumb = [[UIImageView alloc] initWithFrame:playerFrame];

}

- (void) setupCurrentVideoData {

    UILabel *title = (UILabel *)[self.view viewWithTag:1001];
    UILabel *date = (UILabel *)[self.view viewWithTag:112];
    UILabel *description = (UILabel *)[self.view viewWithTag:2004];
    UILabelMarginSet *section = (UILabelMarginSet *)[self.view viewWithTag:107];

    date.hidden = NO;
    date.text = [self.view getLongFormatDateFromData:currentItem];

    NSString *clipType = [[currentItem valueForKey:@"tipo"] valueForKey:@"slug"];
    BOOL switchTitles = [clipType isEqualToString:@"programa"];

    section.frame = CGRectMake(VD_SIDE_MARGIN, VD_SIDE_MARGIN, 100, section.frame.size.height);

    if ( [clipType isEqualToString:@"programa"] ) {

        NSDictionary *showData = [currentItem valueForKey:@"programa"];
        if ( [ currentItem valueForKey:@"programa" ] == ( NSString * )[ NSNull null ] ) {
            section.text = [[ currentItem valueForKey:@"titulo" ] uppercaseString];
            NSArray *keys = [[catalogs objectForKey:TS_PROGRAMA_SLUG] objectForKey:@"keys"];
            NSString *slug = [currentItem valueForKey:@"slug"];
            NSInteger showIndex = [keys indexOfObject:slug];
            if ( showIndex < [keys count]) {
                description.text = [[[[ catalogs objectForKey:TS_PROGRAMA_SLUG] objectForKey:@"originalData"] objectAtIndex:showIndex] objectForKey:@"descripcion"];
            } else {
                description.text = @"";
            }
        } else {
            section.text = [[ showData valueForKey:@"nombre"] uppercaseString];
            description.text = [ showData valueForKey:@"descripcion" ];
        }

        title.text = [self.view getLongFormatDateFromData:currentItem];
        date.hidden = YES;

    } else {

        title.text = switchTitles ? @"" : [currentItem valueForKey:@"titulo"];

        NSObject *categoria = [currentItem valueForKey:@"categoria"];

        if(categoria != [NSNull null]) {
            section.text = [[categoria valueForKey:@"nombre"] uppercaseString];
        } else if(switchTitles) {
            section.text = [[currentItem valueForKey:@"titulo"] uppercaseString];
        } else if(clipType) {
            section.text = [[[currentItem valueForKey:@"tipo"] valueForKey:@"nombre"] uppercaseString];
        } else {
            section.text = @"";
        }

        NSLog(@"%@", [currentItem obtenerDescripcion]);
        description.text = [currentItem obtenerDescripcion];

    }

//    description.text = [ NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@", description.text, description.text, description.text, description.text, description.text, description.text, description.text, description.text , description.text, description.text, description.text, description.text];

    [section sizeToFit];
    section.frame = CGRectMake(section.frame.origin.x, section.frame.origin.y, section.frame.size.width + 20, section.frame.size.height + 10);

    [customBackground addSubview:thumb];
    [thumb sd_setImageWithURL:[self getThumbURLFromAPIItem:currentItem forceLargeImage:NO]
             placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];

    [self adjustLabelsSize];

}

- (void) adjustLabelsSize {

    UILabel *title = (UILabel *)[self.view viewWithTag:1001];
    UILabel *date = (UILabel *)[self.view viewWithTag:112];
    UILabel *description = (UILabel *)[self.view viewWithTag:2004];
    UIButton *download = (UIButton *)[self.view viewWithTag:113];
    UILabelMarginSet *section = (UILabelMarginSet *)[self.view viewWithTag:107];

    [self.view adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(playerFrame.size.width - 60, 300)];
    [self.view setLabel:title underView:section withSeparation:2];
    
    [self.view setLabel:date underView:title withSeparation:10];
    
    download.frame = CGRectMake(playerFrame.size.width - 170, date.hidden ? title.frame.origin.y + 7 : date.frame.origin.y - 4, download.frame.size.width, download.frame.size.height);
    
    [self.view adjustSizeFrameForLabel:description constriainedToSize:CGSizeMake(playerFrame.size.width - 60, 300)];
    [self.view setLabel:description underView:date withSeparation:18];

    thumb.frame = playerFrame;

    wrapper.frame = CGRectMake(playerFrame.origin.x, playerFrame.origin.y + playerFrame.size.height, (playerFrame.size.width + VD_SIDE_MARGIN) - 10, UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? 270 : 343);

    wrapper.contentOffset = CGPointMake(0, 0);
    wrapper.contentSize = CGSizeMake(playerFrame.size.width, description.frame.origin.y + description.frame.size.height + VD_SIDE_MARGIN);

}

- (void) playVideoFromClip:(NSDictionary *)clip {

    [self removeCurrentPlayer];

    if ( isLiveStream ) {
        playerController = [[TSClipPlayerViewController alloc] initWithURL:liveURL andTitle:currentSection];
    } else {
        playerController = [[TSClipPlayerViewController alloc] initWithData:clip andSection:[self getSectionTitleWith:currentSection]];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareButtonClicked) name:@"sharedButtonTouched" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minimizeView) name:@"minimizeButtonTouched" object:nil];

    [playerController playAtView:self.view withFrame:playerFrame withObserver:self playbackFinish:@selector(playbackEnd:)];

}

- (void) resumeVideoPlayer {

    [self playVideoFromClip:currentItem];

}

- (void) removeCurrentPlayer {

    if(playerController) {

        [playerController.moviePlayer stop];
        [playerController.view removeFromSuperview];

        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sharedButtonTouched" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"minimizeButtonTouched" object:nil];

        playerController = nil;
    }

}

- (void) playbackEnd:(NSNotification *)notification {}

- (void) setVideoPlayerFrame {

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    playerFrame = UIInterfaceOrientationIsLandscape( [ [ UIApplication sharedApplication ] statusBarOrientation ] )
                                        ? CGRectMake( 346, 0, 678, 475 )
                                        : CGRectMake( 0, 0, screenBound.size.width, screenBound.size.width * 0.7 );

}

- (void) reset {
    
    if( playerController ) {
        [playerController.moviePlayer prepareToPlay];
        [playerController.moviePlayer pause];
    }
    
}

- (void)removeDetailViewController {
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect screenBound = [[UIScreen mainScreen] bounds];
        self.view.frame = CGRectMake(self.view.frame.origin.x, screenBound.size.height, self.view.frame.size.width, self.view.frame.size.height);
        self.view.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        if ( finished ) {

            [self removeCurrentPlayer];
            [self.view removeGestureRecognizer:panRecognizer];
            panRecognizer = nil;

            TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;
            [topMenu removeTopViewController];
            
        }
    }];
}























#pragma mark - Custom Functions

- (void) loadData {

    if ( isLiveStream ) {

        TSDataRequest *showCatReq = [[TSDataRequest alloc] initWithType:TS_PROGRAMA_SLUG    forSection:nil      forSubsection:nil];
        showCatReq.range = NSMakeRange(1, 300);

        [[[TSDataManager alloc] init] loadRequests:[NSArray arrayWithObjects:showCatReq, nil] delegateResponseTo:self];
        
    } else {

        [super loadData];
        
    }

}

- (void) shareButtonClicked {

    NSLog(@"%@", [currentItem objectForKey:@"navegador_url"]);

    [self shareText:[currentItem objectForKey:@"titulo"] andImage:thumb.image andUrl:[ NSURL URLWithString:[currentItem objectForKey:@"navegador_url"] ]];

}

- (void) deviceOrientationDidChangeNotification:(NSNotification *)notification {

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown) {
        return;
    }

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    if ( viewStatus == TS_VIEW_STATUS_MINIMIZED ) {

        [self.view removeGestureRecognizer:panRecognizer];
        panRecognizer = nil;

        TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;
        [topMenu removeTopViewController];

        self.view.frame = CGRectMake(screenBound.size.width - minimizeVideoFrame.size.width - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN, screenBound.size.height - minimizeVideoFrame.size.height - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN - 70, self.view.frame.size.width, self.view.frame.size.height);

        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setTapGestureRecognizer) userInfo:nil repeats:NO];

    } else {
        self.view.frame = CGRectMake(0, IPAD_VIEW_Y_POSITION, self.view.frame.size.width, self.view.frame.size.height);
    }

    customBackground.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    [self setVideoPlayerFrame];

    [relatedRSSTableView removeFromSuperview];
    relatedRSSTableView = nil;

    [self setupRelatedVideoTableView];

    if ( !isLiveStream ) {
        [self adjustLabelsSize];
    }

    if( playerController ) {
        if ( viewStatus == TS_VIEW_STATUS_MINIMIZED ) {
            playerController.view.frame = minimizeVideoFrame;
        } else {
            playerController.view.frame = playerFrame;
        }
        [playerController setPlayerFrame: playerController.view.frame hideMinimizeButton:NO];
    }

    [playerController startTimer];

}

- (void) setTapGestureRecognizer {

    TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;
    [topMenu addTopViewController:self];

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    self.view.frame = CGRectMake(screenBound.size.width - minimizeVideoFrame.size.width - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN, screenBound.size.height - minimizeVideoFrame.size.height - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN - 70, self.view.frame.size.width, self.view.frame.size.height);

    [self initPanRecognizer];

}

- (void) handleTSConnectionError {

    [self elementsHidden:YES];

    [super handleTSConnectionError];
    
}

- (void) loadCurrentProgramationXML {
    
    TSProgramListXMLParser *parser = [[TSProgramListXMLParser alloc] init];
    parser.delegate = self;
    [parser loadCurrentProgramationXML];
    
}

- (void) TSProgramListXML:(TSProgramListXMLParser *)parser didFinish:(NSMutableArray *)data {
    
    tableElements = [NSMutableArray arrayWithArray:data];

    [self setupRelatedVideoTableView];

}



















#pragma mark -
#pragma mark EasyTableViewDelegate

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {

    UITableViewCell *cell = [self getReuseCell:easyTableView.tableView withID:isLiveStream ? @"TSProgramListTableViewCell" : @"RelatedVideoTableViewCell"];

    return cell.contentView;

}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath*)indexPath {

    if ( isLiveStream ) {

        TSProgramListElement *data = [tableElements objectAtIndex:indexPath.row];
        UILabel *title = (UILabel *)[view viewWithTag:5003];
        UILabel *time = (UILabel *)[view viewWithTag:5002];

        title.text = data.name;
        time.text = data.scheduleString;

        NSArray *titles = [[ catalogs objectForKey:TS_PROGRAMA_SLUG ] objectForKey:@"titles" ];
        NSString *URL;
        for (uint i = 0; i < [titles count]; i++) {
            
            if ( [data.name isEqualToString: [ titles objectAtIndex:i ] ] ) {
                
                NSArray *originalData = [[catalogs objectForKey:TS_PROGRAMA_SLUG ] objectForKey:@"originalData"];
                NSDictionary *programData = [originalData objectAtIndex:i];
                URL = [programData objectForKey: @"imagen_url"];
                break;
            }
            
        }
        NSLog(@"%@ - %@", [view viewWithTag:2], URL);
        URL = URL == nil ? [NSString stringWithFormat:@"http://media-telesur.openmultimedia.biz/programas/%@", data.imageID ] : URL;
        NSLog(@"%@ - %@", [view viewWithTag:2], URL);
        [(UIImageView *)[view viewWithTag:2] sd_setImageWithURL:[ NSURL URLWithString:URL]
                                                 placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];

    } else {

        NSDictionary *data = [tableElements objectAtIndex:indexPath.row];

        [((DefaultIPadTableViewCell *)[view viewWithTag:99]) setData:data];

        [(UIImageView *)[view viewWithTag:101] sd_setImageWithURL:[self getThumbURLForIndex:indexPath
                                                                            forceLargeImage:NO
                                                                            forDefaultTable:YES]
                                                 placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];

    }
}

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView {

    if( selectedIndexPath.row == indexPath.row || isLiveStream ) {
        return;
    }

    if( isDownloading ) {
        [self resetDownloadButton];
    }

    selectedIndexPath = indexPath;
    currentItem = [tableElements objectAtIndex:indexPath.row];

    [self setupCurrentVideoData];
    [self playVideoFromClip: currentItem];

}












#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    if ( isLiveStream ) {
        
        TSDataRequest *catalogRequest = [requests objectAtIndex:0];
        [self setCatalog:catalogRequest.result forKey:catalogRequest.type];
        
        [self loadCurrentProgramationXML];
        return;
        
    }

    [self elementsHidden:NO];

    [super TSDataManager:manager didProcessedRequests:requests];

    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;

    if ( [tableElements count] == 0 ) {
        return;
    }

    if ( ! currentItem ) {
        currentItem = [tableElements objectAtIndex:0];
        [self setupCurrentVideoData];
        [self playVideoFromClip:currentItem];
    }

    [self setupRelatedVideoTableView];

}



















- (void)downloadClip:(UIButton *)sender {
    
    if ( isDownloading ) {
        [self resetDownloadButton];
        return;
    }

    if ( ![self isMediaHostAvailable] ) {
        return;
    }

    [UIView animateWithDuration:0.75 animations:^{
        sender.frame = CGRectMake(sender.frame.origin.x - 50, sender.frame.origin.y, sender.frame.size.width + 50, sender.frame.size.height);
    }];

    currentSender = sender;
    currentDownloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height)];
    currentDownloadLabel.font = sender.titleLabel.font;
    currentDownloadLabel.textColor = sender.titleLabel.textColor;
    currentDownloadLabel.textAlignment = NSTextAlignmentCenter;
    
    [sender.titleLabel removeFromSuperview];

    [currentSender addSubview:currentDownloadLabel];

    [currentSender setAlpha:0.75];

    strFileName = [ NSString stringWithFormat:@"%@.mp4", [currentItem valueForKey:@"slug"] ];
    strFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:strFileName];
    NSURL *url = [NSURL URLWithString:[currentItem valueForKey:@"archivo_url"]];

    //Disable iCloud Backup for Image URL
    NSError *error = nil;
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }else{
        NSLog(@"Success excluding %@ from backup %@", [url lastPathComponent], error);
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

}

- (void) resetDownloadButton {

    [connection cancel];

    [currentSender setAlpha:1];
    
    [UIView animateWithDuration:0.75 animations:^{
        currentSender.frame = CGRectMake(currentSender.frame.origin.x + 50, currentSender.frame.origin.y, currentSender.frame.size.width - 50, currentSender.frame.size.height);
    }];
    
    isDownloading = NO;
    
    [currentDownloadLabel removeFromSuperview];
    [currentSender addSubview:currentSender.titleLabel];
    
    currentDownloadLabel = nil;
    currentSender = nil;
    
    
}












- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    isDownloading = YES;
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.#"];
    
    fileSizeString = [NSString stringWithFormat:@"%@Mb", [fmt stringFromNumber:[NSNumber numberWithFloat:(response.expectedContentLength / 1024) / 1024]]];
    currentDownloadLabel.text = [NSString stringWithFormat:@"%@ 0%%", fileSizeString];
    expectedDownloadLength = (long)response.expectedContentLength;
    
    [[NSFileManager defaultManager] createFileAtPath:strFilePath contents:nil attributes:nil];
    file = [NSFileHandle fileHandleForUpdatingAtPath:strFilePath];// read more about file handle
    if (file)   {
        [file seekToEndOfFile];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)receivedata {
    
    if( receivedata != nil){
        if (file)  {
            [file seekToEndOfFile];
        }
        [file writeData:receivedata];
    }
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:strFilePath error:NULL];
    
    int downloadPercent = ((100.0 / expectedDownloadLength) * [attributes fileSize] );
    
    if( downloadPercent != lastDownloadPercent ) {
        lastDownloadPercent = downloadPercent;
        currentDownloadLabel.text = [NSString stringWithFormat:@"%@  %d%%", fileSizeString, lastDownloadPercent];
        //        [currentDownloadLabel sizeToFit];
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    //close file after finish getting data;
    [file closeFile];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    NSURL *filePathURL = [NSURL fileURLWithPath:strFilePath];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:filePathURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:filePathURL completionBlock:^(NSURL *assetURL, NSError *error){
            if (error) {
                // TODO: error handling
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"descargaVideoCompletado", nil)]
                                                                message:[NSString stringWithFormat:NSLocalizedString(@"descargaVideoCompletadoMessage", nil)]
                                                               delegate:self
                                                      cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"acceptText", nil)]
                                                      otherButtonTitles: nil];
                [alert show];
                [self resetDownloadButton];
            }
        }];
    }

}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //do something when downloading failed
}



















- (void)initPanRecognizer {

    if (!panRecognizer) {
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
        panRecognizer.delegate = self;
    }

}

- (void)panDetected:(UIPanGestureRecognizer *)aPanRecognizer {

    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGPoint translation = [aPanRecognizer translationInView:aPanRecognizer.view];
    CGPoint velocity = [aPanRecognizer velocityInView:aPanRecognizer.view];
    NSInteger movement = translation.y - draggingPoint.y;

//    NSLog(@"asfdasf ad fasdfa sdf %ld", aPanRecognizer.state);
    if (aPanRecognizer.state == UIGestureRecognizerStateBegan) {

        draggingPoint = translation;
        viewStatus = TS_VIEW_STATUS_ON_TRANSITION;

    } else if (aPanRecognizer.state == UIGestureRecognizerStateChanged) {

        [self moveVerticallyToLocation:self.view.frame.origin.y + movement];
        draggingPoint = translation;

    } else if (aPanRecognizer.state == UIGestureRecognizerStateEnded) {

        NSInteger positiveVelocity = (velocity.y > 0) ? velocity.y : velocity.y * -1;

        if (positiveVelocity >= MENU_FAST_VELOCITY_FOR_SWIPE_FOLLOW_DIRECTION) {
            if (velocity.y > 0) {
                [self minimizeView];
            } else {
                [self restoreView];
            }
        } else {
            if ( self.view.frame.origin.y > screenBound.size.height * 0.4 ) {
                if ( self.view.frame.origin.y > screenBound.size.height * 0.7 ) {
                    [self removeDetailViewController];
                } else {
                    [self minimizeView];
                }
            } else {
                [self restoreView];
            }
        }
    }
}

- (void) minimizeView {

    [playerController addAppearControlButton:NO];
    [playerController removeTimer];

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect screenBound = [[UIScreen mainScreen] bounds];

        playerController.view.alpha = 1.0;
        playerController.view.frame = CGRectMake(0, 0, minimizeVideoFrame.size.width, minimizeVideoFrame.size.height);
        playerController.controlsView.alpha = 0.0;

        self.view.frame = CGRectMake(screenBound.size.width - minimizeVideoFrame.size.width - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN, screenBound.size.height - minimizeVideoFrame.size.height - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN - 70, self.view.frame.size.width, self.view.frame.size.height);
        customBackground.alpha = 0.0;

    } completion:^(BOOL finished) {
        if ( finished ) {
            self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, minimizeVideoFrame.size.width, minimizeVideoFrame.size.height);
            [playerController updateSpinnerView];
            viewStatus = TS_VIEW_STATUS_MINIMIZED;
        }
    }];

    TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;
    topMenu.topViewController.view.userInteractionEnabled = YES;
    
}

- (void) restoreView {

    CGRect screenBound = [[UIScreen mainScreen] bounds];
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, screenBound.size.width, screenBound.size.height);

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        playerController.view.frame = playerFrame;
        self.view.frame = CGRectMake(0, IPAD_VIEW_Y_POSITION, self.view.frame.size.width, self.view.frame.size.height);
        customBackground.alpha = 1.0;

    } completion:^(BOOL finished) {
        if ( finished ) {
            viewStatus = TS_VIEW_STATUS_MAXIMIZED;
            [playerController addAppearControlButton:YES];
            [playerController setPlayerFrame:playerFrame hideMinimizeButton:NO];
            if ( configVideoNeeded ) {
                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(configVideo) userInfo:nil repeats:NO];
            }
        }
    }];

    TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;
    topMenu.topViewController.view.userInteractionEnabled = NO;
    
}

- (void) showView {

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    self.view.frame = CGRectMake(screenBound.size.width - 10, screenBound.size.height - 10, 10, 10);
    self.view.alpha = 0.0;

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.view.frame = CGRectMake(0, IPAD_VIEW_Y_POSITION, screenBound.size.width, screenBound.size.height);
        self.view.alpha = 1.0;

    } completion:^(BOOL finished) {
        if ( finished ) {
            viewStatus = TS_VIEW_STATUS_MAXIMIZED;
            [self initPanRecognizer];
            [self.view addGestureRecognizer:panRecognizer];
            [self resumeVideoPlayer];
//            [[SlideNavigationController sharedInstance] setNeedsStatusBarAppearanceUpdate];
        }
    }];
    
}

- (void)moveVerticallyToLocation:(CGFloat)location {
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGRect rect = self.view.frame;
    CGRect finalVideoRect = CGRectMake(screenBound.size.width - minimizeVideoFrame.size.width - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN, screenBound.size.height - minimizeVideoFrame.size.height - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN - 70, minimizeVideoFrame.size.width, minimizeVideoFrame.size.height);
    float percent = rect.origin.y / finalVideoRect.origin.y;

    if ( percent < 0 ) {
        return;
    }

    rect.origin.x = finalVideoRect.origin.x * MIN( percent, 1 );
    rect.origin.y = location;
    self.view.frame = rect;

    if (percent > 1 ) {
        playerController.view.alpha = 1 - ((percent - 1) * 8);
        return;
    }

    float inversePercent = 1.0 - percent;
    playerController.view.frame = CGRectMake(playerFrame.origin.x * inversePercent,
                                             playerFrame.origin.y * inversePercent,
                                             finalVideoRect.size.width + ((playerFrame.size.width - finalVideoRect.size.width) * inversePercent),
                                             finalVideoRect.size.height + ((playerFrame.size.height - finalVideoRect.size.height) * inversePercent));
    customBackground.alpha = inversePercent;
    
}

@end