//
//  TSDataManagerDelegate.h
//  teleSUR
//
//  Created by Simkin on 24/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

@class TSDataManager;

@protocol TSDataManagerDelegate <NSObject>

- (void) TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests;

@end