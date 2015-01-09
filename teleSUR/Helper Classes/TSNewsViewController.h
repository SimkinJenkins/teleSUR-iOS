//
//  TSNewsViewController.h
//  teleSUR
//
//  Created by Simkin on 21/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedItem.h"

@interface TSNewsViewController : UIViewController <UIWebViewDelegate> {

    @protected
        MWFeedItem *currentPost;
        CGFloat webViewYPos;
        NSString *parsedHTML;
}

- (void) initWithData:(MWFeedItem *) post;

@end