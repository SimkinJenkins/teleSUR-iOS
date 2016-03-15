//
//  KABasicTableCellData.m
//  La Jornada
//
//  Created by Simkin on 09/10/15.
//  Copyright © 2015 La Jornada. All rights reserved.
//

#import "KABasicCellData.h"

@implementation KABasicCellData

@synthesize ID, type, title, summary, images, rawData, cellID, cellSize;



- (id) initWithDictionary:(NSDictionary *)raw {

    self = [super init];

    if (self) {
        ID = [raw objectForKey:@"id"];
        title = [raw objectForKey:@"title"] ? [raw objectForKey:@"title"] : [raw objectForKey:@"name"];
        summary = [raw objectForKey:@"summary"];
        type = [raw objectForKey:@"type"];
        self.slug = [raw objectForKey:@"slug"];
        if ( [raw objectForKey:@"images"] && [[raw objectForKey:@"images"] isKindOfClass:[NSArray class]] ) {
            NSArray *rawImagesData = [raw objectForKey:@"images"];
            NSMutableArray *imagesData = [NSMutableArray array];
            for ( uint i = 0; i < [rawImagesData count]; i++ ) {
                [imagesData addObject:[[KABasicImageData alloc] initWithDictionary:[rawImagesData objectAtIndex:i]]];
            }
            images = [NSArray arrayWithArray:imagesData];
        } else {
            images = [NSArray arrayWithObject:[[KABasicImageData alloc] initWithDictionary:[raw objectForKey:@"images"]]];
        }
        rawData = raw;
        self.URL = [raw objectForKey:@"resource_uri"];
    }

    return self;

}



@end