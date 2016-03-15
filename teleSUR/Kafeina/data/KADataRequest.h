//
//  KADataRequest.h
//  teleSUR
//
//  Created by Simkin on 27/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//
//  Esta clase contiene una sola petición dentro del KADataManager y su resultado.

#import <Foundation/Foundation.h>

@interface KADataRequest : NSObject




//El tipo de la petición que puede es noticias-texto
@property (nonatomic, assign) NSString *type;
//La sección actual al momento de la petición puede ser: home, noticias, videos, opinion, blogs, programas, reportajes, busqueda
@property (nonatomic, assign) NSString *section;
//La subsección actual
@property (nonatomic, assign) NSString *subsection;
//ID para pedir detalle de una noticia
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *URLString;
@property (nonatomic, strong) NSString *json;
@property (nonatomic, strong) NSString *requestHTTPMethod;
//ID para pedir detalle de una noticia
@property (nonatomic, assign) NSString *family;
//Paginado para la petición de datos
@property (nonatomic, assign) NSRange range;
@property (nonatomic, strong) NSArray *responseRaw;
//Los datos obtenidos de la petición ya analizados
@property (nonatomic, strong) NSArray *responseParsed;
//Error en caso de haberlo
@property (nonatomic, weak) id error;




- (id)initWithType:(NSString *)requestType forSection:(NSString *)currentSection forSubsection:(NSString *)currentSubsection;
- (id)initWithType:(NSString *)requestType forSection:(NSString *)currentSection forFamily:(NSString *)currentFamily;




@end