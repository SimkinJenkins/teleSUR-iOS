//
//  TSClipPlayerViewController.h
//  teleSUR
//
//  Created by David Regla on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AlphaGradientView.h"

@interface TSClipPlayerViewController : MPMoviePlayerViewController {

    @protected
    
        NSDictionary *item;
        NSString *URL;
        SEL currentSelector;
        UIViewController *currentVC;
        CGRect currentFrame;

        UIButton *playButton;
        UIButton *pauseButton;
        UIButton *repeatButton;
        UIButton *minimizeButton;
        UIButton *shareButton;
        UIButton *statusButton;
        UIButton *appearControlsButton;

        UILabel *statusLabel;
        UILabel *durationLabel;

        UIView *statusBar;
        UIView *loadBar;
        UIView *backBar;

        AlphaGradientView* upGradient;
        AlphaGradientView* bottomGradient;

        UITextField *sectionTxf;

        UIActivityIndicatorView *spinner;

        NSTimer *playbackTimer;
        NSTimer *resumeTimer;

        NSString *currentSection;

        float statusBarWidth;

        int hideControlsCount;

        BOOL statusButtonBeenDragged;

        BOOL isLivestream;
}

@property (nonatomic, retain) UIView *controlsView;

- (id) initWithData:(NSDictionary *)itemData andSection:(NSString *)section;
- (id)initWithURL:(NSString *)initURL andTitle:(NSString *)title;

- (void) playAtViewController:(UIViewController *)viewController playbackFinish:(SEL)selector;
- (void) playAtView:(UIView *)view withFrame:(CGRect)frame withObserver:(UIViewController *)viewController playbackFinish:(SEL)selector;

- (void) addAppearControlButton:(BOOL)add;
- (void) setPlayerFrame:(CGRect)frame hideMinimizeButton:(BOOL)minimizeBtnHidden;
- (void) updateSpinnerView;
- (void) startTimer;
- (void) removeTimer;

@end
