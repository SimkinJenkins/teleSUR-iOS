//
//  NewsViewController.m
//  teleSUR
//
//  Created by Simkin on 26/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "NewsViewController.h"
#import "TSMultimediaData.h"
#import "Post.h"
#import "UILabelMarginSet.h"

NSString* const XIB_ID = @"NewsDefaultCollectionCell";
//NSString* const DEFAULT_CELL_REUSE_ID = @"NewsDefaultCollectionCell";
//NSString* const FIRST_CELL_REUSE_ID = @"NewsFirstCollectionCell";

@implementation NewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) awakeFromNib {
//    [self.collectionView registerNib:[UINib nibWithNibName:DEFAULT_CELL_REUSE_ID bundle:nil] forCellWithReuseIdentifier:DEFAULT_CELL_REUSE_ID];
//    [self.collectionView registerNib:[UINib nibWithNibName:FIRST_CELL_REUSE_ID bundle:nil] forCellWithReuseIdentifier:FIRST_CELL_REUSE_ID];
}

- (void)viewDidLoad {

    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];

    CGFloat inset = 15.0;
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flow.sectionInset = UIEdgeInsetsMake(inset, inset - 5, inset, inset - 5);

    flow.itemSize = CGSizeMake(600, 330);

    self.collectionView.collectionViewLayout = flow;

    [self prepareVariables];

    [self loadNews];
}

- (void)prepareVariables {

    news = [NSMutableArray new];

}

- (void)loadNews {

//    [self mostrarLoadingViewConAnimacion:YES cancelarInteracionUsuario:cancelUserInteraction];

    [[[TSMultimediaData alloc] init] getTextResourcesFor:@"" withSlug:@"" withDelegate:self];

//  [dataClips getTextResourcesFor:currentSection withSlug:selectedSlugFilter withDelegate:self];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {

    return [news count];

}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if(indexPath.row == 0) {
//        return CGSizeMake(490, 490);
//    }
    return CGSizeMake(600, 330);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellID = indexPath.row == 0 ? XIB_ID : XIB_ID;
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell = cell == nil ? (UICollectionViewCell *)[[[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil] lastObject] : cell;

    NSDictionary *clipData = [news objectAtIndex:indexPath.row];

    BOOL isRSS = [clipData isKindOfClass:[Post class]];
    
    NSString *clipType = isRSS ? nil : [[clipData valueForKey:@"tipo"] valueForKey:@"slug"];
    BOOL switchTitles = isRSS ? NO : [clipType isEqualToString:@"programa"];
    // Elementos de celda
    UILabelMarginSet *tituloLabel = (UILabelMarginSet *)[cell viewWithTag:103];
    UILabelMarginSet *seccionLabel = (UILabelMarginSet *)[cell viewWithTag:102];
    
    //Setear fuentes custom
    tituloLabel.frame = CGRectMake(tituloLabel.frame.origin.x, tituloLabel.frame.origin.y, 176, 80);
//    tituloLabel.font = [UIFont fontWithName:@"Roboto-Light" size:14];
    seccionLabel.font = [UIFont fontWithName:@"Roboto-BoldCondensedItalic" size:18];
    
    // Establecer texto de etiquetas y arreglar tamaños.
    if(isRSS) {
        tituloLabel.text = ((Post *)clipData).title;
    } else {
        tituloLabel.text = switchTitles ? @"" : [clipData valueForKey:@"titulo"];
    }
    [tituloLabel sizeToFit];
    seccionLabel.text = [((Post *)clipData).category uppercaseString];

    return cell;
}
/*
- (void)colle

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != [self.clips count] || self.omitirVerMas) {
        
        AsynchronousImageView *thumbnailImageView = (AsynchronousImageView *)[cell viewWithTag:kTHUMBNAIL_IMAGE_VIEW_TAG];
        
        if([thumbnailImageView isKindOfClass:AsynchronousImageView.class]) {
            if (indexPath.row >= [self.arregloClipsAsyncImageViews count]) {
                [self.arregloClipsAsyncImageViews addObject:thumbnailImageView];
                NSString *miniaturaID = @"thumbnail_mediano";
                thumbnailImageView.url = [self getThumbURL:indexPath withID:miniaturaID];
                [thumbnailImageView cargarImagenSiNecesario];
            } else {
                [[thumbnailImageView superview] addSubview:[self.arregloClipsAsyncImageViews objectAtIndex:indexPath.row]];
                [thumbnailImageView removeFromSuperview];
            }
        }
    }
}
 */

#pragma mark -
#pragma mark TSMultimediaDataDelegate

// Maneja los datos recibidos
- (void)TSMultimediaData:(TSMultimediaData *)data entidadesRecibidas:(NSArray *)array paraEntidad:(NSString *)entidad {

    [news setArray:array];
    [self.collectionView reloadData];
//    if (entidad == TS_CLIP_SLUG || [entidad isEqualToString:TS_NOTICIAS_SLUG]) {
        
        // Agregar al final o sustuituir listado actual ?
//        if (self.agregarAlFinal) {
//            [self.clips addObjectsFromArray:array];
//        } else {
//            [self.clips setArray:array];
//            self.arregloClipsAsyncImageViews = [NSMutableArray array];
//        }
//        [self ocultarLoadingViewConAnimacion:YES];
//    }
    
//    if ([delegate respondsToSelector:@selector(TSMultimediaData:entidadesRecibidas:paraEntidad:)]) {
//        [delegate TSMultimediaData:data entidadesRecibidas:array paraEntidad:entidad];
//    }
}

- (void)TSMultimediaData:(TSMultimediaData *)data entidadesRecibidasConError:(id)error {
	NSLog(@"Error: %@", error);
}

@end
