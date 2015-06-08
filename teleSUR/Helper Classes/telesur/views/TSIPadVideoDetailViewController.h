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
#import "TSProgramListXMLParser.h"

@interface TSIPadVideoDetailViewController : TSIpadBasicDetailViewController <NSObject, EasyTableViewDelegate, UIGestureRecognizerDelegate, TSProgramListXMLParserDelegate> {

    @protected
        NSDictionary *currentItem;
        UIScrollView *wrapper;

        UILabel *currentDownloadLabel;
        UIButton *currentSender;

        long expectedDownloadLength;
        NSString *strFilePath;
        NSString *strFileName;
        NSFileHandle *file;

        BOOL configVideoNeeded;

        BOOL isDownloading;
        int lastDownloadPercent;
        NSString *fileSizeString;

        NSURLConnection *connection;
        UIImageView *thumb;

        CGRect playerFrame;

        UIPanGestureRecognizer *panRecognizer;
        CGPoint draggingPoint;

        NSInteger viewStatus;
        CGRect minimizeVideoFrame;
        CGRect maximizeFrame;

        UIView *customBackground;

        NSString *liveURL;
        NSString *liveURLTitle;

}

@property (nonatomic, assign) BOOL isLiveStream;

@property (nonatomic, strong) TSClipPlayerViewController *playerController;

@property (nonatomic, strong) MPMoviePlayerController *player;

- (id) initWithVideoData:(NSDictionary *)data inSection:(NSString *)section;
- (id) initWithURL:(NSString *)URL andTitle:(NSString *)title;

- (void) resumeVideoPlayer;

- (void) setData:(NSDictionary *)itemData;
- (void) setData:(NSDictionary *)itemData withSection:(NSString *)section;
- (void) setURL:(NSString *)URL andTitle:(NSString *)title;

- (void) removeCurrentPlayer;

@end