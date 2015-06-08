//
//  TSClipListadoTableViewController.h
//  teleSUR
//
//  Created by David Regla on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSBasicListViewController.h"
#import "MWFeedItem.h"


@interface TSClipListadoTableViewController : TSBasicListViewController <UITableViewDataSource, UITableViewDelegate> {

    UITableViewController *tableViewController;

    @protected
        //Variables que guardan el tamaño de la celda para no tener que crear una celda nueva cada vez que se pide el alto de un tipo de celda.
        CGFloat standardCellHeight;
        CGFloat bigCellHeight;
        CGFloat loadMoreCellHeight;
        CGFloat homeCellHeight;

        //Bandera que indica si la tabla actual se le añadirá la celda "Cargar Mas Clips". Puede ser deshabilitada para RSS o para tablas especiales como el Home o cuando ya no existen mas clips que cargar de acuerdo a las peticiones al API.
        BOOL loadMoreCellDisabled;

}

@property(nonatomic, retain) UIViewController *detailViewController;

//Regresa el ID de la celda correspondiente al index enviado.
- (NSString *)getIDForCellAtIndexPath:(NSIndexPath *)indexPath;
//Configura la WebCacheImage, de acuerdo al indexPath actual. También decide entre configurar con la URL de la imagen grande o pequeña.
- (void)configureImageInCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath forceLargeImage:(BOOL)largeImage;

- (void)configureImageInCell:(UITableViewCell *)cell withNSURL:(NSURL *)URL;
// Manda a reproducir el clip correspondiente al index enviado
- (void)playSelectedClip:(NSIndexPath *)indexPath;


@property (nonatomic, strong) IBOutlet UITableViewController *tableViewController;

@end