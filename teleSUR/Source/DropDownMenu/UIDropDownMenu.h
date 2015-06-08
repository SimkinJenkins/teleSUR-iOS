//
//  UIDropDownMenu.m
//  DropDownMenu
//
//  Created on 30/03/2012.
//  Updated by Add Image on 17/01/2013.
//  Copyright (c) 2013 Add Image
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

#import <UIKit/UIKit.h>

@protocol UIDropDownMenuDelegate <NSObject>
@optional

- (void) DropDownMenuDidChange:(NSString *)identifier :(NSString *)ReturnValue;
- (void) DropDownMenuWillAppear:(NSString *)identifier;

@end

@interface UIDropDownMenu : NSObject <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate> {

    // general objects
    UITableView *dropdownTable;
    UIView *parentView;
    UITapGestureRecognizer *singleTapGestureRecogniser;
    NSString *identifiername;
    
    
    //Object which the menu is attached to
    NSObject *targetObject;
    
    // possible object types
    UITextField *selectedTextField;
    UIButton *selectedButton;
    
    // arrays
    NSMutableArray *titleArray;
    NSMutableArray *valueArray;
    
    // styling variables
    BOOL ScaleToFitParent;
    int menuWidth;
    int rowHeight;
    UIColor *textColor;
    UIColor *backgroundColor;
    UIColor *selectedBackgroundColor;
    UIColor *borderColor;
    
    // value to return when clicked
    NSString *selectedValue;

    CGPoint menuIndent;
    CGRect menuPosition;

//    NSTextAlignment menuTextAlignment;
    
    id <UIDropDownMenuDelegate> delegate;
}


@property (strong, nonatomic) UITableView *dropdownTable;
@property (strong, nonatomic) UIView *parentView;
@property (strong, nonatomic) UITapGestureRecognizer *singleTapGestureRecogniser;
@property (strong, nonatomic) NSString *identifiername;
@property (strong, nonatomic) NSObject *targetObject;
@property (strong, nonatomic) UITextField *selectedTextField;
@property (strong, nonatomic) UIButton *selectedButton;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSMutableArray *valueArray;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@property (strong, nonatomic) UIColor *borderColor;

@property (strong, nonatomic) UIColor *separatorColor;

@property (nonatomic) BOOL ScaleToFitParent;
@property (nonatomic) int menuWidth;
@property (nonatomic) int rowHeight;
@property (strong, nonatomic) NSString *selectedValue;
@property (nonatomic) BOOL isOpen;

@property (nonatomic) int menuTextAlignment;
@property (nonatomic) UIFont *menuTextFont;
@property (nonatomic) CGPoint menuIndent;
@property (nonatomic) CGRect menuPosition;

@property (nonatomic) BOOL animationFromAbove;

@property (strong) id delegate;
@property (assign) id <UIDropDownMenuDelegate> DropDownMenuDelegate;



- (id) initWithIdentifier:(NSString *)identifier;
-(void)makeMenu:(NSObject *)targetObject targetView:(UIView *)tview;
-(void)selectedObjectClicked:(id)sender;
-(void)dismissMenu;
@end
