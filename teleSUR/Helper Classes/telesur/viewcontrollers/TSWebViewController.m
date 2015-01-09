//
//  TSWebViewController.m
//  teleSUR
//
//  Created by Simkin on 04/12/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSWebViewController.h"

@implementation TSWebViewController

- (id) initWithURL:(NSURL *)URL {

    currentURL = URL;

    return self;

}

- (void)viewDidLoad {

    [super viewDidLoad];

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.frame = CGRectMake(0, 0, screenBound.size.width, screenBound.size.height);

    [self.view addSubview:webView];

    progressProxy = [[NJKWebViewProgress alloc] init];
    webView.delegate = progressProxy;
    progressProxy.webViewProxyDelegate = self;
    progressProxy.progressDelegate = self;

    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    [self loadCurrentURL];

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:progressView];

}

-(void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];

    [progressView removeFromSuperview];

}
















-(void)loadCurrentURL {

    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:currentURL];
    [webView loadRequest:req];

}


















#pragma mark - NJKWebViewProgressDelegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {

    [progressView setProgress:progress animated:YES];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];

}

















#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    if(navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted || (navigationType == UIWebViewNavigationTypeOther && [[request.URL absoluteString] rangeOfString:@"twitter"].length != 0)) {

        if(navigationType == UIWebViewNavigationTypeLinkClicked && [[request.URL absoluteString] rangeOfString:@"www.telesurtv.net"].length != 0) {
            return YES;
        }
        return NO;
    }
    return YES;
}

@end
