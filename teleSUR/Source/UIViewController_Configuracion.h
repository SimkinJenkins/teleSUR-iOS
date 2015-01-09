//
//  UIViewController_Configuracion.h
//  teleSUR
//
//  Created by Hector Zarate on 2/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (UIViewController_Configuracion)

- (void) presentarVideoEnVivo;
- (void) launchLiveAudio;
- (void) stopLiveAudio;

- (CGSize) frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end