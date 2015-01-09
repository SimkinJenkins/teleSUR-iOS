//
//  TSIpadBasicDetailViewController.h
//  teleSUR
//
//  Created by Simkin on 29/12/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSBasicListViewController.h"

#import "EasyTableView.h"

extern NSInteger const TS_DETAIL_ASYNC_IMAGE_TAG;

@interface TSIpadBasicDetailViewController : TSBasicListViewController <NSObject, EasyTableViewDelegate> {

    @protected
        EasyTableView *relatedRSSTableView;
        BOOL refreshButtonEnabled;

}

- (void) configLeftButton;
- (void) configRightButton;

- (void) elementsHidden:(BOOL)hidden;

- (void) shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url;

@end