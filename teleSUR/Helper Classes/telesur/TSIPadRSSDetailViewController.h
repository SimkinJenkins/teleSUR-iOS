//
//  TSIPadRSSDetailViewController.h
//  teleSUR
//
//  Created by Simkin on 24/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBasicListViewController.h"
#import "MWFeedItem.h"
#import "EasyTableView.h"

#import "TSIpadBasicDetailViewController.h"

@interface TSIPadRSSDetailViewController : TSIpadBasicDetailViewController <UIWebViewDelegate> {

    @protected
        MWFeedItem *currentItem;
        CGFloat webViewYPos;
        NSString *parsedHTML;

}

- (id) initWithRSSData:(MWFeedItem *)data inSection:(NSString *)section andSubsection:(NSString *)subsection;

- (id) initWithSection:(NSString *)section andSubsection:(NSString *)subsection;

@end