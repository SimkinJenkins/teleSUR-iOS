//
//  UIViewController+TSDataMG.m
//  teleSUR
//
//  Created by Simkin on 17/02/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import "UIViewController+TSDataMG.h"

@implementation UIViewController (TSDataMG)

NSString* const TS_API_URL = @"http://multimedia.tlsur.net/";
NSString* const JO_IMPRESA_URL = @"http://movil.jornada.com.mx/api/";
NSString* const JO_RELATED_URL = @"http://www.jornada.unam.mx/ultimas/nitf_list.json";
NSString* const JO_PHOTO_BITACORA_URL = @"http://www.jornada.unam.mx/ultimas/jsonbloggingview";
NSString* const JO_PHOTO_GALERIES_URL = @"http://www.jornada.unam.mx/ultimas/jsongalleryview";
NSString* const JO_VIDEOS_URL = @"http://video.jornada.com.mx/clip/";
NSString* const JO_BLOGS_URL = @"http://www.jornada.unam.mx/blogs/webservices/allblogs.php";
NSString* const JO_BLOGS_API_URL = @"http://www.jornada.unam.mx/blogs/api/";
//http://www.jornada.unam.mx/blogs/api/?id=blog_id&postid=post_id


- (NSArray *) getLatestNewsHomeRequest {
    return [[NSArray alloc] initWithObjects:[self getCatalogWithType:@"tipo_clip"], [self getCatalogWithType:@"programa"], [self getRSSRequestForSection:@"" andSlug:@""], [self getClipDataWithType:@"noticia" andRange:NSMakeRange(1, 10)], [self getClipDataWithType:@"programa" andRange:NSMakeRange(1, 10)], [self getRSSRequestForSection:@"noticias" andSlug:@"ultimas"], nil];
}

- (KADataRequest *) getClipDataWithType:(NSString *)type andRange:(NSRange)range {
    KADataRequest *request = [[KADataRequest alloc] initWithType:@"clip" forSection:@"noticia" forFamily:@""];
    request.URL = [self getNSURLWithBaseURL:[self getBaseURLStringWithType:@"clip"] andSeparator:@"?"
                              andParameters:[self getClipDataParametersWithType:type inRange:range]];
    return request;
}

- (KADataRequest *) getCatalogWithType:(NSString *)type {
    KADataRequest *request = [[KADataRequest alloc] initWithType:@"catalog" forSection:@"" forFamily:@""];
    request.URL = [self getNSURLWithBaseURL:[self getBaseURLStringWithType:type] andSeparator:@"?" andParameters:[self getCatalogParameters]];
    return request;
}

- (KADataRequest *) getRSSRequestForSection:(NSString *)section andSlug:(NSString *)slug {
    KADataRequest *request = [[KADataRequest alloc] initWithType:@"RSS" forSection:@"" forFamily:@""];
    request.URL = [self getNSURLWithBaseURL:[self getRSSURLStringWithSection:section withSlug:slug] andSeparator:@"?" andParameters:[self getRSSParameters]];
    return request;
}

- (NSMutableArray *) getClipDataParametersWithType:(NSString *)type inRange:(NSRange)range {
    NSMutableArray *params = [NSMutableArray array];
    [params addObject:@"detalle=completo"];
    [params addObject:[NSString stringWithFormat:@"primero=%lu", (unsigned long)range.location]];
    [params addObject:[NSString stringWithFormat:@"ultimo=%lu", (unsigned long)range.location + range.length]];
    [params addObject:[NSString stringWithFormat:@"tipo=%@", type]];
    return params;
}

-(NSMutableArray *) getCatalogParameters {
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:@"detalle=completo"];
    [parameters addObject:@"primero=1"];
    [parameters addObject:@"ultimo=300"];
    return parameters;
}

-(NSMutableArray *) getRSSParameters {
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:[NSString stringWithFormat:@"x=%d", rand()]];
    return parameters;
}

-(NSURL *) getNSURLWithBaseURL:(NSString *)URL andSeparator:(NSString *)separator andParameters:(NSMutableArray *)parameters {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", URL, separator, [parameters componentsJoinedByString:@"&"]]];
}

- (NSString *) getBaseURLStringWithType:(NSString *)type {
    NSString *urlBase = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"API URL Base"];
    NSString *langCode = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"langCode"];
    return [NSString stringWithFormat:@"%@%@/api/%@/", urlBase, langCode, type];
}

- (NSString *)getRSSURLStringWithSection:(NSString *)section withSlug:(NSString *)filterSlug {
    if ([section isEqualToString:@"blog"]) {
        return [NSString stringWithFormat:NSLocalizedString(@"blogRSS", nil)];
    }
    if ([section isEqualToString:@"opinion"]) {
        if ([filterSlug isEqualToString:@"op-entrevistas"]) {
            return [NSString stringWithFormat:NSLocalizedString(@"op-entrevistasRSS", nil)];
        }
        return [NSString stringWithFormat:NSLocalizedString(@"opinionRSS", nil)];
    }
    if ([section isEqualToString:@"noticias"] && filterSlug && ![filterSlug isEqualToString:@""]) {
        NSString *localizeID = [NSString stringWithFormat:@"%@RSS", filterSlug];
        return [NSString stringWithFormat:NSLocalizedString(localizeID, nil)];
    }
    return [NSString stringWithFormat:NSLocalizedString(@"portadaRSS", nil)];
}

/*
- (NSArray *) getPrintedNewsHomeRequest {
    return [[NSArray alloc] initWithObjects:[self getPrintedNewsRequestHomeForFamily:@"portada"], [self getPrintedNewsRequestHomeForFamily:@"contra"], [self getPrintedNewsRequestHomeForFamily:@"dir"], nil];
}

- (NSArray *) getNewsRequestForSection:(NSString *)ID isPrintedSection:(BOOL)isPrintedSection {
    if ( !ID || [ID isEqualToString:@""] ) {
        return nil;
    }
    if ( !isPrintedSection ) {
        return [[NSArray alloc] initWithObjects:[self getLatestRequestForSection:ID], nil];
    }
    return [[NSArray alloc] initWithObjects:[self getPrintedRequestForSection:ID], nil];
}

- (NSArray *) getCartoonsHomeRequest {
    return [[NSArray alloc] initWithObjects:[self getPrintedNewsRequestHomeForFamily:@"cartones"], nil];
}

- (NSArray *) getGaleriesPhotoBitacoraHomeRequest {
    KADataRequest *request = [[KADataRequest alloc] initWithType:@"photo" forSection:@"bitacora" forFamily:@""];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:@"page=1"];
    request.URL = [self getNSURLWithBaseURL:JO_PHOTO_BITACORA_URL andSeparator:@"?" andParameters:parameters];
    return [[NSArray alloc] initWithObjects:request, nil];
}

- (NSArray *) getGaleriesPhotoGaleriesHomeRequest {
    KADataRequest *request = [[KADataRequest alloc] initWithType:@"photo" forSection:@"bitacora" forFamily:@""];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:@"page=1"];
    request.URL = [self getNSURLWithBaseURL:JO_PHOTO_GALERIES_URL andSeparator:@"?" andParameters:parameters];
    return [[NSArray alloc] initWithObjects:request, nil];
}

- (NSArray *) getVideosHomeRequest {
    KADataRequest *request = [[KADataRequest alloc] initWithType:@"photo" forSection:@"bitacora" forFamily:@""];
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:@"primero=1"];
    [parameters addObject:@"ultimo=20"];
    [parameters addObject:@"detalle=completo"];
    request.URL = [self getNSURLWithBaseURL:JO_VIDEOS_URL andSeparator:@"?" andParameters:parameters];
    return [[NSArray alloc] initWithObjects:request, nil];
}
*/
@end
