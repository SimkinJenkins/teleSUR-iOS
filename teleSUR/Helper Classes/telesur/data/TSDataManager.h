//
//  TSDataManager.h
//  teleSUR
//
//  Created by Simkin on 24/10/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWFeedParser.h"
#import "TSDataManagerDelegate.h"
#import "TSDataRequest.h"

@interface TSDataManager : NSObject <MWFeedParserDelegate> {

    id <TSDataManagerDelegate> delegate;

    @protected

        NSMutableData *JSONData;
        NSMutableArray *parsedItems;
        MWFeedParser *feedParser;
        NSArray *queue;
        TSDataRequest *currentRequest;

        uint index;

        NSMutableArray *currentResults;

        BOOL isANotificationRequest;

}

@property (nonatomic) id <TSDataManagerDelegate> delegate;

- (void)loadNotificationRequests:(NSArray *)currentQueue delegateResponseTo:(id)dataDelegate;

- (void)loadRequests:(NSArray *)currentQueue delegateResponseTo:(id) dataDelegate;
- (void)loadRSSDataFor:(NSString *)section andSubsection:(NSString *)subsection delegateResponseTo:(id)dataDelegate;
- (void)loadAPIDataFor:(NSString *)section andSubsection:(NSString *)subsection withDataType:(NSString *)type inRange:(NSRange)range delegateResponseTo:(id)dataDelegate;

@end
