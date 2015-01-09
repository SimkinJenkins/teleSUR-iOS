
//
//  TSIPadBlogHomeViewController.m
//  teleSUR
//
//  Created by Simkin on 01/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSIPadBlogHomeViewController.h"
#import "TSIPadBlogHomeCollectionViewCell.h"
#import "TSIPadRSSDetailViewController.h"

#import "DefaultCollectionReusableView.h"
#import "UIImageView+WebCache.h"
#import "UIViewController_Configuracion.h"

#import "TSDataManager.h"
#import "TSDataRequest.h"

NSString* const BLOG_HOME_DEFAULT_CELL_REUSE_ID = @"BlogHomeCollectionCell";

@implementation TSIPadBlogHomeViewController

- (void)viewDidLoad {

    [self setSection:[self getHomeSection]];

    [super viewDidLoad];

    self.collectionView = (UICollectionView *)[self.view viewWithTag:101];
    self.collectionView.delegate = self;

    [self.collectionView registerNib:[UINib nibWithNibName:BLOG_HOME_DEFAULT_CELL_REUSE_ID bundle:nil] forCellWithReuseIdentifier:BLOG_HOME_DEFAULT_CELL_REUSE_ID];

    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = CGSizeMake(256, 100);

    [self.collectionView setBackgroundColor:[UIColor whiteColor]];

    positions = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];

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
    NSString *home = [sectionsAllOptions objectAtIndex:4];
    return home;
    
}

- (void) configureWithSection:(NSString *)section {
    
    if(currentSection == section) {
        return;
    }

    currentSection = section;
    currentSubsection = @"";

    if([section isEqualToString:@"reportaje"]) {
//        [self configFilterWithSelectedSlug:@"reportajes-telesur"];
    }

    NSLog(@"configureWithSection : %@", section);

//    [self loadData];

}

- (void)showSelectedPost:(MWFeedItem *)post {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle: nil];
    TSIPadRSSDetailViewController *vc = [[mainStoryboard instantiateViewControllerWithIdentifier:@"TSIPadRSSDetailViewController"]
                                            initWithRSSData:post inSection:currentSection andSubsection:currentSubsection];

    [self.navigationController pushViewController:vc animated:YES];

}

- (void) deviceOrientationDidChangeNotification:(NSNotification *)notification {

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown) {
        return;
    }

    positions = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];

    [self resetCollectionData];
    [self.collectionView reloadData];

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

- (void) resetCollectionData {

    for (int i = 0; i < [tableElements count]; i++) {

        ((MWFeedItem *)[tableElements objectAtIndex:i]).position = CGPointMake(0, 0);

    }

}


















#pragma mark - Custom Public Functions

















#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return [tableElements count];

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellID = BLOG_HOME_DEFAULT_CELL_REUSE_ID;
    UICollectionViewCell *cell = (UICollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell = cell == nil ? (UICollectionViewCell *)[[[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil] lastObject] : cell;

    [((TSIPadBlogHomeCollectionViewCell *)cell) setData:[tableElements objectAtIndex:indexPath.row]];

    CGPoint position = ((MWFeedItem *)[tableElements objectAtIndex:indexPath.row]).position;
    BOOL uninitialized = position.x == 0 && position.y == 0;
    if ( indexPath.row == 0 ) {
        NSInteger xPosition = cell.frame.origin.x / 256;
        if ( [[positions objectAtIndex:xPosition] intValue] != 0 ) {
            uninitialized = NO;
        }
    }

    BOOL hasBackground;

    if( uninitialized  ) {

        NSInteger xPosition = cell.frame.origin.x / 256;
        int yPosition = [[positions objectAtIndex:xPosition] intValue];

        hasBackground = (xPosition + yPosition) % 2 == 1;

        yPosition++;
        [positions setObject:[NSNumber numberWithInt:yPosition] atIndexedSubscript:xPosition];

        ((MWFeedItem *)[tableElements objectAtIndex:indexPath.row]).position = CGPointMake(xPosition, yPosition);

    } else {

        int delta = (int)(position.x + position.y) % 2;
        hasBackground = delta == 1;

    }
    
    [[cell viewWithTag:100] setBackgroundColor: hasBackground ? [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0] : [UIColor clearColor]];

    return cell;

}



















#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [self showSelectedPost:[tableElements objectAtIndex:indexPath.row]];

}



















#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellID = BLOG_HOME_DEFAULT_CELL_REUSE_ID;

    UICollectionViewCell *cell = (UICollectionViewCell *)[[[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil] lastObject];

    [((TSIPadBlogHomeCollectionViewCell *)cell) setData:[tableElements objectAtIndex:indexPath.row]];

    return CGSizeMake(1, [((TSIPadBlogHomeCollectionViewCell *)cell) finalSize].height);

}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
    
}



















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {
    
    [super TSDataManager:manager didProcessedRequests:requests];

    [self.collectionView reloadData];

}




@end