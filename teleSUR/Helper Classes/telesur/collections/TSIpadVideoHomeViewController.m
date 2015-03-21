//
//  TSIpadVideoHomeViewController.m
//  teleSUR
//
//  Created by Simkin on 27/02/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import "TSIpadVideoHomeViewController.h"

#import "NavigationBarsManager.h"
#import "UIViewController+TSLoader.h"
#import "TSDataRequest.h"
#import "TSDataManager.h"
#import "TSIpadNavigationViewController.h"
#import "DefaultCollectionReusableView.h"
#import "UIImageView+WebCache.h"

#import "TSVideoCollectionViewCell.h"



NSString* const VIDEO_HOME_FIRST_CELL_REUSE_ID = @"TSHiglightedVideoCollectionCell";
NSString* const VIDEO_HOME_DEFAULT_CELL_REUSE_ID = @"TSVideoCollectionCell";



@implementation TSIpadVideoHomeViewController







- (id) initWithSection:(NSString *)section {

    currentSection = section;
    currentSubsection = @"";

    [self configRightButton];

    return self;

}







#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    
    [super viewDidLoad];
    
    currentOrientation = [[ UIApplication sharedApplication ] statusBarOrientation];
    
    NSString *APPType = [ [ [ [ NSBundle mainBundle ] infoDictionary ] valueForKey:@"Configuración" ] valueForKey:@"APPtype" ];
    if ( [ APPType isEqualToString:@"multimedia" ] ) {
        return;
    }

    [self setSection:currentSection];

    self.collectionView = (UICollectionView *)[self.view viewWithTag:101];
    
    [self.collectionView registerNib:[UINib nibWithNibName:VIDEO_HOME_FIRST_CELL_REUSE_ID bundle:nil] forCellWithReuseIdentifier:VIDEO_HOME_FIRST_CELL_REUSE_ID];
    [self.collectionView registerNib:[UINib nibWithNibName:VIDEO_HOME_DEFAULT_CELL_REUSE_ID bundle:nil] forCellWithReuseIdentifier:VIDEO_HOME_DEFAULT_CELL_REUSE_ID];
    
    [self configureCollectionLayout];
    
    [self configRightButton];
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [[NavigationBarsManager sharedInstance] setMasterView:[ [ self.view superview] superview] ];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if( currentOrientation != [[ UIApplication sharedApplication ] statusBarOrientation] ) {
        [self deviceOrientationDidChangeNotification:nil];
    }
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
}



















#pragma mark - Custom Public Functions

- (void) handleTSConnectionError {
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;
    
    [super handleTSConnectionError];

}



















#pragma mark - Custom Functions

- (void) configureCollectionLayout {
    
    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;
    
    layout.blockPixels = CGSizeMake(255, UIInterfaceOrientationIsLandscape(currentOrientation) ? 211 : 223 );
    
}

- (void) setSection:(NSString *)slug {

    TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;
    [topMenu setCurrentSection:slug];

}

- (void) liveStreamMenuButtonSelect {

    ((UIView *)[self.view viewWithTag:300]).hidden = !((UIView *)[self.view viewWithTag:300]).hidden;

}

- (void) playSelectedClip:(NSInteger)index {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle: nil];

    NSDictionary *item = [ [ self getDataArrayForIndexPath:selectedIndexPath forDefaultTable:YES ] objectAtIndex:selectedIndexPath.row];

    TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;

    if ( topMenu.topView ) {
        [((TSIPadVideoDetailViewController *)topMenu.topView) setData:item withSection:currentSection];
    } else {
        TSIPadVideoDetailViewController *vc = [[mainStoryboard instantiateViewControllerWithIdentifier:@"TSIPadVideoDetailViewController"]
                                               initWithVideoData:item
                                               inSection:currentSection];
        [topMenu addTopViewController:vc];
    }

}

- (void) deviceOrientationDidChangeNotification:(NSNotification *)notification {
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown) {
        return;
    }
    
    currentOrientation = [[ UIApplication sharedApplication ] statusBarOrientation];
    
    if ( ![currentData count] ) {
        return;
    }
    
    [self configureCollectionLayout];

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



















#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return [tableElements count];

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellID = indexPath.row == 0 ? VIDEO_HOME_FIRST_CELL_REUSE_ID : VIDEO_HOME_DEFAULT_CELL_REUSE_ID;
    UICollectionViewCell *cell = (UICollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell = cell == nil ? (UICollectionViewCell *)[[[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil] lastObject] : cell;

    [cell viewWithTag:100].frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    [cell viewWithTag:100].superview.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);

    [((TSVideoCollectionViewCell *)cell) setData:[tableElements objectAtIndex:indexPath.row]];

    [(UIImageView *)[cell viewWithTag:101] sd_setImageWithURL:[ self getThumbURLForIndex:indexPath
                                                                         forceLargeImage:indexPath.row == 0
                                                                         forDefaultTable:YES ]
                                             placeholderImage:[ UIImage imageNamed:@"SinImagen.png" ] ];

    return cell;

}



















#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    selectedIndexPath = indexPath;
    [self playSelectedClip:indexPath.row];

}



















#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0) {
        return CGSizeMake(3, 2);
    }
    return CGSizeMake(1, 1);
    
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return UIEdgeInsetsMake(9, 5, 3, 5);
    
}



















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    [super TSDataManager:manager didProcessedRequests:requests];

    [self.collectionView reloadData];

    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;

}





@end