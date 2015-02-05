//
//  TSClipPlayerViewController.m
//  teleSUR
//
//  Created by David Regla on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TSClipPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSDictionary_Datos.m"
#import "SlideNavigationController.h"

//#import "GAI.h"
//#import "GAIFields.h"
//#import "GAIDictionaryBuilder.h"

@implementation TSClipPlayerViewController

@synthesize clip, clipURL;

- (id)initConClip:(NSDictionary *)diccionarioClip
{
    NSString *url;
    NSString *subtitledVideoURL = [diccionarioClip valueForKey:@"archivo_subtitulado_url"];
    if ([[diccionarioClip valueForKey:@"metodo_preferido"] isEqualToString:@"streaming"])
    {
        url = [[diccionarioClip valueForKey:@"streaming"] valueForKey:@"apple_hls_url"];
    }
    else
    {
        url = [diccionarioClip valueForKey:@"archivo_url"];
    }

    NSLog(@"%@", url);

    url = subtitledVideoURL != (NSString *)[NSNull null] && ![subtitledVideoURL isEqualToString:@""] ? subtitledVideoURL : url;

    NSLog(@"%@", subtitledVideoURL);
    
                         
    self = [super initWithContentURL:[NSURL URLWithString:url]];

    if (self) {
        self.clipURL = url;
        self.clip = diccionarioClip;
    }

    NSLog(@"%@", self.clipURL);
    [self.moviePlayer setShouldAutoplay:YES];
    return self;
}

- (id)initConProgramaURL:(NSString *)progURL
{
    self = [super initWithContentURL:[NSURL URLWithString:progURL]];
    self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    [self.moviePlayer setShouldAutoplay:YES];
    if (self) {
        self.clipURL = progURL;
    }
    return self;
}

- (id)initStreamingFile:(NSString *)streamURL {
    NSURL *URL = [NSURL URLWithString:streamURL];
    self = [super initWithContentURL:URL];
    return self;
}

- (void)viewDidLoad {

    [self.view setBackgroundColor: [UIColor blackColor]];

}

- (void)viewDidUnload
{
    self.clip = nil;
    self.clipURL = nil;
}

- (void) viewDidDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:currentVC name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];

}

- (void)innerEndPlayer {

    IMP imp = [currentVC methodForSelector:currentSelector];
    void (*func)(id, SEL) = (void *)imp;
    func(currentVC, currentSelector);

}

- (void)playEnViewController:(UIViewController *)viewController finalizarConSelector:(SEL)selector registrandoAccion:(BOOL)registrar {

    [viewController presentMoviePlayerViewControllerAnimated:self];
    [self.moviePlayer play];

    if (selector != nil) {

        currentVC = viewController;
        currentSelector = selector;

        // Agregar observer al finalizar reproducción
        [[NSNotificationCenter defaultCenter] 
         addObserver:self
         selector:@selector(innerEndPlayer)
         name:MPMoviePlayerPlaybackDidFinishNotification
         object:self.moviePlayer];
    }

    // Enviar notificación a Google Analytics
    if (registrar) {
        //Comenté las metricas custom, por no encontrar un equivalente//
//        [tracker set:[GAIFields customDimensionForIndex:1]
//                id: @"Idioma"
//               value:(self.clip) ? [self.clip valueForKey:@"idioma"] : @"es"];
/*
        NSError *error;
        if (![[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                             name: @"Idioma"
                                                            value: (self.clip) ? [self.clip valueForKey:@"idioma"] : @"es"
                                                        withError: &error])
        {
            // Error
            NSLog(@"Error al establecer Variable Idioma: %@", error);
        }
*/
        /********************************************* Google Analytics Comentado ***********************************************/
/*
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"iPad" : @"iPhone/iPod Touch"
                                                              action:@"Video reproducido"
                                                               label:self.clipURL
                                                               value:-1] build]];
*/
/*
        if (![[GANTracker sharedTracker] trackEvent:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"iPad" : @"iPhone/iPod Touch"
                                             action:@"Video reproducido"
                                              label:
                                              value:-1
                                          withError:&error])
        {
            NSLog(@"Error al enviar evento 'Video reproducido': %@", error);
        }
 */
    }

}

- (void)playAtView:(UIView *)view withFrame:(CGRect)frame withObserver:(UIViewController *)viewController playbackFinish:(SEL)selector {

    currentFrame = frame;
    self.view.frame = frame;
    self.moviePlayer.controlStyle = MPMovieControlStyleDefault;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStart:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];
}

- (void)playbackStart:(NSNotification *)notification {

    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, currentFrame.size.width, currentFrame.size.height);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.moviePlayer];

}

@end