//
//  TSClipDetallesViewController.h
//  teleSUR
//
//  Created by David Regla on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSClipListadoTableViewController.h"
#import "TSClipPlayerViewController.h"
#import "TSProgramListElement.h"
#import "TSProgramListXMLParser.h"

extern CGFloat const RIGHT_BOTTOM_MINIMIZED_VIEW_MARGIN;
extern NSInteger const MENU_FAST_VELOCITY_FOR_SWIPE_FOLLOW_DIRECTION;

extern NSInteger const TS_VIEW_STATUS_DEFAULT;
extern NSInteger const TS_VIEW_STATUS_MAXIMIZED;
extern NSInteger const TS_VIEW_STATUS_MINIMIZED;
extern NSInteger const TS_VIEW_STATUS_ON_TRANSITION;

@interface TSClipDetallesViewController : TSClipListadoTableViewController <UIGestureRecognizerDelegate, TSProgramListXMLParserDelegate> {

    @protected

    NSDictionary *currentItem;

    UILabel *currentDownloadLabel;
    UIButton *currentSender;

    BOOL isDownloading;

    long expectedDownloadLength;
    NSString *strFilePath;
    NSString *strFileName;
    NSFileHandle *file;

    int lastDownloadPercent;
    NSString *fileSizeString;

    NSURLConnection *connection;

    UIImageView *thumb;

    TSClipPlayerViewController *playerController;

    UIPanGestureRecognizer *panRecognizer;
    CGPoint draggingPoint;

    NSInteger viewStatus;

    NSString *liveURL;
    NSString *liveURLTitle;
    BOOL isLiveStream;

    UIView *backgroundView;
    UIView *contentView;

}

- (id) initWithData:(NSDictionary *)itemData andSection:(NSString *)section;
- (id) initWithURL:(NSString *)URL andTitle:(NSString *)title;

- (void) setData:(NSDictionary *)itemData andSection:(NSString *)section;
- (void) setURL:(NSString *)URL andTitle:(NSString *)title;

@end