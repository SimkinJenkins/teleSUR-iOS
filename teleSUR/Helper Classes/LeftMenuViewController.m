//
//  MenuViewController.m
//  teleSUR
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 teleSUR. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "CollapsableTableView.h"
#import "UIViewController_Configuracion.h"
#import "TSClipListadoHomeMenuTableVC.h"
#import "HiddenVideoPlayerController.h"
#import "TSClipDetallesViewController.h"

#define kLIVE_VIDEO_BUTTON_TAG 1
#define kLIVE_AUDIO_BUTTON_TAG 2

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder {
	self.slideOutAnimationEnabled = YES;
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad {

	[super viewDidLoad];

//    isLiveAudioON = NO;

    bool livestreamEnabled = [[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"livestreamEnabled"] boolValue] == YES;

    CGRect tableFrame = self.tableView.frame;
    tableFrame.origin.y = livestreamEnabled ? 170 : tableFrame.origin.y;
    tableFrame.size.height -= livestreamEnabled ? 106 : 0;
    self.tableView.frame = tableFrame;

    videoSectionsSlug = [[NSArray alloc] initWithArray:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"videoMenuSubsections"]];
    NSMutableArray *titles = [NSMutableArray array];
    for (uint i = 0; i < [videoSectionsSlug count]; i++) {
        NSString *localizeID = [NSString stringWithFormat:@"%@Section", [videoSectionsSlug objectAtIndex:i]];
        [titles setObject:[NSString stringWithFormat:NSLocalizedString(localizeID, nil)] atIndexedSubscript:i];
    }
    videoSections = [[NSArray alloc] initWithArray:titles];

    sectionsSlug = [[NSArray alloc] initWithArray:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"principalMenuSections"]];
    for (uint i = 0; i < [sectionsSlug count]; i++) {
        NSString *localizeID = [NSString stringWithFormat:@"%@Section", [sectionsSlug objectAtIndex:i]];
        [titles setObject:[NSString stringWithFormat:NSLocalizedString(localizeID, nil)] atIndexedSubscript:i];
    }
    sectionsTitle = [[NSArray alloc] initWithArray:titles];

    self.tableView.sectionsInitiallyCollapsed = YES;
    self.tableView.collapsableTableViewDelegate = self;

    self.tableView.separatorColor = [UIColor colorWithRed:(254/255.0) green:(66/255.0) blue:(65/255.0) alpha:1];

    UIButton *videoLiveButton = (UIButton *)[self.view viewWithTag:kLIVE_VIDEO_BUTTON_TAG];
    videoLiveButton.hidden = !livestreamEnabled;
    [videoLiveButton addTarget:self action:@selector(videoLiveButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

    audioLiveButton = (UIButton *)[self.view viewWithTag:kLIVE_AUDIO_BUTTON_TAG];
    audioLiveButton.hidden = !livestreamEnabled;
    [audioLiveButton addTarget:self action:@selector(audioButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

    [videoLiveButton setTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveVideo", nil)] forState:UIControlStateNormal];
    [audioLiveButton setTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveAudio", nil)] forState:UIControlStateNormal];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL isAudioPlay = ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying;
    if(isAudioPlay) {
        audioLiveButton.backgroundColor = [UIColor colorWithRed:217/255.0 green:25/255.0 blue:24/255.0 alpha:1.0];
    } else {
        audioLiveButton.backgroundColor = [UIColor colorWithRed:255/255.0 green:144/255.0 blue:0/255.0 alpha:1.0];
    }
}

- (void) videoLiveButtonTouched:(UIButton *)sender {

    ((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying = false;
    NSString *moviePath = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Configuración"] valueForKey:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"Streaming URL Alta" : @"Streaming URL Media"];

    if ( [SlideNavigationController sharedInstance].topView ) {
        [((TSClipDetallesViewController *)[SlideNavigationController sharedInstance].topView) setURL:moviePath andTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveVideo", nil)]];
    } else {
        TSClipDetallesViewController *detailView = [[TSClipDetallesViewController alloc] initWithURL:moviePath andTitle:[NSString stringWithFormat:@" %@", NSLocalizedString(@"liveVideo", nil)]];
        [[SlideNavigationController sharedInstance] addTopViewController:detailView];
    }

}

- (void) audioButtonTouched:(UIButton *)sender {
    if(!((HiddenVideoPlayerController *)[SlideNavigationController sharedInstance].rightMenu).isAudioPlaying) {
        sender.backgroundColor = [UIColor colorWithRed:217/255.0 green:25/255.0 blue:24/255.0 alpha:1.0];
        [self launchLiveAudio];
    } else {
        sender.backgroundColor = [UIColor colorWithRed:255/255.0 green:144/255.0 blue:0/255.0 alpha:1.0];
        [self stopLiveAudio];
    }
}

- (void)collapseSection:(CollapsableTableView *)tableView
{
    NSString* vSectionTitle = @"Tag 0";
//    [LeftMenuViewController titleForHeaderForSection:1]; // Use this expression when specifying text for headers.
    BOOL isCollapsed = [[tableView.headerTitleToIsCollapsedMap objectForKey:vSectionTitle] boolValue];
    if(!isCollapsed) {
        [tableView setIsCollapsed:YES forHeaderWithTitle:vSectionTitle];
    }
}

- (void) setSelectedSection:(int)index withSlugCollection:(NSArray *)slugs withTitleCollection:(NSArray *)titles {
    TSClipListadoHomeMenuTableVC *view = [self getVideoHomeView];
    if(view) {
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:nil
                                                                 withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                         andCompletion:nil];
        [view sectionSelected:[slugs objectAtIndex:index] withTitle:[titles objectAtIndex:index]];
    } else {
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
    }
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

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionsSlug count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionsTitle objectAtIndex:section];
}

// Uncomment the following two methods to use custom header views.
- (UILabel *) createHeaderLabel: (UITableView *) tableView :(NSString *)headerTitle {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.frame =CGRectMake(35, 0, 200, 50);
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    titleLabel.text = headerTitle;
    titleLabel.textAlignment = NSTextAlignmentLeft;

    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"Roboto-Light" size:18];

    return titleLabel;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // create the parent view that will hold header Label
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300, 45)];

    UILabel *titleLabel = [self createHeaderLabel: tableView :[sectionsTitle objectAtIndex:section]];
    [customView addSubview:titleLabel];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", [sectionsSlug objectAtIndex:section]]]];
    imageView.frame = CGRectMake(14, 10, imageView.frame.size.width * .8, imageView.frame.size.height * .8);
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44, 300, 1)];
    separator.backgroundColor = [UIColor colorWithRed:(217/255.0) green:(25/255.0) blue:(24/255.0) alpha:1];

    [customView addSubview:imageView];
    [customView addSubview:separator];
    customView.tag = section;
    customView.backgroundColor = [UIColor colorWithRed:(254/255.0) green:(66/255.0) blue:(65/255.0) alpha:1];

    return customView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if( [sectionsSlug indexOfObject:@"video"] == section) {
        return [videoSectionsSlug count];
    }
    return 0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

	// Configure the cell.
    cell.textLabel.text = [NSString stringWithFormat:@"            %@", [videoSections objectAtIndex:indexPath.row]];

    //Se agrega vista seleccionada
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(217/255.0) green:(25/255.0) blue:(24/255.0) alpha:1];
    [cell setSelectedBackgroundView:bgColorView];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor colorWithRed:(254/255.0) green:(66/255.0) blue:(65/255.0) alpha:1];
    cell.textLabel.font = [UIFont fontWithName:@"Roboto-Light" size:16];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self setSelectedSection:(int)indexPath.row withSlugCollection:videoSectionsSlug withTitleCollection:videoSections];

}

- (void) collapsableTableView:(CollapsableTableView *)tableView didUnselectSection:(NSInteger)sectionIndex title:(NSString *)sectionTitle headerView:(UIView *)headerView {

    headerView.backgroundColor = [UIColor colorWithRed:(254/255.0) green:(66/255.0) blue:(65/255.0) alpha:1];

}

- (void) collapsableTableView:(CollapsableTableView *)tableView didSelectSection:(NSInteger)sectionIndex title:(NSString *)sectionTitle headerView:(UIView *)headerView {

    headerView.backgroundColor = [UIColor colorWithRed:(217/255.0) green:(25/255.0) blue:(24/255.0) alpha:1];

    [self collapseSection:tableView];

    if (sectionIndex < [sectionsSlug count] - 2) {
        [self setSelectedSection:(int)sectionIndex withSlugCollection:sectionsSlug withTitleCollection:sectionsTitle];
        return;
    }

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    UIViewController *vc;
    if (sectionIndex == [sectionsSlug count] - 1 || sectionIndex == [sectionsSlug count] - 2) {
        NSString *viewID = sectionIndex == [sectionsSlug count] - 1 ? [NSString stringWithFormat:NSLocalizedString(@"acercaViewID", nil)] :
                            @"TSConfigurationTableViewController";
        vc = [mainStoryboard instantiateViewControllerWithIdentifier: viewID];
    }
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];
    TSClipListadoHomeMenuTableVC *view = [self getVideoHomeView];
    if(view) {
        [view sectionSelected:[sectionsSlug objectAtIndex:sectionIndex] withTitle:[sectionsTitle objectAtIndex:sectionIndex]];
    }
}

#pragma mark -
#pragma mark CollapsableTableViewDelegate

- (void) collapsableTableView:(CollapsableTableView*) tableView willCollapseSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
    headerView.backgroundColor = [UIColor colorWithRed:(254/255.0) green:(66/255.0) blue:(65/255.0) alpha:1];
    [spinner startAnimating];
}

- (void) collapsableTableView:(CollapsableTableView*) tableView didCollapseSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
    [spinner stopAnimating];
}

- (void) collapsableTableView:(CollapsableTableView*) tableView willExpandSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
    headerView.backgroundColor = [UIColor colorWithRed:(217/255.0) green:(25/255.0) blue:(24/255.0) alpha:1];
    [spinner startAnimating];
}

- (void) collapsableTableView:(CollapsableTableView*) tableView didExpandSection:(NSInteger) section title:(NSString*) sectionTitle headerView:(UIView*) headerView
{
    [spinner stopAnimating];
}

@end