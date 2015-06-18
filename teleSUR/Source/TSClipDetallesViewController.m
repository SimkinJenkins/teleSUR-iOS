//
//  TSClipDetallesViewController.m
//  teleSUR
//
//  Created by David Regla on 2/26/11.
//  Copyright 2011 teleSUR. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "TSClipDetallesViewController.h" 
#import "TSClipListadoTableViewController.h"
#import "NSDictionary_Datos.m"
#import "UIViewController_Configuracion.h"

#import "TSClipPlayerViewController.h"

#import "TSDataRequest.h"
#import "TSDataManager.h"
#import "DefaultTableViewCell.h"
#import "UIImageView+WebCache.h"

#import "SlideNavigationController.h"
#import "TSProgramListElement.h"

#import "TSProgramListXMLParser.h"

NSInteger const MENU_FAST_VELOCITY_FOR_SWIPE_FOLLOW_DIRECTION = 1200;
NSInteger const MENU_DEFAULT_SLIDE_OFFSET = 60;

CGFloat const VIEW_Y_POSITION = 0;//65;
CGFloat const RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN = 7;

NSInteger const TS_VIEW_STATUS_DEFAULT = 0;
NSInteger const TS_VIEW_STATUS_MAXIMIZED = 1;
NSInteger const TS_VIEW_STATUS_MINIMIZED = 2;
NSInteger const TS_VIEW_STATUS_FULLSCREEN = 3;
NSInteger const TS_VIEW_STATUS_ON_TRANSITION = 4;

@implementation TSClipDetallesViewController

#pragma mark -
#pragma mark Init

- (id) initWithData:(NSDictionary *)itemData andSection:(NSString *)section {

    if ((self = [super init])) {
        currentItem = itemData;
        currentSection = section;
        isDownloading = NO;
        isLiveStream = NO;
    }

    return self;
}

- (id) initWithURL:(NSString *)URL andTitle:(NSString *)title {

    if ((self = [super init])) {
        liveURL = URL;
        liveURLTitle = title;
        isDownloading = NO;
        isLiveStream = YES;
        catalogs = [NSMutableDictionary dictionary];
    }

    return self;

}


















#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad {

    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    self.view.frame = screenBound;

    backgroundView = [[UIView alloc] initWithFrame:screenBound];
    backgroundView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:backgroundView];

    contentView = [[UIView alloc] initWithFrame:screenBound];
    contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:contentView];

    [self setSearchBarConfiguration];

    [self setTableViewConfiguration];

    [contentView addSubview:self.tableViewController.tableView];

    [self loadShareImageInBackground];

    [self setViewNotifications];

    [SlideNavigationController sharedInstance].enableAutorotate = YES;

    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(configVideo) userInfo:nil repeats:NO];

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self reset];
    [self showView];

}

- (void)viewDidUnload {

    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [self removeCurrentPlayer];

    if( isDownloading ) {

        [self resetDownloadButton];

    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [SlideNavigationController sharedInstance].enableAutorotate = NO;

}



















#pragma mark -
#pragma mark TableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if ( isLiveStream ) {
        
        return 70;

    }

    if(indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoDetailCellView"];
        if (cell == nil) {
            cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"VideoDetailCellView" owner:self options:nil] lastObject];
        }

        [((DefaultTableViewCell *)cell) setData:[tableElements objectAtIndex:indexPath.row]];

        UILabel *moreCell = (UILabel *)[cell viewWithTag:106];
        return moreCell.frame.origin.y + moreCell.frame.size.height;
    }

    return 100;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [tableElements count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;

    if ( isLiveStream ) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"TSProgramListTableViewCell"];
        if (cell == nil) {
            cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"TSProgramListTableViewCell" owner:self options:nil] lastObject];
        }
        TSProgramListElement *data = [tableElements objectAtIndex:indexPath.row];
        UILabel *title = (UILabel *)[cell viewWithTag:5003];
        UILabel *time = (UILabel *)[cell viewWithTag:5002];

        title.text = data.name;
        time.text = data.scheduleString;

    } else {

        if(indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"VideoDetailCellView"];
            if (cell == nil) {
                cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"VideoDetailCellView" owner:self options:nil] lastObject];
            }

            [(UIButton *)[cell viewWithTag:103] addTarget:self action:@selector(downloadClip:) forControlEvents:UIControlEventTouchUpInside];

            [((DefaultTableViewCell *)cell) setData:[tableElements objectAtIndex:indexPath.row]];

        } else if(indexPath.row > [tableElements count]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"VerMasClipsTableCellView"];
            ((UILabel *)[cell viewWithTag:1]).text = [NSString stringWithFormat:NSLocalizedString(@"verMasCellText", nil)];
        } else {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }

    }
    return cell;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if ( indexPath.row != 0 && !isLiveStream) {

        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];

    } else if ( isLiveStream ) {

        TSProgramListElement *data = [tableElements objectAtIndex:indexPath.row];

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
        URL = URL == nil ? [NSString stringWithFormat:@"http://media-telesur.openmultimedia.biz/programas/%@", data.imageID ] : URL;
        [self configureImageInCell:cell withNSURL:[ NSURL URLWithString:URL]];

    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if( indexPath.row == 0 || isLiveStream ) {
        return;
    }

    selectedIndexPath = indexPath;
    NSArray *elements = [ self getDataArrayForIndexPath:indexPath forDefaultTable:YES ];

    if (selectedIndexPath.row < [elements count] || loadMoreCellDisabled) {

        [self setData:[elements objectAtIndex:indexPath.row] andSection:currentSection];

    } else {// Se trata de la celda "Ver Más"

        addAtListEnd = YES;
        [self loadData];

    }

}



















#pragma mark -
#pragma mark Custom Public Overrided Functions

- (void) initViewVariables {

    [super initViewVariables];

    viewStatus = TS_VIEW_STATUS_DEFAULT;
    loadMoreCellDisabled = YES;
    addAtListEnd = YES;

}

- (void) initTableVariables {

    [super initTableVariables];
    [self.tableViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    loadMoreCellDisabled = NO;

}

- (void)loadData {

    if ( ![self isAPIHostAvailable] ) {
        return;
    }

    addAtListEnd = YES;

    if ( isLiveStream ) {

        TSDataRequest *showCatReq = [[TSDataRequest alloc] initWithType:TS_PROGRAMA_SLUG    forSection:nil      forSubsection:nil];
        showCatReq.range = NSMakeRange(1, 300);

        [[[TSDataManager alloc] init] loadRequests:[NSArray arrayWithObjects:showCatReq, nil] delegateResponseTo:self];

    } else {

        tableElements = [NSMutableArray arrayWithObject:currentItem];
        TSDataRequest *relatedReq = [[TSDataRequest alloc] initWithType:TS_CLIP_SLUG       forSection:@""  forSubsection:@""];
        relatedReq.range = NSMakeRange(1, 5);
        relatedReq.relatedSlug = [currentItem objectForKey:@"slug"];
        NSArray *requests = [NSArray arrayWithObjects:relatedReq, nil];
        [[[TSDataManager alloc] init] loadRequests:requests delegateResponseTo:self];

    }
    
}


















#pragma mark -
#pragma mark Custom Public Functions

- (void) setData:(NSDictionary *)itemData andSection:(NSString *)section {

    currentItem = itemData;
    currentSection = section;
    isLiveStream = NO;

    [self initTableVariables];
    [self removeCurrentPlayer];
    [self configVideo];
    [self loadData];

    if ( viewStatus == TS_VIEW_STATUS_MINIMIZED ) {

        [self resetSelfAndContentViewToNormal];
        [self restoreView];

    }
}

- (void) setURL:(NSString *)URL andTitle:(NSString *)title {

    liveURL = URL;
    liveURLTitle = title;
    isLiveStream = YES;

    [self initTableVariables];
    [self removeCurrentPlayer];
    [self configVideo];
    [self loadData];

    if ( viewStatus == TS_VIEW_STATUS_MINIMIZED ) {
        [self restoreView];
    }

}



















#pragma mark -
#pragma mark Custom Functions

- (void) configLeftButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 23, 23);
    [button setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    
    [button addTarget:self.parentViewController.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.parentViewController.navigationItem setLeftBarButtonItem:barButtonItem];

}

- (void) configRightButton {
/*
    self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"share.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(shareButtonClicked)];
*/
}

- (void) shareButtonClicked {

    NSLog(@"%@", [currentItem objectForKey:@"navegador_url"]);
    [self shareText:[currentItem objectForKey:@"titulo"] andImage:thumb.image andUrl:[ NSURL URLWithString:[currentItem objectForKey:@"navegador_url"] ]];

}

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
    [self presentViewController:activityController animated:YES completion:nil];
    
}

- (void) deviceOrientationDidChangeNotification:(NSNotification *)notification {

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || orientation == UIDeviceOrientationPortraitUpsideDown || viewStatus == TS_VIEW_STATUS_MINIMIZED) {
        return;
    }

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);

    self.parentViewController.navigationController.navigationBarHidden = isLandscape;

    if (isLandscape) {
        [self.view addSubview:playerController.view];
    } else {
        [contentView addSubview:playerController.view];
    }

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        playerController.view.frame = isLandscape ? screenBound : CGRectMake(0, 0, screenBound.size.width, screenBound.size.width * 0.7);
    } completion:^(BOOL finished) {
        if ( finished ) {
            [playerController setPlayerFrame: isLandscape ? screenBound : CGRectMake(0, 0, screenBound.size.width, screenBound.size.width * 0.7) hideMinimizeButton:isLandscape];
        }
    }];

    viewStatus = isLandscape ? TS_VIEW_STATUS_FULLSCREEN : TS_VIEW_STATUS_MAXIMIZED;

    if ( isLandscape ) {
        [self.view removeGestureRecognizer:panRecognizer];
    } else {
        [self.view addGestureRecognizer:panRecognizer];
    }

    [playerController startTimer];

}

- (void) removeCurrentPlayer {

    if(playerController) {

        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"minimizeButtonTouched" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sharedButtonTouched" object:nil];

        [playerController.moviePlayer stop];
        [playerController.view removeFromSuperview];
        playerController = nil;
    }

}

- (void)configVideo {

    if ( !playerController ) {
        if ( isLiveStream ) {
            playerController = [[TSClipPlayerViewController alloc] initWithURL:liveURL andTitle:currentSection];
        } else {
            playerController = [[TSClipPlayerViewController alloc] initWithData:currentItem andSection:currentSection];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareButtonClicked) name:@"sharedButtonTouched" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(minimizeView) name:@"minimizeButtonTouched" object:nil];

    }

    CGRect screenBounds = [[UIScreen mainScreen] bounds];

    [playerController playAtView:contentView withFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.width * 0.7) withObserver:self playbackFinish:nil];

}

- (void)setTableViewConfiguration {

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    CGRect tableFrame = self.tableViewController.tableView.frame;
    tableFrame.origin.y = screenBound.size.width * 0.7;
    tableFrame.size.height -= (112 + VIEW_Y_POSITION);

    self.tableViewController.tableView.frame = tableFrame;
    self.tableViewController.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

}

- (void) setSearchBarConfiguration {

    UISearchBar *searchBar = (UISearchBar *)[self.view viewWithTag:101];
    searchBar.placeholder = [NSString stringWithFormat:NSLocalizedString(@"searchPlaceholder", nil)];
    searchBar.hidden = YES;

}

- (void) loadShareImageInBackground {

    thumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    
    [thumb sd_setImageWithURL:[self getThumbURLFromAPIItem:currentItem forceLargeImage:NO]
             placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];

}

- (void) setViewNotifications {

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void) reset {
    
    if( playerController ) {
        [playerController.moviePlayer prepareToPlay];
        [playerController.moviePlayer pause];
    }
    
}

- (void) loadCurrentProgramationXML {

    TSProgramListXMLParser *parser = [[TSProgramListXMLParser alloc] init];
    parser.delegate = self;
    [parser loadCurrentProgramationXML];

}

- (void) TSProgramListXML:(TSProgramListXMLParser *)parser didFinish:(NSMutableArray *)data {

    tableElements = [NSMutableArray arrayWithArray:data];
    [self.tableViewController.tableView reloadData];

}



















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    if ( !isLiveStream ) {

        [super TSDataManager:manager didProcessedRequests:requests];
        return;

    }

    TSDataRequest *catalogRequest = [requests objectAtIndex:0];
    [self setCatalog:catalogRequest.result forKey:catalogRequest.type];

    [self loadCurrentProgramationXML];

}



















- (void)downloadClip:(UIButton *)sender {

    if ( isDownloading ) {

        [self resetDownloadButton];
        return;

    }

    if ( ![self isMediaHostAvailable] ) {
        return;
    }

    NSLog(@"%@", [currentItem valueForKey:@"archivo_url"]);

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
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //Disable iCloud Backup for Image URL
    NSError *error = nil;
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }else{
        NSLog(@"Success excluding %@ from backup %@", [url lastPathComponent], error);
    }

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

    if (aPanRecognizer.state == UIGestureRecognizerStateBegan) {

        draggingPoint = translation;
        viewStatus = TS_VIEW_STATUS_ON_TRANSITION;
        [[SlideNavigationController sharedInstance] setNeedsStatusBarAppearanceUpdate];

        [self resetSelfAndContentViewToNormal];

    } else if (aPanRecognizer.state == UIGestureRecognizerStateChanged) {

        [self moveVerticallyToLocation:contentView.frame.origin.y + movement];
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
            if ( contentView.frame.origin.y > screenBound.size.height * 0.4 ) {
                if ( contentView.frame.origin.y > screenBound.size.height * 0.8 ) {
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
        CGFloat playerW = screenBound.size.width * .5;
        CGFloat playerH = playerW * .7;

        playerController.view.frame = CGRectMake(0, 0, playerW, playerH);
        playerController.controlsView.alpha = 0.0;
        contentView.frame = CGRectMake(screenBound.size.width - playerW - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN, screenBound.size.height - playerH - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN, contentView.frame.size.width, contentView.frame.size.height);
        self.tableViewController.tableView.alpha = 0.0;
        contentView.alpha = 1.0;
        backgroundView.alpha = 0.0;
        [self.view removeGestureRecognizer:panRecognizer];

    } completion:^(BOOL finished) {
        if ( finished ) {
            viewStatus = TS_VIEW_STATUS_MINIMIZED;
            [playerController updateSpinnerView];
            [[SlideNavigationController sharedInstance] setNeedsStatusBarAppearanceUpdate];
            self.view.frame = contentView.frame;
            contentView.frame = CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height);
            [self.view addGestureRecognizer:panRecognizer];
        }
    }];

    [SlideNavigationController sharedInstance].enableAutorotate = NO;
    [SlideNavigationController sharedInstance].topViewController.view.userInteractionEnabled = YES;

}

- (void) restoreView {

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        CGRect screenBound = [[UIScreen mainScreen] bounds];
        playerController.view.frame = CGRectMake(0, 0, screenBound.size.width, screenBound.size.width * 0.7);
        playerController.controlsView.alpha = 1.0;
        contentView.frame = CGRectMake(0, VIEW_Y_POSITION, contentView.frame.size.width, contentView.frame.size.height);
        self.tableViewController.tableView.alpha = 1.0;
        backgroundView.alpha = 1.0;

    } completion:^(BOOL finished) {
        if ( finished ) {
            [playerController addAppearControlButton:YES];
            [playerController updateSpinnerView];
            viewStatus = TS_VIEW_STATUS_MAXIMIZED;
            [[SlideNavigationController sharedInstance] setNeedsStatusBarAppearanceUpdate];
        }
    }];

    [SlideNavigationController sharedInstance].enableAutorotate = YES;
    [SlideNavigationController sharedInstance].topViewController.view.userInteractionEnabled = NO;

}

- (void) showView {

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    backgroundView.alpha = 0.0;
    contentView.frame = CGRectMake(screenBound.size.width - 10, screenBound.size.height - 10, 10, 10);
    contentView.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{

        backgroundView.alpha = 1.0;
        contentView.frame = CGRectMake(0, VIEW_Y_POSITION, screenBound.size.width, screenBound.size.height);
        contentView.alpha = 1.0;

    } completion:^(BOOL finished) {
        if ( finished ) {
            viewStatus = TS_VIEW_STATUS_MAXIMIZED;
            [self initPanRecognizer];
            [self.view addGestureRecognizer:panRecognizer];
            [[SlideNavigationController sharedInstance] setNeedsStatusBarAppearanceUpdate];
        }
    }];

}

- (void) removeDetailViewController {

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        CGRect screenBound = [[UIScreen mainScreen] bounds];
        contentView.frame = CGRectMake(contentView.frame.origin.x, screenBound.size.height, contentView.frame.size.width, contentView.frame.size.height);
        self.view.alpha = 0.0;

    } completion:^(BOOL finished) {
        if ( finished ) {

            [self removeCurrentPlayer];
            [self.view removeGestureRecognizer:panRecognizer];
            panRecognizer = nil;
            [[SlideNavigationController sharedInstance] removeTopViewController];

        }
    }];
}

- (void) moveVerticallyToLocation:(CGFloat)location {

    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGRect rect = contentView.frame;
    CGRect videoRect = CGRectMake(0, 0, screenBound.size.width, screenBound.size.width * 0.7);
    CGRect finalVideoRect = CGRectMake(((screenBound.size.width - (screenBound.size.width * 0.5)) - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN), ((screenBound.size.height - (screenBound.size.width * 0.35)) - RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN), screenBound.size.width * 0.5, screenBound.size.width * 0.35);
    float percent = rect.origin.y / finalVideoRect.origin.y;

    if ( percent < 0 ) {
        return;
    }

    rect.origin.x = finalVideoRect.origin.x * MIN( percent, 1 );
    rect.origin.y = location;
    contentView.frame = rect;

    if (percent > 1 ) {
        playerController.view.alpha = 1 - ((percent - 1) * 8);
        return;
    }

    float inversePercent = 1.0 - percent;
    playerController.view.frame = CGRectMake(0, 0, finalVideoRect.size.width + ((videoRect.size.width - finalVideoRect.size.width) * inversePercent), finalVideoRect.size.height + ((videoRect.size.height - finalVideoRect.size.height) * inversePercent));
    self.tableViewController.tableView.alpha = inversePercent;
    backgroundView.alpha = inversePercent;
    playerController.controlsView.alpha = inversePercent;

}

- (BOOL) prefersStatusBarHidden {
    if ( viewStatus == TS_VIEW_STATUS_MAXIMIZED || viewStatus == TS_VIEW_STATUS_FULLSCREEN ) {
        return YES;
    }
    return NO;
}

- (void) resetSelfAndContentViewToNormal {

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    if ( self.view.frame.origin.x != 0 ) {

        [self.view removeGestureRecognizer:panRecognizer];
        contentView.frame = self.view.frame;
        self.view.frame = CGRectMake(0, 0, screenBound.size.width, screenBound.size.height);
        [self.view addGestureRecognizer:panRecognizer];

    }

}


















@end