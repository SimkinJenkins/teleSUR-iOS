//
//  UIViewController_Configuracion.m
//  teleSUR
//
//  Created by Hector Zarate on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIViewController_Configuracion.h"
#import <UIKit/UIkit.h>
#import "TSClipPlayerViewController.h"
#import "UIDropDownMenu.h"
#import "TSClipListadoHomeMenuTableVC.h"
#import "HiddenVideoPlayerController.h"

//#import "GAI.h"
//#import "GAIDictionaryBuilder.h"

#define kLOADING_TRANSPARENCIA 0.70

@implementation UIViewController (UIViewController_Configuracion)

- (TSClipListadoHomeMenuTableVC *) getVideoHomeView {
    NSArray *views = [[SlideNavigationController sharedInstance] viewControllers];
    for(uint i = 0; i < [views count]; i++) {
        if([[views objectAtIndex:i] isKindOfClass:[TSClipListadoHomeMenuTableVC class]]) {
            return [views objectAtIndex:i];
        }
    }
    return nil;
}

- (void) launchLiveAudio {

    NSString *moviePath = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Configuración"] valueForKey:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Streaming URL Alta" : @"Streaming URL Media"];

    TSClipPlayerViewController *playerController = [[TSClipPlayerViewController alloc] initWithURL:moviePath andTitle:@""];
    [playerController playAtView:self.view withFrame:CGRectMake(0, 0, 1, 1) withObserver:self playbackFinish:nil];

    ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying = YES;
    ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).currentPlayer = playerController;

}

- (void) stopLiveAudio {
    if(((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying) {
        ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying = NO;
        [((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).currentPlayer.moviePlayer stop];
        [((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).currentPlayer.view removeFromSuperview];
        ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).currentPlayer = nil;
    }
}

- (void)playerFinalizado:(NSNotification *)notification
{
    NSLog(@"playerFinalizado");
}

-(void)videoStateChange:(NSNotification *)notification
{
    NSLog(@"%@", notification);
}

-(void)playMediaFinished:(NSNotification*)theNotification
{
    MPMoviePlayerController *moviePlayer=[theNotification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:moviePlayer];
}

-(CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode  {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSDictionary * attributes = @{NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName:paragraphStyle
                                  };
    CGRect textRect = [text boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    return textRect.size;
}

@end