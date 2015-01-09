//
//  TSBasicCellView.m
//  teleSUR
//
//  Created by Simkin on 23/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "TSBasicCellView.h"

@implementation TSBasicCellView

- (void) setData:(NSDictionary *)data {
    
    BOOL isRSS = [data isKindOfClass:[MWFeedItem class]];
    
    if(isRSS) {
        NSLog(@"%@%@", ((MWFeedItem *)data).category, ((MWFeedItem *)data).author);
    }
    
    NSString *clipType = isRSS ? nil : [[data valueForKey:@"tipo"] valueForKey:@"slug"];
    BOOL switchTitles = isRSS ? NO : [clipType isEqualToString:@"programa"];
    
    // Elementos de celda
    UILabelMarginSet *tituloLabel = (UILabelMarginSet *)[self viewWithTag:1];
    UILabelMarginSet *seccionLabel = (UILabelMarginSet *)[self viewWithTag:3];
    
    seccionLabel.hidden = NO;
    
    // Establecer texto de etiquetas y arreglar tamaños.
    if(isRSS) {
        tituloLabel.text = ((MWFeedItem *)data).title;
    } else {
        tituloLabel.text = switchTitles ? @"" : [data valueForKey:@"titulo"];
    }
    [tituloLabel sizeToFit];
    NSObject *categoria = isRSS ? nil : [data valueForKey:@"categoria"];
    if(isRSS) {
        NSString *author = ((MWFeedItem *)data).author;
        if(([((MWFeedItem *)data).category isEqualToString:@"Opinion"] || [((MWFeedItem *)data).category isEqualToString:@"Blog"]) && ![author isEqualToString:@""] && [author rangeOfString:@"teleSUR"].location == NSNotFound) {
            seccionLabel.text = [author uppercaseString];
        } else {
            if( [((MWFeedItem *)data).category isEqualToString:@"Blog"]) {
                seccionLabel.hidden = YES;
            }
            seccionLabel.text = [((MWFeedItem *)data).category uppercaseString];
        }
    } else if(categoria != [NSNull null]) {
        seccionLabel.text = [[categoria valueForKey:@"nombre"] uppercaseString];
    } else if(switchTitles) {
        seccionLabel.text = [[data valueForKey:@"titulo"] uppercaseString];
    } else if(clipType) {
        seccionLabel.text = [[[data valueForKey:@"tipo"] valueForKey:@"nombre"] uppercaseString];
    } else {
        seccionLabel.text = @"";
    }
    
    [self setLabelSizeToFit];
    
    if(!isRSS) {
        [self setVideoIcon:seccionLabel.frame.origin.y];
    }
}

- (void) setLabelSizeToFit {    }

- (void) setVideoIcon:(CGFloat)height {
    
    UIImage *liveBulletImage = [UIImage imageNamed:@"icon-video.png"];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(60, 20, 45, 45)];
    
    iv.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    iv.layer.shadowOffset = CGSizeMake(0, 1);
    iv.layer.shadowOpacity = 0.6;
    iv.layer.shadowRadius = 1.0;
    
    [iv setImage:liveBulletImage];
    [self addSubview:iv];
    
}

-(CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
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
