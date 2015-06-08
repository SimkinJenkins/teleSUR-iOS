//
//  TSClipListadoHomeMenuTableVC.m
//  teleSUR
//
//  Created by Simkin on 13/07/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSClipListadoHomeMenuTableVC.h"
#import "SlideNavigationController.h"
#import "LeftMenuViewController.h"
#import "UIDropDownMenu.h"
#import "UIViewController_Configuracion.h"

#import "UIViewController+TSLoader.h"

#import "TSDataRequest.h"
#import "TSDataManager.h"

#import "NavigationBarsManager.h"

@implementation TSClipListadoHomeMenuTableVC

@synthesize currentTopMenuConfig, headerMenu, searchBar;

- (void)viewDidLoad {

    currentSection = [[[NSArray alloc] initWithArray:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"principalMenuSections"]] objectAtIndex:0];
    currentSubsection = @"";

    [super viewDidLoad];

    [self configSubmenusArrays];

    searchBar = (UISearchBar *)[self.view viewWithTag:101];
    searchBar.placeholder = [NSString stringWithFormat:NSLocalizedString(@"searchPlaceholder", nil)];
    searchBar.hidden = YES;
    [self getCancelButton].titleLabel.text = @"Cancelar";

    //Configurar Menu Lateral
	[SlideNavigationController sharedInstance].panGestureSideOffset = 50;
    [SlideNavigationController sharedInstance].enableShadow = NO;
	((LeftMenuViewController *)[SlideNavigationController sharedInstance].leftMenu).slideOutAnimationEnabled = NO;
    [SlideNavigationController sharedInstance].portraitSlideOffset = 95;

    //Crear Header
    headerMenu = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 225, 35)];
    headerMenu.backgroundColor = [UIColor colorWithRed:(254/255.0) green:(254/255.0) blue:(254/255.0) alpha:1];

    UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-menu-header.png"]];
    leftImage.frame = CGRectMake(0, 0, 21, 23);

    UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-menu-header.png"]];
    rightImage.frame = CGRectMake(0, 0, 13, 7);

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent
                                                animated:NO];

    [self.navigationController.navigationBar setBackgroundColor:headerMenu.backgroundColor];
    self.navigationController.navigationBar.barTintColor = headerMenu.backgroundColor;
    self.navigationController.navigationBar.backgroundColor = headerMenu.backgroundColor;

    [self.navigationController.navigationBar addSubview:headerMenu];

    //Crear Menu Superior
    textfield = [[UITextField alloc] initWithFrame: CGRectMake(0, 3, 225, 35)];
    textfield.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    textfield.textAlignment = NSTextAlignmentCenter;

    NSString *titleLocalizedID = [NSString stringWithFormat:@"%@Section", currentSection];
    [self setNavigationTitle:[NSString stringWithFormat:NSLocalizedString(titleLocalizedID, nil)]];

    [textfield setLeftViewMode:UITextFieldViewModeAlways];
    textfield.leftView = leftImage;

    [textfield setRightViewMode:UITextFieldViewModeAlways];
    textfield.rightView = rightImage;

    [headerMenu addSubview:textfield];
    textMenu = [[UIDropDownMenu alloc] initWithIdentifier:@"menu"];

    textMenu.ScaleToFitParent = TRUE;
    textMenu.delegate = self;
    textMenu.menuTextAlignment = NSTextAlignmentCenter;

    [self configRightButton];
}

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [[NavigationBarsManager sharedInstance] setMasterView:[[ [ self.view superview] superview] superview] ];

    if([currentSection isEqualToString:@"buscar"]) {
        self.navigationController.navigationBarHidden = YES;
    }

    if( selectedIndexPath ) {

        selectedIndexPath = nil;
        headerMenu.hidden = NO;
        [self configTopMenuWithCurrentConfiguration];

    }

}














- (void) initTableVariables {
    
    [super initTableVariables];

    [self.tableViewController.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    loadMoreCellDisabled = NO;

}

- (void) setCatalog:(NSArray *)data forKey:(NSString *)key {

    [ super setCatalog:data forKey:key ];

    if ( [ currentSection isEqualToString:TS_PROGRAMA_SLUG ] && [ key isEqualToString:TS_PROGRAMA_SLUG ] ) {
        [ self configTopMenuWithCurrentConfiguration ];
    }

}

- (void) showUnlocatedNotification:(NSString *)URL {

    [super showUnlocatedNotification:URL];

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {

        self.headerMenu.hidden = YES;

    }

}



















- (void) sectionSelected:(NSString *)section withTitle:(NSString *)title {
    
    if ( [currentSection isEqualToString:@"buscar"] ) {
        self.tableViewController.tableView.frame = beforeSearchSectionTableFrame;
    }
    
    BOOL isSearchSection = [section isEqualToString:@"buscar"];
    
    if(currentSection == section) {
        if(isSearchSection) {
            [searchBar becomeFirstResponder];
        }
        return;
    }
    [textMenu dismissMenu];
    currentSection = section;
    [self setNavigationTitle:title];
    searchBar.hidden = !isSearchSection;
    self.navigationController.navigationBarHidden = isSearchSection;
    
    cancelUserInteraction = !isSearchSection;
    currentSubsection = @"";
    
    [self configTopMenuWithCurrentConfiguration];
    
    NSLog(@"Section selected : %@ - %@", section, title);
    
    if(isSearchSection) {
        beforeSearchSectionTableFrame = self.tableViewController.tableView.frame;
        tableElements = [[NSMutableArray alloc] init];
        [tableViewController.tableView reloadData];
        [searchBar becomeFirstResponder];
        searchBar.text = @"";
        [self.view bringSubviewToFront:searchBar];
        
        [[self getSearhTextfield] addTarget:self
                                     action:@selector(textfieldDidChange)
                           forControlEvents:UIControlEventEditingChanged];
        
        [[self getCancelButton] addTarget:self
                                   action:@selector(cancelClicked)
                         forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        
        [self initTableVariables];
        [self loadData];
        
    }
}

- (void) configTopMenuWithCurrentConfiguration {
    currentTopMenuConfig = [self getTopMenuConfig:currentSection];
    textMenu.titleArray = [currentTopMenuConfig objectForKey:@"titles"];
    textMenu.valueArray = [currentTopMenuConfig objectForKey:@"keys"];
    textfield.rightView.hidden = [[currentTopMenuConfig objectForKey:@"titles"] count] == 0;
    [textMenu makeMenu:textfield targetView:self.view];
    [self.navigationController.navigationBar bringSubviewToFront:headerMenu];
}



















- (void) setNavigationTitle:(NSString *)title {
    CGSize stringsize = [self frameForText:title
                              sizeWithFont:textfield.font
                         constrainedToSize:CGSizeMake(170, textfield.frame.size.height)
                             lineBreakMode:NSLineBreakByWordWrapping];
    textfield.text = title;
    float tfWidth = stringsize.width + 44;
    [textfield setFrame:CGRectMake((225 - tfWidth) * .5, 3, tfWidth, 35)];
    self.navigationItem.title = title;
}

- (void) DropDownMenuWillAppear:(NSString *)identifier {
    
}

- (void) DropDownMenuDidChange:(NSString *)identifier :(NSString *)ReturnValue {
    NSInteger selectedIndex = [[currentTopMenuConfig objectForKey:@"keys"] indexOfObject:ReturnValue];
    NSArray *titles = [currentTopMenuConfig objectForKey:@"titles"];
    [self setNavigationTitle:[titles objectAtIndex:selectedIndex]];
    [self filterSelectedWithSlug:ReturnValue];
}

- (NSDictionary *)getTopMenuConfig:(NSString *)type {
    if ([type isEqualToString:@"video-noticia"] || [type isEqualToString:@"entrevista"]) {
        return @{   @"keys":submenuVideoSectionsSlugs,
                  @"titles":submenuVideosSectionsTitles
                };
    } else if ([type isEqualToString:@"noticias"]) {
        return @{   @"keys":submenuNewsSectionsSlugs,
                    @"titles":submenuNewsSectionsTitles
                    };
    } else if ([type isEqualToString:@"especial-web"]) {
        return @{   @"keys":[NSArray arrayWithObjects:@"sintesis-web", nil],
                    @"titles":[NSArray arrayWithObjects:[NSString stringWithFormat:NSLocalizedString(@"sintesis-webSection", nil)], nil]
                    };
    } else if ([type isEqualToString:@"programa"]) {
        NSArray *catalog = [catalogs objectForKey:type];
        if(!catalog) {
            return @{   @"keys":[NSArray arrayWithObjects:nil],
                        @"titles":[NSArray arrayWithObjects:nil]
                        };
        }
        return [catalogs objectForKey:type];
    } else if ([type isEqualToString:@"reportaje"] || [type isEqualToString:@"blog"] || [type isEqualToString:@"home"] || [type isEqualToString:@"video"]) {
        return @{   @"keys":[NSArray arrayWithObjects:nil],
                    @"titles":[NSArray arrayWithObjects:nil]
                    };
    } else if ([type isEqualToString:@"opinion"]) {
        return @{   @"keys":[NSArray arrayWithObjects:@"op-articulos", @"op-entrevistas", nil],
                    @"titles":[NSArray arrayWithObjects:[NSString stringWithFormat:NSLocalizedString(@"op-articulosSection",nil)],
                                                        [NSString stringWithFormat:NSLocalizedString(@"op-entrevistasSection", nil)], nil]
                    };
    }
    return nil;
}

-(UIButton *) getCancelButton {
    UIView *mainView = [searchBar.subviews objectAtIndex:0];
    for(UIView *subView in mainView.subviews) {
        if([subView isKindOfClass:UIButton.class]) {
            return (UIButton *)subView;
        }
    }
    return nil;
}

-(UITextField *) getSearhTextfield {
    UIView *mainView = [searchBar.subviews objectAtIndex:0];
    for(UIView *subView in mainView.subviews) {
        if([subView isKindOfClass:UITextField.class]) {
            return (UITextField *)subView;
        }
    }
    return nil;
}

- (void) cancelClicked {
    [self dismissKeyboard];
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
}

-(void)textfieldDidChange {
    NSLog(@"%@ --- > count %lu", [self getSearhTextfield].text, (unsigned long)[[self getSearhTextfield].text length]);
    if([[self getSearhTextfield].text length] > 2) {

        if ( ![self isAPIHostAvailable] ) {
            return;
        }

        [self showLoaderWithAnimation:YES cancelUserInteraction:NO withInitialView:NO];
        defaultDataResultIndex = 0;
        TSDataRequest *searchReq = [[TSDataRequest alloc] initWithType:TS_CLIP_SLUG       forSection:@""  forSubsection:@""];
        searchReq.range = NSMakeRange(1, 15);
        searchReq.searchText = [self getSearhTextfield].text;
        NSArray *requests = [NSArray arrayWithObjects:searchReq, nil];
        [[[TSDataManager alloc] init] loadRequests:requests delegateResponseTo:self];
    }
}

-(void)dismissKeyboard {

    [searchBar resignFirstResponder];

}

// Codifica parámetros para URL
- (NSString *)urlEncode:(NSString *)string
{
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)string,
                                                                                 NULL,
                                                                                 CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
}

- (void) configRightButton {

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"refresh.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(refreshButtonClicked)];

}

- (void) refreshButtonClicked {

    [self initTableVariables];
    [self loadData];

}

- (void) configSubmenusArrays {

    submenuVideoSectionsSlugs = [[NSArray alloc] initWithArray:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"submenuVideoSections"]];
    
    NSMutableArray *titles = [NSMutableArray array];
    for (uint i = 0; i < [submenuVideoSectionsSlugs count]; i++) {
        NSString *localizeID = [NSString stringWithFormat:@"%@Section", [submenuVideoSectionsSlugs objectAtIndex:i]];
        [titles setObject:[NSString stringWithFormat:NSLocalizedString(localizeID, nil)] atIndexedSubscript:i];
    }
    submenuVideosSectionsTitles = [[NSArray alloc] initWithArray:titles];

    submenuNewsSectionsSlugs = [[NSArray alloc] initWithArray:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"submenuNewsSections"]];
    
    titles = [NSMutableArray array];
    for (uint i = 0; i < [submenuNewsSectionsSlugs count]; i++) {
        NSString *localizeID = [NSString stringWithFormat:@"%@Section", [submenuNewsSectionsSlugs objectAtIndex:i]];
        [titles setObject:[NSString stringWithFormat:NSLocalizedString(localizeID, nil)] atIndexedSubscript:i];
    }
    submenuNewsSectionsTitles = [[NSArray alloc] initWithArray:titles];

}






























- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if([currentSection isEqualToString:@"buscar"]) {
        [self dismissKeyboard];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    if (selectedIndexPath.row != [tableElements count]) {
//        headerMenu.hidden = YES;
    }

    if([currentSection isEqualToString:@"buscar"]) {
        self.navigationController.navigationBarHidden = NO;
    }

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    if ([currentSection isEqualToString:@"home"]) {
        return 2;
    }
    return 1;

}

- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if(![currentSection isEqualToString:@"home"]) {
        return [[UIView alloc] init];
    }

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
    view.backgroundColor = [UIColor blackColor];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(55, 14, 130, 30)];
    title.font = [UIFont fontWithName:@"Roboto-Regular" size:18];
    title.textColor = [UIColor whiteColor];

    UIImageView *imageView;
    if( section == 0 ) {
        NSString *videoTitle = [NSString stringWithFormat:@"%@", NSLocalizedString(@"videoSection", nil)];
        title.text = [videoTitle uppercaseString];
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video.png"]];
    } else {
        NSString *showTitle = [NSString stringWithFormat:NSLocalizedString(@"programaSection", nil)];
        title.text = [showTitle uppercaseString];
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"programa.png"]];
    }

    imageView.frame = (CGRect) {{10, 12}, imageView.frame.size};

    [view addSubview:title];
    [view addSubview:imageView];

    return view;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [currentSection isEqualToString:@"home"] ? 50 : 0;
}


















#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}






















#pragma mark - UISearchBar Methods -

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

}



















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    [super TSDataManager:manager didProcessedRequests:requests];

    if([currentSection isEqualToString:@"buscar"]) {

        [searchBar becomeFirstResponder];
        CGRect tframe = self.tableViewController.tableView.frame;
        tframe.origin.y = searchBar.frame.origin.y + searchBar.frame.size.height;
        self.tableViewController.tableView.frame = tframe;

    }

}























#pragma mark -
#pragma mark UIViewController+TSLoader

- (void)hideLoaderWithAnimation:(BOOL)animation {

    [super hideLoaderWithAnimation:animation];

    textfield.alpha = 1.0;
    textfield.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;

}

- (void)showLoaderWithAnimation:(BOOL)animation cancelUserInteraction:(BOOL)userInteraction withInitialView:(BOOL)initial {

    [super showLoaderWithAnimation:animation cancelUserInteraction:userInteraction withInitialView:initial];

    textfield.alpha = 0.7;
    textfield.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;

}

@end
