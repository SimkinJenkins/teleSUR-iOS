//
//  TSDataRequest.h
//  teleSUR
//
//  Created by Simkin on 27/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//
//  Esta clase contiene una sola petición dentro del TSDataManager y su resultado.

#import <Foundation/Foundation.h>

@interface TSDataRequest : NSObject

//El tipo de la petición que puede ser: clip, tipo_clip, programa, serie, categoria, estado, pais, tema, corresponsal, personaje ** en el caso de las peticiones a RSS es noticias-texto
@property (nonatomic, assign) NSString *type;
//La sección actual al momento de la petición puede ser: home, noticias, videos, opinion, blogs, programas, reportajes, busqueda
@property (nonatomic, assign) NSString *section;
//La subsección actual
@property (nonatomic, assign) NSString *subsection;
//Por el momento se ocupa solo para relacionados.
@property (nonatomic, assign) NSString *relatedSlug;
//Por el momento se ocupa solo para busqueda.
@property (nonatomic, assign) NSString *searchText;
//Paginado para la petición de datos
@property (nonatomic, assign) NSRange range;

//Los datos obtenidos de la petición ya analizados
@property (nonatomic, strong) NSArray *result;

//Error en caso de haberlo
@property (nonatomic, weak) id error;

- (id)initWithType:(NSString *)requestType forSection:(NSString *)currentSection forSubsection:(NSString *)currentSubsection;

@end
