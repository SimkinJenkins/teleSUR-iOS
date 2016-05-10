//
//  TSiPhoneNavigationController.m
//  teleSUR
//
//  Created by Simkin on 23/03/16.
//  Copyright © 2016 teleSUR. All rights reserved.
//

#import "TSiPhoneNavigationController.h"

@implementation TSiPhoneNavigationController


- (void) configureMenu {
    //Configurar Menu Lateral
    [SlideNavigationController sharedInstance].panGestureSideOffset = 50;
    [SlideNavigationController sharedInstance].enableShadow = NO;
    ((LeftMenuViewController *)[SlideNavigationController sharedInstance].leftMenu).slideOutAnimationEnabled = NO;
    [SlideNavigationController sharedInstance].portraitSlideXOffset = 70;

    //Crear Header
    headerMenu = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 225, 25)];
    headerMenu.backgroundColor = [TSUtils colorRedNavigationBar];

    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nlogo-telesur-header.png"]];
    logo.frame = CGRectMake(75, 1, logo.frame.size.width, logo.frame.size.height);

    UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-menu-header.png"]];
    leftImage.frame = CGRectMake(0, 0, 21, 23);

    UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-menu-header.png"]];
    rightImage.frame = CGRectMake(0, 0, 13, 7);

    [headerMenu addSubview:logo];

    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar addSubview:headerMenu];

    //Crear Menu Superior
    textfield = [[UITextField alloc] initWithFrame: CGRectMake(0, 3, 225, 25)];
    textfield.font = [UIFont fontWithName:@"Helvetica-Bold" size:2];
    textfield.textColor = [UIColor whiteColor];
    textfield.textAlignment = NSTextAlignmentCenter;

    NSString *titleLocalizedID = @"homeSection";
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
}

- (void) setNavigationTitle:(NSString *)title {
    CGSize stringsize = [self frameForText:title
                              sizeWithFont:textfield.font
                         constrainedToSize:CGSizeMake(170, textfield.frame.size.height)
                             lineBreakMode:NSLineBreakByWordWrapping];
    textfield.text = title;
    float tfWidth = stringsize.width + 44;
    [textfield setFrame:CGRectMake((225 - tfWidth) * .5, 3, tfWidth, 35)];
    textfield.hidden = YES;
    self.navigationItem.title = title;
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