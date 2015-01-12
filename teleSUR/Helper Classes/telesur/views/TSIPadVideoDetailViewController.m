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

#import "UIView+TSBasicCell.h"

NSInteger const TS_VD_DETAIL_VIEW_TAG = 150;
NSInteger const TS_VD_DETAIL_ASYNC_IMAGE_TAG = 106;

NSInteger const TS_LIST_WIDTH = 346;
NSInteger const VD_SIDE_MARGIN = 15;

NSInteger const TS_DETAIL_VIEW_HEIGHT = 764;

@implementation TSIPadVideoDetailViewController

@synthesize playerController, player;

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

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    [[NavigationBarsManager sharedInstance] setMasterView:[ [ self.view superview] superview] ];

    [NavigationBarsManager sharedInstance].playerController = self;

}

- (void) viewDidDisappear:(BOOL)animated {

    [self removeCurrentPlayer];

    if ( ![NavigationBarsManager sharedInstance].livestreamON ) {

        [NavigationBarsManager sharedInstance].playerController = nil;

    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if( isDownloading ) {
        
        [self resetDownloadButton];
        
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self setVideoPlayerFrame];
    
    [self sectionSelected:currentSection withTitle:[self getSectionTitleWith:currentSection]];
    
    [self setupVideoView];
    
}














- (NSString *) getSectionTitleWith:(NSString *)slug {

    NSArray *staticSections = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"principalMenuSections"];
    for (uint i = 0; i < [staticSections count]; i++) {
        if([slug isEqualToString:[staticSections objectAtIndex:i]]) {
            NSString *localizeID = [NSString stringWithFormat:@"%@Section", [staticSections objectAtIndex:i]];
            NSLog(@"%@", localizeID);
            return [NSString stringWithFormat:NSLocalizedString(localizeID, nil)];
        }
    }
    return @"";

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
    CGRect frameRect	= isLandscape ? CGRectMake(0, 0, TS_LIST_WIDTH, 638) : CGRectMake(0, TS_DETAIL_VIEW_HEIGHT + 11, screenRect.size.width, 120);

    relatedRSSTableView = isLandscape ? [[EasyTableView alloc] initWithFrame:frameRect numberOfRows:[tableElements count] ofHeight:120]
                                    : [[EasyTableView alloc] initWithFrame:frameRect numberOfColumns:[tableElements count] ofWidth:TS_LIST_WIDTH];

    relatedRSSTableView.delegate						= self;
    relatedRSSTableView.tableView.layer.borderColor     = [UIColor darkGrayColor].CGColor;
    relatedRSSTableView.tableView.layer.borderWidth     = 1.0f;
    relatedRSSTableView.tableView.backgroundColor       = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    relatedRSSTableView.tableView.allowsSelection       = YES;
    relatedRSSTableView.tableView.separatorColor		= [UIColor clearColor];
    relatedRSSTableView.cellBackgroundColor             = [UIColor clearColor];
    //	horizontalView.autoresizingMask                 = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:relatedRSSTableView];

}

- (void) setupVideoView {

    wrapper = [[UIScrollView  alloc] init];

    [wrapper addSubview:[self.view viewWithTag:TS_VD_DETAIL_VIEW_TAG]];
    [self.view addSubview:wrapper];

    UILabel *title = (UILabel *)[self.view viewWithTag:1001];
    UILabel *date = (UILabel *)[self.view viewWithTag:112];
    UILabel *description = (UILabel *)[self.view viewWithTag:1004];
    UILabelMarginSet *section = (UILabelMarginSet *)[self.view viewWithTag:107];
    UIButton *download = (UIButton *)[self.view viewWithTag:113];

    section.frame = CGRectMake(0, VD_SIDE_MARGIN, 100, section.frame.size.height);
    title.frame = CGRectMake(0, title.frame.origin.y, title.frame.size.width, title.frame.size.height);
    date.frame = CGRectMake(0, date.frame.origin.y, date.frame.size.width, date.frame.size.height);
    description.frame = CGRectMake(0, description.frame.origin.y, description.frame.size.width, description.frame.size.height);

    [section setPersistentBackgroundColor:[UIColor colorWithRed:255/255.0 green:2/255.0 blue:2/255.0 alpha:1.0]];

    section.leftMargin = 10;
    section.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:11];//2e2e2e
    date.font = [UIFont fontWithName:@"Roboto-Bold" size:16];//696969
    description.font = [UIFont fontWithName:@"Roboto-Regular" size:16];//black

    [download setTitle:NSLocalizedString(@"descarga", nil) forState:UIControlStateNormal];
    [download addTarget:self action:@selector(downloadClip:) forControlEvents:UIControlEventTouchUpInside];

    thumb = [[UIImageView alloc] initWithFrame:playerFrame];

}

- (void) setupCurrentVideoData {

    UILabel *title = (UILabel *)[self.view viewWithTag:1001];
    UILabel *date = (UILabel *)[self.view viewWithTag:112];
    UILabel *description = (UILabel *)[self.view viewWithTag:1004];
    UILabelMarginSet *section = (UILabelMarginSet *)[self.view viewWithTag:107];

    date.hidden = NO;
    date.text = [self.view getLongFormatDateFromData:currentItem];

    NSString *clipType = [[currentItem valueForKey:@"tipo"] valueForKey:@"slug"];
    BOOL switchTitles = [clipType isEqualToString:@"programa"];

    section.frame = CGRectMake(0, VD_SIDE_MARGIN, 100, section.frame.size.height);

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

        description.text = [currentItem obtenerDescripcion];

    }

    [section sizeToFit];
    section.frame = CGRectMake(section.frame.origin.x, section.frame.origin.y, section.frame.size.width + 20, section.frame.size.height + 10);

    [self.view addSubview:thumb];
    [thumb sd_setImageWithURL:[self getThumbURLFromAPIItem:currentItem forceLargeImage:NO]
             placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];

    [self adjustLabelsSize];

}

- (void) adjustLabelsSize {

    UILabel *title = (UILabel *)[self.view viewWithTag:1001];
    UILabel *date = (UILabel *)[self.view viewWithTag:112];
    UILabel *description = (UILabel *)[self.view viewWithTag:1004];
    UIButton *download = (UIButton *)[self.view viewWithTag:113];
    UILabelMarginSet *section = (UILabelMarginSet *)[self.view viewWithTag:107];

    [self.view adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(playerFrame.size.width, 300)];
    [self.view setLabel:title underView:section withSeparation:2];
    
    [self.view setLabel:date underView:title withSeparation:10];
    
    download.frame = CGRectMake(playerFrame.size.width - 110, date.hidden ? title.frame.origin.y + 7 : date.frame.origin.y - 4, download.frame.size.width, download.frame.size.height);
    
    [self.view adjustSizeFrameForLabel:description constriainedToSize:CGSizeMake(playerFrame.size.width, 300)];
    [self.view setLabel:description underView:download withSeparation:18];

    thumb.frame = playerFrame;

    wrapper.frame = CGRectMake(playerFrame.origin.x, playerFrame.origin.y + playerFrame.size.height, playerFrame.size.width + VD_SIDE_MARGIN, UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? 192 : 285);

    wrapper.contentOffset = CGPointMake(0, 0);
    wrapper.contentSize = CGSizeMake(playerFrame.size.width, description.frame.origin.y + description.frame.size.height + VD_SIDE_MARGIN);

}

- (void) playVideoFromClip:(NSDictionary *)clip {

    [self removeCurrentPlayer];

    playerController = [[TSClipPlayerViewController alloc] initConClip:clip];
    [playerController playAtView:self.view withFrame:playerFrame withObserver:self playbackFinish:@selector(playbackEnd:)];

}

- (void) resumeVideoPlayer {

    [self playVideoFromClip:currentItem];

}

- (void) removeCurrentPlayer {
    if(playerController) {
        [playerController.moviePlayer stop];
        [playerController.view removeFromSuperview];
        playerController = nil;
    }
}

- (void) playbackEnd:(NSNotification *)notification {}

- (void) setVideoPlayerFrame {

    playerFrame = UIInterfaceOrientationIsLandscape( [ [ UIApplication sharedApplication ] statusBarOrientation ] )
                                        ? CGRectMake( 360, 25, 640, 420 )
                                        : CGRectMake( 30, 25, 700, 462 );

}
























#pragma mark - Custom Functions

- (void) loadData {
    
    [super loadData];
    [self removeCurrentPlayer];
    
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

    [self setVideoPlayerFrame];

    [relatedRSSTableView removeFromSuperview];
    relatedRSSTableView = nil;

    [self setupRelatedVideoTableView];

    [self adjustLabelsSize];

    if( playerController ) {
        playerController.view.frame = playerFrame;
    }

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

    NSDictionary *data = [tableElements objectAtIndex:indexPath.row];

    [((DefaultIPadTableViewCell *)[view viewWithTag:99]) setData:data];

    // Here we use the new provided setImageWithURL: method to load the web image
    [(UIImageView *)[view viewWithTag:101] sd_setImageWithURL:[self getThumbURLForIndex:indexPath
                                                                        forceLargeImage:NO
                                                                        forDefaultTable:YES]
                                             placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];

}

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView {

    if( selectedIndexPath.row == indexPath.row ) {
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

    [self elementsHidden:NO];

    [super TSDataManager:manager didProcessedRequests:requests];

    NSLog(@"Antes del error TSIpadVideoDetailViewController");

    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;

    if ( [tableElements count] == 0 ) {
        return;
    }

    if ( ! currentItem ) {
        currentItem = [tableElements objectAtIndex:0];
    }

    [self setupCurrentVideoData];
    [self setupRelatedVideoTableView];

    if ( ! currentItem ) {

        [self playVideoFromClip:currentItem];

    } else {

        [self resumeVideoPlayer];

    }

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
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[currentItem valueForKey:@"archivo_url"]]
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

@end