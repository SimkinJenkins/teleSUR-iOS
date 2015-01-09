//
//  MainiPadViewController.m
//  teleSUR
//
//  Created by Simkin on 25/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "MainIpadViewController.h"
#import "NavigationBarsManager.h"
#import "TSIpadNavigationViewController.h"
#import "DetailIpadViewController.h"
#import "MWFeedItem.h"
#import "DefaultTableViewCell.h"

NSString* const FIRST_CELL_REUSE_ID = @"NewsFirstCollectionCell";
NSString* const DEFAULT_CELL_REUSE_ID = @"NewsDefaultCollectionCell";

@implementation MainIpadViewController

@synthesize clipDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
/*
    [[NavigationBarsManager sharedInstance] setMasterViewController:self];

    if([NavigationBarsManager sharedInstance].detailViewController) {
        clipDelegate = (DetailIpadViewController *)[NavigationBarsManager sharedInstance].detailViewController;
    }
*/

    [self setSection:[self getHomeSection]];

    self.collectionView = (UICollectionView *)[self.view viewWithTag:101];

    [self.collectionView registerNib:[UINib nibWithNibName:FIRST_CELL_REUSE_ID bundle:nil] forCellWithReuseIdentifier:FIRST_CELL_REUSE_ID];
    [self.collectionView registerNib:[UINib nibWithNibName:DEFAULT_CELL_REUSE_ID bundle:nil] forCellWithReuseIdentifier:DEFAULT_CELL_REUSE_ID];

    RFQuiltLayout* layout = (id)[self.collectionView collectionViewLayout];
    layout.direction = UICollectionViewScrollDirectionVertical;
    layout.blockPixels = CGSizeMake(255, 211);

}

- (NSString *) getHomeSection {
    NSArray *sections = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"principalMenuSections"];
    NSMutableArray *sectionsAllOptions = [NSMutableArray array];
    for (uint i = 0; i < [sections count]; i++) {
        NSString *slug = [sections objectAtIndex:i];
        if(![slug isEqualToString:@"buscar"] && ![slug isEqualToString:@"home"]) {
            [sectionsAllOptions addObject:slug];
        }
    }
    NSString *home = [sectionsAllOptions objectAtIndex:0];
    currentSection = home;
    return home;

}

- (void) setSection:(NSString *)slug {
    TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;
    [topMenu setCurrentSection:slug];
}

- (NSString *) getSection {
    return ((TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance).section;
}

- (void) liveStreamMenuButtonSelect {
    ((UIView *)[self.view viewWithTag:300]).hidden = !((UIView *)[self.view viewWithTag:300]).hidden;
}

- (void) configureWithSection:(NSString *)section {
    if(currentSection == section) {
//        if([section isEqualToString:@"buscar"]) {
//            [searchBar becomeFirstResponder];
//        }
        return;
    }
    currentSection = section;
//    searchBar.hidden = ![section isEqualToString:@"buscar"];
//    self.navigationController.navigationBarHidden = [section isEqualToString:@"buscar"];
    cancelUserInteraction = ![section isEqualToString:@"buscar"];
    currentSubsection = @"";
//    [self initDataFilterWith:section];
    if([section isEqualToString:@"reportaje"]) {
//        [self configFilterWithSelectedSlug:@"reportajes-telesur"];
    }

//    self.tableViewController.refreshDisabled = [section isEqualToString:@"buscar"];
//    self.tableViewController.refreshHeaderView.hidden = [section isEqualToString:@"buscar"];
    
    NSLog(@"configureWithSection : %@", section);

    if([section isEqualToString:@"buscar"]) {

//        listElements = [[NSMutableArray alloc] init];

//        [self.collectionView reloadData];
//        [searchBar becomeFirstResponder];
//        searchBar.text = @"";
//        [self.view bringSubviewToFront:searchBar];
    
//        [[self getSearhTextfield] addTarget:self
//                                     action:@selector(textfieldDidChange)
//                           forControlEvents:UIControlEventEditingChanged];
        
//        [[self getCancelButton] addTarget:self
//                                   action:@selector(cancelClicked)
//                         forControlEvents:UIControlEventTouchUpInside];
    } else {
//        [self loadData];
    }
}














- (void)playSelectedClip:(uint)index {
/*
    if ([clipDelegate respondsToSelector:@selector(selectedClip:)]) {
        [clipDelegate selectedClip:[listElements objectAtIndex:index]];
    }
*/
}

- (void)showSelectedPost:(MWFeedItem *)post {
    if ([clipDelegate respondsToSelector:@selector(selectedClip:)]) {
        [clipDelegate selectedPost:post];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}






#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return MIN([tableElements count], 7);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellID = indexPath.row == 0 ? FIRST_CELL_REUSE_ID : DEFAULT_CELL_REUSE_ID;
    UICollectionViewCell *cell = (UICollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell = cell == nil ? (UICollectionViewCell *)[[[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil] lastObject] : cell;

/*
    if(indexPath.row < [self.clips count]) {
        [((DefaultTableViewCell *)cell) setData:[self.clips objectAtIndex:indexPath.row]];

        AsynchronousImageView *thumbnailImageView = (AsynchronousImageView *)[cell viewWithTag:101];
    
        if([thumbnailImageView isKindOfClass:AsynchronousImageView.class]) {
            if (indexPath.row >= [self.arregloClipsAsyncImageViews count]) {
                [self.arregloClipsAsyncImageViews addObject:thumbnailImageView];
                NSString *miniaturaID = @"thumbnail_mediano";
                thumbnailImageView.url = [self getThumbURL:indexPath withID:miniaturaID withData:[self.clips objectAtIndex:indexPath.row] forceLargeImage:NO];
                [thumbnailImageView cargarImagenSiNecesario];
            } else {
                [[thumbnailImageView superview] addSubview:[self.arregloClipsAsyncImageViews objectAtIndex:indexPath.row]];
                [thumbnailImageView removeFromSuperview];
            }
        }
    }
*/
    return cell;
    UILabel* label = (id)[cell viewWithTag:5];
    if(!label) label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    label.tag = 5;
    label.textColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    label.backgroundColor = [UIColor clearColor];
    [cell addSubview:label];
    
    return cell;
}






#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    [self removeIndexPath:indexPath];
}






#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"%ld", (long)indexPath.row);

    if(indexPath.row >= 7) {
        NSLog(@"Asking for index paths of non-existant cells!! %ld from %d cells", (long)indexPath.row, 7);
    }

    if(indexPath.row == 0) {
        return CGSizeMake(3, 2);
    }
    return CGSizeMake(1, 1);
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

@end