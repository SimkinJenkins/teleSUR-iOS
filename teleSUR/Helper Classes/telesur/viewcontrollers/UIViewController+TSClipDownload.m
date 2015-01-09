//
//  UIViewController+TSClipDownload.m
//  teleSUR
//
//  Created by Simkin on 07/12/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "UIViewController+TSClipDownload.h"

@implementation UIViewController (TSClipDownload)
/*
- (void)downloadClip:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"descargarVideo", nil)]
                                                    message:[NSString stringWithFormat:NSLocalizedString(@"descargarVideoMessage", nil)]
                                                   delegate:self
                                          cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"descargarVideoCancelar", nil)]
                                          otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"descargarVideoContinuar", nil)], nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == 1) {

        [(UIButton *)[self.view viewWithTag:103] setEnabled:NO];
        [(UIButton *)[self.view viewWithTag:103] setAlpha:0.75];

        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[currentClip valueForKey:@"archivo_url"]]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0];

        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (theConnection)
        {
            dowloadedData = [NSMutableData data];
        }
        else
        {
            // Error
        }
    }
}
*/
@end
