//
//  TSNewsViewController.h
//  teleSUR
//
//  Created by Simkin on 21/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedItem.h"
#import "TSBasicListViewController.h"

@interface TSNewsViewController : TSBasicListViewController <UIWebViewDelegate> {

    @protected
        MWFeedItem *currentPost;
        CGFloat webViewYPos;
        NSString *parsedHTML;
}

- (void) initWithData:(MWFeedItem *) post;

@end