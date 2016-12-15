//
//  Keyboard.m
//  Keyboard
//
//  Created by wayne on 2016/12/14.
//  Copyright © 2016年 wayne. All rights reserved.
//

#import "Keyboard.h"

@interface JSChar : UIButton

- (void)shift:(BOOL)shift;

- (void)updateChar:(nullable NSString *)chars;

- (void)updateChar:(nullable NSString *)chars shift:(BOOL)shift;

//- (void)addPopup;

@end

#define kChar @[@"q", @"w", @"e", @"r", @"t", @"y", @"u", @"i", @"o", @"p", @"a", @"s", @"d", @"f", @"g", @"h", @"j", @"k", @"l", @"z", @"x", @"c", @"v", @"b", @"n", @"m"]
#define kChar_shift @[ @"Q", @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P", @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L", @"Z", @"X", @"C", @"V", @"B", @"N", @"M"]
#define Symbols  @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", @"-", @"/", @":", @";", @"(", @")", @"$", @"&", @"@", @"\"", @".", @",", @"?", @"!", @"'"]
#define moreSymbols  @[@"[", @"]", @"{", @"}", @"#", @"%", @"^", @"*", @"+", @"=", @"_", @"\\", @"|", @"~", @"<", @">", @"€", @"£", @"¥", @"•", @".", @",", @"?", @"!", @"'"]

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                alpha:1.0]

#define kKBH         216
#define kBtnHeight   35
#define kBtnGap      5
#define kVerticalGap 19
#define kStartBtnX   kBtnGap / 2
#define kStartBtnY   15
#define kShiftWidth  35
#define kAltWidth    45
#define kSpaceWidth  130
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

enum {
    popupViewImageLeft = 0,
    popupViewImageInner,
    popupViewImageRight,
    PKNumberPadViewImageMax
};
@interface Keyboard ()

@property (assign, nonatomic) BOOL showSymbol;
@property (assign, nonatomic) BOOL showMoreSymbol;
@property (assign, nonatomic) BOOL shiftEnabled;

@end

@implementation Keyboard

- (instancetype) init {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGRect frame;
    if(UIDeviceOrientationIsLandscape(orientation))
        frame = CGRectMake(0, kScreenHeight - 162, kScreenWidth, 162);
    else
        frame = CGRectMake(0, kScreenHeight - kKBH, kScreenWidth, kKBH);
    
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Keyboard" owner:self options:nil];
        [[nib objectAtIndex:0] setFrame:frame];
        self = [nib objectAtIndex:0];
        [self loadFunctionalKeys];
        self.backgroundColor = UIColorFromRGB(0x202A39);
    }
    self.charsBtn = [NSMutableArray array];
    [self setupASCIICapableLayout:YES withArray:kChar];
    self.showSymbol = NO;
    self.showMoreSymbol = NO;
    self.shiftEnabled = NO;
    
    return self;
}

- (void) loadFunctionalKeys {
    //shift按钮
    self.shiftButton = [[UIButton alloc] initWithFrame:CGRectMake(kStartBtnX, kStartBtnY + 2 * (kBtnHeight + kVerticalGap), kShiftWidth, kBtnHeight)];
//    [self.shiftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.shiftButton setTitle:@"⇧" forState:UIControlStateNormal];
//    [self.shiftButton.layer setBorderWidth:1.0f];
    [self.shiftButton addTarget:self action:@selector(shiftPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.shiftButton];
    
    //回删按钮
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - kShiftWidth - kStartBtnX, kStartBtnY + 2 * (kBtnHeight + kVerticalGap), kShiftWidth, kBtnHeight)];
//    [self.deleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.deleteButton setTitle:@"<-" forState:UIControlStateNormal];
//    [self.deleteButton.layer setBorderWidth:1.0f];
    [self.deleteButton addTarget:self action:@selector(deletePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    
    //Alt按钮
    self.altButton = [[UIButton alloc] initWithFrame:CGRectMake(kStartBtnX, kStartBtnY + 3 * (kBtnHeight + kVerticalGap), kAltWidth, kBtnHeight)];
//    [self.altButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.altButton setTitle:@"123" forState:UIControlStateNormal];
    [self.altButton.titleLabel setFont:[UIFont fontWithName:@"GurmukhiMN" size:18]];
//    [self.altButton.layer setBorderWidth:1.0f];
    [self.altButton addTarget:self action:@selector(altPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.altButton];
    
    //emoji按钮
    self.emojiButton = [[UIButton alloc] initWithFrame:CGRectMake(kStartBtnX + kBtnGap + kAltWidth, kStartBtnY + 3 * (kBtnHeight + kVerticalGap), kAltWidth, kBtnHeight)];
//    [self.emojiButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.emojiButton setTitle:@"😀" forState:UIControlStateNormal];
//    [self.emojiButton.layer setBorderWidth:1.0f];
    [self.emojiButton addTarget:self action:@selector(emojiPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.emojiButton];
    
    //Space按钮
    self.spaceButton = [[UIButton alloc] initWithFrame:CGRectMake(kStartBtnX + (kBtnGap + kAltWidth) * 2, kStartBtnY + 3 * (kBtnHeight + kVerticalGap), kSpaceWidth, kBtnHeight)];
    [self.spaceButton setTitleColor:UIColorFromRGB(0x202A39) forState:UIControlStateNormal];
    [self.spaceButton setBackgroundColor:[UIColor whiteColor]];
    [self.spaceButton setTitle:@"Space" forState:UIControlStateNormal];
    [self.spaceButton.titleLabel setFont:[UIFont fontWithName:@"GurmukhiMN" size:18]];
//    [self.spaceButton.layer setBorderWidth:1.0f];
    [self.spaceButton addTarget:self action:@selector(spacePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.spaceButton];
    
    //return按钮
    self.returnButton = [[UIButton alloc] initWithFrame:CGRectMake((kBtnGap + kAltWidth) * 2 + kSpaceWidth + kBtnGap * 1.5, kStartBtnY + 3 * (kBtnHeight + kVerticalGap), kScreenWidth - kAltWidth * 2 - 4 * kBtnGap - kSpaceWidth, kBtnHeight)];
//    [self.returnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.returnButton setTitle:@"Return" forState:UIControlStateNormal];
    [self.returnButton.titleLabel setFont:[UIFont fontWithName:@"GurmukhiMN" size:18]];
//    [self.returnButton.layer setBorderWidth:1.0f];
    [self.returnButton addTarget:self action:@selector(returnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.returnButton];

}

- (void)characterTouchAction:(JSChar *)btn {
    //    [self addPopupToButton:btn];
    [self.textView insertText:btn.titleLabel.text];
}

- (void) shiftPressed: (UIButton *)btn {
    if (self.showSymbol) {
        //正显示字符符号 无需切换大写
        self.showMoreSymbol = !self.showMoreSymbol;
        [self updateShiftBtnTitleState];
        NSArray *__symbols = self.showMoreSymbol ? moreSymbols : Symbols;
        [self setupSymbolLayout:NO withArray:__symbols];
    } else {
        self.shiftEnabled = !self.shiftEnabled;
        self.shiftEnabled ? [self setupASCIICapableLayout:NO withArray:kChar_shift] : [self setupASCIICapableLayout:NO withArray:kChar];
        [self.shiftButton setTitle:self.shiftEnabled ? @"⇪" : @"⇧" forState:UIControlStateNormal];
//        NSArray *subChars = [self subviews];
//        [btn setTitle:self.shiftEnabled?@"⇪":@"⇧" forState:UIControlStateNormal];
//        [subChars enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isKindOfClass:[JSChar class]]) {
//                JSChar *tmp = (JSChar *)obj;
//                [tmp shift:self.shiftEnabled];
//            }
//        }];
    }
}

- (void) deletePressed:(UIButton *)btn {
    [self.textView deleteBackward];
}

- (void) altPressed:(UIButton *)btn {
    self.showSymbol = !self.showSymbol;
    if (self.showSymbol) {
        [self setupSymbolLayout:NO withArray:Symbols];
    } else {
        [self setupASCIICapableLayout:NO withArray:kChar];
        self.showMoreSymbol = NO;
    }
    NSString *title = self.showSymbol ? @"ABC" : @"123";
    [self.altButton setTitle:title forState:UIControlStateNormal];
    
    [self updateShiftBtnTitleState];
}

- (void)updateShiftBtnTitleState {
    NSString *title ;
    if (self.showSymbol) {
        title = self.showMoreSymbol?@"123":@"#+=";
    }else{
        title = self.shiftEnabled?@"⇪":@"⇧";
    }
    [self.shiftButton setTitle:title forState:UIControlStateNormal];
}


- (void) emojiPressed:(UIButton *)btn {
    
}

- (void) spacePressed:(UIButton *)btn {
    [self.textView insertText:@" "];
}

-(void) returnPressed:(UIButton *)btn {
    [self.textView insertText:@"\n"];
}

- (void) setupSymbolLayout:(BOOL)init withArray:(NSArray *)array{
    if (!init){
        //不是初始化创建 重新布局字母或字符界面
        NSArray *subviews = self.subviews;
        [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[JSChar class]]) {
                [obj removeFromSuperview];
            }
        }];
    }
    if (self.charsBtn || [self.charsBtn count]) {
        [self.charsBtn removeAllObjects];
        self.charsBtn = nil;
    }
    
    self.charsBtn = [NSMutableArray arrayWithCapacity:0];
    
    int i = 0;
    int btnWidth = (kScreenWidth - kBtnGap * 10) / 10;
    int btnX = kStartBtnX;
    int btnY = kStartBtnY;
    for (NSString *btnStr in array) {
        JSChar *btn = [[JSChar alloc] init];
        if (i < 10) {
            btnX = kStartBtnX + i * (btnWidth + kBtnGap);
            btn.frame = CGRectMake(btnX, btnY, btnWidth, kBtnHeight);
        } else if (i >= 10 && i < 20) {
            btnX = (kScreenWidth - 9 * (btnWidth + kBtnGap) - btnWidth) / 2 + (kBtnGap + btnWidth) * (i - 10);
            btnY = kStartBtnY + kBtnHeight + kVerticalGap;
            btn.frame = CGRectMake(btnX, btnY, btnWidth, kBtnHeight);
        } else {
            btnX = kShiftWidth + (kScreenWidth - 5 * (40 + kBtnGap) - kShiftWidth * 2) / 2 + (kBtnGap + 40) * (i - 20);
            btnY = kStartBtnY + (kBtnHeight + kVerticalGap) * 2;
            btn.frame = CGRectMake(btnX, btnY, kShiftWidth, kBtnHeight);
        }
        
        if (i == 0 || i == 10) {
            btn.tag = 0;
        } else if (i == 9 || i == 19) {
            btn.tag = 9;
        } else {
            btn.tag = 1;
        }
        
        btn.userInteractionEnabled = YES;
        [btn setTitle:btnStr forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:22]];
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(characterTouchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [btn.layer setBorderWidth:1.0f];
        [self addSubview:btn];
        [self.charsBtn addObject:btn];
        i++;
    }
}

- (void) setupASCIICapableLayout:(BOOL)init withArray:(NSArray *)array{
    if (!init){
        //不是初始化创建 重新布局字母或字符界面
        NSArray *subviews = self.subviews;
        [subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[JSChar class]]) {
                [obj removeFromSuperview];
            }
        }];
    }
    if (self.charsBtn || [self.charsBtn count]) {
        [self.charsBtn removeAllObjects];
        self.charsBtn = nil;
    }
    
    self.charsBtn = [NSMutableArray arrayWithCapacity:0];
    
    int i = 0;
    int btnWidth = (kScreenWidth - kBtnGap * 10) / 10;
    int btnX = kStartBtnX;
    int btnY = kStartBtnY;
    for (NSString *btnStr in array) {
        if (i < 10){
            btnX = kStartBtnX + i * (btnWidth + kBtnGap);
        }else if (i >= 10 && i < 19) {
            btnX = (kScreenWidth - 8 * (btnWidth + kBtnGap) - btnWidth) / 2 + (kBtnGap + btnWidth) * (i - 10);
            btnY = kStartBtnY + kBtnHeight + kVerticalGap;
        } else if (i >= 19 && i < 28) {
            btnX = kShiftWidth + (kScreenWidth - 7 * (btnWidth + kBtnGap) - kShiftWidth * 2) / 2 + (kBtnGap + btnWidth) * (i - 19);
            btnY = kStartBtnY + (kBtnHeight + kVerticalGap) * 2;
        }
        
        JSChar *btn = [[JSChar alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, kBtnHeight)];
        btn.tag = i;
        [btn setTitle:btnStr forState:UIControlStateNormal];
//        [btn setBackgroundColor:[UIColor blackColor]];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:22]];
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(characterTouchAction:) forControlEvents:UIControlEventTouchUpInside];
//        [btn.layer setBorderWidth:1.0f];
        [self addSubview:btn];
        [self.charsBtn addObject:btn];
        i++;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self];
    
    for (JSChar *b in self.charsBtn) {
        if ([b subviews].count > 1) {
            [[[b subviews] objectAtIndex:1] removeFromSuperview];
        }
        if(CGRectContainsPoint(b.frame, location))
        {
            [self addPopupToButton:b];
            [[UIDevice currentDevice] playInputClick];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self];
    
    for (JSChar *b in self.charsBtn) {
        if ([b subviews].count > 1) {
            [[[b subviews] objectAtIndex:1] removeFromSuperview];
        }
        if(CGRectContainsPoint(b.frame, location))
        {
            [self addPopupToButton:b];
            [[UIDevice currentDevice] playInputClick];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self];
    
    for (JSChar *b in self.charsBtn) {
        if ([b subviews].count > 1) {
            [[[b subviews] objectAtIndex:1] removeFromSuperview];
        }
        if(CGRectContainsPoint(b.frame, location))
        {
            [self addPopupToButton:b];
            [[UIDevice currentDevice] playInputClick];
        }
    }
}

-(void) touchesEnded: (NSSet<UITouch *> *)touches withEvent: (UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self];
    
    for (UIButton *b in self.charsBtn) {
        if ([b subviews].count > 1) {
            [[[b subviews] objectAtIndex:1] removeFromSuperview];
        }
        if(CGRectContainsPoint(b.frame, location))
        {
            [self.textView insertText:b.titleLabel.text];
        }
    }
}

- (void)addPopupToButton:(JSChar *)b {
    UIImageView *keyPop = nil;
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 52, 60)];
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        if (b.tag == 0 || b.tag == 10) {
            keyPop = [[UIImageView alloc] initWithImage:[self createiOS7KeytopImageWithKind:popupViewImageRight]];
            keyPop.frame = CGRectMake(-16, -71, keyPop.frame.size.width, keyPop.frame.size.height);
        }
        else if (b.tag == 9 || b.tag == 18) {
            keyPop = [[UIImageView alloc] initWithImage:[self createiOS7KeytopImageWithKind:popupViewImageLeft]];
            keyPop.frame = CGRectMake(-38, -71, keyPop.frame.size.width, keyPop.frame.size.height);
        }
        else {
            keyPop = [[UIImageView alloc] initWithImage:[self createiOS7KeytopImageWithKind:popupViewImageInner]];
            keyPop.frame = CGRectMake(-27, -71, keyPop.frame.size.width, keyPop.frame.size.height);
        }
        
//    }
//    else {
//        if (b == [self.charsBtn objectAtIndex:0] || b == [self.charsBtn objectAtIndex:11]) {
//            keyPop = [[UIImageView alloc] initWithImage:[self createKeytopImageWithKind:PKNumberPadViewImageRight]];
//            keyPop.frame = CGRectMake(-16, -71, keyPop.frame.size.width, keyPop.frame.size.height);
//        }
//        else if (b == [self.charsBtn objectAtIndex:10] || b == [self.charsBtn objectAtIndex:21]) {
//            keyPop = [[UIImageView alloc] initWithImage:[self createKeytopImageWithKind:PKNumberPadViewImageLeft]];
//            keyPop.frame = CGRectMake(-38, -71, keyPop.frame.size.width, keyPop.frame.size.height);
//        }
//        else {
//            keyPop = [[UIImageView alloc] initWithImage:[self createKeytopImageWithKind:PKNumberPadViewImageInner]];
//            keyPop.frame = CGRectMake(-27, -71, keyPop.frame.size.width, keyPop.frame.size.height);
//        }
//        
//    }
    
    [text setFont:[UIFont systemFontOfSize:44]];
    
    [text setTextAlignment:NSTextAlignmentCenter];
    [text setBackgroundColor:[UIColor clearColor]];
    [text setAdjustsFontSizeToFitWidth:YES];
    [text setText:b.titleLabel.text];
    
    keyPop.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
    keyPop.layer.shadowOffset = CGSizeMake(0, 2.0);
    keyPop.layer.shadowOpacity = 0.30;
    keyPop.layer.shadowRadius = 3.0;
    keyPop.clipsToBounds = NO;
    
    [keyPop addSubview:text];
    [b addSubview:keyPop];
}

#define __UPPER_WIDTH   (52.0 * [[UIScreen mainScreen] scale])
#define __LOWER_WIDTH   (24.0 * [[UIScreen mainScreen] scale])

#define __PAN_UPPER_RADIUS  (10.0 * [[UIScreen mainScreen] scale])
#define __PAN_LOWER_RADIUS  (5.0 * [[UIScreen mainScreen] scale])

#define __PAN_UPPDER_WIDTH   (__UPPER_WIDTH-__PAN_UPPER_RADIUS*2)
#define __PAN_UPPER_HEIGHT    (52.0 * [[UIScreen mainScreen] scale])

#define __PAN_LOWER_WIDTH     (__LOWER_WIDTH-__PAN_LOWER_RADIUS*2)
#define __PAN_LOWER_HEIGHT    (47.0 * [[UIScreen mainScreen] scale])

#define __PAN_UL_WIDTH        ((__UPPER_WIDTH-__LOWER_WIDTH)/2)

#define __PAN_MIDDLE_HEIGHT    (2.0 * [[UIScreen mainScreen] scale])

#define __PAN_CURVE_SIZE      (10.0 * [[UIScreen mainScreen] scale])
//TODO: dpi不同而引起的比例问题[[UIScreen mainScreen] scale]，关于像素和点的区别：http://blog.fourdesire.com/2014/12/11/ta-zhen-de-bu-shi-wo-xiong-di-xiang-su-gen-dian-da-bu-tong/
#define __PADDING_X     (15 * [[UIScreen mainScreen] scale])
#define __PADDING_Y     (10 * [[UIScreen mainScreen] scale])
#define __WIDTH   (__UPPER_WIDTH + __PADDING_X*2)
#define __HEIGHT   (__PAN_UPPER_HEIGHT + __PAN_MIDDLE_HEIGHT + __PAN_LOWER_HEIGHT + __PADDING_Y*2)


#define __OFFSET_X    -25 * [[UIScreen mainScreen] scale])
#define __OFFSET_Y    59 * [[UIScreen mainScreen] scale])


- (UIImage *)createiOS7KeytopImageWithKind:(int)kind
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint p = CGPointMake(__PADDING_X, __PADDING_Y);
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    
    p.x += __PAN_UPPER_RADIUS;
    CGPathMoveToPoint(path, NULL, p.x, p.y);
    
    p.x += __PAN_UPPDER_WIDTH;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y += __PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_UPPER_RADIUS,
                 3.0*M_PI/2.0,
                 4.0*M_PI/2.0,
                 false);
    
    p.x += __PAN_UPPER_RADIUS;
    p.y += __PAN_UPPER_HEIGHT - __PAN_UPPER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y + __PAN_CURVE_SIZE);
    switch (kind) {
        case popupViewImageLeft:
            p.x -= __PAN_UL_WIDTH*2;
            break;
            
        case popupViewImageInner:
            p.x -= __PAN_UL_WIDTH;
            break;
            
        case popupViewImageRight:
            break;
    }
    
    p.y += __PAN_MIDDLE_HEIGHT + __PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y - __PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y += __PAN_LOWER_HEIGHT - __PAN_CURVE_SIZE - __PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x -= __PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_LOWER_RADIUS,
                 4.0*M_PI/2.0,
                 1.0*M_PI/2.0,
                 false);
    
    p.x -= __PAN_LOWER_WIDTH;
    p.y += __PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y -= __PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_LOWER_RADIUS,
                 1.0*M_PI/2.0,
                 2.0*M_PI/2.0,
                 false);
    
    p.x -= __PAN_LOWER_RADIUS;
    p.y -= __PAN_LOWER_HEIGHT - __PAN_LOWER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y - __PAN_CURVE_SIZE);
    
    switch (kind) {
        case popupViewImageLeft:
            break;
            
        case popupViewImageInner:
            p.x -= __PAN_UL_WIDTH;
            break;
            
        case popupViewImageRight:
            p.x -= __PAN_UL_WIDTH*2;
            break;
    }
    
    p.y -= __PAN_MIDDLE_HEIGHT + __PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y + __PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y -= __PAN_UPPER_HEIGHT - __PAN_UPPER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x += __PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_UPPER_RADIUS,
                 2.0*M_PI/2.0,
                 3.0*M_PI/2.0,
                 false);
    //----
    CGContextRef context;
    UIGraphicsBeginImageContext(CGSizeMake(__WIDTH,
                                           __HEIGHT));
    context = UIGraphicsGetCurrentContext();
    
    switch (kind) {
        case popupViewImageLeft:
            CGContextTranslateCTM(context, 6.0, __HEIGHT);
            break;
            
        case popupViewImageInner:
            CGContextTranslateCTM(context, 0.0, __HEIGHT);
            break;
            
        case popupViewImageRight:
            CGContextTranslateCTM(context, -6.0, __HEIGHT);
            break;
    }
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    //----
    
    CGRect frame = CGPathGetBoundingBox(path);
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.973 green:0.976 blue:0.976 alpha:1.000] CGColor]);
    CGContextFillRect(context, frame);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    UIImage * image = [UIImage imageWithCGImage:imageRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown];
    CGImageRelease(imageRef);
    
    UIGraphicsEndImageContext();
    
    
    CFRelease(path);
    
    return image;
}
@end

@interface JSChar ()

@property (strong, nonatomic) NSString *chars;
@property (assign, nonatomic) BOOL isShift;

@end

@implementation JSChar

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self addPopupToButton:self];
//}
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [[[self subviews] objectAtIndex:1] removeFromSuperview];
//}
- (void)addRoundCornerBackdround {
//    CGSize size = [self bounds].size;
//    UIImage *backImg = [UIImage pb_imageFromColor:NHColor(64, 66, 68)];
//    backImg = [backImg pb_drawRectWithRoundCorner:NHCHAR_CORNER toSize:size];
//    [self setBackgroundImage:backImg forState:UIControlStateNormal];
}

- (void)updateChar:(nullable NSString *)chars {
    if (chars.length > 0) {
        _chars = [chars copy];
        [self updateTitleState];
    }
}

- (void)updateChar:(nullable NSString *)chars shift:(BOOL)shift {
    if (chars.length > 0) {
        _chars = [chars copy];
        self.isShift = shift;
        [self updateTitleState];
    }
}

- (void)shift:(BOOL)shift {
    if (shift == self.isShift) {
        return;
    }
    self.isShift = shift;
    [self updateTitleState];
}

- (void)updateTitleState {
    NSString *tmp = self.isShift?[self.chars uppercaseString]:[self.chars lowercaseString];
    if ([[NSThread currentThread] isMainThread]) {
        [self setTitle:tmp forState:UIControlStateNormal];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setTitle:tmp forState:UIControlStateNormal];
        });
    }
}
/*
 - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
 [self addPopup];
 }
 
 - (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
 
 }
 
 - (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
 NSArray *subviews = [self subviews];
 if (subviews.count == 2) {
 [[[self subviews] objectAtIndex:1] removeFromSuperview];
 }else if (subviews.count == 3) {
 [[[self subviews] objectAtIndex:2] removeFromSuperview];
 }
 }
 
 - (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
 NSArray *subviews = [self subviews];
 if (subviews.count == 2) {
 [[[self subviews] objectAtIndex:1] removeFromSuperview];
 }else if (subviews.count == 3) {
 [[[self subviews] objectAtIndex:2] removeFromSuperview];
 }
 }
 */

#define _UPPER_WIDTH   (50.0 * [[UIScreen mainScreen] scale])
#define _LOWER_WIDTH   (30.0 * [[UIScreen mainScreen] scale])

#define _PAN_UPPER_RADIUS  (7.0 * [[UIScreen mainScreen] scale])
#define _PAN_LOWER_RADIUS  (7.0 * [[UIScreen mainScreen] scale])

#define _PAN_UPPDER_WIDTH   (_UPPER_WIDTH-_PAN_UPPER_RADIUS*2)
#define _PAN_UPPER_HEIGHT    (60.0 * [[UIScreen mainScreen] scale])

#define _PAN_LOWER_WIDTH     (_LOWER_WIDTH-_PAN_LOWER_RADIUS*2)
#define _PAN_LOWER_HEIGHT    (30.0 * [[UIScreen mainScreen] scale])

#define _PAN_UL_WIDTH        ((_UPPER_WIDTH-_LOWER_WIDTH)/2)

#define _PAN_MIDDLE_HEIGHT    (11.0 * [[UIScreen mainScreen] scale])

#define _PAN_CURVE_SIZE      (7.0 * [[UIScreen mainScreen] scale])

#define _PADDING_X     (15 * [[UIScreen mainScreen] scale])
#define _PADDING_Y     (11 * [[UIScreen mainScreen] scale])
#define _WIDTH   (_UPPER_WIDTH + _PADDING_X*2)
#define _HEIGHT   (_PAN_UPPER_HEIGHT + _PAN_MIDDLE_HEIGHT + _PAN_LOWER_HEIGHT + _PADDING_Y*2)


#define _OFFSET_X    -20 * [[UIScreen mainScreen] scale])
#define _OFFSET_Y    59 * [[UIScreen mainScreen] scale])


- (CGImageRef)createKeytopImageWithKind:(int)kind
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint p = CGPointMake(_PADDING_X, _PADDING_Y);
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    
    p.x += _PAN_UPPER_RADIUS;
    CGPathMoveToPoint(path, NULL, p.x, p.y);
    
    p.x += _PAN_UPPDER_WIDTH;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y += _PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_UPPER_RADIUS,
                 3.0*M_PI/2.0,
                 4.0*M_PI/2.0,
                 false);
    
    p.x += _PAN_UPPER_RADIUS;
    p.y += _PAN_UPPER_HEIGHT - _PAN_UPPER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y + _PAN_CURVE_SIZE);
//    switch (kind) {
//        case NHKBImageLeft:
//            p.x -= _PAN_UL_WIDTH*2;
//            break;
//            
//        case NHKBImageInner:
//            p.x -= _PAN_UL_WIDTH;
//            break;
//            
//        case NHKBImageRight:
//            break;
//    }
    
    p.y += _PAN_MIDDLE_HEIGHT + _PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y - _PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y += _PAN_LOWER_HEIGHT - _PAN_CURVE_SIZE - _PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x -= _PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_LOWER_RADIUS,
                 4.0*M_PI/2.0,
                 1.0*M_PI/2.0,
                 false);
    
    p.x -= _PAN_LOWER_WIDTH;
    p.y += _PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y -= _PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_LOWER_RADIUS,
                 1.0*M_PI/2.0,
                 2.0*M_PI/2.0,
                 false);
    
    p.x -= _PAN_LOWER_RADIUS;
    p.y -= _PAN_LOWER_HEIGHT - _PAN_LOWER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y - _PAN_CURVE_SIZE);
    
//    switch (kind) {
//        case NHKBImageLeft:
//            break;
//            
//        case NHKBImageInner:
//            p.x -= _PAN_UL_WIDTH;
//            break;
//            
//        case NHKBImageRight:
//            p.x -= _PAN_UL_WIDTH*2;
//            break;
//    }
    
    p.y -= _PAN_MIDDLE_HEIGHT + _PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y + _PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y -= _PAN_UPPER_HEIGHT - _PAN_UPPER_RADIUS - _PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x += _PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 _PAN_UPPER_RADIUS,
                 2.0*M_PI/2.0,
                 3.0*M_PI/2.0,
                 false);
    //----
    CGContextRef context;
    UIGraphicsBeginImageContext(CGSizeMake(_WIDTH,
                                           _HEIGHT));
    context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, _HEIGHT);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    //----
    
    // draw gradient
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGFloat components[] = {
        0.25f, 0.258f,
        0.266, 1.0f,
        0.48f, 0.48f,
        0.48f, 1.0f};
    
    
    size_t count = sizeof(components)/ (sizeof(CGFloat)* 2);
    
    CGRect frame = CGPathGetBoundingBox(path);
    CGPoint startPoint = frame.origin;
    CGPoint endPoint = frame.origin;
    endPoint.y = frame.origin.y + frame.size.height;
    
    CGGradientRef gradientRef =
    CGGradientCreateWithColorComponents(colorSpaceRef, components, NULL, count);
    
    CGContextDrawLinearGradient(context,
                                gradientRef,
                                startPoint,
                                endPoint,
                                kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradientRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    CFRelease(path);
    
    return imageRef;
}

//- (void)addPopup {
//    UIImageView *keyPop;
//    CGFloat scale = [UIScreen mainScreen].scale;
//    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(_PADDING_X/scale, _PADDING_Y/scale, _UPPER_WIDTH/scale, _PAN_UPPER_HEIGHT/scale)];
//    
////    if ([self.chars isEqualToString:@"q"]||[self.chars isEqualToString:@"a"]) {
////        keyPop = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self createKeytopImageWithKind:NHKBImageRight] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown]];
////        keyPop.frame = CGRectMake(-16, -71, keyPop.frame.size.width, keyPop.frame.size.height);
////    }
////    else if ([self.chars isEqualToString:@"p"]||[self.chars isEqualToString:@"l"]) {
////        keyPop = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self createKeytopImageWithKind:NHKBImageLeft] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown]];
////        keyPop.frame = CGRectMake(-38, -71, keyPop.frame.size.width, keyPop.frame.size.height);
////    }
////    else {
////        keyPop = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self createKeytopImageWithKind:NHKBImageInner] scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown]];
////        keyPop.frame = CGRectMake(-27, -71, keyPop.frame.size.width, keyPop.frame.size.height);
////    }
////    NSString *tmp = self.isShift?[self.chars uppercaseString]:[self.chars lowercaseString];
////    [text setFont:[UIFont fontWithName:NHKBFont(NHKBFontSize).fontName size:44]];
//    [text setTextColor: NHColor(247, 247, 247)];
//    [text setTextAlignment:NSTextAlignmentCenter];
//    [text setBackgroundColor:[UIColor clearColor]];
//    [text setShadowColor:[UIColor whiteColor]];
//    [text setText:tmp];
//    
//    keyPop.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
//    keyPop.layer.shadowOffset = CGSizeMake(0, 3.0);
//    keyPop.layer.shadowOpacity = 1;
//    keyPop.layer.shadowRadius = 5.0;
//    keyPop.clipsToBounds = NO;
//    
//    [keyPop addSubview:text];
//    [self addSubview:keyPop];
//}


- (void)addPopupToButton:(JSChar *)b {
    UIImageView *keyPop = nil;
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 52, 60)];
    
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    if (b.tag == 0 || b.tag == 10) {
        keyPop = [[UIImageView alloc] initWithImage:[self createiOS7KeytopImageWithKind:popupViewImageRight]];
        keyPop.frame = CGRectMake(-16, -71, keyPop.frame.size.width, keyPop.frame.size.height);
    }
    else if (b.tag == 9 || b.tag == 18) {
        keyPop = [[UIImageView alloc] initWithImage:[self createiOS7KeytopImageWithKind:popupViewImageLeft]];
        keyPop.frame = CGRectMake(-38, -71, keyPop.frame.size.width, keyPop.frame.size.height);
    }
    else {
        keyPop = [[UIImageView alloc] initWithImage:[self createiOS7KeytopImageWithKind:popupViewImageInner]];
        keyPop.frame = CGRectMake(-27, -71, keyPop.frame.size.width, keyPop.frame.size.height);
    }
    
    //    }
    //    else {
    //        if (b == [self.charsBtn objectAtIndex:0] || b == [self.charsBtn objectAtIndex:11]) {
    //            keyPop = [[UIImageView alloc] initWithImage:[self createKeytopImageWithKind:PKNumberPadViewImageRight]];
    //            keyPop.frame = CGRectMake(-16, -71, keyPop.frame.size.width, keyPop.frame.size.height);
    //        }
    //        else if (b == [self.charsBtn objectAtIndex:10] || b == [self.charsBtn objectAtIndex:21]) {
    //            keyPop = [[UIImageView alloc] initWithImage:[self createKeytopImageWithKind:PKNumberPadViewImageLeft]];
    //            keyPop.frame = CGRectMake(-38, -71, keyPop.frame.size.width, keyPop.frame.size.height);
    //        }
    //        else {
    //            keyPop = [[UIImageView alloc] initWithImage:[self createKeytopImageWithKind:PKNumberPadViewImageInner]];
    //            keyPop.frame = CGRectMake(-27, -71, keyPop.frame.size.width, keyPop.frame.size.height);
    //        }
    //
    //    }
    
    [text setFont:[UIFont systemFontOfSize:44]];
    
    [text setTextAlignment:NSTextAlignmentCenter];
    [text setBackgroundColor:[UIColor clearColor]];
    [text setAdjustsFontSizeToFitWidth:YES];
    [text setText:b.titleLabel.text];
    
    keyPop.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
    keyPop.layer.shadowOffset = CGSizeMake(0, 2.0);
    keyPop.layer.shadowOpacity = 0.30;
    keyPop.layer.shadowRadius = 3.0;
    keyPop.clipsToBounds = NO;
    
    [keyPop addSubview:text];
    [b addSubview:keyPop];
}

#define __UPPER_WIDTH   (52.0 * [[UIScreen mainScreen] scale])
#define __LOWER_WIDTH   (24.0 * [[UIScreen mainScreen] scale])

#define __PAN_UPPER_RADIUS  (10.0 * [[UIScreen mainScreen] scale])
#define __PAN_LOWER_RADIUS  (5.0 * [[UIScreen mainScreen] scale])

#define __PAN_UPPDER_WIDTH   (__UPPER_WIDTH-__PAN_UPPER_RADIUS*2)
#define __PAN_UPPER_HEIGHT    (52.0 * [[UIScreen mainScreen] scale])

#define __PAN_LOWER_WIDTH     (__LOWER_WIDTH-__PAN_LOWER_RADIUS*2)
#define __PAN_LOWER_HEIGHT    (47.0 * [[UIScreen mainScreen] scale])

#define __PAN_UL_WIDTH        ((__UPPER_WIDTH-__LOWER_WIDTH)/2)

#define __PAN_MIDDLE_HEIGHT    (2.0 * [[UIScreen mainScreen] scale])

#define __PAN_CURVE_SIZE      (10.0 * [[UIScreen mainScreen] scale])
//TODO: dpi不同而引起的比例问题[[UIScreen mainScreen] scale]，关于像素和点的区别：http://blog.fourdesire.com/2014/12/11/ta-zhen-de-bu-shi-wo-xiong-di-xiang-su-gen-dian-da-bu-tong/
#define __PADDING_X     (15 * [[UIScreen mainScreen] scale])
#define __PADDING_Y     (10 * [[UIScreen mainScreen] scale])
#define __WIDTH   (__UPPER_WIDTH + __PADDING_X*2)
#define __HEIGHT   (__PAN_UPPER_HEIGHT + __PAN_MIDDLE_HEIGHT + __PAN_LOWER_HEIGHT + __PADDING_Y*2)


#define __OFFSET_X    -25 * [[UIScreen mainScreen] scale])
#define __OFFSET_Y    59 * [[UIScreen mainScreen] scale])


- (UIImage *)createiOS7KeytopImageWithKind:(int)kind
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint p = CGPointMake(__PADDING_X, __PADDING_Y);
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    
    p.x += __PAN_UPPER_RADIUS;
    CGPathMoveToPoint(path, NULL, p.x, p.y);
    
    p.x += __PAN_UPPDER_WIDTH;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y += __PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_UPPER_RADIUS,
                 3.0*M_PI/2.0,
                 4.0*M_PI/2.0,
                 false);
    
    p.x += __PAN_UPPER_RADIUS;
    p.y += __PAN_UPPER_HEIGHT - __PAN_UPPER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y + __PAN_CURVE_SIZE);
    switch (kind) {
        case popupViewImageLeft:
            p.x -= __PAN_UL_WIDTH*2;
            break;
            
        case popupViewImageInner:
            p.x -= __PAN_UL_WIDTH;
            break;
            
        case popupViewImageRight:
            break;
    }
    
    p.y += __PAN_MIDDLE_HEIGHT + __PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y - __PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y += __PAN_LOWER_HEIGHT - __PAN_CURVE_SIZE - __PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x -= __PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_LOWER_RADIUS,
                 4.0*M_PI/2.0,
                 1.0*M_PI/2.0,
                 false);
    
    p.x -= __PAN_LOWER_WIDTH;
    p.y += __PAN_LOWER_RADIUS;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.y -= __PAN_LOWER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_LOWER_RADIUS,
                 1.0*M_PI/2.0,
                 2.0*M_PI/2.0,
                 false);
    
    p.x -= __PAN_LOWER_RADIUS;
    p.y -= __PAN_LOWER_HEIGHT - __PAN_LOWER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y - __PAN_CURVE_SIZE);
    
    switch (kind) {
        case popupViewImageLeft:
            break;
            
        case popupViewImageInner:
            p.x -= __PAN_UL_WIDTH;
            break;
            
        case popupViewImageRight:
            p.x -= __PAN_UL_WIDTH*2;
            break;
    }
    
    p.y -= __PAN_MIDDLE_HEIGHT + __PAN_CURVE_SIZE*2;
    p2 = CGPointMake(p.x, p.y + __PAN_CURVE_SIZE);
    CGPathAddCurveToPoint(path, NULL,
                          p1.x, p1.y,
                          p2.x, p2.y,
                          p.x, p.y);
    
    p.y -= __PAN_UPPER_HEIGHT - __PAN_UPPER_RADIUS - __PAN_CURVE_SIZE;
    CGPathAddLineToPoint(path, NULL, p.x, p.y);
    
    p.x += __PAN_UPPER_RADIUS;
    CGPathAddArc(path, NULL,
                 p.x, p.y,
                 __PAN_UPPER_RADIUS,
                 2.0*M_PI/2.0,
                 3.0*M_PI/2.0,
                 false);
    //----
    CGContextRef context;
    UIGraphicsBeginImageContext(CGSizeMake(__WIDTH,
                                           __HEIGHT));
    context = UIGraphicsGetCurrentContext();
    
    switch (kind) {
        case popupViewImageLeft:
            CGContextTranslateCTM(context, 6.0, __HEIGHT);
            break;
            
        case popupViewImageInner:
            CGContextTranslateCTM(context, 0.0, __HEIGHT);
            break;
            
        case popupViewImageRight:
            CGContextTranslateCTM(context, -6.0, __HEIGHT);
            break;
    }
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    //----
    
    CGRect frame = CGPathGetBoundingBox(path);
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.973 green:0.976 blue:0.976 alpha:1.000] CGColor]);
    CGContextFillRect(context, frame);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    UIImage * image = [UIImage imageWithCGImage:imageRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationDown];
    CGImageRelease(imageRef);
    
    UIGraphicsEndImageContext();
    
    
    CFRelease(path);
    
    return image;
}
@end
