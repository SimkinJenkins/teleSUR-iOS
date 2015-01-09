//
//  TSReachabilityViewController.m
//  teleSUR
//
//  Created by Simkin on 07/01/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import "TSReachabilityViewController.h"
#import "Reachability.h"

#import "UIViewController+TSLoader.h"

@implementation TSReachabilityViewController

- (void)viewDidLoad {

    [self startReachabilityConnections];

}

- (void) startReachabilityConnections {
    APIHostReachability = [Reachability reachabilityWithHostName:@"multimedia.tlsur.net"];
    TSHostReachability = [Reachability reachabilityWithHostName:@"www.telesurtv.net"];
    mediaHostReachability = [Reachability reachabilityWithHostName:@"media-telesur.openmultimedia.biz"];
    internetReachability = [Reachability reachabilityForInternetConnection];
    WIFIReachability = [Reachability reachabilityForLocalWiFi];
}

- (BOOL) isAPIHostAvailable {

    if ( APIHostReachability.currentReachabilityStatus == NotReachable || TSHostReachability.currentReachabilityStatus == NotReachable ) {

        [self sendTSConnectionErrorWithWiFiFailure:WIFIReachability.currentReachabilityStatus == NotReachable
                                   internetFailure:internetReachability.currentReachabilityStatus == NotReachable
                                     serverFailure:YES];

        return NO;

    }

    return YES;

}

- (BOOL) isMediaHostAvailable {

    if ( mediaHostReachability.currentReachabilityStatus == NotReachable ) {
        [self sendTSConnectionErrorWithWiFiFailure:WIFIReachability.currentReachabilityStatus == NotReachable
                                   internetFailure:internetReachability.currentReachabilityStatus == NotReachable
                                     serverFailure:YES];
        
        return NO;
        
    }
    
    return YES;

}

- (void) sendTSConnectionErrorWithWiFiFailure:(BOOL)isWiFiError internetFailure:(BOOL)isInternetError serverFailure:(BOOL)isServerError {

    NSString *alertTitle = @"";
    NSString *alertMessage = @"";

    if ( isInternetError ) {
        
        if ( isWiFiError ) {

            alertTitle = [NSString stringWithFormat:NSLocalizedString(@"WIFIConnectionErrorTitle", nil)];
            alertMessage = [NSString stringWithFormat:NSLocalizedString(@"WIFIConnectionErrorMessage", nil)];
            
        } else {
            
            alertTitle = [NSString stringWithFormat:NSLocalizedString(@"internetConnectionErrorTitle", nil)];
            alertMessage = [NSString stringWithFormat:NSLocalizedString(@"internetConnectionErrorMessage", nil)];
            
        }
        
    } else {

        alertTitle = [NSString stringWithFormat:NSLocalizedString(@"APIHostConnectionErrorTitle", nil)];
        alertMessage = [NSString stringWithFormat:NSLocalizedString(@"APIHostConnectionErrorMessage", nil)];
        
    }


    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"acceptText", nil)]
                                          otherButtonTitles: nil];
    
    [alert show];

    [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(handleTSConnectionError) userInfo:nil repeats:NO];

    [self startReachabilityConnections];

}

- (void) handleTSConnectionError {

    [self hideLoaderWithAnimation:YES];

}

@end
