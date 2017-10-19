//
//  AccountManageViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/9/18.
//  Copyright © 2015年 知春. All rights reserved.
//

#import "AccountManageViewController.h"
#import "FreeSingleton.h"

@interface AccountManageViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn_getSms;
@property (weak, nonatomic) IBOutlet UITextField *text_phoneNo;
@property (weak, nonatomic) IBOutlet UITextField *text_Sms;
@property (weak, nonatomic) IBOutlet UITextField *text_password;
@property (weak, nonatomic) IBOutlet UIButton *btn_commit;

@property (assign, nonatomic)int timeNumber;

@end

@implementation AccountManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -initView
- (void)initView
{
    _btn_getSms.layer.cornerRadius = 3.f;
    _btn_commit.layer.cornerRadius = 3.f;
    [_btn_getSms addTarget:self action:@selector(btn_getSms_Tapped:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_commit addTarget:self action:@selector(btn_commit_Tapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.navigationItem.title = @"绑定手机号";
    
}

- (void)btn_getSms_Tapped:(UIButton *)btn
{
    [_text_password resignFirstResponder];
    [_text_phoneNo resignFirstResponder];
    [_text_Sms resignFirstResponder];
    
    [KVNProgress showWithStatus:@"正在发送验证码中....."];
    
    __weak AccountManageViewController *weakself = self;
    
    NSInteger ret=[[FreeSingleton sharedInstance] userGetSmsOnCompletion:_text_phoneNo.text block:^(NSUInteger retcode, id data)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [KVNProgress dismiss];
                       });
                       
                       if (retcode == RET_SERVER_SUCC)
                       {
                           [KVNProgress showSuccessWithStatus:@"验证码发送成功"];
                           [weakself timerCalculate];
                       }
                       else
                       {
                           if (data)
                           {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [KVNProgress showErrorWithStatus:data];
                               });
                           }
                           else
                           {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [KVNProgress showErrorWithStatus:@"请求验证码失败"];
                               });
                           }
                           
                       }
                       
                   }];
    
    if (ret != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(ret)];
    }
}

//计算倒计时
- (void)timerCalculate
{
    _timeNumber = 60; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(_timeNumber <= 0)
        {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                _btn_getSms.titleLabel.text = @"重新获取";
                [_btn_getSms setTitle:@"重新获取" forState:UIControlStateNormal];
                _btn_getSms.userInteractionEnabled = YES;
                
            });
        }
        else
        {
            int seconds = _timeNumber % 60;
            
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _btn_getSms.titleLabel.text = [NSString stringWithFormat:@"重新获取(%@)",strTime];
                [_btn_getSms setTitle:[NSString stringWithFormat:@"重新获取(%@)",strTime] forState:UIControlStateNormal];
                
                _btn_getSms.userInteractionEnabled = NO;
                
            });
            _timeNumber--;
        }
    });
    dispatch_resume(_timer);
}

- (void)btn_commit_Tapped:(UIButton *)btn
{
    [_text_password resignFirstResponder];
    [_text_phoneNo resignFirstResponder];
    [_text_Sms resignFirstResponder];
    
    [KVNProgress showWithStatus:@"Loading"];
    __weak AccountManageViewController *weakSelf = self;
    NSInteger retcode = [[FreeSingleton sharedInstance] bindVisitorPhoneNoOnCompletion:_text_phoneNo.text sms:_text_Sms.text password:_text_password.text block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            [Utils warningUserAfterJump:weakSelf msg:@"绑定手机成功" time:1.0f];
            [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_BIND_PHONENO object:nil];
            [weakSelf.navigationController popViewControllerAnimated:YES];
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

- (void)keyboardHide:(UITapGestureRecognizer*)tap{
    [_text_password resignFirstResponder];
    [_text_phoneNo resignFirstResponder];
    [_text_Sms resignFirstResponder];
}

/**
 *  点击完成收入键盘
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_text_password resignFirstResponder];
    [_text_phoneNo resignFirstResponder];
    [_text_Sms resignFirstResponder];
    return YES;
}

@end
