//
//  ViewController.m
//  Keyboard
//
//  Created by wayne on 2016/12/14.
//  Copyright © 2016年 wayne. All rights reserved.
//

#import "ViewController.h"
#import "Keyboard.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    Keyboard *keyboard = [[Keyboard alloc] init];
    keyboard.textView = self.textView;
    self.textView.userInteractionEnabled = YES;
    [self.textView setInputView:keyboard];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touched");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
