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

@implementation TSClipDetallesViewController

#pragma mark -
#pragma mark Init

- (id)initWithData:(NSDictionary *)itemData {

    if ((self = [super init])) {
        currentItem = itemData;
        isDownloading = NO;
    }

    return self;
}













#pragma mark -
#pragma mark View life cycle

- (void)viewDidLoad {

    loadMoreCellDisabled = YES;
    addAtListEnd = YES;

    [super viewDidLoad];

    UISearchBar *searchBar = (UISearchBar *)[self.view viewWithTag:101];
    searchBar.placeholder = [NSString stringWithFormat:NSLocalizedString(@"searchPlaceholder", nil)];
    searchBar.hidden = YES;

    [self setTableViewConfiguration];

    [self configLeftButton];
    [self configRightButton];

    thumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    
    [thumb sd_setImageWithURL:[self getThumbURLFromAPIItem:currentItem forceLargeImage:NO]
             placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];

    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(configVideo) userInfo:nil repeats:NO];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:UIApplicationWillEnterForegroundNotification object:nil];

    [SlideNavigationController sharedInstance].enableAutorotate = YES;

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self reset];
/*
    CGRect screenBound = [[UIScreen mainScreen] bounds];

    self.view.frame = CGRectMake(screenBound.size.width - 10, screenBound.size.height - 10, 10, 10);
    self.view.alpha = 0.0;

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{

        float yPos = 64;
        self.view.frame = CGRectMake(0, yPos, screenBound.size.width, screenBound.size.height - yPos);
        self.view.alpha = 1.0;

    } completion:nil];
*/
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

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

    return cell;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( indexPath.row != 0 ) {
        
        [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if( indexPath.row == 0) {
        return;
    }

    selectedIndexPath = indexPath;

    NSArray *elements = [ self getDataArrayForIndexPath:indexPath forDefaultTable:YES ];

    if (selectedIndexPath.row < [elements count] || loadMoreCellDisabled) {

        currentItem = [elements objectAtIndex:indexPath.row];
        [self initTableVariables];
        [self removeCurrentPlayer];
        [self configVideo];
        [self loadData];

    } else {// Se trata de la celda "Ver Más"

        addAtListEnd = YES;
        [self loadData];

    }

}

















/*
#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    selectedIndexPath = indexPath;

    [self playSelectedClip:indexPath];

}
*/
#pragma mark -
#pragma mark Acciones
/*
- (void)botonDescargarPresionado:(UIButton *)boton;
{
    //Comentado para pruebas
//    [alert release];
}
*/

- (void) configLeftButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 23, 23);
    [button setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    
    [button addTarget:self.parentViewController.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.parentViewController.navigationItem setLeftBarButtonItem:barButtonItem];
    
}

- (void) configRightButton {
    
    self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"share.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(shareButtonClicked)];
    
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

- (void) initTableVariables {

    [super initTableVariables];

    [self.tableViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    loadMoreCellDisabled = NO;

}













#pragma mark - Custom Functions

- (void)loadData {

    if ( ![self isAPIHostAvailable] ) {
        return;
    }

    addAtListEnd = YES;

    tableElements = [NSMutableArray arrayWithObject:currentItem];
    TSDataRequest *relatedReq = [[TSDataRequest alloc] initWithType:TS_CLIP_SLUG       forSection:@""  forSubsection:@""];
    relatedReq.range = NSMakeRange(1, 5);
    relatedReq.relatedSlug = [currentItem objectForKey:@"slug"];
    NSArray *requests = [NSArray arrayWithObjects:relatedReq, nil];
    [[[TSDataManager alloc] init] loadRequests:requests delegateResponseTo:self];

}

- (void)playerDidFinish {

    if (selectedIndexPath.row == 0) {
        return;
    }

//    [super playerDidFinish];

}

- (void) deviceOrientationDidChangeNotification:(NSNotification *)notification {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || orientation == UIDeviceOrientationPortraitUpsideDown) {
        return;
    }

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);

    self.parentViewController.navigationController.navigationBarHidden = isLandscape;

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        playerController.view.frame = isLandscape ? screenBound : CGRectMake(0, 0, screenBound.size.width, screenBound.size.width * 0.7);
    } completion:nil];
    
}

- (void) removeCurrentPlayer {
    if(playerController) {
        [playerController.moviePlayer stop];
        [playerController.view removeFromSuperview];
        playerController = nil;
    }
}

- (void)configVideo {
    
    playerController = [[TSClipPlayerViewController alloc] initConClip:currentItem];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    
    [playerController playAtView:self.view withFrame:CGRectMake(0, 0, screenBound.size.width, screenBound.size.width * 0.7) withObserver:self playbackFinish:@selector(playerDidFinish)];
    
}

- (void)setTableViewConfiguration {
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    
    CGRect tableFrame = self.tableViewController.tableView.frame;
    tableFrame.origin.y = screenBound.size.width * 0.7;
    tableFrame.size.height -= 145;
    
    self.tableViewController.tableView.frame = tableFrame;
    self.tableViewController.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
}

- (void) reset {
    
    if( playerController ) {
        [playerController.moviePlayer prepareToPlay];
        [playerController.moviePlayer pause];
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