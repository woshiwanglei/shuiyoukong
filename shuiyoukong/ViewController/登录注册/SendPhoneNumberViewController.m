//
//  SendPhoneNumberViewController.m
//  Free
//
//  Created by yangcong on 15/5/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SendPhoneNumberViewController.h"
#import "UIChangeIncident.h"
#import "MBProgressHUD.h"
#import "Utils.h"
#import "FreeSingleton.h"
@interface SendPhoneNumberViewController ()

@property (weak, nonatomic) IBOutlet UITextField *TestNumber;
@property (weak, nonatomic) IBOutlet UIButton *againNumber;
@property (weak, nonatomic) IBOutlet UITextField *PassWord;
@property (weak, nonatomic) IBOutlet UITextField *againPassWord;
@property (weak, nonatomic) IBOutlet UIButton *certain;

@property (weak, nonatomic) IBOutlet UIView *TestView;
@property (weak, nonatomic) IBOutlet UIView *PassView;
@property (weak, nonatomic) IBOutlet UIView *aginPassView;

@property (nonatomic,assign) int timeNumber;
@end

@implementation SendPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self inintView];
}

-(void)inintView
{
    _TestNumber.borderStyle = UITextBorderStyleNone;
    _PassWord.borderStyle = UITextBorderStyleNone;
    _againPassWord.borderStyle = UITextBorderStyleNone;
    _TestNumber.returnKeyType = UIReturnKeyDone;
    _PassWord.returnKeyType = UIReturnKeyDone;
    _againPassWord.returnKeyType = UIReturnKeyDone;
    //[UIChangeIncident ButtonChangPattern:_againNumber];
   // [UIChangeIncident ButtonChangPattern:_certain];
    _TestNumber.delegate = self;
    _PassWord.delegate = self;
    _againPassWord.delegate = self;
    
    [self timeout];
    
    self.view.backgroundColor = [UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1];
    [self setBackGroundView:_TestView];
    [self setBackGroundView:_PassView];
    [self setBackGroundView:_aginPassView];
    
    _againNumber.backgroundColor = FREE_BACKGOURND_COLOR;
    _againNumber.layer.borderColor = [[UIColor clearColor] CGColor];
    _againNumber.layer.masksToBounds = YES;
    _againNumber.layer.cornerRadius = 5;
    _certain.backgroundColor = FREE_BACKGOURND_COLOR;
    _certain.layer.borderColor = [[UIColor clearColor] CGColor];
    _certain.layer.masksToBounds = YES;
    _certain.layer.cornerRadius = 5;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];

    
}
-(void)setBackGroundView:(UIView *)views
{
    views.backgroundColor = [UIColor whiteColor];
    views.layer.borderWidth = 1;
    views.layer.borderColor =[[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0] CGColor];

}
-(void)timeout{
    
    _timeNumber=60; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(_timeNumber<=0)
        {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_againNumber setTitle:@"重新获取" forState:UIControlStateNormal];
                _againNumber.userInteractionEnabled = YES;
                
            });
        }
        else
        {
            int seconds = _timeNumber % 60;
            
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_againNumber setTitle:[NSString stringWithFormat:@"重新获取(%@)",strTime] forState:UIControlStateNormal];
                
                _againNumber.userInteractionEnabled = NO;
                
            });
            _timeNumber--;
            
        }
    });
    dispatch_resume(_timer);
    
}

/**
 *  再次发送
 *
 *  @param sender
 */
- (IBAction)againChanges:(UIButton *)sender
{
    [self sendPhone_Number];
}

-(void)sendPhone_Number
{
    _timeNumber=60; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(_timeNumber<=0)
        {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_againNumber setTitle:@"重新获取" forState:UIControlStateNormal];
                _againNumber.userInteractionEnabled = YES;
                
            });
        }
        else
        {
            int seconds = _timeNumber % 60;
            
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_againNumber setTitle:[NSString stringWithFormat:@"重新获取(%@)",strTime] forState:UIControlStateNormal];
                
                _againNumber.userInteractionEnabled = NO;
                
            });
            _timeNumber--;
            
        }
    });
    dispatch_resume(_timer);
    
    __weak SendPhoneNumberViewController *weakSelf = self;
    MBProgressHUD *hud = [Utils waiting:self msg:@"重新获取验证码中..."];
    NSInteger retcode = [[FreeSingleton sharedInstance] userGetPassWordOnCompletion:_phone_number block:^(NSUInteger retger, id data)
                         {
                             [Utils hideHUD:hud];
                             if (retger == RET_SERVER_SUCC)
                             {
                                 [Utils warningUser:weakSelf msg:@"请求验证码成功"];
                                 hud.mode = MBProgressHUDModeText;
                                 hud.detailsLabelText=data;
                                 [hud hide:YES afterDelay:1.5];
                             }
                             else
                             {
                                 [Utils warningUser:weakSelf msg:@"请求验证码失败"];
                                 hud.mode = MBProgressHUDModeText;
                                 hud.detailsLabelText=data;
                                 [hud hide:YES afterDelay:1.5];
                             }
                         }];
    
    if (retcode != RET_OK) {
        [Utils hideHUD:hud];
        [Utils warningUser:weakSelf msg:zcErrMsg(retcode)];
    }


}
#pragma  mark - 更改密码
- (IBAction)sendSucceed:(UIButton *)sender
{
    
    [self sendSucceedPassWord];
    
}

-(void)sendSucceedPassWord
{
    __weak SendPhoneNumberViewController *weakSelf = self;
    
    MBProgressHUD *hud = [Utils waiting:weakSelf msg:@"更换密码中..."];
    
    NSInteger retger = [[FreeSingleton sharedInstance] UserFinishGetPassWordOnCompletion:_phone_number pwd:_PassWord.text pwd_confirm:_againPassWord.text sms:_TestNumber.text block:^(NSUInteger retcode, id data)
                        {
                            [Utils hideHUD:hud];
                            
                            if (retcode == RET_SERVER_SUCC)
                            {
                                [Utils warningUser:weakSelf msg:@"更改密码成功"];
                                hud.mode = MBProgressHUDModeText;
                                hud.detailsLabelText=data;
                                [hud hide:YES afterDelay:1.5];
                                
                                [self performSegueWithIdentifier:@"getbacklogin" sender:self];
                            }
                            else
                            {
                                [Utils warningUser:weakSelf msg:@"更改密码失败"];
                                hud.mode = MBProgressHUDModeText;
                                hud.detailsLabelText=data;
                                [hud hide:YES afterDelay:1.5];
                                
                            }
                        }];
    if (retger != RET_OK) {
        [Utils hideHUD:hud];
        [Utils warningUser:self msg:zcErrMsg(retger)];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_TestNumber resignFirstResponder];
    [_PassWord resignFirstResponder];
    [_againPassWord resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 其他
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [_TestNumber resignFirstResponder];
    [_PassWord resignFirstResponder];
    [_againPassWord resignFirstResponder];
}

@end
