//
//  DetailIpadViewController.m
//  teleSUR
//
//  Created by Simkin on 30/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "DetailIpadViewController.h"
#import "UILabelMarginSet.h"
#import "NSDictionary_Datos.h"
#import "TSClipPlayerViewController.h"
#import "NavigationBarsManager.h"
#import "NSString+HTML.h"
#import "AsynchronousImageView.h"

NSInteger const TS_ABOUT_VIEW_TAG = 400;
NSInteger const TS_ABOUT_EN_VIEW_TAG = 401;

NSInteger const TS_DETAIL_VIEW_TAG = 150;
NSInteger const TS_STREAM_VIEW_TAG = 300;
NSInteger const TS_VIDEO_STREAM_BUTTON_TAG = 301;
NSInteger const TS_AUDIO_STREAM_BUTTON_TAG = 302;

NSInteger const TS_DETAIL_ASYNC_IMAGE_TAG = 106;

@implementation DetailIpadViewController

@synthesize playerController, player;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    isAudioPlaying = NO;

    [self.view viewWithTag:TS_DETAIL_VIEW_TAG].hidden = YES;
    [self.view viewWithTag:TS_ABOUT_VIEW_TAG].hidden = YES;
    [self.view viewWithTag:TS_ABOUT_EN_VIEW_TAG].hidden = YES;
    [self.view viewWithTag:TS_STREAM_VIEW_TAG].hidden = YES;

    NSLog(@"%@", [NSString stringWithFormat:NSLocalizedString(@"aboutViewTag", nil)]);
    aboutViewTag = [[NSString stringWithFormat:NSLocalizedString(@"aboutViewTag", nil)] intValue];

    wrapper = [[UIScrollView  alloc] initWithFrame:CGRectMake(12, 445, 660, 192)];
    wrapper.autoresizesSubviews = NO;
    [wrapper addSubview:[self.view viewWithTag:TS_DETAIL_VIEW_TAG]];
    [self.view addSubview:wrapper];

    UIButton *descargarButton = (UIButton *)[self.view viewWithTag:103];
    UIButton *shareButton = (UIButton *)[self.view viewWithTag:105];

    [descargarButton addTarget:self action:@selector(downloadClip:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton addTarget:self action:@selector(shareClip:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *videoLiveButton = (UIButton *)[self.view viewWithTag:TS_VIDEO_STREAM_BUTTON_TAG];
    UIButton *audioLiveButton = (UIButton *)[self.view viewWithTag:TS_AUDIO_STREAM_BUTTON_TAG];

    [videoLiveButton setTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveVideo", nil)] forState:UIControlStateNormal];
    [audioLiveButton setTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveAudio", nil)] forState:UIControlStateNormal];

    audioLiveButton.hidden = YES;

    AsynchronousImageView *image = (AsynchronousImageView *)[self.view viewWithTag:TS_DETAIL_ASYNC_IMAGE_TAG];
    image.frame = CGRectMake(10, 25, 640, 420);

    sectionLabel = (UILabelMarginSet *)[self.view viewWithTag:107];
    [sectionLabel setPersistentBackgroundColor:[UIColor colorWithRed:255/255.0 green:2/255.0 blue:2/255.0 alpha:1.0]];

}

- (void)downloadClip:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"descargarVideo", nil)]
                                                    message:[NSString stringWithFormat:NSLocalizedString(@"descargarVideoMessage", nil)]
                                                   delegate:self
                                          cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"descargarVideoCancelar", nil)]
                                          otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"descargarVideoContinuar", nil)], nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1)
    {
        [(UIButton *)[self.view viewWithTag:103] setEnabled:NO];
        [(UIButton *)[self.view viewWithTag:103] setAlpha:0.75];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[currentClip valueForKey:@"archivo_url"]]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0];
        NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (theConnection)
        {
            dowloadedData = [NSMutableData data];
        }
        else
        {
            // Error
        }
    }
}

- (void)shareClip:(UIButton *)sender {
    NSDictionary *clip = currentClip;
    for(NSString *name in clip) {
        NSLog(@"%@ ---- %@", name, [clip objectForKey:name]);
    }
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://multimedia.telesurtv.net%@", [clip valueForKey:@"url"]]];
    [self shareText:[clip valueForKey:@"titulo"] andImage:[clip valueForKey:@"thumbnail_grande"] andUrl:URL];
}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)setClip:(NSDictionary *)clip {

    wrapper.frame = CGRectMake(12, 445, 660, 192);

    UILabel *tituloLabel = (UILabel *)[self.view viewWithTag:101];
    UILabel *fechaLabel = (UILabel *)[self.view viewWithTag:102];
    UIButton *descargarButton = (UIButton *)[self.view viewWithTag:103];
    UILabel *descripcionLabel = (UILabel *)[self.view viewWithTag:104];
    UIButton *shareButton = (UIButton *)[self.view viewWithTag:105];
    AsynchronousImageView *image = (AsynchronousImageView *)[self.view viewWithTag:TS_DETAIL_ASYNC_IMAGE_TAG];

    descargarButton.hidden = NO;
    fechaLabel.hidden = NO;
    shareButton.hidden = NO;
    image.hidden = YES;

    //Setear fuentes custom
    sectionLabel.leftMargin = 5;
    sectionLabel.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:14];//2e2e2e
    fechaLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:16];//696969
    shareButton.titleLabel.font = descargarButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:16];//white
    descripcionLabel.font = [UIFont fontWithName:@"Roboto-Light" size:12];//black

    [descargarButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"descarga", nil)] forState:UIControlStateNormal];
    [shareButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"compartir", nil)] forState:UIControlStateNormal];

    NSString *clipType = [[clip valueForKey:@"tipo"] valueForKey:@"slug"];
    BOOL switchTitles = [clipType isEqualToString:@"programa"];

    //Reset sizes
    sectionLabel.frame = CGRectMake(10, 20, 300, 50);
    tituloLabel.frame = CGRectMake(10, tituloLabel.frame.origin.y, 642, 1000);
    descripcionLabel.frame = CGRectMake(10, descripcionLabel.frame.origin.y, 642, 1000);
    

    // Establecer texto de etiquetas y arreglar tamaños.
    NSObject *categoria = [clip valueForKey:@"categoria"];
    if(categoria != [NSNull null]) {
        sectionLabel.text = [[categoria valueForKey:@"nombre"] uppercaseString];
    } else if(switchTitles) {
        sectionLabel.text = [[clip valueForKey:@"titulo"] uppercaseString];
    } else if(clipType) {
        sectionLabel.text = [[[clip valueForKey:@"tipo"] valueForKey:@"nombre"] uppercaseString];
    } else {
        sectionLabel.text = @"";
    }
    [sectionLabel sizeToFit];
    sectionLabel.frame = CGRectMake(sectionLabel.frame.origin.x, sectionLabel.frame.origin.y, sectionLabel.frame.size.width + 10, sectionLabel.frame.size.height);

    tituloLabel.text = [clip valueForKey:@"titulo"];
    fechaLabel.text = [clip obtenerFechaLargaParaEsteClip];
    descripcionLabel.text = [clip obtenerDescripcion];
    [tituloLabel sizeToFit];
    tituloLabel.frame = CGRectMake(tituloLabel.frame.origin.x, sectionLabel.frame.origin.y + sectionLabel.frame.size.height + 2, tituloLabel.frame.size.width + 10, tituloLabel.frame.size.height);
    fechaLabel.frame = CGRectMake(fechaLabel.frame.origin.x, tituloLabel.frame.origin.y + tituloLabel.frame.size.height + 12, fechaLabel.frame.size.width, fechaLabel.frame.size.height);
    descargarButton.frame = CGRectMake(descargarButton.frame.origin.x, fechaLabel.frame.origin.y - 3, descargarButton.frame.size.width, descargarButton.frame.size.height);
    shareButton.frame = CGRectMake(shareButton.frame.origin.x, descargarButton.frame.origin.y, shareButton.frame.size.width, shareButton.frame.size.height);
    CGSize descSize = [self frameForText:descripcionLabel.text sizeWithFont:descripcionLabel.font constrainedToSize:CGSizeMake(descripcionLabel.frame.size.width, 100000) lineBreakMode:NSLineBreakByWordWrapping];
    descripcionLabel.frame = CGRectMake(descripcionLabel.frame.origin.x, fechaLabel.frame.origin.y + fechaLabel.frame.size.height + 16, descSize.width, descSize.height);
    wrapper.contentOffset = CGPointMake(0, 0);
    wrapper.contentSize = CGSizeMake(wrapper.frame.size.width, descripcionLabel.frame.origin.y + descripcionLabel.frame.size.height + 15);
}

- (void)setPost:(Post *)post {
    
    [self removeCurrentPlayer];

    wrapper.frame = CGRectMake(11, 0, 660, 627);

    UILabel *tituloLabel = (UILabel *)[self.view viewWithTag:101];
    UILabel *fechaLabel = (UILabel *)[self.view viewWithTag:102];
    UIButton *descargarButton = (UIButton *)[self.view viewWithTag:103];
    UILabel *descripcionLabel = (UILabel *)[self.view viewWithTag:104];
    UIButton *shareButton = (UIButton *)[self.view viewWithTag:105];
    AsynchronousImageView *image = (AsynchronousImageView *)[self.view viewWithTag:TS_DETAIL_ASYNC_IMAGE_TAG];

/*
    BOOL sectionBol = sectionLabel.hidden;
    UIView *sectionParent = sectionLabel.superview;
    UIView *tituloParent = tituloLabel.superview;
    NSLog(@"%@", NSStringFromCGRect(sectionLabel.frame));
*/
    descargarButton.hidden = YES;
    fechaLabel.hidden = YES;
    shareButton.hidden = YES;
    image.hidden = NO;

    //Setear fuentes custom
    sectionLabel.leftMargin = 5;
    sectionLabel.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:14];//2e2e2e
    fechaLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:16];//696969
    shareButton.titleLabel.font = descargarButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:16];//white
    descripcionLabel.font = [UIFont fontWithName:@"Roboto-Light" size:14];//black

    [shareButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"compartir", nil)] forState:UIControlStateNormal];

    //Reset sizes
    sectionLabel.frame = CGRectMake(10, 465, 300, 50);
    tituloLabel.frame = CGRectMake(10, tituloLabel.frame.origin.y, 642, 1000);
    descripcionLabel.frame = CGRectMake(10, descripcionLabel.frame.origin.y, 642, 1000);
    
    
    sectionLabel.text = [post.category uppercaseString];

    [sectionLabel sizeToFit];
    sectionLabel.frame = CGRectMake(sectionLabel.frame.origin.x, sectionLabel.frame.origin.y, sectionLabel.frame.size.width + 10, sectionLabel.frame.size.height);

    tituloLabel.text = post.title;

    descripcionLabel.text = [[currentPost.content stringByDecodingHTMLEntities] stringByReplacingParagraphTagsWithNewLines];

    [tituloLabel sizeToFit];
    tituloLabel.frame = CGRectMake(tituloLabel.frame.origin.x, sectionLabel.frame.origin.y + sectionLabel.frame.size.height + 2, tituloLabel.frame.size.width + 10, tituloLabel.frame.size.height);

    CGSize descSize = [self frameForText:descripcionLabel.text sizeWithFont:descripcionLabel.font constrainedToSize:CGSizeMake(descripcionLabel.frame.size.width, 100000) lineBreakMode:NSLineBreakByWordWrapping];
    descripcionLabel.frame = CGRectMake(descripcionLabel.frame.origin.x, tituloLabel.frame.origin.y + tituloLabel.frame.size.height + 16, descSize.width, descSize.height);
    wrapper.contentOffset = CGPointMake(0, 0);
    wrapper.contentSize = CGSizeMake(wrapper.frame.size.width, descripcionLabel.frame.origin.y + descripcionLabel.frame.size.height + 15);

    if([image isKindOfClass:AsynchronousImageView.class]) {
        [image reset];
        image.url = [currentPost.enclosure valueForKey:@"url"];
        [image cargarImagenSiNecesario];
    }

}

- (void) playVideoFromClip:(NSDictionary *)clip {
    [self removeCurrentPlayer];
    playerController = [[TSClipPlayerViewController alloc] initConClip:clip];
    [playerController playAtView:self.view withFrame:CGRectMake(20, 25, 640, 420) withObserver:self playbackFinish:@selector(playbackEnd:)];
    [self.view bringSubviewToFront:[self.view viewWithTag:TS_STREAM_VIEW_TAG]];
}

- (void) resumeVideoPlayer {
    playerController = [[TSClipPlayerViewController alloc] initConClip:currentClip];
    [playerController playAtView:self.view withFrame:CGRectMake(20, 25, 640, 420) withObserver:self playbackFinish:@selector(playbackEnd:)];
    [self.view bringSubviewToFront:[self.view viewWithTag:TS_STREAM_VIEW_TAG]];
}

- (void) removeCurrentPlayer {
    if(playerController) {
        [playerController.moviePlayer stop];
        [playerController.view removeFromSuperview];
        playerController = nil;
    }
}

- (void) playbackEnd:(NSNotification *)notification {

}

- (void) toogleLiveView {
    UIView *menu = [self.view viewWithTag:TS_STREAM_VIEW_TAG];
    [self showLiveView:menu.hidden];
}

- (void) showLiveView:(BOOL)hidden {
    UIView *menu = [self.view viewWithTag:TS_STREAM_VIEW_TAG];
    UIButton *videoStream = (UIButton *)[self.view viewWithTag:TS_VIDEO_STREAM_BUTTON_TAG];
//    UIButton *audioButton = (UIButton *)[self.view viewWithTag:TS_AUDIO_STREAM_BUTTON_TAG];
    menu.hidden = !hidden;
    [self.view bringSubviewToFront:menu];
    if(!menu.hidden) {
        [videoStream addTarget:self action:@selector(launchVideoStream) forControlEvents:UIControlEventTouchUpInside];
//        [audioButton addTarget:self action:@selector(audioButtonWillTrigger:) forControlEvents:UIControlEventTouchUpInside];
        [self addGestureRecognizer:YES];
    } else {
        [[NavigationBarsManager sharedInstance].masterView removeGestureRecognizer:singleTapGestureRecogniser];
        [videoStream removeTarget:self action:@selector(launchVideoStream) forControlEvents:UIControlEventTouchUpInside];
//        [audioButton removeTarget:self action:@selector(audioButtonWillTrigger:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void) audioButtonWillTrigger:(UIButton *)sender {
    isAudioPlaying = !isAudioPlaying;
    if(isAudioPlaying) {
        sender.backgroundColor = [UIColor colorWithRed:217/255.0 green:25/255.0 blue:24/255.0 alpha:1.0];
        [self launchAudioStream];
    } else {
        sender.backgroundColor = [UIColor colorWithRed:255/255.0 green:144/255.0 blue:0/255.0 alpha:1.0];
        [self stopAudioStream];
    }
}

- (void) addGestureRecognizer:(BOOL)isStreamView {
    singleTapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    singleTapGestureRecogniser.numberOfTapsRequired = 1;
    singleTapGestureRecogniser.delegate = self;
    [[NavigationBarsManager sharedInstance].masterView addGestureRecognizer:singleTapGestureRecogniser];
    streamViewHaveGesture = isStreamView;
}

- (void) toogleAboutView {
    UIView *menu = [self.view viewWithTag:aboutViewTag];
    menu.hidden = !menu.hidden;
    [self.view bringSubviewToFront:menu];
    if(!menu.hidden) {
        lastPlaybackStatus = playerController.moviePlayer.playbackState;
        [playerController.moviePlayer pause];
        [self addGestureRecognizer:NO];
    } else {
        [[NavigationBarsManager sharedInstance].masterView removeGestureRecognizer:singleTapGestureRecogniser];
        if(lastPlaybackStatus == MPMoviePlaybackStatePlaying) {
            [playerController.moviePlayer play];
        }
    }
}

- (void) launchVideoStream {
    if(playerController) {
        lastPlaybackStatus = playerController.moviePlayer.playbackState;
    }
    [self toogleLiveView];
    [self removeCurrentPlayer];

    NSString *moviePath = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Configuración"] valueForKey:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Streaming URL Alta" : @"Streaming URL Media"];

    playerController = [[TSClipPlayerViewController alloc] initConProgramaURL:moviePath];
    // Reproducir video
    [playerController playEnViewController:self
                      finalizarConSelector:@selector(livestreamEnd)
                         registrandoAccion:NO];
}

- (void) launchAudioStream {
    if(playerController) {
        lastPlaybackStatus = playerController.moviePlayer.playbackState;
    }
    [self toogleLiveView];
    [self removeCurrentPlayer];
    
    NSString *moviePath = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Configuración"] valueForKey:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Streaming URL Alta" : @"Streaming URL Media"];
    
    playerController = [[TSClipPlayerViewController alloc] initConProgramaURL:moviePath];
    // Reproducir video
    [playerController playAtView:self.view
                       withFrame:CGRectMake(0, 0, 1, 1)
                    withObserver:self
                  playbackFinish:@selector(livestreamEnd)];
}

- (void) stopAudioStream {
    [self removeCurrentPlayer];
    [self resumeVideoPlayer];
}

- (void) livestreamEnd {
    [self resumeVideoPlayer];
}

- (void) selectedClip:(NSDictionary *)clip {
    if(currentClip == clip) {
        return;
    }
    currentClip = clip;
    [self hideMenus];
    [self setClip:clip];
    [self playVideoFromClip:clip];
}

- (void) hideMenus {
    [self.view viewWithTag:TS_DETAIL_VIEW_TAG].hidden = NO;
    [self.view viewWithTag:aboutViewTag].hidden = YES;
    [self.view viewWithTag:TS_STREAM_VIEW_TAG].hidden = YES;
}

- (void) selectedPost:(Post *)post {
    if(currentPost == post) {
        return;
    }
    currentPost = post;
    [self hideMenus];
    [self setPost:post];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(streamViewHaveGesture) {
        if ([touch.view isDescendantOfView:[self.view viewWithTag:TS_STREAM_VIEW_TAG]]) {
            return NO;
        } else {
            [self toogleLiveView];
            return YES;
        }
    } else {
        if (![touch.view isDescendantOfView:[self.view viewWithTag:aboutViewTag]]) {
            [self toogleAboutView];
        }
        return NO;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [dowloadedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [dowloadedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    dowloadedData = nil;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error de descarga", @"Error de descarga") message:@"Falló la descarga, intenta nuevamente"  delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    [alert show];
    //Comentado para pruebas
    //    [alert release];
    
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *tempPath = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), [NSString stringWithFormat:@"%@.mp4", [currentClip valueForKey:@"titulo"]]];
    
    [dowloadedData writeToFile:tempPath atomically:NO];
    
    UISaveVideoAtPathToSavedPhotosAlbum([[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"mp4"], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);

    [(UIButton *)[self.view viewWithTag:103] setEnabled:YES];
    [(UIButton *)[self.view viewWithTag:103] setAlpha:1];
    dowloadedData = nil;
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (id)contextInfo
{
    if (error == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Descarga finalizada", @"Descarga finalizada") message:@"Finalizó la descarga, el video se encuentra en el rollo de tu cámara."  delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
        //Comentado para pruebas
        //        [alert release];
    }
    else
    {
        NSLog(@"Error guardando video: %@", error);
    }
}

@end
