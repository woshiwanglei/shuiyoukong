//
//  ForGetPassWordViewController.m
//  Free
//
//  Created by yangcong on 15/5/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ForGetPassWordViewController.h"
#import "UIChangeIncident.h"
#import "MBProgressHUD.h"
#import "Utils.h"
#import "FreeSingleton.h"
#import "SendPhoneNumberViewController.h"

@interface ForGetPassWordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *PhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *GetNumber;
@property (weak, nonatomic) IBOutlet UIView *BackBG;

@end

@implementation ForGetPassWordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
}

- (void)initView
{
    _PhoneNumber.borderStyle = UITextBorderStyleNone;
    
    _GetNumber.layer.borderColor = [[UIColor clearColor] CGColor];
    _GetNumber.layer.masksToBounds = YES;
    _GetNumber.layer.cornerRadius = 5;
    _GetNumber.backgroundColor  = FREE_BACKGOURND_COLOR;
    
    self.view.backgroundColor =[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1];
    _BackBG.backgroundColor = [UIColor whiteColor];
    _BackBG.layer.borderWidth = 1;
    _BackBG.layer.borderColor =[[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0] CGColor];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    _PhoneNumber.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
/**
 *  获取验证码
 *
 *  @param sender 
 */
- (IBAction)sendPhoneNumber:(UIButton *)sender
{
   [self forgetPassWord];
   //[self performSegueWithIdentifier:@"sendPhoneNumber" sender:self];
}
-(void)forgetPassWord
{
    [_PhoneNumber resignFirstResponder];
    __weak ForGetPassWordViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"正在获取验证码..."];
    NSInteger retcode = [[FreeSingleton sharedInstance] userGetPassWordOnCompletion:_PhoneNumber.text block:^(NSUInteger retger, id data)
                         {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [KVNProgress dismiss];
                             });
                             if (retger == RET_SERVER_SUCC)
                             {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [weakSelf performSegueWithIdentifier:@"sendPhoneNumber" sender:self];
                                 });
                             }
                             else
                             {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [KVNProgress showErrorWithStatus:@"请求验证码失败"
                                                               onView:weakSelf.view];
                                 });
                             }
                         }];
    
    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)
                                  onView:weakSelf.view];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    SendPhoneNumberViewController *registers=(SendPhoneNumberViewController *)[segue destinationViewController];
    
    registers.phone_number=_PhoneNumber.text;
}

@end
