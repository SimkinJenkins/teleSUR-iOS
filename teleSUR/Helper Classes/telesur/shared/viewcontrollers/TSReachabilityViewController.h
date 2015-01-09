//
//  TSReachabilityViewController.h
//  teleSUR
//
//  Created by Simkin on 07/01/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Reachability.h"

@interface TSReachabilityViewController : UIViewController {

    @protected
        Reachability *APIHostReachability;
        Reachability *TSHostReachability;
        Reachability *mediaHostReachability;
        Reachability *internetReachability;
        Reachability *WIFIReachability;

}

- (BOOL) isAPIHostAvailable;
- (BOOL) isMediaHostAvailable;

- (void) handleTSConnectionError;
- (void) sendTSConnectionErrorWithWiFiFailure:(BOOL)isWiFiError internetFailure:(BOOL)isInternetError serverFailure:(BOOL)isServerError;

@end
