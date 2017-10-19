//
//  UpdateMyNameViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/4.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "UpdateMyNameViewController.h"
#import "FreeSingleton.h"

@interface UpdateMyNameViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *input_text;

@end

@implementation UpdateMyNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:_input_text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_input_text];
    
    if (_nickName != nil && [_nickName length]!= 0)
    {
        _input_text.text = _nickName;
    }
    
    _input_text.delegate = self;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(commitFriendName:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelFriendName:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    self.navigationItem.title = @"修改备注";
    _input_text.clearButtonMode = UITextFieldViewModeAlways;
    _input_text.returnKeyType = UIReturnKeyDone;
    _input_text.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    [_input_text becomeFirstResponder];
}

- (void)commitFriendName:(id)sender
{
    [_input_text resignFirstResponder];
    __weak UpdateMyNameViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"];
    
    NSString *input_text = _input_text.text;
    
    NSInteger retcode = [[FreeSingleton sharedInstance] userEditNickNameOnCompletion:input_text block:^(NSUInteger ret, id data){
//        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showSuccessWithStatus:@"更改成功"
                                            onView:weakSelf.view];
            });
            
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:KEY_NICK_NAME];
            [FreeSingleton sharedInstance].nickName = data;
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DID_IMG_CHANGED object:nil];
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showErrorWithStatus:data
                                          onView:weakSelf.view];
            });
        }
    }];
    if (retcode != RET_OK) {
//        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)
                                  onView:weakSelf.view.window];
    }
}

- (void)cancelFriendName:(id)sender
{
    [_input_text resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
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
