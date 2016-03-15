//
//  KADataRequest.m
//  teleSUR
//
//  Created by Simkin on 27/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "KADataRequest.h"

@implementation KADataRequest

@synthesize type, section, subsection, responseParsed, responseRaw, range, error, family;

- (id)initWithType:(NSString *)requestType forSection:(NSString *)currentSection forSubsection:(NSString *)currentSubsection {

    self = [super init];
    if (self) {
        type = requestType;
        section = currentSection;
        subsection = currentSubsection;
    }
    return self;

}

- (id)initWithType:(NSString *)requestType forSection:(NSString *)currentSection forFamily:(NSString *)currentFamily {

    self = [super init];
    if (self) {
        type = requestType;
        section = currentSection;
        family = currentFamily;
    }
    return self;

}

@end