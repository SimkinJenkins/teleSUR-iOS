//
//  TSIPadVideoDetailViewController.h
//  teleSUR
//
//  Created by Simkin on 30/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSBasicListViewController.h"
#import "EasyTableView.h"
#import "TSClipPlayerViewController.h"

#import "TSIpadBasicDetailViewController.h"

@interface TSIPadVideoDetailViewController : TSIpadBasicDetailViewController <NSObject, EasyTableViewDelegate> {

    @protected
        NSDictionary *currentItem;
        UIScrollView *wrapper;

        UILabel *currentDownloadLabel;
        UIButton *currentSender;

        long expectedDownloadLength;
        NSString *strFilePath;
        NSString *strFileName;
        NSFileHandle *file;

        BOOL isDownloading;
        int lastDownloadPercent;
        NSString *fileSizeString;

        NSURLConnection *connection;
        UIImageView *thumb;

        CGRect playerFrame;

}

@property (nonatomic, strong) TSClipPlayerViewController *playerController;

@property (nonatomic, strong) MPMoviePlayerController *player;

- (id) initWithVideoData:(NSDictionary *)data inSection:(NSString *)section;

- (void) resumeVideoPlayer;

@end