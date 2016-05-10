//
//  TSUtils.m
//  teleSUR
//
//  Created by Simkin on 14/03/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import "TSUtils.h"

@implementation TSUtils

+ (UIColor *) colorRedNavigationBar {
    return [UIColor colorWithRed:(200/255.0) green:(5/255.0) blue:(37/255.0) alpha:1];
}

+ (UIColor *) colorRedLeftMenu {
    return [UIColor colorWithRed:(233/255.0) green:(49/255.0) blue:(49/255.0) alpha:1];
}

+ (UIColor *) colorShowPink {
    return [UIColor colorWithRed:(204/255.0) green:(153/255.0) blue:(204/255.0) alpha:1];
}

+ (UIColor *) colorShowBlue {
    return [UIColor colorWithRed:(102/255.0) green:(153/255.0) blue:(255/255.0) alpha:1];
}

+ (UIColor *) colorShowYellow {
    return [UIColor colorWithRed:(204/255.0) green:(153/255.0) blue:(51/255.0) alpha:1];
}

+ (NSInteger) TS2_ITEMS_PER_PAGE {
    return 15;
}

+ (NSInteger) TS2_HOME_CLIPS_PER_PAGE {
    return 10;
}

+ (NSString *) TS2_TIPO_CLIP_SLUG {
    return @"tipo_clip";
}

+ (NSString *) TS2_CLIP_SLUG {
    return @"clip";
}

+ (NSString *) TS2_PROGRAMA_SLUG {
    return @"programa";
}

+ (NSString *) TS2_NOTICIAS_SLUG {
    return @"noticias-texto";
}

@end