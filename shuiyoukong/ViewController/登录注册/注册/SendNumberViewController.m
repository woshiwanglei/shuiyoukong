//
//  SendNumberViewController.m
//  Free
//
//  Created by yangcong on 15/5/4.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SendNumberViewController.h"
#import "MBProgressHUD.h"
#import "Utils.h"
#import "FreeSingleton.h"
#import "Error.h"
#import "RegistersViewController.h"
#import "UIChangeIncident.h"
@interface SendNumberViewController ()

//@property (nonatomic,strong) MBProgressHUD *hud;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation SendNumberViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
}
-(void)initView
{
    _phoneNumber.borderStyle = UITextBorderStyleNone;
    
    _sendButton.layer.borderColor = [[UIColor clearColor] CGColor];
    _sendButton.layer.masksToBounds = YES;
    _sendButton.layer.cornerRadius = 5;
    _sendButton.backgroundColor  = FREE_BACKGOURND_COLOR;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dic;
    
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    _textView.editable = NO;
    _textView.scrollEnabled = NO;
    _textView.userInteractionEnabled = NO;
    _phoneNumber.delegate = self;
    self.view.backgroundColor =[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1];
    _phoneBgview.backgroundColor = [UIColor whiteColor];
    _phoneBgview.layer.borderWidth = 1;
    _phoneBgview.layer.borderColor =[[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0] CGColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden=NO;
}

/**
 *  点击空白放弃第一响应者
 *
 *  @param sender 
 */
- (IBAction)hidekeyboard:(id)sender
{
       [_phoneNumber resignFirstResponder];
}
/**
 *  发送验证码
 *
 *  @param sender 
 */
- (IBAction)sendButton:(UIButton *)sender
{
   [self sendSucceed];
//   [self performSegueWithIdentifier:@"sendNumber" sender:self];
   
}
/**
 *  发送事件
 */
-(void) sendSucceed
{
    [_phoneNumber resignFirstResponder];
    
    [KVNProgress showWithStatus:@"正在发送验证码中....."];;
    
    __weak SendNumberViewController *weakself = self;
    
    NSInteger ret=[[FreeSingleton sharedInstance] userGetSmsOnCompletion:self.phoneNumber.text block:^(NSUInteger retcode, id data)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
        });

        if (retcode == RET_SERVER_SUCC)
            {
                [weakself performSegueWithIdentifier:@"sendNumber" sender:self];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    RegistersViewController *registers = (RegistersViewController *)[segue destinationViewController];
    
    registers.phone_num=_phoneNumber.text;
}

@end
