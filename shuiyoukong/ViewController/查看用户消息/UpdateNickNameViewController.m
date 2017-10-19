//
//  UpdateNickNameViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "UpdateNickNameViewController.h"
#import "FreeSingleton.h"
#import "FreeSQLite.h"

@interface UpdateNickNameViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *text_input;

@end

@implementation UpdateNickNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:_text_input];
}

- (void)initView
{
    if (_friendName != nil && [_friendName length]!= 0)
    {
        _text_input.text = _friendName;
    }
    
    _text_input.delegate = self;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(commitFriendName:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelFriendName:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    self.navigationItem.title = @"修改备注";
    _text_input.clearButtonMode = UITextFieldViewModeAlways;
    _text_input.returnKeyType = UIReturnKeyDone;
    _text_input.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    [_text_input becomeFirstResponder];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_text_input];
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
            if (toBeString.length > 15) {
                textField.text = [toBeString substringToIndex:15];
            }
        }
        else{
            
        }
    }
    else{
        if (toBeString.length > 15) {
            textField.text = [toBeString substringToIndex:15];
        }
    }
}

- (void)commitFriendName:(id)sender
{
    
    [_text_input resignFirstResponder];
    __weak UpdateNickNameViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"];
    NSMutableDictionary *dict = [[FreeSQLite sharedInstance] selectFreeSQLiteUserInfo:_accountId];
    NSString *input_text = _text_input.text;
    if ([_text_input.text isEqualToString:@""])
    {
        input_text = dict[@"friendName"];
    }
    
    NSInteger retcode = [[FreeSingleton sharedInstance] updateFriendNameOnCompletion:dict[@"id"] friendName:input_text block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            [[FreeSQLite sharedInstance] updateFriendNameFreeSqLIteSQLiteAdressList:_accountId friendName:input_text];
//            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:nil];//触发刷新通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPDATE_FRIENDNAME object:input_text];//触发刷新通知
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"修改失败"];
        }
    }];
    
    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
    }
}

- (void)cancelFriendName:(id)sender
{
    [_text_input resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
