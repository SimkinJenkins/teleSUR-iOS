//
//  TSTextNewsHomeViewController.m
//  teleSUR
//
//  Created by Simkin on 20/04/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import "TSTextNewsHomeViewController.h"

@implementation TSTextNewsHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configRightButton];
    [self loadHomeData];
    self.tableView.backgroundColor = [UIColor whiteColor];
}

- (void) loadHomeData {
    /*
     if ( ![self isAPIHostAvailable] ) {
     return;
     }
     */
    [self showLoaderWithAnimation:YES cancelUserInteraction:YES withInitialView:YES];
    TSDataRequest *RSSReq = [[TSDataRequest alloc] initWithType:[TSUtils TS2_NOTICIAS_SLUG] forSection:@"noticias" forSubsection:nil];
    [[[TSDataManager alloc] init] loadRequests:[NSArray arrayWithObjects:RSSReq, nil] delegateResponseTo:self];
}

#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {
    TSDataRequest *textNewsRequest = [requests objectAtIndex:0];
    tableItems = [NSMutableArray array];
    [tableItems addObject:[self getParsedTextNewsFromRequest:textNewsRequest]];
    [self hideLoaderWithAnimation:YES];
    [self.tableView reloadData];
}

- (NSArray *) getParsedTextNewsFromRequest:(TSDataRequest *)request {
    NSMutableArray *parsedData = [NSMutableArray array];
    BOOL onOff = YES;
    for ( uint i = 0; i < [request.result count]; i++ ) {
        MWFeedItem *item = [request.result objectAtIndex:i];
        KABasicCellData *cellData = i + 1 < [request.result count] && onOff ? [self getDoubleParsedTextNewsFromMWFeedItem:item] : [self getParsedTextNewsFromMWFeedItem:item];
        NSLog(@"%d - %d - %@ - %@", i, onOff, cellData.cellID, cellData);
        if ( cellData ) {
            cellData.cellID = onOff ? @"HomeDoubleTableViewCell" : @"HomeSingleImageNewsTableViewCell" ;
            cellData.cellSize = [cellData.cellID isEqualToString:@"HomeDoubleTableViewCell"] ? CGSizeMake(320, 160) : CGSizeMake(320, 235);
            if ( [cellData.cellID isEqualToString:@"HomeDoubleTableViewCell"] && i + 1 < [request.result count] ) {
                ((KABasicDoubleCellData *)cellData).extraData = [self getParsedTextNewsFromMWFeedItem:[request.result objectAtIndex:i + 1]];
                i++;
            }
            [parsedData addObject:cellData];
        }
        onOff = !onOff;
    }
    return [NSArray arrayWithArray:parsedData];
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

- (void) didSelectRowWithData:(KABasicCellData *)item {
    [self showSelectedPost:(MWFeedItem *)item.rawData];
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
//    NSLog( @"%@", data.cellID );
    if ( [data.cellID isEqualToString:@"HomeDoubleTableViewCell"] ) {
        [cell setupDoubleViewCellWithColor:[TSUtils colorRedNavigationBar]];
    } else if ( [data.cellID isEqualToString:@"HomeSingleImageNewsTableViewCell"] ) {
        [cell setupSingleImageViewCellWithColor:[TSUtils colorRedNavigationBar]];
    }

    [super configureCell:cell withData:data];

    if ( [data.cellID isEqualToString:@"HomeDoubleTableViewCell"] ) {
        if ( [data isKindOfClass:[KABasicDoubleCellData class]] ) {
            [super configureCell:cell withData:((KABasicDoubleCellData *)data).extraData withTitle:[cell viewWithTag:10101] andSecondaryText:[cell viewWithTag:10102]];
        } else {
            [cell viewWithTag:9100].hidden = YES;
        }
        [cell fitSizesDoubleViewCell];
    } else if ( [data.cellID isEqualToString:@"HomeSingleImageNewsTableViewCell"] ) {
        [cell fitSizesSingleImageViewCell];
    }
    return cell;
}

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







@end
