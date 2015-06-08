//
//  TSClipPlayerViewController.m
//  teleSUR
//
//  Created by David Regla on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TSClipPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSDictionary_Datos.m"
#import "SlideNavigationController.h"
#import "AlphaGradientView.h"
#import "CircularGradientView.h"

float const GRADIENT_HEIGHT = 40;
int const HIDE_CONTROLS_TIME = 5;

@implementation TSClipPlayerViewController

@synthesize controlsView;

- (id)initWithData:(NSDictionary *)itemData andSection:(NSString *)section {

    currentSection = section;

    URL = [[itemData valueForKey:@"metodo_preferido"] isEqualToString:@"streaming"]
                        ? [[itemData valueForKey:@"streaming"] valueForKey:@"apple_hls_url"]
                        : [itemData valueForKey:@"archivo_url"];
    NSString *subtitledVideoURL = [itemData valueForKey:@"archivo_subtitulado_url"];

    URL = subtitledVideoURL != (NSString *)[NSNull null] && ![subtitledVideoURL isEqualToString:@""] ? subtitledVideoURL : URL;
    NSLog(@"%@ - %@", subtitledVideoURL, URL);

    self = [super initWithContentURL:[NSURL URLWithString:URL]];
    [self.moviePlayer setShouldAutoplay:YES];

    return self;

}

- (id)initWithURL:(NSString *)initURL andTitle:(NSString *)title {

    URL = initURL;
    currentSection = title;
    isLivestream = YES;

    self = [super init];

    self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;

    [self.moviePlayer setContentURL:[NSURL URLWithString:URL]];
    [self.moviePlayer setShouldAutoplay:YES];

    return self;

}



















- (void)viewDidLoad {

    [self.view setBackgroundColor: [UIColor blackColor]];

    self.moviePlayer.controlStyle = MPMovieControlStyleNone;

    statusBarWidth = 215;

    [self constructCustomPlayerControls];

}

- (void) viewDidDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:currentVC name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];

}



















- (void)setPlayerFrame:(CGRect)frame hideMinimizeButton:(BOOL)minimizeBtnHidden {

    self.view.frame = frame;
    currentFrame = frame;
    self.view.frame = frame;
    showControlsButton.frame = controlsView.frame = CGRectMake(0, 0, currentFrame.size.width, currentFrame.size.height);

    NSLog(@"setPlayerFrame : %@", NSStringFromCGRect(currentFrame));

    statusBarWidth = currentFrame.size.width - 105;

    upGradient.frame = CGRectMake(0, 0, currentFrame.size.width, GRADIENT_HEIGHT);
    bottomGradient.frame = CGRectMake(0, currentFrame.size.height - GRADIENT_HEIGHT, currentFrame.size.width, GRADIENT_HEIGHT);
    shareButton.frame = CGRectMake(currentFrame.size.width - 68, -17, shareButton.frame.size.width, shareButton.frame.size.height);

    sectionTxf.frame = CGRectMake(55 + ((statusBarWidth - sectionTxf.frame.size.width) * 0.5), 5, sectionTxf.frame.size.width, sectionTxf.frame.size.height);

    durationLabel.frame = CGRectMake(currentFrame.size.width - 38, currentFrame.size.height - 24, durationLabel.frame.size.width, durationLabel.frame.size.height);
    statusLabel.frame = CGRectMake(10, durationLabel.frame.origin.y, statusLabel.frame.size.width, statusLabel.frame.size.height);

    [self updatePlaybackProgressFromTimer:nil];

    playButton.frame = CGRectMake((currentFrame.size.width - playButton.frame.size.width) * 0.5, (currentFrame.size.height - playButton.frame.size.height) * 0.5, playButton.frame.size.width, playButton.frame.size.height);
    pauseButton.frame = playButton.frame;
    repeatButton.frame = playButton.frame;

    minimizeButton.hidden = minimizeBtnHidden;

    [self updateSpinnerView];
}

- (void) updateSpinnerView {

    spinner.frame = CGRectMake((self.view.frame.size.width - spinner.frame.size.width) * 0.5, (self.view.frame.size.height - spinner.frame.size.height) * 0.5, spinner.frame.size.width, spinner.frame.size.height);

}

- (void) playAtViewController:(UIViewController *)viewController playbackFinish:(SEL)selector {

    [viewController presentMoviePlayerViewControllerAnimated:self];
    [self.moviePlayer play];

    if (selector != nil) {

        currentVC = viewController;
        currentSelector = selector;

        [[NSNotificationCenter defaultCenter] 
         addObserver:self
         selector:@selector(innerEndPlayer)
         name:MPMoviePlayerPlaybackDidFinishNotification
         object:self.moviePlayer];
    }

    [controlsView removeFromSuperview];

    [self updateSpinnerView];
}

- (void)playAtView:(UIView *)view withFrame:(CGRect)frame withObserver:(UIViewController *)viewController playbackFinish:(SEL)selector {

    [self setPlayerFrame:frame hideMinimizeButton:NO];

    self.view.backgroundColor = [UIColor grayColor];

    [view addSubview:self.view];
    [self.moviePlayer play];

    if (selector != nil) {

        currentVC = viewController;
        currentSelector = selector;

        [[NSNotificationCenter defaultCenter]
         addObserver:viewController
         selector:selector
         name:MPMoviePlayerPlaybackDidFinishNotification
         object:self.moviePlayer];

    }

    if ( frame.size.width < 10 ) {
        [controlsView removeFromSuperview];
        [spinner removeFromSuperview];
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(durationAvailable:) name:MPMovieDurationAvailableNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStart:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
}

- (void) addAppearControlButton:(BOOL)add {
    
    if ( add ) {
        if ( controlsView.alpha != 1.0 ) {
            [self.view addSubview:showControlsButton];
        }
    } else {
        [showControlsButton removeFromSuperview];
    }
    
}

- (void) removeTimer {

    if ( playbackTimer ) {
        [playbackTimer invalidate];
        playbackTimer = nil;
    }

}











- (void)loadStateDidChange:(NSNotification *)notification {

//    NSLog(@"loadStateDidChange : %u ", self.moviePlayer.loadState );

    if( self.moviePlayer.loadState == MPMovieLoadStateStalled ) {
        [spinner startAnimating];
        [self.view addSubview:spinner];
        statusButton.hidden = YES;
        statusBar.hidden = YES;
        loadBar.hidden = YES;
    }

}

- (void)playbackStart:(NSNotification *)notification {

//    NSLog(@"playbackStart : %d , %d, %d, %d ", self.moviePlayer.playbackState, MPMoviePlaybackStatePlaying, MPMoviePlaybackStatePaused, MPMoviePlaybackStateStopped );

    if ( self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying ) {

        [playButton removeFromSuperview];
        [controlsView addSubview:pauseButton];

        [spinner stopAnimating];
        [spinner removeFromSuperview];

        if ( controlsView.alpha == 1.0 ) {
            [self startTimer];
        }

    } else if ( self.moviePlayer.playbackState == MPMoviePlaybackStatePaused ) {

        if ( !statusButtonBeenDragged ) {

            [pauseButton removeFromSuperview];
            [controlsView addSubview:playButton];
            [self removeTimer];

        }

    } else if ( self.moviePlayer.playbackState == MPMoviePlaybackStateStopped ) {

        [self onPlaybackStopped];
    }

}

- (void) onPlaybackStopped {

    if ( showControlsButton.superview ) {
        [self appearButtonTouched:nil];
    }
    
    [self removeTimer];

}

- (void) updatePlaybackProgressFromTimer:(NSTimer *)timer {

    if (([UIApplication sharedApplication].applicationState == UIApplicationStateActive) && (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)) {

        NSLog(@"updatePlaybackProgressFromTimer : %f : %f : %f", self.moviePlayer.playableDuration, self.moviePlayer.currentPlaybackTime, self.moviePlayer.duration);

        hideControlsCount++;

        if ( hideControlsCount == HIDE_CONTROLS_TIME ) {

            [self hideControls];

        }
    }

    [self updatePlaybackBars];

}

- (void) updatePlaybackBars {

    if ( !isLivestream ) {
        [ self updatePlaybackBarsWithCurrentTime:isnan(self.moviePlayer.currentPlaybackTime) ? 0.0f : self.moviePlayer.currentPlaybackTime ];
    }

}

- (void) updatePlaybackBarsWithCurrentTime:(float)currentTime {

    float progress = isnan(self.moviePlayer.currentPlaybackTime) ? 0.0f : currentTime / self.moviePlayer.duration;
    float loadprogress = isnan(self.moviePlayer.currentPlaybackTime) ? 0.0f : self.moviePlayer.playableDuration / self.moviePlayer.duration;
    statusLabel.text = [self getMMSSStringFrom:currentTime];
    statusBar.frame = CGRectMake(50, currentFrame.size.height - 21, statusBarWidth * progress, 10);
    loadBar.frame = CGRectMake(statusBar.frame.origin.x + statusBar.frame.size.width, statusBar.frame.origin.y, statusBarWidth * (MAX(0.01, loadprogress - progress)), 10);
    backBar.frame = CGRectMake(loadBar.frame.origin.x + loadBar.frame.size.width, statusBar.frame.origin.y, statusBarWidth - (statusBar.frame.size.width + loadBar.frame.size.width), 10);

    if ( !statusButtonBeenDragged ) {
        statusButton.center = CGPointMake(statusBar.frame.origin.x + statusBar.frame.size.width, statusBar.frame.origin.y + 5);
    }

}

- (void) hideControls {

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        controlsView.alpha = 0.0;

    } completion:^(BOOL finished) {

        [self removeTimer];

        [self addAppearControlButton:YES];

    }];

}

- (void) startTimer {

    hideControlsCount = 0;
    [self updatePlaybackProgressFromTimer:nil];
    if ( !playbackTimer ) {
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
    }

}

- (void)durationAvailable:(NSNotification *)notification {

    durationLabel.text = [self getMMSSStringFrom:self.moviePlayer.duration];
    statusButton.hidden = NO;
    statusBar.hidden = NO;
    loadBar.hidden = NO;
    [self updatePlaybackBars];

}

- (void)playbackDidFinish:(NSNotification *)notification {

    NSError *error = [[notification userInfo] objectForKey:@"error"];
    if (error) {
        NSLog(@"Did finish with error: %@", error);
    }

    [controlsView addSubview:repeatButton];
    [playButton removeFromSuperview];
    [pauseButton removeFromSuperview];

    [self onPlaybackStopped];

}

- (NSString *) getMMSSStringFrom:(NSTimeInterval)time {

    int minutes = floor(time / 60);
    int seconds = round(time - minutes * 60);
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];

}












- (void)minimizeButtonTouched:(UIButton *)sender {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"minimizeButtonTouched" object:nil];

}

- (void)shareButtonTouched:(UIButton *)sender {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"sharedButtonTouched" object:nil];

}

- (void)playButtonTouched:(UIButton *)sender {

    [playButton removeFromSuperview];
    [self.moviePlayer play];

}

- (void)pauseButtonTouched:(UIButton *)sender {

    [pauseButton removeFromSuperview];
    [self.moviePlayer pause];

}

- (void)repeatButtonTouched:(UIButton *)sender {

    [repeatButton removeFromSuperview];
    [self.moviePlayer play];

}

- (void)appearButtonTouched:(UIButton *)sender {

    if ( controlsView.alpha == 1.0 ) {
        hideControlsCount = 0;
        return;
    }

    [self addAppearControlButton:NO];

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        controlsView.alpha = 1.0;
        [self startTimer];

    } completion:^(BOOL finished) {

        
    }];



}











- (void)constructCustomPlayerControls {

    controlsView = [[UIView alloc] initWithFrame:self.moviePlayer.view.frame];
    showControlsButton = [[UIButton alloc] initWithFrame:self.moviePlayer.view.frame];
    showControlsButton.backgroundColor = [UIColor clearColor];
//    showControlsButton.alpha = 0.5;
    [showControlsButton addTarget:self.parentViewController.navigationController action:@selector(appearButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

    UIImage *minimizeImage = [UIImage imageNamed:@"player-minimize.png"];
    UIImage *minimizeHighlightedImage = [UIImage imageNamed:@"player-minimize-highlighted.png"];
    UIImage *statusBulletImage = [UIImage imageNamed:@"player-playback-status.png"];
    UIImage *playImage = [UIImage imageNamed:@"player-play.png"];
    UIImage *playHighlightedImage = [UIImage imageNamed:@"player-play-highlighted.png"];
    UIImage *pauseImage = [UIImage imageNamed:@"player-pause.png"];
    UIImage *pauseHighlightedImage = [UIImage imageNamed:@"player-pause-highlighted.png"];
    UIImage *shareImage = [UIImage imageNamed:@"player-share.png"];
    UIImage *shareHighlightedImage = [UIImage imageNamed:@"player-share-highlighted.png"];
    UIImage *repeatImage = [UIImage imageNamed:@"player-repeat.png"];
    UIImage *repeatHighlightedImage = [UIImage imageNamed:@"player-repeat-highlighted.png"];

    float shadowWidth = 3.0f;
    float fontSize = 11.0f;

    upGradient = [[AlphaGradientView alloc] initWithFrame:
                                   CGRectMake(0, 0, self.view.frame.size.width, GRADIENT_HEIGHT)];
    upGradient.direction = GRADIENT_UP;
    upGradient.color = [UIColor blackColor];
    [controlsView addSubview:upGradient];

    bottomGradient = [[AlphaGradientView alloc] initWithFrame:
                                     CGRectMake(0, 185, self.view.frame.size.width, GRADIENT_HEIGHT)];
    bottomGradient.direction = GRADIENT_DOWN;
    bottomGradient.color = [UIColor blackColor];
    [controlsView addSubview:bottomGradient];

    minimizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    minimizeButton.frame = CGRectMake(-7, -17, minimizeImage.size.width, minimizeImage.size.height);
    minimizeButton.alpha = 0.6;
    [minimizeButton setImage:minimizeImage forState:UIControlStateNormal];
    [minimizeButton setImage:minimizeHighlightedImage forState:UIControlStateHighlighted];

    [minimizeButton addTarget:self.parentViewController.navigationController action:@selector(minimizeButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

    minimizeButton.imageView.layer.cornerRadius = shadowWidth;
    minimizeButton.layer.shadowRadius = shadowWidth;
    minimizeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    minimizeButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    minimizeButton.layer.shadowOpacity = 1.0f;
    minimizeButton.layer.masksToBounds = NO;

    playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(135, 85, playImage.size.width, playImage.size.height);
    playButton.alpha = 0.6;
    [playButton setImage:playImage forState:UIControlStateNormal];
    [playButton setImage:playHighlightedImage forState:UIControlStateHighlighted];

    [playButton addTarget:self.parentViewController.navigationController action:@selector(playButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

    playButton.imageView.layer.cornerRadius = shadowWidth;
    playButton.layer.shadowRadius = shadowWidth;
    playButton.layer.shadowColor = [UIColor blackColor].CGColor;
    playButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    playButton.layer.shadowOpacity = 2.0f;
    playButton.layer.masksToBounds = NO;

    pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseButton.frame = CGRectMake(135, 85, pauseImage.size.width, pauseImage.size.height);
    pauseButton.alpha = 0.6;
    [pauseButton setImage:pauseImage forState:UIControlStateNormal];
    [pauseButton setImage:pauseHighlightedImage forState:UIControlStateHighlighted];

    [pauseButton addTarget:self.parentViewController.navigationController action:@selector(pauseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

    pauseButton.imageView.layer.cornerRadius = shadowWidth;
    pauseButton.layer.shadowRadius = shadowWidth;
    pauseButton.layer.shadowColor = [UIColor blackColor].CGColor;
    pauseButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    pauseButton.layer.shadowOpacity = 2.0f;
    pauseButton.layer.masksToBounds = NO;

    repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    repeatButton.frame = CGRectMake(135, 85, repeatImage.size.width, repeatImage.size.height);
    repeatButton.alpha = 0.6;
    [repeatButton setImage:repeatImage forState:UIControlStateNormal];
    [repeatButton setImage:repeatHighlightedImage forState:UIControlStateHighlighted];

    [repeatButton addTarget:self.parentViewController.navigationController action:@selector(repeatButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

    repeatButton.imageView.layer.cornerRadius = shadowWidth;
    repeatButton.layer.shadowRadius = shadowWidth;
    repeatButton.layer.shadowColor = [UIColor blackColor].CGColor;
    repeatButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    repeatButton.layer.shadowOpacity = 2.0f;
    repeatButton.layer.masksToBounds = NO;

    shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(205, -19, shareImage.size.width, shareImage.size.height);
    shareButton.alpha = 0.6;
    [shareButton setImage:shareImage forState:UIControlStateNormal];
    [shareButton setImage:shareHighlightedImage forState:UIControlStateHighlighted];

    [shareButton addTarget:self.parentViewController.navigationController action:@selector(shareButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

    shareButton.imageView.layer.cornerRadius = shadowWidth;
    shareButton.layer.shadowRadius = shadowWidth;
    shareButton.layer.shadowColor = [UIColor blackColor].CGColor;
    shareButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    shareButton.layer.shadowOpacity = 2.0f;
    shareButton.layer.masksToBounds = NO;

    statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    statusButton.frame = CGRectMake(35, 193, statusBulletImage.size.width, statusBulletImage.size.height);
    [statusButton setImage:statusBulletImage forState:UIControlStateNormal];
    statusButton.hidden = YES;

    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc]
                                        initWithTarget:self
                                        action:@selector(statusButtonDragged:)];

    [statusButton addGestureRecognizer:gesture];

    [controlsView addSubview:minimizeButton];
    [controlsView addSubview:shareButton];

    statusLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(10, 200, 40.0, 15.0)];

    [statusLabel setFont:[UIFont fontWithName:statusLabel.font.familyName size:fontSize]];

    statusLabel.text = @"00:00";
    statusLabel.textColor = [UIColor whiteColor];
    [controlsView addSubview:statusLabel];

    durationLabel = [[UILabel alloc] initWithFrame:
                                    CGRectMake(280, 200, 40.0, 15.0)];

    [durationLabel setFont:[UIFont fontWithName:durationLabel.font.familyName size:fontSize]];

    durationLabel.text = @"00:00";
    durationLabel.textColor = [UIColor whiteColor];
    [controlsView addSubview:durationLabel];

    sectionTxf = [[UITextField alloc] initWithFrame:
                                            CGRectMake(50, 0, 230.0, 30)];

    UIImage *logoImage = [UIImage imageNamed:@"player-logo.png"];
    UIImageView *leftImage = [[UIImageView alloc] initWithImage:logoImage];
    leftImage.frame = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
    [sectionTxf setLeftViewMode:UITextFieldViewModeAlways];
    sectionTxf.leftView = leftImage;

    [sectionTxf setFont:[UIFont fontWithName:sectionTxf.font.familyName size:14.0]];
    sectionTxf.textAlignment = NSTextAlignmentCenter;
    sectionTxf.text = currentSection;
    sectionTxf.textColor = [UIColor whiteColor];

    [sectionTxf sizeToFit];

    sectionTxf.frame = CGRectMake(55 + ((statusBarWidth - sectionTxf.frame.size.width) * 0.5), 8, sectionTxf.frame.size.width, logoImage.size.height);
    [controlsView addSubview:sectionTxf];

    statusBar = [[UIView alloc] initWithFrame:CGRectMake(50, 203, 1, 10)];
    statusBar.backgroundColor = [UIColor redColor];
    statusBar.alpha = 0.8f;
    statusBar.hidden = YES;

    loadBar = [[UIView alloc] initWithFrame:CGRectMake(51, 203, 1, 10)];
    loadBar.backgroundColor = [UIColor grayColor];
    loadBar.alpha = 0.8f;
    loadBar.hidden = YES;

    backBar = [[UIView alloc] initWithFrame:CGRectMake(52, 203, statusBarWidth - 2, 10)];
    backBar.backgroundColor = [UIColor blackColor];
    backBar.alpha = 0.8f;

    [controlsView addSubview:statusBar];
    [controlsView addSubview:loadBar];
    [controlsView addSubview:backBar];

    [controlsView addSubview:statusButton];

    [self.view addSubview:controlsView];

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setTintColor:[UIColor redColor]];
    spinner.frame = CGRectMake(145, 92, spinner.frame.size.width, spinner.frame.size.height);
    [spinner startAnimating];

    [self.view addSubview:spinner];

}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)statusButtonDragged:(UIPanGestureRecognizer *)gesture {

    CGPoint translation = [gesture translationInView:statusButton];

    if (gesture.state == UIGestureRecognizerStateBegan) {

        [self.moviePlayer pause];
        statusButtonBeenDragged = YES;

        [playButton removeFromSuperview];
        [pauseButton removeFromSuperview];
        [repeatButton removeFromSuperview];

        [self removeTimer];
        [self removeResumeTimer];

    } else if (gesture.state == UIGestureRecognizerStateChanged) {

        if ( statusButton.center.x >= statusBar.frame.origin.x && statusButton.center.x <= statusBar.frame.origin.x + statusBarWidth ) {

            statusButton.center = CGPointMake(MIN(MAX(statusButton.center.x + translation.x, statusBar.frame.origin.x), statusBar.frame.origin.x + statusBarWidth), statusButton.center.y);
            [gesture setTranslation:CGPointZero inView:statusButton];

            float progress = (statusButton.center.x - statusBar.frame.origin.x) / statusBarWidth;
            float currentTime = self.moviePlayer.duration * progress;
            self.moviePlayer.currentPlaybackTime = currentTime;

            [self updatePlaybackBarsWithCurrentTime:currentTime];

        }

    } else if (gesture.state == UIGestureRecognizerStateEnded) {

        statusButtonBeenDragged = NO;

        [spinner startAnimating];
        [self.view addSubview:spinner];

        [self updateSpinnerView];

        [self removeResumeTimer];
        resumeTimer = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(resumeMovie) userInfo:nil repeats:NO];

    }
}

- (void) removeResumeTimer {

    if ( resumeTimer ) {
        [resumeTimer invalidate];
        resumeTimer = nil;
    }

}

- (void) resumeMovie {

    [self.moviePlayer play];

}

- (void)innerEndPlayer {
    
    IMP imp = [currentVC methodForSelector:currentSelector];
    void (*func)(id, SEL) = (void *)imp;
    func(currentVC, currentSelector);
    
}

@end