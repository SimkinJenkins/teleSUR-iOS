//
//  KABasicImageData.m
//  La Jornada
//
//  Created by Simkin on 09/10/15.
//  Copyright © 2015 La Jornada. All rights reserved.
//

#import "KABasicImageData.h"

@implementation KABasicImageData

@synthesize ID, type, title, summary, URL, thumbURL;



- (id)initWithDictionary:(NSDictionary *)rawData {

    self = [super init];
    if (self) {

        ID = [rawData objectForKey:@"id"];
        type = [rawData objectForKey:@"kind"];

        title = [rawData objectForKey:@"header"];
        summary = [rawData objectForKey:@"caption"];

        URL = [rawData objectForKey:@"url"];
        thumbURL = [rawData objectForKey:@"snap"];

    }
    return self;

}



@end