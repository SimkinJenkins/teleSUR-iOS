//
//  TSIpadNavigationViewController.m
//  teleSUR
//
//  Created by Simkin on 29/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSIpadNavigationViewController.h"
#import "NavigationBarsManager.h"
#import "TSIPadRSSDetailViewController.h"
#import "TSIPadVideoDetailViewController.h"
#import "TSIPadOpinionViewController.h"
#import "TSIPadBlogHomeViewController.h"
#import "TSIpadVideoHomeViewController.h"

#import "TSDataManager.h"

@implementation TSIpadNavigationViewController

@synthesize headerVw, headerTxf, leftMenuVw, menuTxf, currentTopMenuConfig, livestreamMenu, playerController, topView;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}




















- (void)viewDidLoad {

    [super viewDidLoad];

    [[NavigationBarsManager sharedInstance] setTopNavigationController:self];
    [[NavigationBarsManager sharedInstance] setMasterNavigationController:self];

    [self initCatalogs];

    [self configureTitleHeader];

    bool livestreamEnabled = [[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"livestreamEnabled"] boolValue] == YES;
    if (livestreamEnabled) {
        [self configureRightNavigationButtons];
    }

    [self configureLeftMenu];

    [self configureMenuButtons];

    BOOL isMultimediaAPP = [ [ [ [ [ NSBundle mainBundle ] infoDictionary ] valueForKey:@"Configuración" ] valueForKey:@"APPtype" ] isEqualToString:@"multimedia" ];
    if ( isMultimediaAPP ) {
        [self setCurrentSection:[sectionsSlug objectAtIndex:0]];
        [self setMenuTitle:@""];
        [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(launchDefaultSectionInMultimediaAPP) userInfo:nil repeats:NO];

    }

}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
}



















- (void)addTopViewController:(UIViewController *)viewController {
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    self.topViewController.view.userInteractionEnabled = NO;
    
    self.topView = viewController;
    [self.view.window insertSubview:viewController.view aboveSubview:self.topViewController.view];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (void) removeTopViewController {
    [self.topView.view removeFromSuperview];
    self.topView = nil;
}

- (void) setNavigationItemsHidden:(BOOL)hidden {

    leftMenuVw.hidden = [self.section isEqualToString:@"home"] || [self.section isEqualToString:@"opinion"] || [self.section isEqualToString:@"blog"] || hidden;
    headerVw.hidden = hidden;
    livestreamLabelView.hidden = hidden;

}

















- (void) initCatalogs {
    catalogs = [NSMutableDictionary dictionary];
    
    videoSectionsSlug = [[NSArray alloc] initWithArray:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"videoMenuSubsections"]];    NSMutableArray *titles = [NSMutableArray array];
    for (uint i = 0; i < [videoSectionsSlug count]; i++) {
        NSString *localizeID = [NSString stringWithFormat:@"%@Section", [videoSectionsSlug objectAtIndex:i]];
        [titles setObject:[NSString stringWithFormat:NSLocalizedString(localizeID, nil)] atIndexedSubscript:i];
    }
    videoSections = [[NSArray alloc] initWithArray:titles];

    NSArray *staticSections = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"principalMenuSections"];
    NSMutableArray *sectionsAllOptions = [NSMutableArray array];
    for (uint i = 0; i < [staticSections count] - 1; i++) {
        NSString *slug = [staticSections objectAtIndex:i];
        if(![slug isEqualToString:@"buscar"]) {
            [sectionsAllOptions addObject:slug];
        }
    }
    sectionsSlug = [[NSArray alloc] initWithArray:sectionsAllOptions];
    for (uint i = 0; i < [sectionsSlug count]; i++) {
        NSString *localizeID = [NSString stringWithFormat:@"%@Section", [sectionsSlug objectAtIndex:i]];
        [titles setObject:[NSString stringWithFormat:NSLocalizedString(localizeID, nil)] atIndexedSubscript:i];
    }
    sectionsTitle = [[NSArray alloc] initWithArray:titles];
    
    newsSectionsSlugs = [NSArray arrayWithObjects:@"latinoamerica", @"mundo", @"deportes", @"cultura", @"salud", @"ciencia-y-tecnologia", nil];
    for (uint i = 0; i < [newsSectionsSlugs count]; i++) {
        NSString *localizeID = [NSString stringWithFormat:@"%@Section", [newsSectionsSlugs objectAtIndex:i]];
        [titles setObject:[NSString stringWithFormat:NSLocalizedString(localizeID, nil)] atIndexedSubscript:i];
    }
    newsSectionsTitles = [[NSArray alloc] initWithArray:titles];
    
    self.navigationBar.barTintColor = [UIColor colorWithRed:(241/255.0) green:(238/255.0) blue:(238/255.0) alpha:1];

//    self.navigationBar.barTintColor = [UIColor redColor];

    self.toolbar.barTintColor = [UIColor colorWithRed:(241/255.0) green:(238/255.0) blue:(238/255.0) alpha:1];

    [NavigationBarsManager sharedInstance].delegate = self;
}

- (void) setCurrentSection:(NSString *)slug {

    if([self.section isEqualToString:slug]) {
        return;
    }
    NSLog(@"setcurrentsection : %@", slug);

    self.section = slug;

    [leftMenu dismissMenu];

    NSInteger index = [sectionsSlug indexOfObject:slug];
    BOOL inVideo = NO;
    NSString *title;
    if(index > [sectionsTitle count]) {
        index = [videoSectionsSlug indexOfObject:slug];
        title = [videoSections objectAtIndex:index];
        inVideo = YES;
    } else {
        title = [sectionsTitle objectAtIndex:index];
    }
    [self setNavigationTitle:title];
    self.navigationItem.title = title;

    if(inVideo || index < [sectionsSlug count] - 1) {
        if(![slug isEqualToString:@"infografia"] && ![slug isEqualToString:@"reportaje"] && ![slug isEqualToString:@"blog"]) {
            NSString *titleID = [slug isEqualToString:@"programa"] ? @"leftMenuProgramDefault" : @"leftMenuDefault";
            [self setMenuTitle:[NSString stringWithFormat:NSLocalizedString(titleID, nil)]];
        } else {
            [self setMenuTitle:@""];
        }
    } else {
        [self setMenuTitle:@""];
    }

    [self configTopMenuWithCurrentConfiguration];

}

- (void) configureTitleHeader {

    CGRect screenBound = [[UIScreen mainScreen] bounds];
    headerVw = [[UIView alloc] initWithFrame:CGRectMake((screenBound.size.width * .5) - 112, 0, 225, 35)];
    headerVw.backgroundColor = [UIColor colorWithRed:(241/255.0) green:(238/255.0) blue:(238/255.0) alpha:1];

    UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-menu-header.png"]];
    leftImage.frame = CGRectMake(0, 0, 21, 23);

    headerTxf = [[UITextField alloc] initWithFrame: CGRectMake(0, 3, 225, 35)];
    headerTxf.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    headerTxf.textAlignment = NSTextAlignmentCenter;

    [headerTxf setLeftViewMode:UITextFieldViewModeAlways];
    headerTxf.leftView = leftImage;
    headerTxf.delegate = self;

    [self setNavigationTitle:[sectionsTitle objectAtIndex:0]];

    [headerVw addSubview:headerTxf];

    [self.navigationBar addSubview:headerVw];
}

- (void) setNavigationTitle:(NSString *)title {
    CGSize stringsize = [self frameForText:title sizeWithFont:headerTxf.font constrainedToSize:CGSizeMake(headerTxf.frame.size.width + 50, 100) lineBreakMode:NSLineBreakByWordWrapping];
    headerTxf.text = title;
    float tfWidth = stringsize.width + 42;
    [headerTxf setFrame:CGRectMake((225 - tfWidth) * .5, 3, tfWidth, 35)];
    NSLog(@"headerFrame : %@", title);
    [self setTitle:title];
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

- (void) configureLeftMenu {
    UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live-bullet.png"]];
    rightImage.frame = CGRectMake(0, 0, 13, 8);
    
    leftMenuVw = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 240, 35)];
    leftMenuVw.backgroundColor = [UIColor colorWithRed:(241/255.0) green:(238/255.0) blue:(238/255.0) alpha:1];

    //Crear Menu Superior
    menuTxf = [[UITextField alloc] initWithFrame: CGRectMake(0, 3, 225, 35)];
    menuTxf.font = [UIFont fontWithName:@"Helvetica" size:18];
    menuTxf.textAlignment = NSTextAlignmentLeft;

    [menuTxf setRightViewMode:UITextFieldViewModeAlways];
    menuTxf.rightView = rightImage;

    [leftMenuVw addSubview:menuTxf];
    leftMenu = [[UIDropDownMenu alloc] initWithIdentifier:@"menu"];
    leftMenu.backgroundColor = [UIColor colorWithRed:(241/255.0) green:(238/255.0) blue:(238/255.0) alpha:1];
    leftMenu.menuWidth = 344;
    leftMenu.rowHeight = 36;
    leftMenu.menuTextFont = [UIFont fontWithName:@"Roboto-Light" size:18];
    leftMenu.separatorColor = [UIColor colorWithRed:(226/255.0) green:(223/255.0) blue:(223/255.0) alpha:1];;
    leftMenu.menuIndent = CGPointMake(20, 0);
    leftMenu.menuPosition = CGRectMake(1, 64, 1, 1);
    leftMenu.delegate = self;

    [self.navigationBar addSubview:leftMenuVw];

}

- (void) configureMenuButtons {

    NSInteger videoSectionIndex = [sectionsSlug indexOfObject:@"video"];
    for (uint i = 0; i < [sectionsSlug count]; i++) {
        BOOL isVideoButton = videoSectionIndex == i;
        UIButton *newButton = [self getToolButton:[sectionsTitle objectAtIndex:i]
                                      withImageID:[NSString stringWithFormat:@"ipad-%@.png", [sectionsSlug objectAtIndex:i]]
                                  atIndexPosition:i
                                        addTarget:!isVideoButton];
        if(isVideoButton) {
            videoButton = newButton;
        }
    }

    videoMenu = [[UIDropDownMenu alloc] initWithIdentifier:@"videoMenu"];
    videoMenu.backgroundColor = [UIColor colorWithRed:(254/255.0) green:(65/255.0) blue:(65/255.0) alpha:1];
    videoMenu.menuWidth = 280;
    videoMenu.rowHeight = 55;
    videoMenu.menuTextAlignment = NSTextAlignmentCenter;
    videoMenu.menuTextFont = [UIFont fontWithName:@"Roboto-Light" size:24];
    videoMenu.textColor = [UIColor whiteColor];
    videoMenu.menuIndent = CGPointMake(20, 0);
    videoMenu.animationFromAbove = NO;

    videoMenu.menuPosition = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? CGRectMake(230, 485, 1, 1) : CGRectMake(140, 740, 1, 1);

    videoMenu.separatorColor = videoMenu.backgroundColor;
    videoMenu.selectedBackgroundColor = [UIColor colorWithRed:(218/255.0) green:(25/255.0) blue:(25/255.0) alpha:1];
    videoMenu.delegate = self;

    videoMenu.titleArray = [[NSMutableArray alloc] initWithArray:videoSections];
    videoMenu.valueArray = [[NSMutableArray alloc] initWithArray:videoSectionsSlug];

}

- (UIButton *) getToolButton:(NSString *)title withImageID:(NSString *)imageID atIndexPosition:(int)indexPos addTarget:(BOOL)target {

    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);

    UIButton *button = [[UIButton alloc] initWithFrame:isLandscape ?
                                CGRectMake( ( 480 - [ sectionsSlug count ] * 50 ) + ( indexPos * 110 ), 0, 88, 59 ) :
                                CGRectMake( ( 400 - [ sectionsSlug count ] * 50 ) + ( indexPos * 94 ), 0, 88, 59 )];

    button.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:14];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    UIImage *background = [UIImage imageNamed:imageID];
    [button setBackgroundImage:background forState:UIControlStateNormal];

    button.tag = 200 + indexPos;
    if(target) {
        [button addTarget:self action:@selector(bottomMenuSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.toolbar addSubview:button];

    return button;
}

- (void) bottomMenuSelect:(UIButton *)sender {

    NSInteger index = sender.tag - 200;

    if([self.section isEqualToString:[sectionsSlug objectAtIndex:index]]) {
        return;
    }

    [self setCurrentSection:[sectionsSlug objectAtIndex:index]];

    [leftMenu dismissMenu];
    [videoMenu dismissMenu];

    if ( livestreamMenu.superview ) {
        [livestreamMenu removeFromSuperview];
    }

    [self launchSectionWithIndex:index animated:YES];

}

- (void) launchDefaultSectionInMultimediaAPP {

    [self launchSectionWithIndex:0 animated:NO];

}

- (void) launchSectionWithIndex:(NSInteger)index animated:(BOOL)animated {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle: nil];

    UIViewController *vc = [ mainStoryboard instantiateViewControllerWithIdentifier:[ self getViewControllerIDForIndex:index ] ];

    BOOL isMultimediaAPP = [ [ [ [ [ NSBundle mainBundle ] infoDictionary ] valueForKey:@"Configuración" ] valueForKey:@"APPtype" ] isEqualToString:@"multimedia" ];

    if ( index == 5 || index == 6 || (isMultimediaAPP && index < 10) ) {
        [self stopLiveAudio];
        vc = [(TSIpadVideoHomeViewController *) vc initWithSection:[sectionsSlug objectAtIndex:index]];
    } else if ( index > 9 ) {
        [self stopLiveAudio];
        vc = [(TSIpadVideoHomeViewController *) vc initWithSection:[videoSectionsSlug objectAtIndex:index - 10]];
    } else if ( index == 1 ) {
        vc = [(TSIPadRSSDetailViewController *) vc initWithSection:[sectionsSlug objectAtIndex:index] andSubsection:@""];
    }

    currentVC = vc;

    [self setViewControllers:@[vc] animated:animated];

    [self setSection:[sectionsSlug objectAtIndex:index > 9 ? index - 10 : index]];

}

- (NSString *) getViewControllerIDForIndex:(NSInteger)index {

    BOOL isMultimediaAPP = [ [ [ [ [ NSBundle mainBundle ] infoDictionary ] valueForKey:@"Configuración" ] valueForKey:@"APPtype" ] isEqualToString:@"multimedia" ];

    if ( isMultimediaAPP ) {
        return @"TSIpadVideoHomeViewController";
    }

    if ( index == 0 ) {
        return @"TSIPadHomeViewController";
    } else if ( index == 3 ) {
        return @"TSIPadOpinionViewController";
    } else if ( index == 4 ) {
        return @"TSIPadBlogHomeViewController";
    } else if ( index == 5 || index == 6 || index > 9 ) {
        return @"TSIpadVideoHomeViewController";
    } else if ( index == 7 ) {
        return @"TSConfigurationTableViewController";
    }

    return @"TSIPadRSSDetailViewController";

}

- (void) configTopMenuWithCurrentConfiguration {
    currentTopMenuConfig = [self getTopMenuConfig:self.section];
    leftMenu.titleArray = [currentTopMenuConfig objectForKey:@"titles"];
    leftMenu.valueArray = [currentTopMenuConfig objectForKey:@"keys"];
    NSLog(@"configTop : %d", [[currentTopMenuConfig objectForKey:@"titles"] count] == 0);
    menuTxf.rightView.hidden = [[currentTopMenuConfig objectForKey:@"titles"] count] == 0;
    if([NavigationBarsManager sharedInstance].masterView) {
        [leftMenu makeMenu:menuTxf targetView:[NavigationBarsManager sharedInstance].masterView];
    }
    leftMenuVw.hidden = [self.section isEqualToString:@"home"] || [self.section isEqualToString:@"opinion"] || [self.section isEqualToString:@"blog"];
    [self.navigationController.navigationBar bringSubviewToFront:leftMenuVw];
}

- (NSDictionary *)getTopMenuConfig:(NSString *)type {
    if ([type isEqualToString:@"video-noticia"] || [type isEqualToString:@"entrevista"]) {
        return @{   @"keys":[newsSectionsSlugs subarrayWithRange:NSMakeRange(0, [newsSectionsSlugs count] - 1)],
                    @"titles":[newsSectionsTitles subarrayWithRange:NSMakeRange(0, [newsSectionsSlugs count] - 1)]
                    };
    } else if ([type isEqualToString:@"noticias"]) {
        return @{   @"keys":[newsSectionsSlugs subarrayWithRange:NSMakeRange(0, 4)],
                    @"titles":[newsSectionsTitles subarrayWithRange:NSMakeRange(0, 4)]
                    };
    } else if ([type isEqualToString:@"especial-web"]) {
        return @{   @"keys":[NSArray arrayWithObjects:@"sintesis-web", nil],
                    @"titles":[NSArray arrayWithObjects:[NSString stringWithFormat:NSLocalizedString(@"sintesis-webSection", nil)], nil]
                    };
    } else if ([type isEqualToString:@"programa"]) {
        NSArray *catalog = [catalogs objectForKey:type];
        if(!catalog) {
            [self loadCatalog:type];
            return @{   @"keys":[NSArray array],
                        @"titles":[NSArray array]
                        };
        }
        return [catalogs objectForKey:type];
    } else if ([type isEqualToString:@"reportaje"] || [type isEqualToString:@"blog"] || [type isEqualToString:@"home"] || [type isEqualToString:@"video"]) {
        return @{   @"keys":[NSArray array],
                    @"titles":[NSArray array]
                    };
    } else if ([type isEqualToString:@"opinion"]) {
        return @{   @"keys":[NSArray arrayWithObjects:@"op-articulos", @"op-entrevistas", nil],
                    @"titles":[NSArray arrayWithObjects:[NSString stringWithFormat:NSLocalizedString(@"op-articulosSection",nil)],
                               [NSString stringWithFormat:NSLocalizedString(@"op-entrevistasSection", nil)], nil]
                    };
    }
    return nil;
}
/*
- (NSDictionary *)getTopMenuConfig:(NSString *)type {
    if ([type isEqualToString:@"video-noticia"] || [type isEqualToString:@"entrevista"]) {
        return @{   @"keys":newsSectionsSlugs,
                    @"titles":newsSectionsTitles
                    };
    } else if ([type isEqualToString:@"especial-web"]) {
        return @{   @"keys":[NSArray arrayWithObjects:@"sintesis-web", nil],
                    @"titles":[NSArray arrayWithObjects:[NSString stringWithFormat:NSLocalizedString(@"sintesis-webSection", nil)], nil]
                    };
    } else if ([type isEqualToString:@"programa"]) {
        NSArray *catalog = [catalogs objectForKey:type];
        if(!catalog) {
//            [self loadCatalog:type];
            return @{   @"keys":[NSArray arrayWithObjects:nil],
                        @"titles":[NSArray arrayWithObjects:nil]
                        };
        }
        return [catalogs objectForKey:type];
    } else if ([type isEqualToString:@"reportaje"]) {
        return @{   @"keys":[NSArray arrayWithObjects:nil],
                    @"titles":[NSArray arrayWithObjects:nil]
                    };
    } else if ([type isEqualToString:@"opinion"]) {
        return @{   @"keys":[NSArray arrayWithObjects:@"op-articulos", @"op-entrevistas", nil],
                    @"titles":[NSArray arrayWithObjects:[NSString stringWithFormat:NSLocalizedString(@"op-articulosSection",nil)],
                               [NSString stringWithFormat:NSLocalizedString(@"op-entrevistasSection", nil)], nil]
                    };
    } else if ([type isEqualToString:@"home"]) {
        return @{   @"keys":[NSArray arrayWithObjects:nil],
                    @"titles":[NSArray arrayWithObjects:nil]
                    };
    }
    return nil;
}
*/
- (void) setMenuTitle:(NSString *)title {
    menuTxf.frame = CGRectMake(30, 3, 400, 35);
    CGSize stringsize = [self frameForText:title sizeWithFont:menuTxf.font constrainedToSize:CGSizeMake(menuTxf.frame.size.width, 100) lineBreakMode:NSLineBreakByWordWrapping];
    menuTxf.text = title;
    float tfWidth = stringsize.width + 20;
    [menuTxf setFrame:CGRectMake(30, 3, tfWidth, 35)];
}

- (void) configureRightNavigationButtons {

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    UIImage *liveBulletImage = [UIImage imageNamed:@"live-bullet.png"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 100, 21)];
    label.font = [label.font fontWithSize:18];
    label.text = @"En Vivo";
    [label sizeToFit];
    livestreamLabelView = [[UIView alloc] initWithFrame:CGRectMake(screenBound.size.width - 210, 5, 140, 30)];
    UIView *liveView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, livestreamLabelView.frame.size.height)];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(label.frame.size.width + 6, 15, 13, 8)];
    [iv setImage:liveBulletImage];
    [iv setTintColor: [UIColor blackColor]];
    [liveView addSubview:label];
    [liveView addSubview:iv];

    UIButton *invisibleButton = [[UIButton alloc] initWithFrame:liveView.frame];
//    invisibleButton.backgroundColor = [UIColor blackColor];
    [liveView addSubview:invisibleButton];
    [invisibleButton addTarget:self action:@selector(liveStreamMenuButtonSelect) forControlEvents:UIControlEventTouchUpInside];

    livestreamMenu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 230, 110)];
    livestreamMenu.backgroundColor = [UIColor colorWithRed:241/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];

    UIButton *video = [[UIButton alloc] initWithFrame:CGRectMake(20, 15, 190, 37)];
    video.backgroundColor = [UIColor colorWithRed:255/255.0 green:144/255.0 blue:0.0 alpha:1.0];
    [video setTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveVideo", nil)] forState:UIControlStateNormal];
    [video setImage: [UIImage imageNamed:@"senal.png"] forState:UIControlStateNormal];
    [video addTarget:self action:@selector(videostreamSelect) forControlEvents:UIControlEventTouchUpInside];
    [livestreamMenu addSubview:video];

    UIButton *audio = [[UIButton alloc] initWithFrame:CGRectMake(20, 60, 190, 37)];
    audio.tag = 1000;
    audio.backgroundColor = [UIColor colorWithRed:255/255.0 green:144/255.0 blue:0.0 alpha:1.0];
    [audio setTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveAudio", nil)] forState:UIControlStateNormal];
    [audio setImage: [UIImage imageNamed:@"audio.png"] forState:UIControlStateNormal];
    [audio addTarget:self action:@selector(launchLiveAudio) forControlEvents:UIControlEventTouchUpInside];
    [livestreamMenu addSubview:audio];

    [livestreamLabelView addSubview:liveView];

    [self.navigationBar addSubview:livestreamLabelView];

}

- (void) liveStreamMenuButtonSelect {

    [leftMenu dismissMenu];
    [videoMenu dismissMenu];

    if ( livestreamMenu.superview ) {
        [livestreamMenu removeFromSuperview];
    } else {
        [[NavigationBarsManager sharedInstance].masterView addSubview:livestreamMenu];
        CGRect screenBound = [[UIScreen mainScreen] bounds];
        livestreamMenu.alpha = 0.0;
        livestreamMenu.frame = CGRectMake(screenBound.size.width - 290, 0, 230, 110);
        [UIView animateWithDuration:.17 animations:^{
            livestreamMenu.alpha = 1.0;
            livestreamMenu.frame = CGRectMake(screenBound.size.width - 290, self.navigationBar.frame.size.height + self.navigationBar.frame.origin.y, 230, 110);
        }];
    }

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

}

- (void) videostreamSelect {

    [livestreamMenu removeFromSuperview];

    TSIpadNavigationViewController *topMenu = (TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance;
    [topMenu removeTopViewController];

    [NavigationBarsManager sharedInstance].livestreamON = YES;

    if([NavigationBarsManager sharedInstance].playerController && [NavigationBarsManager sharedInstance].playerController.playerController) {
        lastPlaybackStatus = [NavigationBarsManager sharedInstance].playerController.playerController.moviePlayer.playbackState;
    }

    NSString *moviePath = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Configuración"] valueForKey:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Streaming URL Alta" : @"Streaming URL Media"];

    if ( topView ) {
        [((TSIPadVideoDetailViewController *) topView) setURL:moviePath andTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveVideo", nil)]];
    } else {
        TSIPadVideoDetailViewController *detailView = [[TSIPadVideoDetailViewController alloc] initWithURL:moviePath andTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveVideo", nil)]];
        [self addTopViewController:detailView];
    }

}

- (void) livestreamEnd {

    [NavigationBarsManager sharedInstance].livestreamON = NO;

    return;

    if( lastPlaybackStatus == MPMoviePlaybackStatePlaying && [NavigationBarsManager sharedInstance].playerController ) {
        [[NavigationBarsManager sharedInstance].playerController resumeVideoPlayer];
    }

}

- (void) launchLiveAudio {

    if ( [NavigationBarsManager sharedInstance].audioLivestreamON ) {
    
        if(playerController) {
            [playerController.moviePlayer stop];
            [playerController.view removeFromSuperview];
            playerController = nil;
        }

        [NavigationBarsManager sharedInstance].audioLivestreamON = NO;
        return;
    }

    [NavigationBarsManager sharedInstance].audioLivestreamON = YES;

    [livestreamMenu viewWithTag:1000].backgroundColor = [UIColor colorWithRed:217/255.0 green:25/255.0 blue:24/255.0 alpha:1.0];

    if([NavigationBarsManager sharedInstance].playerController && [NavigationBarsManager sharedInstance].playerController.playerController) {
        lastPlaybackStatus = [NavigationBarsManager sharedInstance].playerController.playerController.moviePlayer.playbackState;
    }

    NSString *moviePath = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Configuración"] valueForKey:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Streaming URL Alta" : @"Streaming URL Media"];

    playerController = [[TSClipPlayerViewController alloc] initWithURL:moviePath andTitle:@""];
    [playerController playAtView:self.view withFrame:CGRectMake(0, 0, 1, 1) withObserver:self playbackFinish:nil];

}

- (void) stopLiveAudio {

    if ( ![NavigationBarsManager sharedInstance].audioLivestreamON ) {
        return;
    }

    [NavigationBarsManager sharedInstance].audioLivestreamON = NO;

    [livestreamMenu viewWithTag:1000].backgroundColor = [UIColor colorWithRed:255/255.0 green:144/255.0 blue:0/255.0 alpha:1.0];

    if(playerController) {
        [playerController.moviePlayer stop];
        [playerController.view removeFromSuperview];
        playerController = nil;
    }

    [self livestreamEnd];

}

- (void) deviceOrientationDidChangeNotification:(NSNotification *)notification {

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown) {
        return;
    }

    CGRect screenBound = [[UIScreen mainScreen] bounds];
    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);

    if( headerVw ) {
        headerVw.frame = CGRectMake((screenBound.size.width * .5) - 112, 0, 225, 35);
    }

    if ( livestreamLabelView ) {
        livestreamLabelView.frame = CGRectMake(screenBound.size.width - 210, 5, 140, 30);
        livestreamMenu.frame = CGRectMake(screenBound.size.width - 290, self.navigationBar.frame.size.height + self.navigationBar.frame.origin.y, 230, 110);

    }

    if ( videoMenu ) {
        videoMenu.menuPosition = isLandscape ? CGRectMake(230, 485, 1, 1) : CGRectMake(140, 740, 1, 1);
    }

    for (uint i = 0; i < [sectionsSlug count]; i++) {
        UIView *button = [self.toolbar viewWithTag:(200 + i)];
        button.frame = isLandscape ? CGRectMake( ( 480 - [ sectionsSlug count ] * 50 ) + ( i * 110 ), 0, 88, 59 ) :
                                    CGRectMake( ( 400 - [ sectionsSlug count ] * 50 ) + ( i * 94 ), 0, 88, 59 );
    }

}

- (void)loadCatalog:(NSString *)type {
    
    [[[TSDataManager alloc] init] loadAPIDataFor:@"" andSubsection:@"" withDataType:type inRange:NSMakeRange(1, 300) delegateResponseTo:self];
    
}

- (void)setCatalog:(NSArray *)data forKey:(NSString *)key {
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *titles = [NSMutableArray array];
    for(uint i = 0; i < [data count]; i++) {
        NSDictionary *row = [data objectAtIndex:i];
        [keys addObject:[row objectForKey:@"slug"]];
        [titles addObject:[row objectForKey:@"nombre"]];
    }
    [catalogs setObject:@{@"keys":keys, @"titles":titles, @"originalData":data} forKey:key];
    [self configTopMenuWithCurrentConfiguration];
}

















#pragma mark Header Title Textfield delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;
}



















#pragma mark DropDownMenu delegate

- (void) DropDownMenuWillAppear:(NSString *)identifier {
    if([identifier isEqualToString:@"videoMenu"]) {
        [leftMenu dismissMenu];
//        [self.toolbar sendSubviewToBack:videoMenu.dropdownTable];
    } else {
        [videoMenu dismissMenu];
    }
    if ( livestreamMenu.superview ) {
        [livestreamMenu removeFromSuperview];
    }

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void) DropDownMenuDidChange:(NSString *)identifier :(NSString *)ReturnValue {

    if([identifier isEqualToString:@"videoMenu"]) {
        NSInteger selectedIndex = [videoSectionsSlug indexOfObject:ReturnValue];
        [self setCurrentSection:[videoSectionsSlug objectAtIndex:selectedIndex]];
        [self launchSectionWithIndex:selectedIndex + 10 animated:YES];
    } else {
        int selectedIndex = (int)[[currentTopMenuConfig objectForKey:@"keys"] indexOfObject:ReturnValue];
        NSArray *titles = [currentTopMenuConfig objectForKey:@"titles"];
        [self setMenuTitle:[titles objectAtIndex:selectedIndex]];

        [(TSBasicListViewController *)currentVC filterSelectedWithSlug:ReturnValue];
    }
}



















#pragma mark -
#pragma mark NavigationBarsManagerDelegate

- (void) navigationManagerViewSet:(UIView *)masterView {

    if( leftMenu ) {
        [ leftMenu makeMenu:menuTxf targetView:masterView ];
    }
    if( videoMenu ) {
        [ videoMenu makeMenu:videoButton targetView:masterView ];
    }
}



















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    TSDataRequest *catReq = [requests objectAtIndex:0];

    if( catReq.error ) {
        return;
    }

    [self setCatalog:catReq.result forKey:catReq.type];
    
}









@end