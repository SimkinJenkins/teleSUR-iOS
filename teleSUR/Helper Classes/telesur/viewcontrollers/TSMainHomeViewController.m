//
//  TSMainHomeViewController.m
//  teleSUR
//
//  Created by Simkin on 17/02/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import "TSMainHomeViewController.h"

@implementation TSMainHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.tableView.hidden = YES;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self configRightButton];
    [self loadHomeData];
    [(TSiPhoneNavigationController *)[SlideNavigationController sharedInstance] configureMenu];
}

- (void) loadHomeData {
/*
    if ( ![self isAPIHostAvailable] ) {
        return;
    }
*/
    [self showLoaderWithAnimation:YES cancelUserInteraction:YES withInitialView:YES];
    TSDataRequest *clipCatReq   = [[TSDataRequest alloc] initWithType:[TSUtils TS2_TIPO_CLIP_SLUG]  forSection:nil               forSubsection:nil];
    TSDataRequest *showCatReq   = [[TSDataRequest alloc] initWithType:[TSUtils TS2_PROGRAMA_SLUG]   forSection:nil               forSubsection:nil];
    TSDataRequest *RSSReq       = [[TSDataRequest alloc] initWithType:[TSUtils TS2_NOTICIAS_SLUG]   forSection:@"noticias"       forSubsection:nil];
    TSDataRequest *videoReq     = [[TSDataRequest alloc] initWithType:[TSUtils TS2_CLIP_SLUG]       forSection:@"video-noticia"  forSubsection:@""];
    TSDataRequest *showReq      = [[TSDataRequest alloc] initWithType:[TSUtils TS2_CLIP_SLUG]       forSection:@"programa"       forSubsection:@""];
//    TSDataRequest *breaknewsReq = [[TSDataRequest alloc] initWithType:TS2_NOTICIAS_SLUG   forSection:@"noticias"       forSubsection:@"ultimas"];
    clipCatReq.range = NSMakeRange(1, 300);
    showCatReq.range = NSMakeRange(1, 300);
    videoReq.range = NSMakeRange(1, [TSUtils TS2_HOME_CLIPS_PER_PAGE]);
    showReq.range = NSMakeRange(1, [TSUtils TS2_HOME_CLIPS_PER_PAGE]);
    [[[TSDataManager alloc] init] loadRequests:[NSArray arrayWithObjects:clipCatReq, showCatReq, RSSReq, videoReq, showReq/*, breaknewsReq*/, nil] delegateResponseTo:self];
}

#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {
    TSDataRequest *catalogClipType = [requests objectAtIndex:0];
    TSDataRequest *catalogPrograms = [requests objectAtIndex:1];
    TSDataRequest *textNewsRequest = [requests objectAtIndex:2];
    TSDataRequest *videosRequest = [requests objectAtIndex:3];
    videosCount = (uint)[videosRequest.result count];
    TSDataRequest *showsRequest = [requests objectAtIndex:4];
    showsCount = (uint)[showsRequest.result count];
//    TSDataRequest *latestRequest = [requests objectAtIndex:5];
    tableItems = [NSMutableArray array];
    KABasicHCellData *highlights = [[KABasicHCellData alloc] init];
    highlights.title = @"Portada";
    highlights.hCellID = @"HomeTopTableViewCell";
    highlights.pagerHidden = YES;
    highlights.hTableFrame = CGRectMake(0, 0, 320, 128);
    highlights.cellSize = CGSizeMake(260, 128);
    highlightedElements = [self getParsedTextNewsFromRequest:textNewsRequest];
    highlights.htableElements = [highlightedElements subarrayWithRange:NSMakeRange(0, 5)];
    highlightedElements = [highlightedElements subarrayWithRange:NSMakeRange(5, [highlightedElements count] - 5)];
    [tableItems addObject:highlights];

    int middle = (uint)[highlightedElements count] / 2;
    [tableItems addObjectsFromArray:[highlightedElements subarrayWithRange:NSMakeRange(0, middle)]];
    highlightedElements = [highlightedElements subarrayWithRange:NSMakeRange(middle, [highlightedElements count] - middle)];

    KABasicHCellData *shows = [[KABasicHCellData alloc] init];
    shows.title = @"PROGRAMAS";
    shows.cellID = @"HomeHSecondaryCarrouselTableViewCell";
    shows.hCellID = @"HomeShowTableViewCell";
    shows.pagerHidden = YES;
    shows.hTableFrame = CGRectMake(0, 25, 320, 130);
    shows.cellSize = CGSizeMake(130, 85);
    shows.htableElements = [self getParsedClipsFromRequest:showsRequest];
    [tableItems addObject:shows];

    [tableItems addObjectsFromArray:[highlightedElements subarrayWithRange:NSMakeRange(0, [highlightedElements count])]];

    KABasicHCellData *videos = [[KABasicHCellData alloc] init];
    videos.title = @"VIDEOS DESTACADOS";
    videos.cellID = @"HomeHSecondaryCarrouselTableViewCell";
    videos.hCellID = @"HomeVideoCarrouselTableViewCell";
    videos.pagerHidden = YES;
    videos.hTableFrame = CGRectMake(0, 30, 320, 120);
    videos.cellSize = CGSizeMake(200, 150);
    videos.htableElements = [self getParsedClipsFromRequest:videosRequest];
    [tableItems addObject:videos];

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

- (NSArray *) getParsedTextNewsFromRequest:(TSDataRequest *)request {
    NSMutableArray *parsedData = [NSMutableArray array];
    uint middle = ceil(([request.result count] - 5) / 2);
    for ( uint i = 0; i < [request.result count]; i++ ) {
        MWFeedItem *item = [request.result objectAtIndex:i];
        KABasicCellData *cellData = i > 4 ? [self getDoubleParsedTextNewsFromMWFeedItem:item] : [self getParsedTextNewsFromMWFeedItem:item];
        if ( cellData ) {
            if ( i > 4 ) {
                cellData.cellID = [self getCellIDForSimpleIndex:i < middle + 5 ? i - 5 : i - (middle + 5) forATotal: i < middle + 5 ? middle : [request.result count] - (5 + middle)];
                cellData.cellSize = [cellData.cellID isEqualToString:@"HomeDoubleTableViewCell"] ? CGSizeMake(320, 160) : CGSizeMake(320, 235);
                if ( [cellData.cellID isEqualToString:@"HomeDoubleTableViewCell"] && i + 1 < [request.result count] ) {
                    ((KABasicDoubleCellData *)cellData).extraData = [self getParsedTextNewsFromMWFeedItem:[request.result objectAtIndex:i + 1]];
                    i++;
                }
            }
            [parsedData addObject:cellData];
        }
    }
    return [NSArray arrayWithArray:parsedData];
}

- (NSString *) getCellIDForSimpleIndex:(uint)index forATotal:(uint)total {
    NSLog(@"getCellIDForSimpleIndex : %d from %d", index, total);
    if ( total == 2 || total == 3 || total == 5 ) {
        return index == 2 ? @"HomeSingleImageNewsTableViewCell" : @"HomeDoubleTableViewCell";
    } else if ( total == 4 || total == 6 || total == 7 ) {
        return index == 1 || index == 4 ? @"HomeDoubleTableViewCell" : @"HomeSingleImageNewsTableViewCell";
    } else if ( total == 8 ) {
        return index == 0 || index == 3 || index == 6 ? @"HomeDoubleTableViewCell" : @"HomeSingleImageNewsTableViewCell";
    }
    return @"HomeDoubleTableViewCell";
}

- (KABasicCellData *) getParsedTextNewsFromMWFeedItem:(MWFeedItem *)item {
    if ( ![item isKindOfClass:[MWFeedItem class]] ) {
        return nil;
    }
    return [self setData:item toCellData:[[KABasicCellData alloc] init]];
}

- (KABasicCellData *) getDoubleParsedTextNewsFromMWFeedItem:(MWFeedItem *)item {
    if ( ![item isKindOfClass:[MWFeedItem class]] ) {
        return nil;
    }
    return [self setData:item toCellData:[[KABasicDoubleCellData alloc] init]];
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

- (NSIndexPath *) parseIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.section == 1 ) {
        return [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:1];
    } else if ( indexPath.section == 2 ) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row + videosCount + 1 inSection:2];
    }
    return indexPath;
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

- (void)showSelectedPost:(MWFeedItem *)post {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];
    TSNewsViewController *detailView = [mainStoryboard instantiateViewControllerWithIdentifier: @"TSNewsViewController"];
    [detailView initWithData:post];
    [self.navigationController pushViewController:detailView animated:YES];
}

- (void) configRightButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"senal.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(videoLiveButtonTouched:)];
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
        [cell setupHighlightedViewCell:data.cellIndex % 2 == 0];
    } else if ( [data.cellID isEqualToString:@"HomeVideoTableViewCell"] ) {
        [cell setupVideoViewCell];
    } else if ( [data.cellID isEqualToString:@"HomeDoubleTableViewCell"] ) {
        [cell setupDoubleViewCellWithColor:[TSUtils colorRedNavigationBar]];
    } else if ( [data.cellID isEqualToString:@"HomeSingleImageNewsTableViewCell"] ) {
        [cell setupSingleImageViewCellWithColor:[TSUtils colorRedNavigationBar]];
    } else if ( [data.cellID isEqualToString:@"HomeVideoCarrouselTableViewCell"] ) {
        [cell setupVideoCarrouselViewCell:data.cellIndex % 2 == 0];
        [cell setupVideoIcon:CGRectMake(90, 28, 35, 35)];
    } else if ( [data.cellID isEqualToString:@"HomeShowTableViewCell"] ) {
        [cell setupShowCarrouselViewCell:data.cellIndex % 3];
    }

    [super configureCell:cell withData:data];

    if ( [data.cellID isEqualToString:@"HomeTopTableViewCell"] ) {
        [cell fitSizesHighlightedViewCell];
    } else if ( [data.cellID isEqualToString:@"HomeVideoTableViewCell"] ) {
        [cell fitSizesVideoViewCell];
    } else if ( [data.cellID isEqualToString:@"HomeDoubleTableViewCell"] ) {
        if ( [data isKindOfClass:[KABasicDoubleCellData class]] ) {
            [super configureCell:cell withData:((KABasicDoubleCellData *)data).extraData withTitle:[cell viewWithTag:10101] andSecondaryText:[cell viewWithTag:10102]];
        } else {
            [cell viewWithTag:9100].hidden = YES;
        }
        [cell fitSizesDoubleViewCell];
    } else if ( [data.cellID isEqualToString:@"HomeSingleImageNewsTableViewCell"] ) {
        [cell fitSizesSingleImageViewCell];
    } else if ( [data.cellID isEqualToString:@"HomeVideoCarrouselTableViewCell"] ) {
        [cell fitSizesVideoCarrouselViewCell];
    }
    return cell;
}
/*
- (void)configureCellImage:(UIView *)cell forIndexPath:(NSIndexPath *)indexPath {
    [super configureCellImage:cell forIndexPath:[self parseIndexPath:indexPath]];
}
*/
- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void) configureCellImage:(UIView *)cell withData:(KABasicCellData *)data {
    if ( [data isKindOfClass:[KABasicDoubleCellData class]] && ((KABasicDoubleCellData *)data).extraData ) {
        [super configureCellImage:cell withImageVW:(UIImageView *)[cell viewWithTag:9100] withData:((KABasicDoubleCellData *)data).extraData];
    }
    [super configureCellImage:cell withImageVW:(UIImageView *)[cell viewWithTag:9000] withData:data];

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