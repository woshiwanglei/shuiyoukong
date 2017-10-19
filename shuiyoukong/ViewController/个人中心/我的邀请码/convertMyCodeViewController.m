//
//  convertMyCodeViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/22.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "convertMyCodeViewController.h"
#import "FreeSingleton.h"

@interface convertMyCodeViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *input_text;
@property (weak, nonatomic) IBOutlet UIButton *btn_convert;

@end

@implementation convertMyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _input_text.delegate = nil;
}

- (void)initView
{
    self.navigationItem.title = @"兑换邀请码";
    
    _btn_convert.layer.cornerRadius = 3.f;
    _btn_convert.layer.masksToBounds = YES;
    
    _input_text.tintColor = FREE_BACKGOURND_COLOR;
    _input_text.delegate = self;
    [_btn_convert addTarget:self action:@selector(commitInviteCode) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}


/**
 *  点击完成收入键盘
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_input_text resignFirstResponder];
    return YES;
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [_input_text resignFirstResponder];
}


- (void)commitInviteCode
{
    if (_input_text.text != nil) {
        [KVNProgress showWithStatus:@"Loading"];
       NSInteger retcode = [[FreeSingleton sharedInstance] useInviteCodeOnCompletion:_input_text.text block:^(NSUInteger ret, id data) {
           [KVNProgress dismiss];
            if(ret == RET_SERVER_SUCC)
            {
                [KVNProgress showSuccessWithStatus:data];
            }
           else
           {
               [KVNProgress showErrorWithStatus:data];
           }
        }];
        
        if (retcode != RET_OK) {
            [KVNProgress dismiss];
            [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
        }
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    // Check for non-numeric characters
    NSUInteger proposedNewLength = textField.text.length - range.length + string.length;
    if (proposedNewLength > 5)
        return NO;
    return YES;
}

@end
