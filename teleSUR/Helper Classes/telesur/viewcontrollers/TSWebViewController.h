//
//  TSWebViewController.h
//  teleSUR
//
//  Created by Simkin on 04/12/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface TSWebViewController : UIViewController <UIWebViewDelegate, NJKWebViewProgressDelegate> {

    @protected
        UIWebView *webView;
        NJKWebViewProgressView *progressView;
        NJKWebViewProgress *progressProxy;
        NSURL *currentURL;

}

- (id) initWithURL:(NSURL *)URL;

@end
