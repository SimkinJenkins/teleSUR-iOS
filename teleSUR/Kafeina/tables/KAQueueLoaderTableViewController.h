//
//  KAQueueLoaderTableViewController.h
//  La Jornada
//
//  Created by Simkin on 14/10/15.
//  Copyright © 2015 La Jornada. All rights reserved.
//

#import "KABasicTableViewController.h"

#import "KADataRequest.h"

@interface KAQueueLoaderTableViewController : KABasicTableViewController <NSURLSessionDataDelegate> {

    @protected
        NSArray *loadQueue;
        uint loadQueuePosition;
}

- (void) loadRequestsArray:(NSArray *)requests;
- (void) loadQueueDidLoad:(NSArray *)requests;

- (NSArray *) getLoadRequestResponseContent:(NSArray *)data;
- (KABasicCellData *) parseResposeContentElement:(NSDictionary *)data;
- (NSArray *) parseResponseContent:(NSArray *)data;
- (void) loadNextRequest;

@end