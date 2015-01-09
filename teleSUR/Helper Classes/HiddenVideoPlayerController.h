//
//  HiddenVideoPlayerController.h
//  teleSUR
//
//  Created by Simkin on 24/07/14.
//  Copyright (c) 2014 Telesur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSClipPlayerViewController.h"

@interface HiddenVideoPlayerController : UIViewController

@property (nonatomic, assign) BOOL isAudioPlaying;
@property (nonatomic, weak) TSClipPlayerViewController *currentPlayer;

@end