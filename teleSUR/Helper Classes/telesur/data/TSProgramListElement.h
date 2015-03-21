//
//  TSProgramListElement.h
//  teleSUR
//
//  Created by Simkin on 19/03/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSProgramListElement : NSObject {

    NSDate *initialDate;
    NSDate *endDate;

    NSString *name;
    NSString *summary;

    NSString *scheduleString;

}

@property (nonatomic, copy) NSDate *initialDate;
@property (nonatomic, copy) NSDate *endDate;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *summary;

@property (nonatomic, copy) NSString *scheduleString;

@end
