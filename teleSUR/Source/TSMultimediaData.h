//
//  TSMultimediaData.h
//  teleSUR-iOS
//
//  Created by David Regla on 2/12/11.
//  Copyright 2011 teleSUR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSMultimediaDataDelegate.h"
#import "MWFeedParser.h"

@interface TSMultimediaData : NSObject <MWFeedParserDelegate> {

    id <NSObject, TSMultimediaDataDelegate> __weak delegate;

	NSMutableData *JSONData;

    @private
        NSString *entidadString;
        NSMutableArray *parsedItems;
        MWFeedParser *feedParser;
}

@property (nonatomic, weak) id <NSObject, TSMultimediaDataDelegate> delegate;
@property (nonatomic, retain) NSString *entidadString;

- (void)getDatosParaEntidad:(NSString *)entidad
                 conFiltros:(NSMutableArray *)filtros
                    enRango:(NSRange)rango
                conDelegate:(id)datosDelegate;
- (void)getTextResourcesFor:(NSString *)section
                   withSlug:(NSString *)filterSlug
               withDelegate:(id)delegateData;

- (NSString *)urlEncode:(NSString *)string;

@end