//
//  TSUtils.h
//  teleSUR
//
//  Created by Simkin on 14/03/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSUtils : NSObject

+ (UIColor *) colorRedNavigationBar;
+ (UIColor *) colorRedLeftMenu;

+ (UIColor *) colorShowPink;
+ (UIColor *) colorShowBlue;
+ (UIColor *) colorShowYellow;

+ (NSInteger) TS2_ITEMS_PER_PAGE;
+ (NSInteger) TS2_HOME_CLIPS_PER_PAGE;
+ (NSString *) TS2_TIPO_CLIP_SLUG;
+ (NSString *) TS2_CLIP_SLUG;
+ (NSString *) TS2_PROGRAMA_SLUG;
+ (NSString *) TS2_NOTICIAS_SLUG;

@end