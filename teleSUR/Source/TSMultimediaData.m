//
//  TSMultimediaData.m
//  teleSUR-iOS
//
//  Created by David Regla on 2/12/11.
//  Copyright 2011 teleSUR. All rights reserved.
//

#import "TSMultimediaData.h"
#import "MWFeedParser.h"

#include "UIViewController_Preferencias.h"

@implementation TSMultimediaData

@synthesize delegate, entidadString;

- (void)getTextResourcesFor:(NSString *) section
                   withSlug:(NSString *) filterSlug
               withDelegate:(id)delegateData
{

    self.entidadString = section;
	self.delegate = delegateData;

    parsedItems = [[NSMutableArray alloc] init];

	NSURL *feedURL = [NSURL URLWithString:[self getRSSURLStringWithSection:section withSlug:filterSlug]];

    NSLog(@"%@", feedURL);

//	feed = [[Feed alloc] initWithURL:feedURL];
//    feed.delegate = self;
//    [feed refresh];

    feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
    feedParser.delegate = self;
    feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
    feedParser.connectionType = ConnectionTypeAsynchronously;
    [feedParser parse];

}

- (NSString *)getRSSURLStringWithSection:(NSString *)section
                                withSlug:(NSString *)filterSlug
{
    NSString *langCode = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"langCode"];
    BOOL defaultIdiom = [langCode isEqualToString:@"es"];
    if ([section isEqualToString:@"blog"]) {
        return defaultIdiom ? @"http://www.telesurtv.net/rss/RssBlogs.xml" : @"http://www.telesurtv.net/english/rss/RssBlogs.xml";
    } else if ([section isEqualToString:@"opinion"]) {
        if ([filterSlug isEqualToString:@"op-entrevistas"]) {
            return defaultIdiom ? @"http://www.telesurtv.net/rss/RssInterviews.xml" : @"http://www.telesurtv.net/english/rss/RssInterviews.xml";
        }
        return defaultIdiom ? @"http://www.telesurtv.net/rss/RssOpinion.xml" : @"http://www.telesurtv.net/english/rss/RssOpinion.xml";
    } else if ([section isEqualToString:@"noticias"]) {
        if ([filterSlug isEqualToString:@"latinoamerica"]) {
            return defaultIdiom ? @"http://www.telesurtv.net/rss/RssLatinoamerica.xml" : @"http://www.telesurtv.net/english/rss/RssLatinoamerica.xml";
        } else if ([filterSlug isEqualToString:@"mundo"]) {
            return defaultIdiom ? @"http://www.telesurtv.net/rss/RssMundo.xml" : @"http://www.telesurtv.net/english/rss/RssWorld.xml";
        } else if ([filterSlug isEqualToString:@"deportes"]) {
            return defaultIdiom ? @"http://www.telesurtv.net/rss/RssDeporte.xml" : @"http://www.telesurtv.net/english/rss/RssSports.xml";
        } else if ([filterSlug isEqualToString:@"cultura"]) {
            return defaultIdiom ? @"http://www.telesurtv.net/rss/RssCultura.xml" : @"http://www.telesurtv.net/english/rss/RssCulture.xml";
        }
    }
    return defaultIdiom ? @"http://www.telesurtv.net/rss/RssPortada.xml" : @"http://www.telesurtv.net/english/rss/RssHome.xml";
}

- (void)getDatosParaEntidad:(NSString *)entidad
                 conFiltros:(NSMutableArray *)filtros
                    enRango:(NSRange)rango
                conDelegate:(id)datosDelegate
{

    self.entidadString = entidad;
	self.delegate = datosDelegate;

	NSString *urlBase = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"API URL Base"];
	NSString *langCode = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"langCode"];

    NSMutableArray *parametrosGET = [NSMutableArray array];
	id currentFiltro = nil;
	
    // Agregar posibles filtros para clips
	if ([entidad isEqualToString:@"clip"])
    {
        // Buscar nombres de parámetros reconocidos y agregarlos al arreglo de parámetros GET
        NSArray *params = [NSArray arrayWithObjects:@"desde", @"hasta", @"tiempo", @"orden", @"detalle", @"categoria", @"programa", @"geotag", @"tipo", @"pais", @"tema", @"corresponsal", @"personaje", @"ubicacion", @"relacionados", @"texto", @"detalle", @"region", nil];

//        [parametrosGET addObject:[NSString stringWithFormat:@"detalle=completo"]];

        for (uint i = 0; i < [filtros count]; i++) {
            NSDictionary *filtro = [filtros objectAtIndex:i];
            for (NSString *param in params) {
//                NSLog(@"Comparación :%@ - es - %@ -----> %@", param, [filtro objectForKey:param], filtro);
                if((currentFiltro = [filtro objectForKey:param])) {
                    if ([currentFiltro isKindOfClass:[NSArray class]]) {
                        for (currentFiltro in currentFiltro)
                            [parametrosGET addObject:[NSString stringWithFormat:@"%@=%@", param, currentFiltro]];
                    } else {
                        [parametrosGET addObject:[NSString stringWithFormat:@"%@=%@", param, currentFiltro]];
                    }
                }
            }
        }
/*
            if ((currentFiltro = [filtros objectForKey:param])) {
            }
*/
	}
    else if ([entidad isEqualToString:@"categoria"])
    { }
    else if ([entidad isEqualToString:@"programa"])
    { }
    else if ([entidad isEqualToString:@"pais"])
    {
/*
        NSArray *params = [NSArray arrayWithObjects:@"ubicacion", nil];

        for (NSString *param in params)
            if ((currentFiltro = [filtros objectForKey:param])) {
                if ([currentFiltro isKindOfClass:[NSArray class]]) {
                    for (currentFiltro in currentFiltro)
                        [parametrosGET addObject:[NSString stringWithFormat:@"%@=%@", param, currentFiltro]];
                } else {
                    [parametrosGET addObject:[NSString stringWithFormat:@"%@=%@", param, currentFiltro]];
                }
            }
*/
    }
    else if ([entidad isEqualToString:@"tema"])
    { }
    else if ([entidad isEqualToString:@"corresponsal"])
    { }
    else if ([entidad isEqualToString:@"personaje"])
    { }
    else if ([entidad isEqualToString:@"tipo_clip"])
    { }
    else
    {
		NSLog(@"El nombre de la entidad no se reconoce: %@", entidad);
/*
		if ([delegate respondsToSelector:@selector(entidadesRecibidasConFalla:)])
        {
            NSError *error = [NSError errorWithDomain:@"TSMultimediaData" code:100 userInfo:[NSDictionary dictionary]];
			[delegate performSelector:@selector(entidadesRecibidasConFalla:) withObject:error];
		}
*/
		return;
	}
	
	// cualquier entidad puede ser paginada
    if (rango.length)
    {
        [parametrosGET addObject:[NSString stringWithFormat:@"primero=%lu", (unsigned long)rango.location]];
        [parametrosGET addObject:[NSString stringWithFormat:@"ultimo=%lu", (unsigned long)(rango.location + rango.length - 1)]];
    }

    [parametrosGET addObject:@"detalle=completo"];

	// construir quierystring, URL, consulta y conexión
	NSString *queryString = [parametrosGET componentsJoinedByString:@"&"];
	
	NSURL *multimediaAPIRequestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/api/%@/?%@", urlBase, langCode, entidad, queryString]];

//    NSLog(@"%@", multimediaAPIRequestURL);
	NSLog(@"URL a consultar: %@", multimediaAPIRequestURL);
    NSLog(@"%lu - %lu - para -> %@", (unsigned long)rango.location, (unsigned long)rango.length, entidad);

	NSURLRequest *apiRequest=[NSURLRequest requestWithURL:multimediaAPIRequestURL
											  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
										  timeoutInterval:10.0];
	
	NSURLConnection *conexion = [[NSURLConnection alloc] initWithRequest:apiRequest delegate:self];
	
	if (conexion)
    {
        JSONData = [[NSMutableData alloc] init];
	}
    else
    {
        NSLog(@"Error de conexión");
/*
		if ([delegate respondsToSelector:@selector(entidadesRecibidasConError:)])
        {
            NSError *error = [NSError errorWithDomain:@"TSMultimediaData" code:101 userInfo:[NSDictionary dictionary]];
			[delegate performSelector:@selector(entidadesRecibidasConError:) withObject:error];
		}
*/
	}
}

// Codifica parámetros para URL
- (NSString *)urlEncode:(NSString *)string
{
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)string,
                                                               NULL,
                                                               CFSTR("!*'();:@&=+$,/?%#[]"),
                                                               CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}


#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// Preparar objeto de datos
    [JSONData setLength:0];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Poblar objeto de datos con datos recibidos
    [JSONData appendData:data];

}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

	// Liberar objeto de conexión y objeto de datos
    JSONData = nil;

	if ([delegate respondsToSelector:@selector(TSMultimediaData:entidadesRecibidasConError:)])
        [delegate TSMultimediaData:self entidadesRecibidasConError:error];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

	// Parsear JSON
	NSError *JSONError = NULL;

    NSArray *resultadoArray = [NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&JSONError];

	if (!JSONError) {
		if (delegate && [delegate respondsToSelector:@selector(TSMultimediaData:entidadesRecibidas:paraEntidad:)]) {
			[delegate TSMultimediaData:self entidadesRecibidas:resultadoArray paraEntidad:self.entidadString];
        }
	} else {
		if (delegate && [delegate respondsToSelector:@selector(TSMultimediaData:entidadesRecibidasConError:)]) {
			[delegate TSMultimediaData:self entidadesRecibidasConError:JSONError];
        }
	}
    // liberar objeto de conexión y objeto de datos
    JSONData = nil;

}








#pragma mark -
#pragma mark Parsing

// Reset and reparse
- (void)refresh {
    [parsedItems removeAllObjects];
    [feedParser stopParsing];
    [feedParser parse];
}








#pragma mark -
#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
//    NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
//    NSLog(@"Parsed Feed Info: “%@”", info.title);
//    self.title = info.title;
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
//    NSLog(@"Parsed Feed Item: “%@”", item.title);
    if (item) [parsedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
    NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));

    [self feedParsed:[parsedItems sortedArrayUsingDescriptors:
                      [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                           ascending:NO]]]];

}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"Finished Parsing With Error: %@", error);
    if (parsedItems.count == 0) {
        NSLog(@"No se recuperaron items del RSS");
//        self.title = @"Failed"; // Show failed message in title
    } else {
        // Failed but some items parsed, so show and inform of error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parsing Incomplete"
                                                        message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }

    [self feedParsed:[parsedItems sortedArrayUsingDescriptors:
                      [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                           ascending:NO]]]];
}

- (void)feedParsed:(NSArray *)data {

    if (delegate && [delegate respondsToSelector:@selector(TSMultimediaData:entidadesRecibidas:paraEntidad:)]) {
        [delegate TSMultimediaData:self entidadesRecibidas:data paraEntidad:@"noticias-texto"];
    }

}

#pragma Mark -

- (void)dealloc
{
	self.delegate = nil;
    //Comentado para pruebas
//	[super dealloc];
}

@end
