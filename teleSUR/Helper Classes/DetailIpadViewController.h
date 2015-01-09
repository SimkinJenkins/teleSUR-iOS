//
//  DetailIpadViewController.h
//  teleSUR
//
//  Created by Simkin on 30/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainIpadViewController.h"
#import "TSClipPlayerViewController.h"
#import "UILabelMarginSet.h"

@interface DetailIpadViewController : UIViewController <ClipSelectionDelegate, UIGestureRecognizerDelegate> {
    
    @protected
    
        MPMoviePlaybackState lastPlaybackStatus;
        NSDictionary *currentClip;
        UITapGestureRecognizer *singleTapGestureRecogniser;
        BOOL streamViewHaveGesture;
        UIScrollView *wrapper;
        NSMutableData *dowloadedData;
        int aboutViewTag;
        BOOL isAudioPlaying;
        UILabelMarginSet *sectionLabel;
}

@property (nonatomic, strong)  TSClipPlayerViewController *playerController;

@property (nonatomic, strong) MPMoviePlayerController *player;

- (void)toogleLiveView;
- (void)showLiveView:(BOOL)hidden;
- (void)toogleAboutView;

@end