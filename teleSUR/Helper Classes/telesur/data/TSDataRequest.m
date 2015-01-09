//
//  TSDataRequest.m
//  teleSUR
//
//  Created by Simkin on 27/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSDataRequest.h"

@implementation TSDataRequest

@synthesize type, section, subsection, result, range, error, relatedSlug, searchText;

- (id)initWithType:(NSString *)requestType forSection:(NSString *)currentSection forSubsection:(NSString *)currentSubsection {

    self = [super init];
    if (self) {
        type = requestType;
        section = currentSection;
        subsection = currentSubsection;
    }
    return self;

}

@end