//
//  TSIPadRSSDetailViewController.m
//  teleSUR
//
//  Created by Simkin on 24/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSIPadRSSDetailViewController.h"
#import "MWFeedItem.h"
#import "EasyTableView.h"
#import "UILabelMarginSet.h"
#import "UIViewController_Configuracion.h"
#import "DefaultIPadTableViewCell.h"
#import "UIImageView+WebCache.h"

#import "TSDataManager.h"
#import "TSDataRequest.h"
#import "MWFeedItem.h"
#import "TSWebViewController.h"
#import "TSIpadNavigationViewController.h"
#import "NSString+HTML.h"

NSInteger const TS_DETAIL_VIEW_TAG = 150;

NSInteger const DETAIL_VIEW_WIDTH = 765;
NSInteger const DETAIL_VIEW_HEIGHT = 635;
NSInteger const SIDE_MARGIN = 20;

@implementation TSIPadRSSDetailViewController

#pragma mark - ViewController initialize

- (id) initWithRSSData:(MWFeedItem *)data inSection:(NSString *)section andSubsection:(NSString *)subsection {

    currentItem = data;
    self = [ self initWithSection:section andSubsection:subsection];
    isAnInitialScreen = NO;

    [self configLeftButton];
    [self configRightButton];

    return self;

}

- (id) initWithSection:(NSString *)section andSubsection:(NSString *)subsection {

    isAnInitialScreen = YES;
    currentSection = section;
    currentSubsection = subsection;

    [self configRightButton];

    return self;
}



















#pragma mark - View lifecycle

- (void)viewDidLoad {

    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self setupRSSView];

    if ( currentItem ) {
        [self setupCurrentRSSData];
    }

}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    ((TSIpadNavigationViewController *)self.navigationController).headerTxf.hidden = NO;

    if ( isAnInitialScreen ) {
        ((TSIpadNavigationViewController *)self.navigationController).leftMenuVw.hidden = NO;
    }

    if ( webViewActive ) {

        [(TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance setNavigationItemsHidden:NO];

    }

}

- (void) viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];

}



















- (void)showSelectedPost:(MWFeedItem *)post {
    
    [self showPost:post inSection:@"noticias" andSubsection:[self getNotificationSubsection]];
    
}

- (void) showPost:(MWFeedItem *)item inSection:(NSString *)section andSubsection:(NSString *)subsection {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle: nil];
    
    TSIPadRSSDetailViewController *vc = [[mainStoryboard instantiateViewControllerWithIdentifier:@"TSIPadRSSDetailViewController"]
                                         initWithRSSData:item inSection:section andSubsection:subsection];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}



















#pragma mark - Acciones

- (void)setupRelatedRSSTableView {

    BOOL isLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);

    if (relatedRSSTableView) {
        relatedRSSTableView.numberOfCells = [tableElements count];
        [relatedRSSTableView reloadData];
        [relatedRSSTableView.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        currentItem = nil;
        return;
    }

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frameRect	= !isLandscape ? CGRectMake(0, DETAIL_VIEW_HEIGHT + 11, screenRect.size.width, 250)
                                    : CGRectMake(DETAIL_VIEW_WIDTH + 11, 0, screenRect.size.width - DETAIL_VIEW_WIDTH - 10, 638);

    relatedRSSTableView = isLandscape ? [[EasyTableView alloc] initWithFrame:frameRect
                                                                numberOfRows:[tableElements count]
                                                                    ofHeight:(screenRect.size.width - DETAIL_VIEW_WIDTH) - 18]
                                    : [[EasyTableView alloc] initWithFrame:frameRect
                                                              numberOfColumns:[tableElements count]
                                                                   ofWidth:250];
    relatedRSSTableView.delegate						= self;
    relatedRSSTableView.tableView.layer.borderColor     = [UIColor darkGrayColor].CGColor;
    relatedRSSTableView.tableView.layer.borderWidth     = 1.0f;
    relatedRSSTableView.tableView.backgroundColor       = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    relatedRSSTableView.tableView.allowsSelection       = YES;
    relatedRSSTableView.tableView.separatorColor		= [UIColor clearColor];
    relatedRSSTableView.cellBackgroundColor             = [UIColor clearColor];
    [self.view addSubview:relatedRSSTableView];

}

- (void) setupRSSView {

    UIImageView *image = (UIImageView *)[self.view viewWithTag:TS_DETAIL_ASYNC_IMAGE_TAG];
    image.frame = CGRectMake(SIDE_MARGIN, 25, DETAIL_VIEW_WIDTH - (SIDE_MARGIN * 3), (DETAIL_VIEW_WIDTH - (SIDE_MARGIN * 2)) * .66);

    UILabelMarginSet *sectionLabel = (UILabelMarginSet *)[self.view viewWithTag:107];
    [sectionLabel setPersistentBackgroundColor:[UIColor colorWithRed:255/255.0 green:2/255.0 blue:2/255.0 alpha:1.0]];

}

- (void) setupCurrentRSSData {

    UILabel *title = (UILabel *)[self.view viewWithTag:1001];
    UILabel *dateLabel = (UILabel *)[self.view viewWithTag:102];
    UILabel *desc = (UILabel *)[self.view viewWithTag:1004];
//    UIButton *shareButton = (UIButton *)[self.view viewWithTag:105];
    UILabelMarginSet *section = (UILabelMarginSet *)[self.view viewWithTag:107];
    UIImageView *image = (UIImageView *)[self.view viewWithTag:TS_DETAIL_ASYNC_IMAGE_TAG];

    //Setear fuentes custom
    section.leftMargin = 10;
    section.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:11];//2e2e2e
    dateLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:16];//696969
    desc.font = [UIFont fontWithName:@"Roboto-Ligth" size:15];//black

    //Reset sizes
    section.frame = CGRectMake(SIDE_MARGIN, SIDE_MARGIN, 300, 50);
    title.frame = CGRectMake(SIDE_MARGIN, title.frame.origin.y, DETAIL_VIEW_WIDTH - (SIDE_MARGIN * 3), 1000);
    desc.frame = CGRectMake(SIDE_MARGIN, desc.frame.origin.y, DETAIL_VIEW_WIDTH - (SIDE_MARGIN * 3), 1000);

    NSString *author = currentItem.author;
    if(([currentItem.category isEqualToString:@"Opinion"] || [currentItem.category isEqualToString:@"Blog"]) && ![author isEqualToString:@""] && [author rangeOfString:@"teleSUR"].location == NSNotFound) {
        section.text = [author uppercaseString];
    } else {
        if( [currentItem.category isEqualToString:@"Blog"]) {
            section.hidden = YES;
        }
        section.text = [currentItem.category uppercaseString];
    }

    [section sizeToFit];
    section.frame = CGRectMake(section.frame.origin.x, section.frame.origin.y, section.frame.size.width + 20, section.frame.size.height + 10);

    title.text = currentItem.title;

    desc.text = currentItem.summary != nil ? [currentItem.summary stringByConvertingHTMLToPlainText] : @"";

    if ( desc.text.length > 500 ) {
        desc.text = [NSString stringWithFormat:@"%@...", [desc.text substringToIndex:500] ];
    }

    [title sizeToFit];
    title.frame = CGRectMake(title.frame.origin.x, section.frame.origin.y + section.frame.size.height + 2, title.frame.size.width + 10, title.frame.size.height);

    image.frame = CGRectMake(SIDE_MARGIN, title.frame.origin.y + title.frame.size.height + 15, image.frame.size.width, image.frame.size.height);

    CGSize descSize = [self frameForText:desc.text sizeWithFont:desc.font constrainedToSize:CGSizeMake(desc.frame.size.width, 100000) lineBreakMode:NSLineBreakByWordWrapping];
    desc.frame = CGRectMake(desc.frame.origin.x, image.frame.origin.y + image.frame.size.height + 16, descSize.width, descSize.height);

    [(UIImageView *)[self.view viewWithTag:TS_DETAIL_ASYNC_IMAGE_TAG] sd_setImageWithURL:[self getThumbURLFromMWFeedItem:currentItem
                                                                                                          forceLargeImage:YES]
                                                                        placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];

    webViewYPos = (desc.frame.origin.y + desc.frame.size.height + 10);

    UIScrollView *scroll;
    if ( ![self.view viewWithTag:1000] ) {
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(11, 0, DETAIL_VIEW_WIDTH,
                                                    UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])
                                                    ? 638 : DETAIL_VIEW_HEIGHT)];
        scroll.tag = 1000;
        [scroll addSubview:section];
        [scroll addSubview:title];
        [scroll addSubview:desc];
        [scroll addSubview:[self getWebViewer]];
        [scroll addSubview:[self.view viewWithTag:TS_DETAIL_ASYNC_IMAGE_TAG]];

        [self.view addSubview:scroll];
    } else {
        scroll = (UIScrollView *)[self.view viewWithTag:1000];
        [scroll scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        [scroll addSubview:[self getWebViewer]];
    }

}

- (UIWebView *) getWebViewer {

    UIWebView *wv;

    if ( ![self.view viewWithTag:1000] && ![[self.view viewWithTag:1000] viewWithTag:1100] ) {
        wv = [[UIWebView alloc] init];
        wv.tag = 1100;
        wv.delegate = self;
    } else {
        wv = (UIWebView *)[[self.view viewWithTag:1000] viewWithTag:1100];
        CGRect frame = wv.frame;
        frame.size.height = 5.0f;
        wv.frame = frame;

    }

    if ( [currentItem.rawContent isEqualToString:@""] ) {
        return wv;
    }

    NSString *URLBase = [[currentItem.enclosures objectAtIndex:0] valueForKey:@"url"];
    URLBase = [URLBase substringWithRange:NSMakeRange(0, [URLBase rangeOfString:@"/sites"].location)];

    parsedHTML = [currentItem.rawContent stringByReplacingOccurrencesOfString:@"/export" withString:URLBase];
    parsedHTML = [parsedHTML stringByReplacingOccurrencesOfString:@"//www.youtube.com" withString:@"http://www.youtube.com"];
    BOOL loadTweetWidget = [parsedHTML rangeOfString:@"twitter-tweet"].length != 0;
    NSString *loadWidgetStr = loadTweetWidget ? @"<script src=\"http://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>" : @"";
    parsedHTML = [ NSString stringWithFormat:@"%@%@", parsedHTML, loadWidgetStr ];
/*
     parsedHTML =
     @"<p style=\"text-align: justify;\">En el apogeo del <strong><a href=\"http://telesurtv.net/news/Suramerica-saluda-triunfo-deTabare-Vazquez-en-Uruguay-20141201-0051.html\"><span style=\"color:#0000CD;\">triunfo del presidente electo de Uruguay por el partido del Frente Amplio (FA) Tabar&eacute; V&aacute;zquez</span> </a></strong>con el 53,06 por ciento apoyo electoral y el 58 por ciento de mayor&iacute;a parlamentaria, har&aacute; frente a varios desaf&iacute;os en su segundo mandato.</p> <p style=\"text-align: justify;\">Por tanto, el analista pol&iacute;tico Pablo Alfano en una entrevista especial para teleSUR subray&oacute; que una de las primeras tareas a realizar se debe enfocar en la disminuci&oacute;n del seis por ciento de desempleo, mejorar los salarios que en principio ya se han palpado estos logros cuando en el Gobierno del presidente actual&nbsp;Jos&eacute; &ldquo;Pepe&rdquo; Mujica&nbsp;dignific&oacute; a la trabajadora dom&eacute;stica y el trabajador rural.</p> <div style=\"background:#eee;border:1px solid #ccc;padding:5px 10px;\"><strong>Lea:</strong> <strong><a href=\"http://telesurtv.net/news/Corte-Electoral-8857-de-participacion-en-comicios-uruguayos-20141130-0049.html\"><span style=\"color:#0000CD;\">&ldquo;Corte Electoral: 88,57% de participaci&oacute;n en comicios uruguayos&rdquo;</span></a></strong></div> <p style=\"text-align: justify;\">En este orden V&aacute;zquez anunci&oacute; que garantizar&aacute; el programa del FA que contempla el sector econ&oacute;mico para atender a discapacitados, adultos mayores, la primera infancia y llevar el presupuesto de la ense&ntilde;anza de 4,5 por ciento del Producto Interno Bruto (PIB) al seis por ciento.</p> <p style=\"text-align: justify;\">Todo esto frente al d&eacute;ficit fiscal que se ubic&oacute; en los niveles m&aacute;s altos en el mes de octubre con el 3,0 a 3,2 por ciento.</p> <p style=\"text-align: justify;\">Otro de los retos por lograr tienen que ver con la pol&iacute;tica exterior, en el que Alfano con oflato diplom&aacute;tico vislumbr&oacute; que independientemente de que se escoja una mujer o un hombre para mantener las relaciones internacionales, apunt&oacute; que Jos&eacute; &ldquo;Pepe&rdquo; Mujica jugar&aacute; un rol muy importante desde la bancada del FA que ser&aacute; determinante para avanzar en materia regional.</p> <div style=\"background:#eee;border:1px solid #ccc;padding:5px 10px;\"><strong>Lea:<a href=\"http://telesurtv.net/news/Tabare-Vazquez-anuciara-su-gabinete-esta-semana-20141201-0004.html\"><span style=\"color:#0000CD;\"> &ldquo;Tabar&eacute; V&aacute;zquez anuciar&aacute; su gabinete esta semana&rdquo;</span></a></strong></div> <p style=\"text-align: justify;\">Sobre la oposici&oacute;n uruguaya V&aacute;zquez se mostr&oacute; dispuesto a un di&aacute;logo para tratar todos los &aacute;mbitos de la sociedad.</p> <p style=\"text-align: justify;\"><strong>Vea: &ldquo;Tabar&eacute; V&aacute;zquez llama a trabajar por Uruguay&rdquo;</strong></p> <p style=\"text-align: justify;\"><iframe allowfullscreen=\"\" frameborder=\"0\" height=\"200\" src=\"http://www.youtube.com/embed/BWk8Ig8DC08\" width=\"290\"></iframe></p> <p style=\"text-align: justify;\">&nbsp;</p>"
     
     "<p><img alt=\"\" height=\"395\" hspace=\"5\" src=\"/export/sites/telesur/img/multimedia/2014/12/03/seminario.jpg_2118332220.jpg\" vspace=\"5\" width=\"700\" /></p>"
     "<blockquote class=\"twitter-tweet\"><p>wie wohl sowas aufgezeichnet wird, mitten am tag <a href=\"http://t.co/JKJJCLRE\" title=\"http://youtu.be/LuDN2bCIyus\">youtu.be/LuDN2bCIyus</a></p>&mdash; Philipp Sauber (@psauber) <a href=\"https://twitter.com/psauber/status/222430318941061121\" data-datetime=\"2012-07-09T20:41:35+00:00\">July 9, 2012</a></blockquote><script src=\"http://platform.twitter.com/widgets.js\" charset=\"utf-8\"></script>";
*/
    parsedHTML = [parsedHTML stringByReplacingOccurrencesOfString:@"/export" withString:URLBase];
/*
    NSRegularExpression *widthRegex = [NSRegularExpression regularExpressionWithPattern:@"width=\"\\d*\"" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression *heightRegex = [NSRegularExpression regularExpressionWithPattern:@"height=\"\\d*\"" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression *hspaceRegex = [NSRegularExpression regularExpressionWithPattern:@"hspace=\"\\d*\"" options:NSRegularExpressionCaseInsensitive error:nil];
    NSRegularExpression *vspaceRegex = [NSRegularExpression regularExpressionWithPattern:@"vspace=\"\\d*\"" options:NSRegularExpressionCaseInsensitive error:nil];
    parsedHTML = [widthRegex stringByReplacingMatchesInString:parsedHTML options:0 range:NSMakeRange(0, parsedHTML.length) withTemplate:@"width=\"450\""];
    parsedHTML = [heightRegex stringByReplacingMatchesInString:parsedHTML options:0 range:NSMakeRange(0, parsedHTML.length) withTemplate:@"height=\"auto\""];
    parsedHTML = [hspaceRegex stringByReplacingMatchesInString:parsedHTML options:0 range:NSMakeRange(0, parsedHTML.length) withTemplate:@""];
    parsedHTML = [vspaceRegex stringByReplacingMatchesInString:parsedHTML options:0 range:NSMakeRange(0, parsedHTML.length) withTemplate:@""];
*/
    [wv loadHTMLString:parsedHTML baseURL:nil];
    
    return wv;
    
}



















#pragma mark - Custom Functions

- (void) shareButtonClicked {

    [self shareText:currentItem.title andImage:((UIImageView *)[self.view viewWithTag:TS_DETAIL_ASYNC_IMAGE_TAG]).image andUrl:[ NSURL URLWithString:currentItem.link ]];
    
}

- (void) deviceOrientationDidChangeNotification:(NSNotification *)notification {

    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown) {
        return;
    }

    [relatedRSSTableView removeFromSuperview];
    relatedRSSTableView = nil;

    [self setupRelatedRSSTableView];

    if ( [self.view viewWithTag:1000] ) {
        [self.view viewWithTag:1000].frame = CGRectMake(11, 0, DETAIL_VIEW_WIDTH, UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? 638 : DETAIL_VIEW_HEIGHT);
    }

}



















#pragma mark -
#pragma mark EasyTableViewDelegate

- (UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect {

    UITableViewCell *cell = [self getReuseCell:easyTableView.tableView withID:@"RelatedRSSTableViewCell"];
    return cell.contentView;

}

- (void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath*)indexPath {

    MWFeedItem *data = [tableElements objectAtIndex:indexPath.row];

    [((DefaultIPadTableViewCell *)[view viewWithTag:99]) setData:(NSDictionary *)data];

    // Here we use the new provided setImageWithURL: method to load the web image
    [(UIImageView *)[view viewWithTag:101] sd_setImageWithURL:[self getThumbURLForIndex:indexPath
                                                                        forceLargeImage:NO
                                                                        forDefaultTable:YES]
                                             placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];

}

- (void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView {

    if ( indexPath.row != selectedIndexPath.row ) {
        selectedIndexPath = indexPath;
        currentItem = [tableElements objectAtIndex:indexPath.row];
        [self setupCurrentRSSData];
    }

}



















#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    if(webView.frame.size.height != 0) {
        return;
    }
    
    CGRect frame = webView.frame;
    frame.size.height = 5.0f;
    webView.frame = frame;
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {

    webView.frame = CGRectMake(11, webViewYPos, DETAIL_VIEW_WIDTH - 45, webView.scrollView.contentSize.height);

    if(webView.scrollView.contentSize.height == 0 && webView.scrollView.contentSize.width == 0) {
        [webView loadHTMLString:parsedHTML baseURL:nil];
        return;
    }

    UIScrollView *scroll = (UIScrollView *)[self.view viewWithTag:1000];
    scroll.contentSize = CGSizeMake(DETAIL_VIEW_WIDTH - 45, webView.frame.origin.y + webView.frame.size.height + 10);

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    /*
     NSLog(@"%ld ----> %@ - %ld - %ld - %ld - %ld - %ld - %ld", navigationType, request.URL, (long)UIWebViewNavigationTypeLinkClicked, (long)UIWebViewNavigationTypeFormSubmitted, (long)UIWebViewNavigationTypeBackForward, (long)UIWebViewNavigationTypeFormResubmitted, (long)UIWebViewNavigationTypeFormResubmitted, (long)UIWebViewNavigationTypeOther);
     */
    if(navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted || (navigationType == UIWebViewNavigationTypeOther && [[request.URL absoluteString] rangeOfString:@"twitter"].length != 0)) {
        if(navigationType == UIWebViewNavigationTypeLinkClicked && [[request.URL absoluteString] rangeOfString:@"www.telesurtv.net"].length != 0) {

            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                     bundle: nil];
            
            TSWebViewController *webView = [mainStoryboard instantiateViewControllerWithIdentifier: @"TSWebViewController"];
            webView = [webView initWithURL:request.URL];
            
            [self.navigationController pushViewController:webView animated:YES];

            [(TSIpadNavigationViewController *)[NavigationBarsManager sharedInstance].topNavigationInstance setNavigationItemsHidden:YES];

            webViewActive = YES;
        }
        return NO;
    }
    return YES;
}



















#pragma mark -
#pragma mark TSDataManagerDelegate

- (void)TSDataManager:(TSDataManager *)manager didProcessedRequests:(NSArray *)requests {

    [self elementsHidden:NO];

    [super TSDataManager:manager didProcessedRequests:requests];

    if ( [tableElements count] == 0 ) {
        return;
    }

    [self setupRelatedRSSTableView];

    if ( ! currentItem ) {
        currentItem = [tableElements objectAtIndex:0];
        [self setupCurrentRSSData];
    }

}





@end
