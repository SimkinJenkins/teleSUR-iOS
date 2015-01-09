//
//  TSBasicListViewController.h
//  teleSUR
//
//  Created by Simkin on 22/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSDataManagerDelegate.h"
#import "MWFeedItem.h"
#import "TSReachabilityViewController.h"

extern NSInteger const TS_ITEMS_PER_PAGE;
extern NSInteger const TS_HOME_CLIPS_PER_PAGE;
extern NSString* const TS_TIPO_CLIP_SLUG;
extern NSString* const TS_CLIP_SLUG;
extern NSString* const TS_PROGRAMA_SLUG;
extern NSString* const TS_NOTICIAS_SLUG;

@interface TSBasicListViewController : TSReachabilityViewController <TSDataManagerDelegate> {

@protected

    //Aquí se guardan los resultados de las peticiones hechas al TSManagerData.
    NSArray *currentData;
    //Aquí se guardan los elementos que componen la tabla principal o default.
    NSMutableArray *tableElements;
    //Aquí se guardan los catalogos de datos tales como tipo_clip, programa, etc.
    NSMutableDictionary *catalogs;

    //Sección actual de la aplicación, seleccionada en el menú lateral. home, noticias, noticias-texto, opiniones, etc.
    NSString *currentSection;
    //Subsección actual de la aplicación, seleccionada en el menú de arriba para filtrar la info que se presenta en la sección.
    NSString *currentSubsection;
    //Indice del item de la tabla seleccionada por el usuario.
    NSIndexPath *selectedIndexPath;

    //Bandera que sirve para saber si los datos pedidos se agregarán al final de la tabla de elementos o compondrán una nueva tabla
    BOOL addAtListEnd;
    //Posición en la que se guarda el catalogo de elementos que compondrá la tabla de elementos. Sirve
    int defaultDataResultIndex;
    //Bandera que sirve para deshabilitar teclado, al entrar a algunas secciones sobre todo es útil al venir de la sección de búsqueda.
    BOOL cancelUserInteraction;
    //Bandera que sirve para saber cuando se ha iniciado la aplicación y se necesita mostrar el cargador con la imagen del splash de teleSUR.
    BOOL isAnInitialScreen;

}

@property (nonatomic, retain) NSMutableArray *currentFilters;

// Inicializa las variables necesarias para el funcionamiento de la vista. Se llama solo al crear la vista
- (void) initViewVariables;
// Reinicia los valores de la tabla principal
- (void) initTableVariables;
// Función general que manda a cargar los datos necesarios para la presentación de datos. Se llama en el ViewDidLoad
- (void) loadData;
// Carga los datos para la sección y subsección actual.
- (void) loadCurrentSectionData;


// Metodo para saber si alguna sección es una sección de noticias de texto (RSS) o si es una sección de videos.
- (BOOL) isRSSSection:(NSString *)section;
// Metodo delegado para recibir los datos de la carga de datos enviada al TSDataManager
- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests;

// Regresa la URL para la celda en el index enviado, toma en cuenta el row y la sección. También decide entre mandar la URL de la imagen grande o pequeña de acuerdo al index. Se puede forzar a que mande la imagen grande.
- (NSURL *) getThumbURLForIndex:(NSIndexPath *)indexPath forceLargeImage:(BOOL)largeImage forDefaultTable:(BOOL)defaultTable;
// Regresa la URL para una celda que pertenece a un RSS.
- (NSURL *) getThumbURLFromMWFeedItem:(MWFeedItem *)feedItem forceLargeImage:(BOOL)largeImage;
// Regresa la URL para una celda que pertenece a un video del API.
- (NSURL *) getThumbURLFromAPIItem:(NSDictionary *)data forceLargeImage:(BOOL)largeImage;
// Regresa el array que contiene los datos de acuerdo al indexPath, decide de acuerdo a la sección. Util cuando se tiene una tabla con varias secciones y los datos están en arrays diferentes como en el caso del HOME.
- (NSArray *) getDataArrayForIndexPath:(NSIndexPath *)indexPath forDefaultTable:(BOOL)defaultTable;




- (void) reloadData;

- (void) loadDataWithSection:(NSString *)section withSlug:(NSString *)slug;
//- (void) configFilterWithSelectedSlug:(NSString *)slug;
//- (void) initDataFilterWith:(NSString *)section;
- (void) filterSelectedWithSlug:(NSString *)slug;



- (void) loadCatalog:(NSString *)key;
- (void) setCatalog:(NSArray *)data forKey:(NSString *)key;

- (UITableViewCell *)getReuseCell:(UITableView *)tableView withID:(NSString *)cellID;

- (void) showNews;
- (NSArray *) getResultDataAtIndex:(int) index;

@end