//
//  Keyboard.h
//  Keyboard
//
//  Created by wayne on 2016/12/14.
//  Copyright © 2016年 wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Keyboard : UIView
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) NSMutableArray *charsBtn;
@property (strong, nonatomic) UIButton *shiftButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *altButton;
@property (strong, nonatomic) UIButton *emojiButton;
@property (strong, nonatomic) UIButton *spaceButton;
@property (strong, nonatomic) UIButton *returnButton;
@end
