//
//  InterestViewController.m
//  Free
//
//  Created by yangcong on 15/5/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "InterestViewController.h"
#import "FreeSingleton.h"
#import "Error.h"
#import "BtnModel.h"
#import "JSONKit.h"
#import "Utils.h"
#import "MyInfoTableViewController.h"

@interface InterestViewController ()
{
    BOOL isInteres;

}
@property (nonatomic,strong) NSMutableArray *interestLable;

@property (nonatomic,strong) NSMutableArray *arrynumber;
@property (nonatomic,strong) NSMutableArray *btnModelArray;
@property (nonatomic,strong) NSMutableArray *sumbitArray;
@property (nonatomic,strong) NSMutableArray *dictArray;

@property (weak, nonatomic) IBOutlet UITextField *obtainField;
@property (weak, nonatomic) IBOutlet UIButton *NewObtan;
@property (weak, nonatomic) IBOutlet UIView *InterBG;
@property (strong, nonatomic) NSMutableArray *existlable;

@property (strong, nonatomic) NSMutableArray *allArray;
@property UIScrollView *scrollview;

@end

@implementation InterestViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _interestLable = [NSMutableArray array];
    
    _interestLable = [[FreeSingleton sharedInstance] getLalbeTitle];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_obtainField];
    [self initView];
    [self initData];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:_obtainField];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIViewController *setPrizeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    if ([setPrizeVC isKindOfClass:[MyInfoTableViewController class]]) {
        MyInfoTableViewController *vc = (MyInfoTableViewController *)setPrizeVC;
        vc.isNeedRefresh = YES;
    }
}

-(void)initData
{
    
    _arrynumber = [NSMutableArray array];
    
    _btnModelArray = [NSMutableArray array];
    
    _existlable = [NSMutableArray array];
    
    [KVNProgress showWithStatus:@"Loading"];
    
    __weak InterestViewController *weakSelf = self;
    
    [[FreeSingleton sharedInstance] getobtainLableOncompletion:^(NSUInteger ret, id data)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [KVNProgress dismiss];
         });
         if (ret == RET_SERVER_SUCC)
         {
             [weakSelf initModel:data];
         }
         
     }];
}
- (IBAction)keyBoard:(UIControl *)sender {
    
    [_obtainField resignFirstResponder];
    [_scrollview resignFirstResponder];

}
-(void)initView
{
    
    isInteres = NO;
    
    self.tabBarController.tabBar.hidden = YES;
    
    _btnModelArray = [NSMutableArray array];
    
    _scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-110)];

    _scrollview.delegate = self;
    
    [self.view addSubview:_scrollview];
    _obtainField.delegate = self;
    _NewObtan.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    _obtainField.returnKeyType = UIReturnKeyDone;
    _obtainField.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    
    _NewObtan.layer.borderColor = [[UIColor clearColor] CGColor];
    _NewObtan.layer.masksToBounds = YES;
    _NewObtan.layer.cornerRadius = 5;
    _NewObtan.backgroundColor  = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
    
    _InterBG.backgroundColor = [UIColor whiteColor];
    _InterBG.layer.borderWidth = 1;
    _InterBG.layer.borderColor =[[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0] CGColor];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Actiondo:)];
    
    [_scrollview addGestureRecognizer:tapGesture];
    
}

-(void)Actiondo:(UITapGestureRecognizer *)tap
{
    [self.obtainField resignFirstResponder];
}


-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    if (isInteres == YES) {
        
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
        
        [self setUserInfo];
        __weak InterestViewController *weakSelf = self;
        NSInteger ret = [[FreeSingleton sharedInstance] postobtainLaleOncompletion:[_dictArray JSONString] block:^(NSUInteger retcode, id data) {
            if (retcode == RET_SERVER_SUCC)
            {
                [weakSelf setUserInfo];
            }
            else
            {
                NSLog(@"tag error is %@", data);
            }
        }];
        
        if (ret != RET_OK) {
            [KVNProgress showErrorWithStatus:zcErrMsg(ret)];
        }
    }
    else
    {
        NSLog(@"没有选择");
    }

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
//数据库
- (void)initModel:(id)data
{
    _arrynumber = data;
    
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
    
    _allArray = [NSMutableArray array];
    
    if ([_interestLable count]) {
        _allArray = [NSMutableArray arrayWithArray:_interestLable];
    }
    //本地数据
    
    if (!_allArray || _allArray.count == 0)
    {
        for (int i = 0; i < [_arrynumber count]; i++)
        {
            BtnModel *model = [[BtnModel alloc] init];
            model.isSucceed = NO;
            model.btnTitle = _arrynumber[i][@"tagName"];
            model.tag = _arrynumber[i][@"id"];
            model.type = _arrynumber[i][@"type"];
            [_btnModelArray addObject:model];
        }
    }
    else
        {
            for (int i = 0; i<_interestLable.count; i++) {
                
                BtnModel *model = [[BtnModel alloc] init];
                model.isSucceed = YES;
                model.btnTitle = _interestLable[i][@"tagName"];
                model.tag = _interestLable[i][@"id"];
                model.type = _interestLable[i][@"type"];
                [_btnModelArray addObject:model];
            }
            //数据库
            for (int i = 0; i < _arrynumber.count; i++)
            {
                NSString *tagNames = _arrynumber[i][@"tagName"];

                for (int j = 0; j<[_interestLable count]; j++) {
            
                    NSString *lableName = _interestLable[j][@"tagName"];
            
                    if ([lableName isEqualToString:tagNames]) {
                
                        break;
                    }
            
                    if (j == _interestLable.count - 1) {
                
                        NSDictionary *dic = _arrynumber[i];
                        
                        [_allArray addObject:dic];
                
                        BtnModel *model = [[BtnModel alloc] init];
                        model.isSucceed = NO;
                        model.btnTitle = dic[@"tagName"];
                        model.tag = dic[@"id"];
                        model.type = dic[@"type"];
                        [_btnModelArray addObject:model];

                    }
        }
    }
}
    _scrollview.contentSize =CGSizeMake([UIScreen mainScreen].bounds.size.width, ([_btnModelArray count]%3?[_btnModelArray count]/3 + 1:[_btnModelArray count]/3)*50);
    
    for (int i = 0; i < [_btnModelArray count]; i++)
    {
         //NSString *tagNames = _arrynumber[i][@"tagName"];
        BtnModel *model = _btnModelArray[i];
    
            UIButton *bnt = [[UIButton alloc] initWithFrame:CGRectMake(10+(i%3)*(w+20), 10+(i/3)*50, w, 30)];
            
            bnt.layer.masksToBounds = YES;
            bnt.layer.cornerRadius = 6;
            bnt.layer.borderWidth = 1;
            [bnt setTitleColor:[UIColor colorWithRed:77/255.0 green:74/255.0 blue:77/255.0 alpha:1] forState:UIControlStateNormal];
            bnt.layer.borderColor = [[UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1] CGColor];
            bnt.backgroundColor = [UIColor clearColor];
            bnt.tag = i;
        
        
        
            if ([model.btnTitle length] > 5)
            {
                bnt.titleLabel.font = [UIFont systemFontOfSize:9];
                [bnt setTitle:model.btnTitle forState:UIControlStateNormal];
            }
            else
            {
                bnt.titleLabel.font = [UIFont systemFontOfSize:15];
                [bnt setTitle:model.btnTitle forState:UIControlStateNormal];
            }
        
            [bnt addTarget:self action:@selector(bntclik:) forControlEvents:UIControlEventTouchUpInside];
        
        if (model.isSucceed) {
            
            bnt.backgroundColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
        }

        
            [_scrollview addSubview:bnt];
       
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
    isInteres = YES;
    
    BtnModel *tnModel = _btnModelArray[sender.tag];
    tnModel.isSucceed = !tnModel.isSucceed;
    
    if (tnModel.isSucceed)
    {
        sender.backgroundColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
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
    
    isInteres = YES;
    
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
        isInteres = YES;
            
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
        
//        [bntt addTarget:self action:@selector(bntclikes:) forControlEvents:UIControlEventTouchUpInside];
        
        _scrollview.contentSize =CGSizeMake([UIScreen mainScreen].bounds.size.width, ([_btnModelArray count]%3?[_btnModelArray count]/3 + 1:[_btnModelArray count]/3)*54);
        isInteres = YES;
        
        _obtainField.text = nil;
        
        [_btnModelArray addObject:mdl];
        
        [_scrollview addSubview: bntt];
        }
    }
}


#pragma mark -滑动隐藏键盘
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self.obtainField resignFirstResponder];
    
}
#pragma mark 键盘即将退出
- (void)keyBoardWillShow:(NSNotification *)note
{
    if ([UIScreen mainScreen].bounds.size.height > 700) {
        
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                         animations:^{
                             self.view.transform = CGAffineTransformMakeTranslation(0, -275);
                         }
         ];
    }
    else if([UIScreen mainScreen].bounds.size.height == 667)
    {
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                         animations:^{
                             self.view.transform = CGAffineTransformMakeTranslation(0, -265);
                         }
         ];
    }
    else if([UIScreen mainScreen].bounds.size.height == 568)
    {
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                         animations:^{
                             self.view.transform = CGAffineTransformMakeTranslation(0, -255);
                         }
         ];
    }
    else
    {
        [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                         animations:^{
                             self.view.transform = CGAffineTransformMakeTranslation(0, -245);
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
- (void) setUserInfo
{
    [[NSUserDefaults standardUserDefaults] setObject:_dictArray forKey:KEY_LABLE_NUM];
    [FreeSingleton sharedInstance].lableArray = _dictArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    
    // NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > 8) {
                textField.text = [toBeString substringToIndex:8];
            }
        }
        else{
            
        }
    }
    else{
        if (toBeString.length > 8) {
            textField.text = [toBeString substringToIndex:8];
        }
    }
}

@end
