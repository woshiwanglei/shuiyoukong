//
//  ObtainLableViewController.m
//  Free
//
//  Created by yangcong on 15/5/7.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ObtainLableViewController.h"
#import "FreeSingleton.h"
#import "Error.h"
#import "BtnModel.h"
#import "JSONKit.h"
#import "Utils.h"

@interface ObtainLableViewController ()

@property (nonatomic,strong) NSMutableArray *arrynumber;
@property (nonatomic,strong) NSMutableArray *btnModelArray;
@property (nonatomic,strong) NSMutableArray *sumbitArray;
@property (nonatomic,strong) NSMutableArray *dictArray;

@property (weak, nonatomic) IBOutlet UITextField *obtainField;
@property (weak, nonatomic) IBOutlet UIButton *NewObtan;

@property (weak, nonatomic) IBOutlet UIView *ObtainViewBG;

@property UIScrollView *scrollview;


@end

@implementation ObtainLableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initView];
    [self initData];
}
-(void)initData
{
    
    _arrynumber = [NSMutableArray array];
    
    _btnModelArray = [NSMutableArray array];
    
    MBProgressHUD *hud = [Utils waiting:self msg:@"请稍后..."];
    
    __weak ObtainLableViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] getobtainLableOncompletion:^(NSUInteger ret, id data)
     {
         [Utils hideHUD:hud];
         if (ret == RET_SERVER_SUCC)
         {
             [weakSelf initModel:data];
         }
             
         }];
    _NewObtan.layer.borderColor = [[UIColor clearColor] CGColor];
    _NewObtan.layer.masksToBounds = YES;
    _NewObtan.layer.cornerRadius = 5;
    _NewObtan.backgroundColor  = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
    
    _ObtainViewBG.backgroundColor = [UIColor whiteColor];
    _ObtainViewBG.layer.borderWidth = 1;
    _ObtainViewBG.layer.borderColor =[[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0] CGColor];
}
- (IBAction)Keyboard:(id)sender {
    
    [_obtainField resignFirstResponder];
    [_scrollview resignFirstResponder];
}

-(void)initView
{
    
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    self.navigationItem.hidesBackButton = YES;
    
    _btnModelArray = [NSMutableArray array];

    _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-110)];
    
    _scrollview.delegate = self;
    
    [self.view addSubview:_scrollview];
    _obtainField.delegate = self;
    _NewObtan.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    _obtainField.returnKeyType = UIReturnKeyDone;
    _obtainField.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Actiondo:)];
    
    [_scrollview addGestureRecognizer:tapGesture];
    
  //  _scrollview.backgroundColor = [UIColor redColor];
    
}

-(void)Actiondo:(UITapGestureRecognizer *)tap
{
    [self.obtainField resignFirstResponder];
}
#pragma mark 键盘即将退出
- (void)keyBoardWillShow:(NSNotification *)note
{
    
    if ([UIScreen mainScreen].bounds.size.height>700) {
        
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                         animations:^{
                             self.view.transform = CGAffineTransformMakeTranslation(0, -270);
                         }
         ];
    }
    else if([UIScreen mainScreen].bounds.size.height==667)
    {
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                         animations:^{
                             self.view.transform = CGAffineTransformMakeTranslation(0, -255);
                         }
         ];
    }
    else if([UIScreen mainScreen].bounds.size.height==568)
    {
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                         animations:^{
                             self.view.transform = CGAffineTransformMakeTranslation(0, -250);
                         }
         ];
    }
    else
    {
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                         animations:^{
                             self.view.transform = CGAffineTransformMakeTranslation(0, -250);
                         }
         ];
        
    }
    
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                     animations:^{
        self.view.transform = CGAffineTransformIdentity;
                                 }
    ];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_obtainField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _NewObtan.enabled = YES;
    return YES;
}

- (void)initModel:(id)data
{
    _arrynumber = [data mutableCopy];
    
    [self startSetButton];
}
/**
 *  创建button
 *
 *  @param sender
 */
#pragma mark - 创建button
-(void)startSetButton
{
    float w = ([UIScreen mainScreen].bounds.size.width-20-40)/3;
    
    for (int i = 0; i < [_arrynumber count]; i++)
    {
        
        UIButton *bnt = [[UIButton alloc] initWithFrame:CGRectMake(10+(i%3)*(w+20), 10+(i/3)*50, w, 30)];
        
        bnt.layer.masksToBounds = YES;
        bnt.layer.cornerRadius = 6;
        bnt.layer.borderWidth = 1;
        [bnt setTitleColor:[UIColor colorWithRed:77/255.0 green:74/255.0 blue:77/255.0 alpha:1] forState:UIControlStateNormal];
        bnt.layer.borderColor = [[UIColor blackColor] CGColor];
        bnt.backgroundColor = [UIColor clearColor];

        _scrollview.contentSize =CGSizeMake([UIScreen mainScreen].bounds.size.width, ([_arrynumber count]/3*30+([_arrynumber count]/3-1)*50 )-self.navigationController.navigationBar.frame.size.height);
        
        bnt.tag = i;
        NSString *tagNames = _arrynumber[i][@"tagName"];
        if ([tagNames length] > 5)
        {
            bnt.titleLabel.font = [UIFont systemFontOfSize:9];
            [bnt setTitle:tagNames forState:UIControlStateNormal];
        }
        else
        {
            bnt.titleLabel.font = [UIFont systemFontOfSize:15];
            [bnt setTitle:tagNames forState:UIControlStateNormal];
        }
        
        
        [bnt addTarget:self action:@selector(bntclik:) forControlEvents:UIControlEventTouchUpInside];
        
        [_scrollview addSubview:bnt];
        
        BtnModel *model = [[BtnModel alloc] init];
        model.isSucceed = NO;
        model.btnTitle = _arrynumber[i][@"tagName"];
        model.tag = _arrynumber[i][@"id"];
        model.type = _arrynumber[i][@"type"];
        
        [_btnModelArray addObject:model];
    }
}
/**
 *  标签触发的事件
 *
 *  @param sender
 */
#pragma mark -标签button
-(void)bntclik:(UIButton *)sender
{
    BtnModel *tnModel = _btnModelArray[sender.tag];
    tnModel.isSucceed = !tnModel.isSucceed;
    
    if (tnModel.isSucceed)
    {
        sender.backgroundColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];;
    }
    else
    {
        sender.backgroundColor = [UIColor clearColor];
    }
}
/**
 *  提交新添加的标签
 *
 *  @param sender
 */
#pragma mark -提交新添加的标签
- (IBAction)newObtainlable:(UIButton *)sender {
    
    [_obtainField resignFirstResponder];
    
    float w = ([UIScreen mainScreen].bounds.size.width-20-40)/3;
    
    if (_obtainField.text.length  == 0 || !_obtainField.text)
    {
        
    }
    else
    {
        if (_obtainField.text.length >9) {
            
//            UIAlertView *promptalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"标签内容不能超过8个字" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
//            
//            [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timeOver:) userInfo:promptalert repeats:YES];
//            
//            [promptalert show];
            [KVNProgress showErrorWithStatus:@"标签内容不能超过8个字"];
            
        }
        else
        {
        NSInteger iod = [_btnModelArray count];
        iod ++;
        BtnModel *mdl = [[BtnModel alloc] init];
        mdl.tag = [NSString stringWithFormat:@"%ld",(long)iod];
        
        mdl.isSucceed = YES;
        mdl.type = @"0";
        NSString *interestName = _obtainField.text;
        interestName = [interestName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        interestName = [interestName stringByReplacingOccurrencesOfString:@" " withString:@""];
        interestName = [interestName stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        interestName = [interestName stringByReplacingOccurrencesOfString:@"\n" withString:@""];

        mdl.btnTitle = interestName;
       
        UIButton *bntt = [[UIButton alloc] initWithFrame:CGRectMake(10+([_btnModelArray count]%3)*(w+20), 10+([_btnModelArray count]/3)*50, w, 30)];
        bntt.layer.masksToBounds = YES;
        bntt.layer.cornerRadius = 6;
        bntt.layer.borderWidth = 1;
        bntt.layer.borderColor = [[UIColor blackColor] CGColor];
        bntt.backgroundColor = [UIColor clearColor];
        [bntt setTitleColor:[UIColor colorWithRed:77/255.0 green:74/255.0 blue:77/255.0 alpha:1] forState:UIControlStateNormal];
        bntt.tag =(NSInteger)mdl.tag;
        NSString *lableltitle = mdl.btnTitle;
        if ([lableltitle length] > 5)
        {
            bntt.titleLabel.font = [UIFont systemFontOfSize:9];
            [bntt setTitle:lableltitle forState:UIControlStateNormal];
        }
        else
        {
            bntt.titleLabel.font = [UIFont systemFontOfSize:15];
            [bntt setTitle:lableltitle forState:UIControlStateNormal];
        }
        bntt.enabled = NO;
        bntt.backgroundColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
        [bntt addTarget:self action:@selector(bntclik:) forControlEvents:UIControlEventTouchUpInside];
      

        _obtainField.text = nil;
        [_btnModelArray addObject:mdl];
        [_scrollview addSubview: bntt];
            
        }
    }
}

//-(void)timeOver:(NSTimer *)theTimer
//{
//    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
//    
//    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
//    
//    [promptAlert removeFromSuperview];
//    
//    
//}
#pragma mark -上传选择标签
- (IBAction)ObtainSucceed:(UIBarButtonItem *)sender {
    
   
    _sumbitArray = [NSMutableArray array];
    
    
    //重模型数组中 获取出选中button的tittle
    
    for (BtnModel *models in _btnModelArray)
    {
        if (models.isSucceed)
        {
            
            [_sumbitArray addObject:models];
            
        }
    }
    _dictArray = [NSMutableArray array];
    
    for (int i= 0; i< [_sumbitArray count]; i++) {
        
        BtnModel *models = _sumbitArray[i];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:models.tag forKey:@"id"];
        [dic setObject:models.btnTitle forKey:@"tagName"];
        [dic setObject:models.type forKey:@"type"];
        
        [_dictArray addObject:[dic mutableCopy]];
    }
    
    if (_dictArray == nil || !_dictArray) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HostViewController"];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
        [UIApplication sharedApplication].keyWindow.rootViewController = viewController;
        // [self performSegueWithIdentifier:@"sendObtainlable" sender:self];
    }
    else
    {
    __weak ObtainLableViewController *weakSelf = self;
    MBProgressHUD *hud = [Utils waiting:weakSelf msg:@"正在处理中.."];
    NSInteger ret = [[FreeSingleton sharedInstance] postobtainLaleOncompletion:[_dictArray JSONString] block:^(NSUInteger retcode, id data) {
                [Utils hideHUD:hud];
        if (retcode == RET_SERVER_SUCC)
        {
            NSLog(@"%@", data);

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HostViewController"];
            
            [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = viewController;
            [self setUserInfo];
            
            //[self performSegueWithIdentifier:@"sendObtainlable" sender:self];
        }
        else
            {
                [Utils warningUserAfterJump:weakSelf msg:@"失败" time:1.5];
                NSLog(@"tag error is %@", data);
            }
    }];
    
        if (ret != RET_OK)
        {
            [Utils warningUser:self msg:zcErrMsg(ret)];
        }
    
    }
}

- (void) setUserInfo
{
    
    [[NSUserDefaults standardUserDefaults] setObject:_dictArray forKey:KEY_LABLE_NUM];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}


#pragma mark -滑动隐藏键盘
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self.obtainField resignFirstResponder];
    
}
@end
