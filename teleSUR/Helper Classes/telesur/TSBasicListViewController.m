//
//  TSBasicListViewController.m
//  teleSUR
//
//  Created by Simkin on 22/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSBasicListViewController.h"
#import "TSDataManager.h"

#import "UIViewController+TSLoader.h"

#import "TSWebViewController.h"

NSInteger const TS_ITEMS_PER_PAGE = 15;
NSInteger const TS_HOME_CLIPS_PER_PAGE = 10;
NSString* const TS_TIPO_CLIP_SLUG = @"tipo_clip";
NSString* const TS_CLIP_SLUG = @"clip";
NSString* const TS_PROGRAMA_SLUG = @"programa";
NSString* const TS_NOTICIAS_SLUG = @"noticias-texto";

@implementation TSBasicListViewController

@synthesize currentFilters;


#pragma mark - View init

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self initViewVariables];
    }

    return self;
}



















#pragma mark - View lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];

    [self initTableVariables];
    [self loadData];

}



















#pragma mark - Custom Public Functions

- (void) initViewVariables {
    
    isAnInitialScreen = YES;
    initialLoadIsComplete = NO;
    defaultDataResultIndex = 0;
    
    catalogs = [NSMutableDictionary dictionary];
    
}

- (void)loadData {

    [self showLoaderWithAnimation:YES cancelUserInteraction:cancelUserInteraction withInitialView:isAnInitialScreen];

    [self loadCurrentSectionData];

}

- (void) loadCurrentSectionData {
    if ( ![self isAPIHostAvailable] ) {
        return;
    }
    TSDataRequest *sectionReq;
    if ( [self isRSSSection:currentSection] ) {
        sectionReq = [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG   forSection:currentSection       forSubsection:currentSubsection];
    } else {
        sectionReq = [[TSDataRequest alloc] initWithType:TS_CLIP_SLUG       forSection:currentSection       forSubsection:currentSubsection];
        if ( addAtListEnd ) {
            TSDataRequest *lastRequest = [currentData objectAtIndex:0];
            sectionReq.range = NSMakeRange(lastRequest.range.location + lastRequest.range.length, TS_ITEMS_PER_PAGE);
        } else {
            sectionReq.range = NSMakeRange(1, TS_ITEMS_PER_PAGE);
        }
    }
    if ( [ currentSection isEqualToString:TS_PROGRAMA_SLUG ] && [ catalogs objectForKey:TS_PROGRAMA_SLUG ] == nil ) {
        TSDataRequest *showCatReq = [[TSDataRequest alloc] initWithType:TS_PROGRAMA_SLUG    forSection:nil      forSubsection:nil];
        showCatReq.range = NSMakeRange(1, 300);
        [[[TSDataManager alloc] init] loadRequests:[NSArray arrayWithObjects:showCatReq, sectionReq, nil] delegateResponseTo:self];
    } else {
        [[[TSDataManager alloc] init] loadRequests:[NSArray arrayWithObject:sectionReq] delegateResponseTo:self];
    }
}

- (BOOL) isRSSSection:(NSString *)section {

    return [section isEqualToString:@"noticias"] || [section isEqualToString:@"opinion"] || [section isEqualToString:@"blog"];

}

- (void) reloadData {

    [self loadData];

}

- (void) initTableVariables {

    currentData = [NSArray array];

    selectedIndexPath = nil;
    cancelUserInteraction = YES;

    addAtListEnd = NO;

}

- (void)loadCatalog:(NSString *)type {

    [self showLoaderWithAnimation:YES cancelUserInteraction:cancelUserInteraction withInitialView:NO];

    [[[TSDataManager alloc] init] loadAPIDataFor:@"" andSubsection:@"" withDataType:type inRange:NSMakeRange(1, 300) delegateResponseTo:self];

}

- (void)setCatalog:(NSArray *)data forKey:(NSString *)key {

//    NSLog(@"-----setCatalog: %@ - %lu", key, (unsigned long)[data count]);
    if ( ![data count] ) {
        return;
    }
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *titles = [NSMutableArray array];

    for(uint i = 0; i < [data count]; i++) {
        NSDictionary *row = [data objectAtIndex:i];
        if( row != nil && [ row isKindOfClass: [ NSDictionary class ] ] && [row objectForKey:@"slug"] != nil && [row objectForKey:@"nombre"] != nil) {
            [keys addObject:[row objectForKey:@"slug"]];
            [titles addObject:[row objectForKey:@"nombre"]];
        }
    }

    [catalogs setObject:@{@"keys":keys, @"titles":titles, @"originalData":data} forKey:key];

}

- (void) filterSelectedWithSlug:(NSString *)slug {

    if ([currentSubsection isEqualToString:slug]) {
        NSLog(@"filterSelectedWithSlug: Sended slug is equal to current slug. slug:%@", slug);
        return;
    }

    currentSubsection = slug;

    [self initTableVariables];
    [self loadData];

}

- (UITableViewCell *)getReuseCell:(UITableView *)tableView withID:(NSString *)cellID {

    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    return cell == nil ? (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil] lastObject] : cell;

}

- (NSURL *) getThumbURLForIndex:(NSIndexPath *)indexPath forceLargeImage:(BOOL)largeImage forDefaultTable:(BOOL)defaultTable {

    NSArray *dataArray = [ self getDataArrayForIndexPath:indexPath forDefaultTable:defaultTable];
    NSDictionary *data = [ dataArray objectAtIndex:indexPath.row ];
    BOOL isFeedItem = [ data isKindOfClass:[ MWFeedItem class ] ];

    if( isFeedItem ) {
        return [ self getThumbURLFromMWFeedItem:(MWFeedItem *)data forceLargeImage:largeImage ];
    }

    return [ self getThumbURLFromAPIItem:data forceLargeImage:largeImage ];

}

- (NSArray *) getDataArrayForIndexPath:(NSIndexPath *)indexPath forDefaultTable:(BOOL)defaultTable {

    return tableElements;

}

- (NSURL *) getThumbURLFromMWFeedItem:(MWFeedItem *)feedItem forceLargeImage:(BOOL)largeImage {
    uint objIndex = [feedItem.enclosures count] == 1 || largeImage ? 0 : 1;
    NSDictionary *enclosure = [feedItem.enclosures objectAtIndex:objIndex];
    return [NSURL URLWithString:[enclosure objectForKey:@"url"]];
}

- (NSURL *) getThumbURLFromAPIItem:(NSDictionary *)data forceLargeImage:(BOOL)largeImage {
    NSString *miniaturaID = largeImage ? @"thumbnail_grande" : @"thumbnail_mediano";
    if ( [data class] == [NSNull class] )  {
        return [NSURL URLWithString:@""];
    }
    return [NSURL URLWithString:[data objectForKey:miniaturaID]];
}

- (NSArray *) getResultDataAtIndex:(int) index {
    return ((TSDataRequest *)[currentData objectAtIndex:index]).result;
}

- (void) loadNotificationRSSNewsWithURL:(NSString *)URL andSection:(NSString *)section {

    notificationSection = section;
    notificationURL = URL;

    if ([URL isKindOfClass:[NSNull class]] || !URL) {
        NSLog(@"Alerta hubo un error no se recibió la URL de la notificación");
    }

    if ( [[[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Configuración"] valueForKey:@"langCode"] isEqualToString:@"es"] ) {
        notificationSlug = [URL substringWithRange:NSMakeRange(29, [URL length] - 29)];
    } else {
        notificationSlug = [URL substringWithRange:NSMakeRange(38, [URL length] - 38)];
    }

    NSLog(@"%@", URL);
    NSLog(@"-------------------========================%@", notificationSlug);
    notificationSlug = [notificationSlug substringWithRange:NSMakeRange(0, [notificationSlug length] - 5)];
    NSLog(@"-------------------========================%@", notificationSlug);

    if ( initialLoadIsComplete ) {
        [self loadNotificationSections];
    }

}

- (void) loadNotificationSections {

    if ( ![self isAPIHostAvailable] ) {
        return;
    }

    TSDataRequest *RSSReq;

    if ( [notificationSection isEqualToString:@"P"] ) {
        RSSReq = [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG forSection:@"noticias" forSubsection:@"portada"];
    } else if ( [notificationSection isEqualToString:@"L"] ) {
        RSSReq = [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG forSection:@"noticias" forSubsection:@"latinoamerica"];
    } else if ( [notificationSection isEqualToString:@"M"] ) {
        RSSReq = [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG forSection:@"noticias" forSubsection:@"mundo"];
    } else if ( [notificationSection isEqualToString:@"D"] ) {
        RSSReq = [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG forSection:@"noticias" forSubsection:@"deportes"];
    } else if ( [notificationSection isEqualToString:@"C"] ) {
        RSSReq = [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG forSection:@"noticias" forSubsection:@"cultura"];
    } else {
        RSSReq = [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG forSection:@"noticias" forSubsection:@"ultimas"];
    }

    [self showLoaderWithAnimation:YES cancelUserInteraction:YES withInitialView:NO];

    [[[TSDataManager alloc] init] loadNotificationRequests:[NSArray arrayWithObjects:RSSReq, nil] delegateResponseTo:self];

}

- (NSString *) getNotificationSubsection {

    if ( [notificationSection isEqualToString:@"P"] ) {
        return @"portada";
    } else if ( [notificationSection isEqualToString:@"L"] ) {
        return @"latinoamerica";
    } else if ( [notificationSection isEqualToString:@"M"] ) {
        return @"mundo";
    } else if ( [notificationSection isEqualToString:@"D"] ) {
        return @"deportes";
    } else if ( [notificationSection isEqualToString:@"C"] ) {
        return @"cultura";
    }

    return @"ultimas";

}

- (void) notificationsSectionsDidLoad:(NSArray *)requests {

    [self hideLoaderWithAnimation:YES];

    NSString *trimmedNotificationSlug = [notificationSlug substringWithRange:NSMakeRange(0, 20)];

    NSLog(@"-------------------========================notificationsSectionsDidLoad %@", trimmedNotificationSlug);

    for ( uint i = 0; i < [requests count]; i++ ) {

        TSDataRequest *RSSRequest = [requests objectAtIndex:i];

        for ( uint j = 0; j < [RSSRequest.result count]; j++ ) {

            MWFeedItem *item = [RSSRequest.result objectAtIndex:j];

            NSLog(@"%d, %d - %@", i, j, item.link);

            if ( [item.link rangeOfString:trimmedNotificationSlug].length != 0 ) {

                [self showNotificationPost:item];
                notificationSlug = nil;
                return;

            }

        }

    }

    [self showUnlocatedNotification:notificationURL];

    isNotificationWebViewLastView = YES;
    notificationSlug = nil;
    notificationURL = nil;

}

- (void) showUnlocatedNotification:(NSString *)URL {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle: nil];

    TSWebViewController *webView = [mainStoryboard instantiateViewControllerWithIdentifier: @"TSWebViewController"];
    webView = [webView initWithURL:[[NSURL alloc] initWithString:URL]];

    [self.navigationController pushViewController:webView animated:YES];

}

- (NSString *) getSectionTitleWith:(NSString *)slug {
    NSString *localizeID = [NSString stringWithFormat:@"%@Section", slug];
    return [NSString stringWithFormat:NSLocalizedString(localizeID, nil)];
}

- (void) showNotificationPost:(MWFeedItem *)post {}
- (void)showSelectedPost:(MWFeedItem *)post {}


















#pragma mark - Custom Functions



















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    [self checkForRequestErrors:requests];

    if ( [ currentSection isEqualToString:TS_PROGRAMA_SLUG ] && [ catalogs objectForKey:TS_PROGRAMA_SLUG ] == nil ) {

        TSDataRequest *catalogRequest = [requests objectAtIndex:0];

        [self setCatalog:catalogRequest.result forKey:catalogRequest.type];
        requests = [ requests subarrayWithRange:NSMakeRange(1, 1) ];

    }

    currentData = [NSArray arrayWithArray:requests];

    if( addAtListEnd ) {
        [tableElements addObjectsFromArray:[self getResultDataAtIndex:defaultDataResultIndex]];
    } else {
        tableElements = [NSMutableArray arrayWithArray:[self getResultDataAtIndex:defaultDataResultIndex]];
    }

    [self hideLoaderWithAnimation:YES];

    initialLoadIsComplete = YES;

    if ( notificationSlug ) {

        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(loadNotificationSections) userInfo:nil repeats:NO];

    }

}

- (void)TSDataManager:(TSDataManager *)manager didProcessedNotificationRequests:(NSArray *)requests {

    [self checkForRequestErrors:requests];

    [self notificationsSectionsDidLoad:requests];

}

- (void) checkForRequestErrors:(NSArray *)requests {
    
    for (int i = 0; i < [requests count]; i++) {
        
        if ( ((TSDataRequest *)[requests objectAtIndex:i]).error ) {
            
            [self sendTSConnectionErrorWithWiFiFailure:NO internetFailure:NO serverFailure:YES];
            
        }
        
    }
    
}














@end