//
//  KAQueueLoaderTableViewController.m
//  La Jornada
//
//  Created by Simkin on 14/10/15.
//  Copyright © 2015 La Jornada. All rights reserved.
//

#import "KAQueueLoaderTableViewController.h"

@implementation KAQueueLoaderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) loadRequestsArray:(NSArray *)requests {
    [self resetLoadQueue];
    loadQueue = requests;
    [self loadNextRequest];
}

- (void) loadNextRequest {
    
    if ( loadQueuePosition < [loadQueue count] ) {
        KADataRequest *request = [loadQueue objectAtIndex:loadQueuePosition];
        if ( request.json ) {
            [self loadCurrentJsonRequest:request];
        } else {
            [self loadCurrentRequest:request];
        }
    } else {
        [self loadQueueDidLoad:[NSArray arrayWithArray:loadQueue]];
        [self resetLoadQueue];
    }
    
}

- (void) resetLoadQueue {
    loadQueue = nil;
    loadQueuePosition = 0;
}

- (void) loadCurrentRequest:(KADataRequest *)request {
    NSLog(@"%@", request.URL);
    [[[NSURLSession sharedSession] dataTaskWithURL:request.URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ( error ) {
            request.error = error;
        } else {
            request.responseRaw = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            request.responseParsed = [self parseResponseContent:[self getLoadRequestResponseContent:request.responseRaw]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            loadQueuePosition++;
            [self loadNextRequest];
        });
    }] resume];
}

- (void)loadCurrentJsonRequest:(KADataRequest *)request {
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURL *url = [NSURL URLWithString:request.URLString];
    NSMutableURLRequest *URLrequest = [NSMutableURLRequest requestWithURL:url];
    URLrequest.HTTPBody = [request.json dataUsingEncoding:NSUTF8StringEncoding];
    [URLrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    URLrequest.HTTPMethod = request.requestHTTPMethod;
    NSLog(@"URL a requestedURL: %@", request.URLString);
    [[defaultSession dataTaskWithRequest:URLrequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld - %@", (long)[httpResponse statusCode], [json objectForKey:@"traceback"]);
        NSLog(@"%@", error);
        if ( (!( [httpResponse statusCode] == 401 || [httpResponse statusCode] == 501) && json )) {
            request.responseRaw = (NSArray *)json;
        }
        if ( [httpResponse statusCode] != 200 && [httpResponse statusCode] != 201 ) {
            
        }
        request.error  = error;
        dispatch_async(dispatch_get_main_queue(), ^{
            loadQueuePosition++;
            [self loadNextRequest];
        });
    }] resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

- (NSArray *) getLoadRequestResponseContent:(NSArray *)data {
    return [[data objectAtIndex:0] objectForKey:@"content"];
}

- (NSArray *) parseResponseContent:(NSArray *)data {
    NSMutableArray *parsedData = [NSMutableArray array];
    for (uint i = 0; i < [data count]; i++) {
        [parsedData addObject:[self parseResposeContentElement:[data objectAtIndex:i]]];
    }
    return [NSArray arrayWithArray:parsedData];
}

- (KABasicCellData *) parseResposeContentElement:(NSDictionary *)data {
    return [[KABasicCellData alloc] initWithDictionary:data];
}

- (void) loadQueueDidLoad:(NSArray *)requests {
    for ( uint i = 0; i < [requests count]; i++) {
        KADataRequest *reqData = [requests objectAtIndex:i];
        if (!tableItems) {
            tableItems = [NSMutableArray arrayWithArray:reqData.responseParsed];
        } else {
            [tableItems addObjectsFromArray:reqData.responseParsed];
        }
    }
    [self.tableView reloadData];
}

@end
