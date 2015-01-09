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

-(void) presentarVideoEnVivo
{
    ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying = false;
    NSString *moviePath = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Configuración"] valueForKey:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Streaming URL Alta" : @"Streaming URL Media"];
    ;// Crear y configurar player
    NSLog(@"%@", moviePath);
    TSClipPlayerViewController *playerController = [[TSClipPlayerViewController alloc] init];
//    playerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [playerController.moviePlayer setContentURL:[NSURL URLWithString:moviePath]];

    // Reproducir video
    [playerController playEnViewController:[self getVideoHomeView]
                      finalizarConSelector:nil
                         registrandoAccion:NO];
    /********************************************* Google Analytics Comentado ***********************************************/
//    NSError *error;
/*
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"iPad" : @"iPhone/iPod Touch"
                                                          action:@"Señal en vivo iniciada"
                                                           label:moviePath
                                                           value:-1] build]];
*/
/*
    if (![[GANTracker sharedTracker] trackEvent:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"iPad" : @"iPhone/iPod Touch"
                                         action:@"Señal en vivo iniciada"
                                          label:
                                          value:-1
                                      withError:&error])
    {
        NSLog(@"Error");
    }
*/
}

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

    TSClipPlayerViewController *playerController = [[TSClipPlayerViewController alloc] initConProgramaURL:moviePath];
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


/*
 - (NSString *) platformType:(NSString *)platform
 {
 if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
 if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
 if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
 if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
 if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
 if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
 if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
 if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
 if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
 if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
 if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
 if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
 if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
 if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
 if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
 if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
 if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
 if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
 if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
 if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
 if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
 if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
 if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
 if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
 if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
 if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
 if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
 if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
 if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
 if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
 if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
 if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
 if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
 if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
 if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
 if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
 if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
 if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
 if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
 if ([platform isEqualToString:@"i386"])         return @"Simulator";
 if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
 return platform;
 }
 */

@end