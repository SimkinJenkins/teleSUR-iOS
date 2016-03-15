//
//  TSMainHomeViewController.m
//  teleSUR
//
//  Created by Simkin on 17/02/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import "TSMainHomeViewController.h"

@implementation TSMainHomeViewController

NSInteger const TS2_ITEMS_PER_PAGE = 15;
NSInteger const TS2_HOME_CLIPS_PER_PAGE = 10;
NSString* const TS2_TIPO_CLIP_SLUG = @"tipo_clip";
NSString* const TS2_CLIP_SLUG = @"clip";
NSString* const TS2_PROGRAMA_SLUG = @"programa";
NSString* const TS2_NOTICIAS_SLUG = @"noticias-texto";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.tableView.hidden = YES;
    [self configureMenu];
    [self configRightButton];
    [self loadHomeData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    textfield.hidden = YES;
}

- (void) loadData {
    [self loadRequestsArray:[self getLatestNewsHomeRequest]];
}

- (void) loadHomeData {
/*
    if ( ![self isAPIHostAvailable] ) {
        return;
    }
*/
    [self showLoaderWithAnimation:YES cancelUserInteraction:YES withInitialView:YES];
    TSDataRequest *clipCatReq   = [[TSDataRequest alloc] initWithType:TS2_TIPO_CLIP_SLUG  forSection:nil               forSubsection:nil];
    TSDataRequest *showCatReq   = [[TSDataRequest alloc] initWithType:TS2_PROGRAMA_SLUG   forSection:nil               forSubsection:nil];
    TSDataRequest *RSSReq       = [[TSDataRequest alloc] initWithType:TS2_NOTICIAS_SLUG   forSection:@"noticias"       forSubsection:nil];
    TSDataRequest *videoReq     = [[TSDataRequest alloc] initWithType:TS2_CLIP_SLUG       forSection:@"video-noticia"  forSubsection:@""];
    TSDataRequest *showReq      = [[TSDataRequest alloc] initWithType:TS2_CLIP_SLUG       forSection:@"programa"       forSubsection:@""];
    TSDataRequest *breaknewsReq = [[TSDataRequest alloc] initWithType:TS2_NOTICIAS_SLUG   forSection:@"noticias"       forSubsection:@"ultimas"];
    clipCatReq.range = NSMakeRange(1, 300);
    showCatReq.range = NSMakeRange(1, 300);
    videoReq.range = NSMakeRange(1, TS2_HOME_CLIPS_PER_PAGE);
    showReq.range = NSMakeRange(1, TS2_HOME_CLIPS_PER_PAGE);
    [[[TSDataManager alloc] init] loadRequests:[NSArray arrayWithObjects:clipCatReq, showCatReq, RSSReq, videoReq, showReq, breaknewsReq, nil]
                            delegateResponseTo:self];
}

#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {
    TSDataRequest *catalogClipType = [requests objectAtIndex:0];
    TSDataRequest *catalogPrograms = [requests objectAtIndex:1];
    TSDataRequest *textNewsRequest = [requests objectAtIndex:2];
    TSDataRequest *videosRequest = [requests objectAtIndex:3];
    videosCount = [videosRequest.result count];
    TSDataRequest *showsRequest = [requests objectAtIndex:4];
    showsCount = [showsRequest.result count];
    TSDataRequest *latestRequest = [requests objectAtIndex:5];
    tableItems = [NSMutableArray array];
    KABasicHCellData *highlights = [[KABasicHCellData alloc] init];
    highlights.title = @"Portada";
    highlights.hCellID = @"HomeTopTableViewCell";
    highlights.cellSize = CGSizeMake(320, 200);
    highlights.htableElements = highlightedElements = [self getParsedTextNewsFromRequest:textNewsRequest];
    [tableItems addObject:highlights];
    [tableItems addObjectsFromArray:[self getParsedClipsFromRequest:videosRequest]];
    [tableItems addObjectsFromArray:[self getParsedClipsFromRequest:showsRequest]];
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
        cellData.summary = switchTitles ? [data objectForKey:@"titulo"] : [self setDataForVideoItem:data withType:clipType];
        cellData.URL = [data objectForKey:@"archivo_url"];

        KABasicImageData *image = [[KABasicImageData alloc] init];
//        image.title = [data objectForKey:@"alt"];
//        image.summary = [data objectForKey:@"alt"];
        image.thumbURL = [data objectForKey:@"thumbnail_mediano"];

        cellData.images = [NSArray arrayWithObject:image];
        cellData.rawData = data;

        cellData.cellID = @"HomeVideoTableViewCell";
        cellData.cellSize = CGSizeMake(320, 89);

        [parsedData addObject:cellData];
    }
    return  [NSArray arrayWithArray:parsedData];
}

- (NSString *) setDataForVideoItem:(NSDictionary *)data withType:(NSString *)clipType {
    BOOL switchTitles = [clipType isEqualToString:@"programa"];
    NSObject *category = [data valueForKey:@"categoria"];
    if(category != [NSNull null]) {
        return [[category valueForKey:@"nombre"] uppercaseString];
    } else if(switchTitles) {
        return [[data valueForKey:@"titulo"] uppercaseString];
    } else if(clipType) {
        return [[[data valueForKey:@"tipo"] valueForKey:@"nombre"] uppercaseString];
    }
    return switchTitles ? @"" : [data valueForKey:@"titulo"];
}

- (NSArray *) getParsedTextNewsFromRequest:(TSDataRequest *)request {
    NSMutableArray *parsedData = [NSMutableArray array];
    for ( uint i = 0; i < [request.result count]; i++ ) {
        MWFeedItem *item = [request.result objectAtIndex:i];
        if ( [item isKindOfClass:[MWFeedItem class]] ) {
            KABasicCellData *cellData = [[KABasicCellData alloc] init];
            cellData.title = item.title;
            cellData.summary = item.category;
            cellData.type = item.summary;
            cellData.URL = item.link;
            cellData.rawData = item;

            KABasicImageData *image = [[KABasicImageData alloc] init];
            image.title = [(NSDictionary *)[item.enclosures objectAtIndex:0] objectForKey:@"alt"];
            image.summary = [(NSDictionary *)[item.enclosures objectAtIndex:0] objectForKey:@"alt"];
            image.thumbURL = [(NSDictionary *)[item.enclosures objectAtIndex:0] objectForKey:@"url"];

            cellData.images = [NSArray arrayWithObject:image];
            [parsedData addObject:cellData];
        }
    }
    return [NSArray arrayWithArray:parsedData];
}

- (void) TSDataManager:(TSDataManager *)manager didProcessedNotificationRequests:(NSArray *)requests {
    
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( section == 0) {
        return 1;
    } else if ( section == 1 ) {
        return videosCount;
    }
    return showsCount;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView cellForRowAtIndexPath:[self parseIndexPath:indexPath]];
}

- (NSIndexPath *) parseIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == 1 ) {
        return [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:1];
    } else if ( indexPath.section == 2 ) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row + videosCount + 1 inSection:2];
    }
    return indexPath;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView heightForRowAtIndexPath:[self parseIndexPath:indexPath]];
}

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
}

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
        [((TSClipDetallesViewController *)[SlideNavigationController sharedInstance].topView) setData:cellData.rawData andSection:[self getSectionTitleWith:@"home"]];
    } else {
        TSClipDetallesViewController *detailView = [[TSClipDetallesViewController alloc] initWithData:cellData.rawData andSection:[self getSectionTitleWith:@"home"]];
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

- (void) configureMenu {
    //Configurar Menu Lateral
    [SlideNavigationController sharedInstance].panGestureSideOffset = 50;
    [SlideNavigationController sharedInstance].enableShadow = NO;
    ((LeftMenuViewController *)[SlideNavigationController sharedInstance].leftMenu).slideOutAnimationEnabled = NO;
    [SlideNavigationController sharedInstance].portraitSlideOffset = 95;

    //Crear Header
    headerMenu = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 225, 35)];
    headerMenu.backgroundColor = [TSUtils colorRedNavigationBar];

    UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-menu-header.png"]];
    leftImage.frame = CGRectMake(0, 0, 21, 23);

    UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-menu-header.png"]];
    rightImage.frame = CGRectMake(0, 0, 13, 7);

    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar addSubview:headerMenu];

    //Crear Menu Superior
    textfield = [[UITextField alloc] initWithFrame: CGRectMake(0, 3, 225, 35)];
    textfield.font = [UIFont fontWithName:@"Helvetica-Bold" size:2];
    textfield.textColor = [UIColor whiteColor];
    textfield.textAlignment = NSTextAlignmentCenter;

    NSString *titleLocalizedID = @"homeSection";
    [self setNavigationTitle:[NSString stringWithFormat:NSLocalizedString(titleLocalizedID, nil)]];

    [textfield setLeftViewMode:UITextFieldViewModeAlways];
    textfield.leftView = leftImage;

    [textfield setRightViewMode:UITextFieldViewModeAlways];
    textfield.rightView = rightImage;

    [headerMenu addSubview:textfield];
    textMenu = [[UIDropDownMenu alloc] initWithIdentifier:@"menu"];

    textMenu.ScaleToFitParent = TRUE;
    textMenu.delegate = self;
    textMenu.menuTextAlignment = NSTextAlignmentCenter;
}

- (void) setNavigationTitle:(NSString *)title {
    CGSize stringsize = [self frameForText:title
                              sizeWithFont:textfield.font
                         constrainedToSize:CGSizeMake(170, textfield.frame.size.height)
                             lineBreakMode:NSLineBreakByWordWrapping];
    textfield.text = title;
    float tfWidth = stringsize.width + 44;
    [textfield setFrame:CGRectMake((225 - tfWidth) * .5, 3, tfWidth, 35)];
    self.navigationItem.title = title;
}

- (void) configRightButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"senal.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(videoLiveButtonTouched:)];
}

- (void)showSelectedPost:(MWFeedItem *)post {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
    TSNewsViewController *detailView = [mainStoryboard instantiateViewControllerWithIdentifier: @"TSNewsViewController"];
    [detailView initWithData:post];
    [self.navigationController pushViewController:detailView animated:YES];
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

- (UIView *) configureCell:(UIView *)cell withData:(KABasicCellData *)data {
    NSLog( @"%@", data.cellID );
    if ( [data.cellID isEqualToString:@"HomeTopTableViewCell"] ) {
        [cell setupHighlightedViewCell];
    } else if ( [data.cellID isEqualToString:@"HomeVideoTableViewCell"] ) {
        [cell setupVideoViewCell];
    }
    [super configureCell:cell withData:data];
    if ( [data.cellID isEqualToString:@"HomeTopTableViewCell"] ) {
        [cell fitSizesHighlightedViewCell];
    } else if ( [data.cellID isEqualToString:@"HomeVideoTableViewCell"] ) {
        [cell fitSizesVideoViewCell];
    }
    return cell;
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

@end