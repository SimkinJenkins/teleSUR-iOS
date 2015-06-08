//
//  TSIPadOpinionViewController.m
//  teleSUR
//
//  Created by Simkin on 01/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSIPadOpinionViewController.h"
#import "TSIPadRSSDetailViewController.h"
#import "TSIPadOpinionCollectionViewCell.h"
#import "UIImageView+WebCache.h"

#import "TSDataRequest.h"
#import "TSDataManager.h"
#import "UIViewController+TSLoader.h"

NSString* const OPINION_HOME_DEFAULT_CELL_REUSE_ID = @"OpinionHomeCollectionViewCell";

@implementation TSIPadOpinionViewController

- (void)viewDidLoad {

    [self setSection:[self getHomeSection]];

    rowSizes = [NSMutableArray array];

    [super viewDidLoad];

    self.collectionView = (UICollectionView *)[self.view viewWithTag:101];
    self.collectionView.delegate = self;

    [self.collectionView registerNib:[UINib nibWithNibName:OPINION_HOME_DEFAULT_CELL_REUSE_ID bundle:nil] forCellWithReuseIdentifier:OPINION_HOME_DEFAULT_CELL_REUSE_ID];

    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = CGSizeMake(256, 100);

    [self.collectionView setBackgroundColor:[UIColor whiteColor]];

    [self configRightButton];

    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
}



















- (void) setSection:(NSString *)slug {

    [self configureWithSection:slug];
    //    TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;
    //    [topMenu setCurrentSection:slug];

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
    NSString *home = [sectionsAllOptions objectAtIndex:3];
    return home;

}

- (void) configureWithSection:(NSString *)section {

    if([currentSection isEqualToString:section]) {
        return;
    }

    currentSection = section;
    currentSubsection = @"";

//    [self initDataFilterWith:section];

    if([section isEqualToString:@"reportaje"]) {
//        [self configFilterWithSelectedSlug:@"reportajes-telesur"];
    }

    NSLog(@"configureWithSection : %@", section);

}

- (void)showSelectedPost:(MWFeedItem *)post {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle: nil];
    NSString *subsection = [post.type isEqualToString:@"op-entrevistas"] ? post.type : @"";
    TSIPadRSSDetailViewController *vc = [[mainStoryboard instantiateViewControllerWithIdentifier:@"TSIPadRSSDetailViewController"]
                                         initWithRSSData:post inSection:currentSection andSubsection:subsection];
    [self.navigationController pushViewController:vc animated:YES];

}

- (void) deviceOrientationDidChangeNotification:(NSNotification *)notification {}

- (void)showNotificationPost:(MWFeedItem *)post {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle: nil];
    
    TSIPadRSSDetailViewController *vc = [[mainStoryboard instantiateViewControllerWithIdentifier:@"TSIPadRSSDetailViewController"]
                                         initWithRSSData:post inSection:@"noticias" andSubsection:[self getNotificationSubsection]];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}













#pragma mark - Custom Public Functions

- (void)loadData {
    
    [self showLoaderWithAnimation:YES cancelUserInteraction:cancelUserInteraction withInitialView:isAnInitialScreen];
    
    [self loadSectionData];

}

- (void) loadSectionData {

    if ( ![self isAPIHostAvailable] ) {
        return;
    }

    TSDataRequest *opOpinionReq    =  [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG   forSection:@"opinion"  forSubsection:@""];
    TSDataRequest *opInterviewReq  =  [[TSDataRequest alloc] initWithType:TS_NOTICIAS_SLUG   forSection:@"opinion"  forSubsection:@"op-entrevistas"];

    [[[TSDataManager alloc] init] loadRequests:[NSArray arrayWithObjects:opOpinionReq, opInterviewReq, nil]
                            delegateResponseTo:self];

}

- (NSArray *) getDataArrayForIndexPath:(NSIndexPath *)indexPath forDefaultTable:(BOOL)defaultTable {

    if ( indexPath.section == 1 ) {

        return secondSectionElements;

    }

    return tableElements;

}















- (void) configureCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    BOOL isInterview = indexPath.row % 4 > 1;
    int row = floor(indexPath.row / 4);

    NSIndexPath *newIndexPath = [ NSIndexPath indexPathForRow:(indexPath.row - (row * 2)) - (isInterview ? 2 : 0) inSection:isInterview ? 1 : 0 ];
    NSArray *dataArray = [ self getDataArrayForIndexPath:newIndexPath forDefaultTable:YES ];

    if ( newIndexPath.row < [ dataArray count ] ) {
        MWFeedItem *item = [ dataArray objectAtIndex:newIndexPath.row ];
        [((TSIPadOpinionCollectionViewCell *)cell) setData:item];
        
        [(UIImageView *)[cell viewWithTag:113] sd_setImageWithURL:[ self getThumbURLForIndex:newIndexPath
                                                                             forceLargeImage:NO
                                                                             forDefaultTable:isInterview ]
                                                 placeholderImage:[ UIImage imageNamed:@"SinImagen.png" ] ];

        BOOL isANoneRow = (row % 2) == 0;
        BOOL hasBackground = indexPath.row % 2 == 0;
        hasBackground = isANoneRow ? hasBackground : !hasBackground;
        [[cell viewWithTag:100] setBackgroundColor: hasBackground ? [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0] : [UIColor clearColor]];
        UIView *back = [cell viewWithTag:100];
        back.frame = CGRectMake(back.frame.origin.x, back.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    }

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

    return [tableElements count] + [secondSectionElements count];

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellID = OPINION_HOME_DEFAULT_CELL_REUSE_ID;
    UICollectionViewCell *cell = (UICollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell = cell == nil ? (UICollectionViewCell *)[[[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil] lastObject] : cell;

    [self configureCell:cell forItemAtIndexPath:indexPath];

    return cell;

}












#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    BOOL isInterview = indexPath.row % 4 > 1;
    int row = floor(indexPath.row / 4);

    NSIndexPath *newIndexPath = [ NSIndexPath indexPathForRow:(indexPath.row - (row * 2)) - (isInterview ? 2 : 0) inSection:isInterview ? 1 : 0 ];
    NSArray *dataArray = [ self getDataArrayForIndexPath:newIndexPath forDefaultTable:YES ];

    if ( newIndexPath.row < [ dataArray count ] ) {

        [ self showSelectedPost:[ dataArray objectAtIndex:newIndexPath.row ] ];

    }

}













#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellID = OPINION_HOME_DEFAULT_CELL_REUSE_ID;
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[[[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil] lastObject];

    int row = floor(indexPath.row / 4);

    if ( [rowSizes count] <= row ) {

        CGSize tempCellSize = CGSizeMake(0, 0);

        for ( int i = 0; i < 4; i++ ) {

            BOOL isInterview = i % 4 > 1;

            NSIndexPath *newIndexPath = [ NSIndexPath indexPathForRow:(row * 2) + i - (isInterview ? 2 : 0) inSection:isInterview ? 1 : 0 ];
            NSArray *dataArray = [ self getDataArrayForIndexPath:newIndexPath forDefaultTable:YES ];

            if ( newIndexPath.row < [dataArray count] ) {

                MWFeedItem *item = [dataArray objectAtIndex:newIndexPath.row];
                item.type = isInterview ? @"op-entrevistas" : @"op-articulos";
                [((TSIPadOpinionCollectionViewCell *)cell) setData:item];
                CGSize cellSize = [((TSIPadOpinionCollectionViewCell *)cell) finalSize];
                tempCellSize = tempCellSize.height < cellSize.height ? cellSize : tempCellSize;

            }

        }

        [ rowSizes addObject:[ NSValue valueWithCGSize:tempCellSize ] ];

    }

    return [[rowSizes objectAtIndex:row] CGSizeValue];

}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
    
}

















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    [super TSDataManager:manager didProcessedRequests:requests];

    TSDataRequest *opInterviewReq = [requests objectAtIndex:1];
    secondSectionElements = [ NSMutableArray arrayWithArray: opInterviewReq.result ];

    [self.collectionView reloadData];

}

@end