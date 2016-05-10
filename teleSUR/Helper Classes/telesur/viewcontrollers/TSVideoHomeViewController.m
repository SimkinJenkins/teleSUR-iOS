//
//  TSVideoHomeViewController.m
//  teleSUR
//
//  Created by Simkin on 13/04/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import "TSVideoHomeViewController.h"

@implementation TSVideoHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self configRightButton];
    [self loadHomeData];
}

- (void) configRightButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"senal.png"] style:
                                              UIBarButtonItemStylePlain target:self action:@selector(videoLiveButtonTouched:)];
}

- (void) videoLiveButtonTouched:(UIButton *)sender {
    ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying = false;
    NSString *moviePath = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Configuración"] valueForKey:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Streaming URL Alta" : @"Streaming URL Media"];
    if ( [SlideNavigationController sharedInstance].topView ) {
        [((TSClipDetallesViewController *)[SlideNavigationController sharedInstance].topView) setURL:moviePath andTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveVideo", nil)]];
    } else {
        TSClipDetallesViewController *detailView = [[TSClipDetallesViewController alloc] initWithURL:moviePath andTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveVideo", nil)]];
        [[SlideNavigationController sharedInstance] addTopViewController:detailView];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    textfield.hidden = YES;
}

- (void) loadHomeData {
    /*
     if ( ![self isAPIHostAvailable] ) {
     return;
     }
     */
    [self showLoaderWithAnimation:YES cancelUserInteraction:YES withInitialView:YES];
    TSDataRequest *videosReq = [[TSDataRequest alloc] initWithType:[TSUtils TS2_CLIP_SLUG]   forSection:@"video-noticia" forSubsection:@""];
    TSDataRequest *intervReq = [[TSDataRequest alloc] initWithType:[TSUtils TS2_CLIP_SLUG]   forSection:@"entrevista"    forSubsection:@""];
    TSDataRequest *speciaReq = [[TSDataRequest alloc] initWithType:[TSUtils TS2_CLIP_SLUG]   forSection:@"especial-web"  forSubsection:@""];
    TSDataRequest *infogrReq = [[TSDataRequest alloc] initWithType:[TSUtils TS2_CLIP_SLUG]   forSection:@"infografias"   forSubsection:@""];

    infogrReq.range = speciaReq.range = intervReq.range = videosReq.range = NSMakeRange(1, [TSUtils TS2_HOME_CLIPS_PER_PAGE]);
    [[[TSDataManager alloc] init] loadRequests:[NSArray arrayWithObjects:videosReq, intervReq, speciaReq, infogrReq, nil] delegateResponseTo:self];
}

#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {
    TSDataRequest *videosRequest = [requests objectAtIndex:0];
    TSDataRequest *intervRequest = [requests objectAtIndex:1];
    TSDataRequest *speciaRequest = [requests objectAtIndex:2];
    TSDataRequest *infogrRequest = [requests objectAtIndex:3];

    tableItems = [NSMutableArray array];
    KABasicHCellData *highlights = [[KABasicHCellData alloc] init];
    highlights.hCellID = @"VideoHomeHighlightedTebleViewCell";
    highlights.pagerHidden = YES;
    highlights.hTableFrame = CGRectMake(0, 0, 320, 180);
    highlights.cellSize = CGSizeMake(263, 168);
    highlights.htableElements = [self getParsedClipsFromRequest:videosRequest];
    [tableItems addObject:highlights];

    KABasicHCellData *interv = [[KABasicHCellData alloc] init];
    interv.title = [[NSString stringWithFormat:@" %@", NSLocalizedString(@"entrevistaSection", nil)] uppercaseString];
    interv.cellID = @"HomeHSecondaryCarrouselTableViewCell";
    interv.hCellID = @"VideoHomeBasicTableViewCell";
    interv.pagerHidden = YES;
    interv.hTableFrame = CGRectMake(0, 25, 320, 350);
    interv.cellSize = CGSizeMake(255, 215);
    interv.htableElements = [self getParsedClipsFromRequest:intervRequest];
    [tableItems addObject:interv];

    KABasicHCellData *specia = [[KABasicHCellData alloc] init];
    specia.title = [[NSString stringWithFormat:@" %@", NSLocalizedString(@"especial-webSection", nil)] uppercaseString];
    specia.cellID = @"HomeHSecondaryCarrouselTableViewCell";
    specia.hCellID = @"VideoHomeBasicTableViewCell";
    specia.pagerHidden = YES;
    specia.hTableFrame = interv.hTableFrame;
    specia.cellSize = interv.cellSize;
    specia.htableElements = [self getParsedClipsFromRequest:speciaRequest];
    [tableItems addObject:specia];

    KABasicHCellData *infogr = [[KABasicHCellData alloc] init];
    infogr.title = [[NSString stringWithFormat:@" %@", NSLocalizedString(@"infografiaSection", nil)] uppercaseString];
    infogr.cellID = @"HomeHSecondaryCarrouselTableViewCell";
    infogr.hCellID = @"VideoHomeBasicTableViewCell";
    infogr.pagerHidden = YES;
    infogr.hTableFrame = interv.hTableFrame;
    infogr.cellSize = interv.cellSize;
    infogr.htableElements = [self getParsedClipsFromRequest:infogrRequest];
    [tableItems addObject:infogr];

    [self hideLoaderWithAnimation:YES];
    self.navigationController.navigationBarHidden = NO;
    self.tableView.hidden = NO;
    [self.tableView reloadData];

}

- (NSArray *) getParsedClipsFromRequest:(TSDataRequest *)request {
    NSMutableArray *parsedData = [NSMutableArray array];
    for ( uint i = 0; i < [request.result count]; i++ ) {
        NSDictionary *data = [request.result objectAtIndex:i];
        KABasicCellData *cellData = [[KABasicCellData alloc] init];
        BOOL isRSS = [data isKindOfClass:[MWFeedItem class]];
        NSString *clipType = isRSS ? nil : [[data valueForKey:@"tipo"] valueForKey:@"slug"];
        BOOL switchTitles = [clipType isEqualToString:@"programa"];
        cellData.title = switchTitles ? [self setDataForVideoItem:data withType:clipType] : [data objectForKey:@"titulo"];
        //truena
        cellData.summary = switchTitles ? [data objectForKey:@"titulo"] : [self setDataForVideoItem:data withType:clipType];
        cellData.URL = [data objectForKey:@"archivo_url"];
        KABasicImageData *image = [[KABasicImageData alloc] init];
        image.thumbURL = [data objectForKey:@"thumbnail_mediano"];
        cellData.images = [NSArray arrayWithObject:image];
        cellData.rawData = data;
        [parsedData addObject:cellData];
    }
    return  [NSArray arrayWithArray:parsedData];
}

- (NSString *) setDataForVideoItem:(NSDictionary *)data withType:(NSString *)clipType {
    BOOL switchTitles = [clipType isEqualToString:@"programa"];
    NSObject *category = [data valueForKey:@"categoria"];
    if(category != [NSNull null]) {
        return [category valueForKey:@"nombre"];
    } else if(switchTitles) {
        return [[data valueForKey:@"titulo"] uppercaseString];
    } else if(clipType) {
        return [[data valueForKey:@"tipo"] valueForKey:@"nombre"];
    }
    return switchTitles ? @"" : [data valueForKey:@"titulo"];
}

- (KABasicCellData *) getParsedTextNewsFromMWFeedItem:(MWFeedItem *)item {
    if ( ![item isKindOfClass:[MWFeedItem class]] ) {
        return nil;
    }
    return [self setData:item toCellData:[[KABasicCellData alloc] init]];
}

- (KABasicCellData *) setData:(MWFeedItem *)item toCellData:(KABasicCellData *)data {
    data.title = item.title;
    data.summary = item.category;
    data.type = item.summary;
    data.URL = item.link;
    data.rawData = item;
    if ( [(NSDictionary *)[item.enclosures objectAtIndex:0] objectForKey:@"url"] ) {
        KABasicImageData *image = [[KABasicImageData alloc] init];
        image.title = [(NSDictionary *)[item.enclosures objectAtIndex:0] objectForKey:@"alt"];
        image.summary = [(NSDictionary *)[item.enclosures objectAtIndex:0] objectForKey:@"alt"];
        image.thumbURL = [(NSDictionary *)[item.enclosures objectAtIndex:0] objectForKey:@"url"];
        data.images = [NSArray arrayWithObject:image];
    }
    return data;
}

- (void) TSDataManager:(TSDataManager *)manager didProcessedNotificationRequests:(NSArray *)requests {
    
}


#pragma mark -
#pragma mark Table view data source
/*
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 return [tableItems count];
 }
 
 
 -(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 return 3;
 }
 */
/*
 - (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 return [super tableView:tableView cellForRowAtIndexPath:[self parseIndexPath:indexPath]];
 }
 */

/*
 - (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 return [super tableView:tableView heightForRowAtIndexPath:[self parseIndexPath:indexPath]];
 }
 */
/*
 - (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
 
 }
 */
/*
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
 UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
 view.backgroundColor = [UIColor blackColor];
 UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(40, 8, 130, 20)];
 title.font = [UIFont fontWithName:@"Roboto-Regular" size:18];
 title.textColor = [UIColor whiteColor];
 UIImageView *imageView;
 if( section == 0 ) {
 NSString *newsTitle = [NSString stringWithFormat:@"%@", NSLocalizedString(@"noticiasSection", nil)];
 title.text = [newsTitle uppercaseString];
 imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noticias.png"]];
 } else if( section == 1 ) {
 NSString *videoTitle = [NSString stringWithFormat:@"%@", NSLocalizedString(@"videoSection", nil)];
 title.text = [videoTitle uppercaseString];
 imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video.png"]];
 } else {
 NSString *showTitle = [NSString stringWithFormat:NSLocalizedString(@"programaSection", nil)];
 title.text = [showTitle uppercaseString];
 imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"programa.png"]];
 }
 imageView.frame = CGRectMake(10, 9, imageView.frame.size.width * 0.6, imageView.frame.size.height * 0.6);
 [view addSubview:title];
 [view addSubview:imageView];
 return view;
 }
 
 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
 return 36;
 }
 */
- (void) didSelectRowWithData:(KABasicCellData *)item {
    NSLog(@"didSelectRowWithData:%@", item);
    BOOL isRSS = [item.rawData isKindOfClass:[MWFeedItem class]];
    if (isRSS) {
        [self showSelectedPost:(MWFeedItem *)item.rawData];
    } else {
        [self playSelectedClip:item];
    }
}

- (void)playSelectedClip:(KABasicCellData *)cellData {
    if(((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying) {
        ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying = NO;
        [((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).currentPlayer.moviePlayer stop];
        [((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).currentPlayer.view removeFromSuperview];
        ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).currentPlayer = nil;
    }
    if ( [SlideNavigationController sharedInstance].topView ) {
        [((TSClipDetallesViewController *)[SlideNavigationController sharedInstance].topView) setData:(NSDictionary *)cellData.rawData andSection:[self getSectionTitleWith:@"home"]];
    } else {
        TSClipDetallesViewController *detailView = [[TSClipDetallesViewController alloc] initWithData:(NSDictionary *)cellData.rawData andSection:[self getSectionTitleWith:@"home"]];
        [[SlideNavigationController sharedInstance] addTopViewController:detailView];
    }
}

- (NSString *) getSectionTitleWith:(NSString *)slug {
    NSString *localizeID = [NSString stringWithFormat:@"%@Section", slug];
    return [NSString stringWithFormat:NSLocalizedString(localizeID, nil)];
}

/*
 - (void) loadQueueDidLoad:(NSArray *)requests {
 
 [super loadQueueDidLoad:requests];
 KADataRequest *uportada = [requests objectAtIndex:0];
 KADataRequest *ucover = [requests objectAtIndex:1];
 KADataRequest *udir = [requests objectAtIndex:2];
 KADataRequest *blogs = [requests objectAtIndex:3];
 
 tableItems = [NSMutableArray arrayWithArray:ucover.responseParsed];
 
 KABasicCellData *portada = [[KABasicCellData alloc] init];
 portada.title = @"ÚLTIMAS NOTICIAS";
 portada.cancelUserInteraction = YES;
 portada.cellSize = CGSizeMake(320, 26);
 //    portada.summary = [self getFormattedDateFromJOContent:uportada];
 [tableItems insertObject:portada atIndex:0];
 
 KABasicHCellData *highlights = [[KABasicHCellData alloc] init];
 highlights.title = @"Portada";
 highlights.hCellID = @"JOLatestHTableCellView";
 highlights.cellSize = CGSizeMake(320, 200);
 highlights.htableElements = uportada.responseParsed;
 [tableItems insertObject:highlights atIndex:1];
 
 KABasicHCellData *opinion = [[KABasicHCellData alloc] init];
 opinion.htableElements = blogs.responseParsed;
 //    opinion.htableElements = uportada.responseParsed;
 opinion.title = @"Blogs";
 opinion.summary = @"";
 opinion.cellID = @"JOLatestSpecialSectionCellView";
 opinion.hCellID = @"JOLatestSpecialSectionHCellView";
 opinion.cellSize = CGSizeMake(320, 175);
 opinion.hTableFrame = CGRectMake(0, 25, 320, 150);
 opinion.hPagerFrame = CGRectMake(200, 3, 100, 20);
 opinion.type = @"opinion";
 //    tableItems = [NSMutableArray arrayWithObjects:portada, opinion, nil];
 NSMutableDictionary *foundSections = [NSMutableDictionary dictionaryWithObject:opinion forKey:opinion.type];
 for ( uint i = 0; i < [udir.responseParsed count]; i++) {
 KABasicCellData *item = [udir.responseParsed objectAtIndex:i];
 NSString *section = [item.rawData objectForKey:@"section"];
 if( ![foundSections objectForKey:section] ) {
 NSLog(@"Section added : %@", section);
 NSString *temp = [item.title copy];
 //            item.title = [self getJOTitleForSection:section];
 item.summary = [temp copy];
 item.cellID = @"JOLatestSectionCellView";
 item.type = section;
 [foundSections setObject:item forKey:section];
 }
 }
 uDIRContent = [[self getLoadRequestResponseContent:udir.responseRaw] copy];
 NSArray *sectionsOrder =  @[@"opinion", @"politica", @"economia", @"mundo", @"estados", @"capital", @"sociedad", @"ciencias", @"cultura", @"espectaculos", @"deportes"];
 for ( uint i = 0; i < [sectionsOrder count]; i++) {
 if ( [foundSections objectForKey:[sectionsOrder objectAtIndex:i]] ) {
 [tableItems insertObject:[foundSections objectForKey:[sectionsOrder objectAtIndex:i]] atIndex:[tableItems count]];
 }
 }
 [((UIRefreshControl *)[self.view viewWithTag:2010]) endRefreshing];
 [self.tableView reloadData];
 }
 */

- (void)showSelectedPost:(MWFeedItem *)post {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
    TSNewsViewController *detailView = [mainStoryboard instantiateViewControllerWithIdentifier: @"TSNewsViewController"];
    [detailView initWithData:post];
    [self.navigationController pushViewController:detailView animated:YES];
}

- (UIView *) configureCell:(UIView *)cell withData:(KABasicCellData *)data {
    NSLog( @"%@", data.cellID );
    if ( [data.cellID isEqualToString:@"HomeTopTableViewCell"] ) {
        [cell setupHighlightedViewCell:data.cellIndex % 2 == 0];
    } else if ( [data.cellID isEqualToString:@"HomeVideoTableViewCell"] ) {
        [cell setupVideoViewCell];
    } else if ( [data.cellID isEqualToString:@"VideoHomeBasicTableViewCell"] ) {
        [cell setupVideoHomeViewCell];
        [cell setupVideoIcon:CGRectMake(110, 36, 35, 35)];
    } else if ( [data.cellID isEqualToString:@"VideoHomeHighlightedTebleViewCell"] ) {
        [cell setupVideoCarrouselViewCell:data.cellIndex % 2 == 0];
        [cell setupVideoIcon:CGRectMake(140, 50, 40, 40)];
    } else if ( [data.cellID isEqualToString:@"HomeShowTableViewCell"] ) {
        [cell setupShowCarrouselViewCell:data.cellIndex % 3];
    }
    
    [super configureCell:cell withData:data];
    
    if ( [data.cellID isEqualToString:@"HomeTopTableViewCell"] ) {
        [cell fitSizesHighlightedViewCell];
    } else if ( [data.cellID isEqualToString:@"HomeVideoTableViewCell"] ) {
        [cell fitSizesVideoViewCell];
    } else if ( [data.cellID isEqualToString:@"VideoHomeBasicTableViewCell"] ) {
        [cell fitSizesVideoHomeViewCell];
    } else if ( [data.cellID isEqualToString:@"VideoHomeHighlightedTebleViewCell"] ) {
        [cell fitSizesVideoCarrouselViewCell];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
}























#pragma mark -
#pragma mark SlideNavigationController

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayTopMenu {
    return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayBottomMenu {
    return NO;
}











- (UITableViewCell *) setHTableAtCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath withID:(NSString *)cellID {
    cell = [super setHTableAtCell:cell forIndexPath:indexPath withID:cellID];
    KABasicHCellData *cellData = [tableItems objectAtIndex:indexPath.row];
    if ( cellData.title ) {
        ((UILabel *)[cell viewWithTag:9900]).text = cellData.title;
    }
    return cell;
}


@end
