//
//  TSNewsViewController.m
//  teleSUR
//
//  Created by Simkin on 21/08/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSNewsViewController.h"
#import "MWFeedItem.h"
#import "UIImageView+WebCache.h"
#import "NSString+HTML.h"

#import "TSWebViewController.h"

@implementation TSNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initWithData:(MWFeedItem *)post {
    currentPost = post;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    UIImageView *thumbnailImageView = (UIImageView *)[self.view viewWithTag:100];
    thumbnailImageView.frame = CGRectMake(0, 0, thumbnailImageView.frame.size.width, thumbnailImageView.frame.size.height);

    UILabel *section = [[UILabel alloc] initWithFrame:CGRectMake(10, thumbnailImageView.frame.size.height - 30, 300, 100)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, section.frame.origin.y + 60, 300, 150)];
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(10, title.frame.origin.y + 60, 300, 1000)];

    title.lineBreakMode = NSLineBreakByWordWrapping;
    title.numberOfLines = 0;

    desc.lineBreakMode = NSLineBreakByWordWrapping;
    desc.numberOfLines = 0;

    //Setear fuentes custom
    title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    section.font = [UIFont fontWithName:@"Roboto-BoldCondensed" size:8];//2e2e2e
    desc.font = [UIFont fontWithName:@"Roboto-Regular" size:15];//black

    NSString *author = currentPost.author;
    if(([currentPost.category isEqualToString:@"Opinion"] || [currentPost.category isEqualToString:@"Blog"]) && ![author isEqualToString:@""] && [author rangeOfString:@"teleSUR"].location == NSNotFound) {
        section.text = [author uppercaseString];
    } else {
        if( [currentPost.category isEqualToString:@"Blog"]) {
            section.hidden = YES;
        }
        section.text = [currentPost.category uppercaseString];
    }

    title.text = currentPost.title;
    desc.text = [currentPost.summary stringByConvertingHTMLToPlainText];

    if ( desc.text.length > 500 ) {
        desc.text = [NSString stringWithFormat:@"%@...", [desc.text substringToIndex:500] ];
    }

    //Tamaños y posiciones
    CGRect screenBound = [[UIScreen mainScreen] bounds];

    [title sizeToFit];

    desc.frame = CGRectMake(10, title.frame.origin.y + title.frame.size.height + 15, desc.frame.size.width, desc.frame.size.height);

    [desc sizeToFit];

    NSLog(@"%@ -> %@", NSStringFromCGRect(desc.frame), desc.text);
    webViewYPos = (desc.frame.origin.y + desc.frame.size.height + 10);

    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -2, screenBound.size.width, screenBound.size.height - 60)];

    scroll.tag = 1000;

    [scroll addSubview:section];
    [scroll addSubview:title];
    [scroll addSubview:desc];
    [scroll addSubview:thumbnailImageView];
    [scroll addSubview:[self getWebViewer]];

    [self.view addSubview:scroll];

    [self configLeftButton];
    [self configRightButton];
}

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [(UIImageView *)[self.view viewWithTag:100] sd_setImageWithURL:[[currentPost.enclosures objectAtIndex:0] valueForKey:@"url"]
                                                  placeholderImage:[UIImage imageNamed:@"SinImagen.png"]];

}













- (void) configLeftButton {

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 23, 23);
    [button setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];

    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];

}

- (void) configRightButton {

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"share.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(shareButtonClicked)];

}

- (void) shareButtonClicked {

    [self shareText:currentPost.title andImage:((UIImageView *)[self.view viewWithTag:100]).image andUrl:[ NSURL URLWithString:currentPost.link ]];

}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url {

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

- (UIWebView *) getWebViewer {

    UIWebView *wv = [[UIWebView alloc] init];
    wv.delegate = self;

    NSString *URLBase = [[currentPost.enclosures objectAtIndex:0] valueForKey:@"url"];
    URLBase = [URLBase substringWithRange:NSMakeRange(0, [URLBase rangeOfString:@"/sites"].location)];

    if ( currentPost.rawContent != nil && ![currentPost.rawContent isEqualToString:@""] ) {
        parsedHTML = [currentPost.rawContent stringByReplacingOccurrencesOfString:@"/export" withString:URLBase];
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
        NSRegularExpression *imgRegex = [NSRegularExpression regularExpressionWithPattern:@"<img " options:NSRegularExpressionCaseInsensitive error:nil];
        NSRegularExpression *widthRegex = [NSRegularExpression regularExpressionWithPattern:@"width=\"\\d*\"" options:NSRegularExpressionCaseInsensitive error:nil];
        NSRegularExpression *heightRegex = [NSRegularExpression regularExpressionWithPattern:@"height=\"\\d*\"" options:NSRegularExpressionCaseInsensitive error:nil];
        NSRegularExpression *hspaceRegex = [NSRegularExpression regularExpressionWithPattern:@"hspace=\"\\d*\"" options:NSRegularExpressionCaseInsensitive error:nil];
        NSRegularExpression *vspaceRegex = [NSRegularExpression regularExpressionWithPattern:@"vspace=\"\\d*\"" options:NSRegularExpressionCaseInsensitive error:nil];
        parsedHTML = [widthRegex stringByReplacingMatchesInString:parsedHTML options:0 range:NSMakeRange(0, parsedHTML.length) withTemplate:@"width=\"303\""];
        parsedHTML = [heightRegex stringByReplacingMatchesInString:parsedHTML options:0 range:NSMakeRange(0, parsedHTML.length) withTemplate:@"height=\"auto\""];
        parsedHTML = [hspaceRegex stringByReplacingMatchesInString:parsedHTML options:0 range:NSMakeRange(0, parsedHTML.length) withTemplate:@""];
        parsedHTML = [vspaceRegex stringByReplacingMatchesInString:parsedHTML options:0 range:NSMakeRange(0, parsedHTML.length) withTemplate:@""];
        parsedHTML = [imgRegex stringByReplacingMatchesInString:parsedHTML options:0 range:NSMakeRange(0, parsedHTML.length) withTemplate:@"<img width=\"303\" "];
    } else {
        parsedHTML = @"";
    }

    [wv loadHTMLString:parsedHTML baseURL:nil];

    return wv;

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

    CGRect screenBound = [[UIScreen mainScreen] bounds];

    webView.frame = CGRectMake(0, webViewYPos, screenBound.size.width, webView.scrollView.contentSize.height);

    if(webView.scrollView.contentSize.height == 0 && webView.scrollView.contentSize.width == 0) {
        [webView loadHTMLString:parsedHTML baseURL:nil];
        return;
    }

    UIScrollView *scroll = (UIScrollView *)[self.view viewWithTag:1000];
    scroll.contentSize = CGSizeMake(screenBound.size.width, webView.frame.origin.y + webView.frame.size.height + 10);

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
/*
    NSLog(@"%ld ----> %@ - %ld - %ld - %ld - %ld - %ld - %ld", navigationType, request.URL, (long)UIWebViewNavigationTypeLinkClicked, (long)UIWebViewNavigationTypeFormSubmitted, (long)UIWebViewNavigationTypeBackForward, (long)UIWebViewNavigationTypeFormResubmitted, (long)UIWebViewNavigationTypeFormResubmitted, (long)UIWebViewNavigationTypeOther);
*/
    if(navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted || (navigationType == UIWebViewNavigationTypeOther && [[request.URL absoluteString] rangeOfString:@"twitter"].length != 0)) {
        if(navigationType == UIWebViewNavigationTypeLinkClicked && [[request.URL absoluteString] rangeOfString:@"www.telesurtv.net"].length != 0) {
            /*aqui se manda la liga*/
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                                     bundle: nil];
            
            TSWebViewController *webView = [mainStoryboard instantiateViewControllerWithIdentifier: @"TSWebViewController"];
            webView = [webView initWithURL:request.URL];

            [self.navigationController pushViewController:webView animated:YES];

        }
        return NO;
    }
    return YES;
}

@end
