    //
//  TSDataManager.m
//  teleSUR
//
//  Created by Simkin on 24/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSDataManager.h"
#import "TSDataRequest.h"


@implementation TSDataManager

@synthesize delegate;

#pragma mark -
#pragma mark Public methods

- (void)loadRequests:(NSArray *)currentQueue delegateResponseTo:(id) dataDelegate {

    queue = currentQueue;
    index = 0;
    self.delegate = dataDelegate;
    [self startLoadProcess];

}

- (void) loadRSSDataFor:(NSString *) section
          andSubsection:(NSString *) subsection
     delegateResponseTo:(id) dataDelegate {
    
    NSArray *tempQueue = [NSArray arrayWithObject:[[TSDataRequest alloc] initWithType:@"noticias-texto" forSection:section forSubsection:subsection]];
    
    [self loadRequests:tempQueue delegateResponseTo:dataDelegate];
    
}

- (void) loadAPIDataFor:(NSString *) section
          andSubsection:(NSString *) subsection
           withDataType:(NSString *) type
                inRange:(NSRange) range
     delegateResponseTo:(id) dataDelegate {

    TSDataRequest *request = [[TSDataRequest alloc] initWithType:type forSection:section forSubsection:subsection];
    request.range = range;
    NSArray *tempQueue = [NSArray arrayWithObject:request];

    [self loadRequests:tempQueue delegateResponseTo:dataDelegate];

}











- (void) startLoadProcess {

    index = 0;
    currentResults = [NSMutableArray array];
    [self loadCurrentRequest];

}

- (void) loadNextQueueRequest {
    
    index++;

    [self loadCurrentRequest];

}

- (void)loadCurrentRequest {

    if( index >= [queue count] ) {
        [self didLoadQueueFinished];
        return;
    }

    currentRequest = [queue objectAtIndex:index];

    if( [currentRequest.type isEqualToString: @"noticias-texto"] ) {
        [self loadCurrentRSSRequest];
    } else {
        [self loadCurrentAPIRequest];
    }

}

- (void)didLoadQueueFinished {

    for (int i = 0; i < [queue count]; i++) {
        if ( i < [currentResults count]) {
            ((TSDataRequest *)[queue objectAtIndex:i]).result = [currentResults objectAtIndex:i];
        }
    }
    if ([delegate respondsToSelector:@selector(TSDataManager:didProcessedRequests:)]) {
        [delegate TSDataManager:self didProcessedRequests:queue];
    }

}

- (void)loadCurrentRSSRequest {

    parsedItems = [[NSMutableArray alloc] init];

    NSURL *feedURL = [NSURL URLWithString:[self getRSSURLStringWithSection:currentRequest.section withSlug:currentRequest.subsection]];

    NSLog(@"%@", feedURL);

    feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
    feedParser.delegate = self;
    feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
    feedParser.connectionType = ConnectionTypeAsynchronously;
    [feedParser parse];

}

- (void)loadCurrentAPIRequest {

    NSString *urlBase = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"API URL Base"];
    NSString *langCode = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"langCode"];
    
    NSMutableArray *parameters = [NSMutableArray array];
    id currentFilter = nil;
    
    // Agregar posibles filtros para clips
    if ([currentRequest.type isEqualToString:@"clip"]) {
        // Buscar nombres de parámetros reconocidos y agregarlos al arreglo de parámetros GET
        NSArray *params = [NSArray arrayWithObjects:@"desde", @"hasta", @"tiempo", @"orden", @"detalle", @"categoria", @"programa", @"geotag", @"tipo", @"pais", @"tema", @"corresponsal", @"personaje", @"ubicacion", @"relacionados", @"texto", @"detalle", @"region", nil];

        NSMutableArray *filters = [self getAPIFilterForSection:currentRequest.section andSubsection:currentRequest.subsection];

        if( currentRequest.relatedSlug ) {
            [filters addObject:@{@"relacionados":currentRequest.relatedSlug}];
        }
        if( currentRequest.searchText ) {
            [filters addObject:@{@"texto":[currentRequest.searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]}];
        }

        for (uint i = 0; i < [filters count]; i++) {
            NSDictionary *filter = [filters objectAtIndex:i];
            for (NSString *param in params) {
                if((currentFilter = [filter objectForKey:param])) {
                    if ([currentFilter isKindOfClass:[NSArray class]]) {
                        for (currentFilter in currentFilter) {
                            [parameters addObject:[NSString stringWithFormat:@"%@=%@", param, currentFilter]];
                        }
                    } else {
                        [parameters addObject:[NSString stringWithFormat:@"%@=%@", param, currentFilter]];
                    }
                }
            }
        }
    } else if ([currentRequest.type isEqualToString:@"categoria"] || [currentRequest.type isEqualToString:@"programa"] || [currentRequest.type isEqualToString:@"pais"] || [currentRequest.type isEqualToString:@"tema"] || [currentRequest.type isEqualToString:@"corresponsal"] || [currentRequest.type isEqualToString:@"personaje"] || [currentRequest.type isEqualToString:@"tipo_clip"]) {
        NSLog(@"No se hace nada para el request tipo %@", currentRequest.type);
    } else {
        NSLog(@"El nombre de la entidad no se reconoce: %@", currentRequest.type);
        return;
    }
    
    // cualquier entidad puede ser paginada
    if (currentRequest.range.location) {

        [parameters addObject:[NSString stringWithFormat:@"primero=%lu", (unsigned long)currentRequest.range.location]];
        [parameters addObject:[NSString stringWithFormat:@"ultimo=%lu", (unsigned long)(currentRequest.range.location + currentRequest.range.length - 1)]];

    }

    [parameters addObject:@"detalle=completo"];

    // construir quierystring, URL, consulta y conexión
    NSString *queryStr = [parameters componentsJoinedByString:@"&"];

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/api/%@/?%@", urlBase, langCode, currentRequest.type, queryStr]];
    
    //    NSLog(@"%@", multimediaAPIRequestURL);
    NSLog(@"URL a consultar: %@", URL);
    NSLog(@"%lu - %lu - para -> %@", (unsigned long)currentRequest.range.location, (unsigned long)currentRequest.range.length, currentRequest.type);
    
    NSURLRequest *request=[NSURLRequest requestWithURL:URL
                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:10.0];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (connection) {
        
        JSONData = [[NSMutableData alloc] init];
        
    } else {
        
        NSLog(@"Error de conexión");
        
    }

}

- (NSString *) getRSSURLStringWithSection:(NSString *)section
                                withSlug:(NSString *)filterSlug {

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

- (NSMutableArray *) getAPIFilterForSection:(NSString *)section andSubsection:(NSString *)subsection {

    NSMutableArray *filters = [self getDefaultAPIFilterForSection:section];

    if ([subsection isEqualToString:@"latinoamerica"]) {
        [filters addObject:@{@"region":@"america-latina"}];
    } else if([subsection isEqualToString:@"ciencia-y-tecnologia"]) {
        [filters addObject:@{@"categoria":@"ciencia"}];
        [filters addObject:@{@"categoria":@"ciencia-y-tecnologia"}];
    } else if([subsection isEqualToString:@"mundo"]) {
        [filters addObject:@{@"region":@"america"}];
        [filters addObject:@{@"region":@"asia"}];
        [filters addObject:@{@"region":@"europa"}];
        [filters addObject:@{@"region":@"africa"}];
        [filters addObject:@{@"region":@"oceania"}];
    } else if([section isEqualToString:@"reportaje"]) {
        [filters addObject:@{@"tipo":@"reportaje"}];
    } else if(![subsection isEqualToString:@""]) {
        //@"deportes"
        //@"cultura"
        //@"salud"
        //@"sintesis-web"
        //Todos los programas
        NSString *key = [section isEqualToString:@"programa"] ? @"programa" : @"categoria";
        [filters addObject:@{key:subsection}];
    }

    return filters;
}

- (NSMutableArray *) getDefaultAPIFilterForSection:(NSString *)section {
    
    NSMutableArray *filters = [[NSMutableArray alloc] init];
    
    if ([section isEqualToString:@"entrevista"] || [section isEqualToString:@"especial-web"] || [section isEqualToString:@"programa"] || [section isEqualToString:@"infografia"]) {
        
        [filters addObject:@{@"tipo":section}];
        
    } else if ([section isEqualToString:@"video-noticia"]) {
        
        [filters addObject:@{@"tipo":@"noticia"}];
        
    } else {
        NSLog(@"initDataFilterWith: No filter configured for current section. section:%@", section);
    }
    
    return filters;
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

- (void)feedParserDidStart:(MWFeedParser *)parser {     /*NSLog(@"Started Parsing: %@", parser.url);*/      }

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {     /*NSLog(@"Parsed Feed Info: “%@”", info.title);*/       }

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    //    NSLog(@"Parsed Feed Item: “%@”", item.title);
    if (item) [parsedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
//    NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    [self feedParsed:[parsedItems sortedArrayUsingDescriptors:
                      [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date"
                                                                           ascending:NO]]]];

}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"Finished Parsing With Error: %@", error);
    if (parsedItems.count == 0) {
        NSLog(@"No se recuperaron items del RSS");
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

    [currentResults addObject:data];

    [self loadNextQueueRequest];

}










#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Preparar objeto de datos
    [JSONData setLength:0];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Poblar objeto de datos con datos recibidos
    [JSONData appendData:data];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Liberar objeto de conexión y objeto de datos
    JSONData = nil;

    NSLog(@"connection:%@ didFailWithError:%@", connection, error);
    currentRequest.error = error;

    [self loadNextQueueRequest];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Parsear JSON
    NSError *JSONError = NULL;

    [currentResults addObject:[NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&JSONError]]];

//    ((TSDataRequest *)[queue objectAtIndex:index]).result = [NSArray arrayWithArray:[NSJSONSerialization JSONObjectWithData:JSONData options:kNilOptions error:&JSONError]];
    ((TSDataRequest *)[queue objectAtIndex:index]).error  = JSONError;

    JSONData = nil;

    [self loadNextQueueRequest];
}


@end