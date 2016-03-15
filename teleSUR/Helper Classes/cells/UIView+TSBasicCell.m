//
//  UIView+TSBasicCell.m
//  teleSUR
//
//  Created by Simkin on 23/09/14.
//  Copyright (c) 2014 teleSUR. All rights reserved.
//

#import "UIView+TSBasicCell.h"
#import "MWFeedItem.h"
#import "UILabelMarginSet.h"

@implementation UIView (TSBasicCell)

- (void) initializeCell {

    UILabelMarginSet *title = (UILabelMarginSet *)[self viewWithTag: [self getTitleLabelTag]];
    UILabelMarginSet *seccionLabel = (UILabelMarginSet *)[self viewWithTag: [self getSectionLabelTag]];

    title.font = [self getTitleFont];
    seccionLabel.font = [UIFont fontWithName:@"Roboto-BoldCondensedItalic" size:9];

}
















- (void) setData:(NSDictionary *)data {

    BOOL isRSS = [data isKindOfClass:[MWFeedItem class]];
    NSString *clipType = isRSS ? nil : [[data valueForKey:@"tipo"] valueForKey:@"slug"];

    if ( !isRSS && clipType == (NSString *)[NSNull null] ) {
        return;
    }

    UILabel *title = (UILabel *)[self viewWithTag:[self getTitleLabelTag]];
    UILabel *section = (UILabel *)[self viewWithTag:[self getSectionLabelTag]];

    if ( isRSS ) {

        [self setDataForRSSItem:( MWFeedItem * )data forTitle:title andSection:section];
        [self fitSizesForRSSItemTitle:title andSection:section];

    } else if ( [clipType isEqualToString:@"programa"] ) {

        [self setDataForShowItem:data forTitle:title andSection:section];
        [self fitSizesForShowItemTitle:title andSection:section];

    } else if ( clipType && [clipType isEqualToString:@"infografia"] ) {

        [self setDataForInfographItem:data forTitle:title andSection:section];
        [self fitSizesForInfographItemTitle:title andSection:section];

    } else {

        [self setDataForVideoItem:data forTitle:title andSection:section withType:clipType];
        [self fitSizesForVideoItemTitle:title andSection:section];

    }

}






- (void) setDataForVideoItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section withType:(NSString *)clipType {
    section.hidden = NO;
    BOOL switchTitles = [clipType isEqualToString:@"programa"];
    NSObject *category = [data valueForKey:@"categoria"];
    title.text = switchTitles ? @"" : [data valueForKey:@"titulo"];
    if(category != [NSNull null]) {
        section.text = [[category valueForKey:@"nombre"] uppercaseString];
    } else if(switchTitles) {
        section.text = [[data valueForKey:@"titulo"] uppercaseString];
    } else if(clipType) {
        section.text = [[[data valueForKey:@"tipo"] valueForKey:@"nombre"] uppercaseString];
    } else {
        section.text = @"";
    }
}

- (void) fitSizesForVideoItemTitle:(UILabel *)title andSection:(UILabel *)section {

    [self sizeToFitRedBackgroundLabel:(UILabelMarginSet *)section];

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(150, 70)];

    [self setVideoIcon];

}

- (void) setDataForShowItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section {

    if ( [data valueForKey:@"programa"] == (NSString *)[NSNull null] ) {
        section.text = [data valueForKey:@"titulo"];
    } else {
        section.text = [[[data valueForKey:@"programa"] valueForKey:@"nombre"] uppercaseString];
    }

    if ( title ) {
        title.text = [self getLongFormatDateFromData:data];
    }

}

- (void) fitSizesForShowItemTitle:(UILabel *)title andSection:(UILabel *)section {

    [self fitSizesForVideoItemTitle:title andSection:section];

}

- (void) setDataForRSSItem:(MWFeedItem *)data forTitle:(UILabel *)title andSection:(UILabel *)section {

    section.hidden = NO;
    
    title.text = data.title;

    NSString *author = ((MWFeedItem *)data).author;

    if(([data.category isEqualToString:@"Opinion"] || [data.category isEqualToString:@"Blog"]) && ![author isEqualToString:@""] && [author rangeOfString:@"teleSUR"].location == NSNotFound) {
        
        section.text = [author uppercaseString];
        
    } else {
        if( [data.category isEqualToString:@"Blog"]) {
            section.hidden = YES;
        } else {
            section.text = [data.category uppercaseString];
        }
    }
}

- (void) fitSizesForRSSItemTitle:(UILabel *)title andSection:(UILabel *)section {

    [self adjustSizeFrameForLabel:title constriainedToSize:CGSizeMake(147, 70)];

}

- (void) setDataForInfographItem:(NSDictionary *)data forTitle:(UILabel *)title andSection:(UILabel *)section {

    section.hidden = YES;
    title.font = [UIFont fontWithName:@"Roboto-Bold" size:14];

    title.frame = CGRectMake(title.frame.origin.x, title.frame.origin.y, 150, 50);

    title.text = [data valueForKey:@"titulo"];

}

- (void) fitSizesForInfographItemTitle:(UILabel *)title andSection:(UILabel *)section {

    [self setVideoIcon];

}




















- (void) setVideoIcon {

    UIImageView *iv = (UIImageView *)[self viewWithTag:2829];

    if ( !iv ) {
        UIImage *liveBulletImage = [UIImage imageNamed:@"icon-video.png"];
        iv = [[UIImageView alloc] initWithFrame:[self getVideoIconRect]];

        iv.tag = 2829;
        iv.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        iv.layer.shadowOffset = CGSizeMake(0, 1);
        iv.layer.shadowOpacity = 0.6;
        iv.layer.shadowRadius = 1.0;

        [iv setImage:liveBulletImage];
        [self addSubview:iv];
    } else {
        iv.hidden = NO;
        iv.frame = [self getVideoIconRect];
    }

}

- (CGRect) getVideoIconRect {

    return CGRectMake(60, 20, 45, 45);

}









- (void) configRedBackgroundSectionLabel {
    UILabelMarginSet *section = (UILabelMarginSet *)[self viewWithTag:[self getSectionLabelTag]];
    section.font = [UIFont fontWithName:@"Roboto-Black" size:8];
    section.leftMargin = 5;
    [section setPersistentBackgroundColor:[UIColor colorWithRed:255/255.0 green:2/255.0 blue:2/255.0 alpha:1.0]];
}

- (void) sizeToFitRedBackgroundLabel:(UILabelMarginSet *)section {
    CGSize sectionSize = [self frameForText:section.text sizeWithFont:section.font constrainedToSize:CGSizeMake(150, 20) lineBreakMode:NSLineBreakByWordWrapping];
    [section setFrame:CGRectMake(section.frame.origin.x, section.frame.origin.y, sectionSize.width + 11, sectionSize.height + 6)];
}

- (UIFont *) getTitleFont {
    return [UIFont fontWithName:@"Roboto-Light" size:14];
}

- (NSInteger) getTitleLabelTag {
    return 1;
}

- (NSInteger) getSectionLabelTag {
    return 3;
}












- (void) adjustSizeFrameForLabel:(UILabel *)label constriainedToSize:(CGSize)size {
    CGSize labelSize = [self frameForText:label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    [label setFrame:CGRectMake(label.frame.origin.x, label.frame.origin.y, labelSize.width, labelSize.height)];
}

-(CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSDictionary * attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
    CGRect textRect = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return textRect.size;
}

- (void) setLabel:(UILabel *)label atBottomsView:(UIView *)view withSeparation:(CGFloat)indent {

//    [label sizeToFit];
    label.frame = CGRectMake(label.frame.origin.x, view.frame.size.height - (label.frame.size.height + indent), label.frame.size.width, label.frame.size.height);

}

- (void) alignLabel:(UILabel *)label atTopsView:(UIView *)view withSeparation:(CGFloat)indent {

//    [label sizeToFit];
    label.frame = CGRectMake(label.frame.origin.x, view.frame.origin.y + indent, label.frame.size.width, label.frame.size.height);

}

- (void) setLabel:(UILabel *)label aboveView:(UIView *)view withSeparation:(CGFloat)indent {

//    [label sizeToFit];
    label.frame = CGRectMake(label.frame.origin.x, view.frame.origin.y - (label.frame.size.height + indent), label.frame.size.width, label.frame.size.height);

}

- (void) setLabel:(UILabel *)label underView:(UIView *)view withSeparation:(CGFloat)indent {

//    [label sizeToFit];
    label.frame = CGRectMake(label.frame.origin.x, (view.frame.origin.y + view.frame.size.height) + indent, label.frame.size.width, label.frame.size.height);
    
}

- (NSString *) getLongFormatDateFromData:(NSDictionary *)data {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];

    NSString *localeID = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"localeID"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:localeID]];

    return [formatter stringFromDate:[self getNSDateParaFromData:data]];

}

- (NSString *) getLongFormatDateFromRSS:(MWFeedItem *)data {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];

    NSString *localeID = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuración"] objectForKey:@"localeID"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:localeID]];

    return [formatter stringFromDate:data.date];
    
}

// Devuelve NSDate con la fecha de este item,
// que se espera tenga el formato: yyyy-MM-dd HH:mm:ss
- (NSDate *) getNSDateParaFromData:(NSDictionary *)data {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"es_MX"];

    [formatter setLocale:locale];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    return [formatter dateFromString:[NSString stringWithFormat:@"%@", [data valueForKey:@"fecha"]]];

}

@end
