//
//  EditTitleViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "EditTitleViewController.h"
#import "CreateActivityViewController.h"

@interface EditTitleViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *text_input;

@end

@implementation EditTitleViewController

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
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:nil];
}

#pragma mark - initView
- (void)initView
{
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    UIBarButtonItem *backIteme = [[UIBarButtonItem alloc]init];
    backIteme.title = @" ";
    self.navigationItem.backBarButtonItem = backIteme;
    
    self.navigationItem.title = @"填写活动标题";
    
    if ([_activity_title length]) {
        _text_input.text = _activity_title;
    }
    
    [_text_input becomeFirstResponder];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(sendTitle)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_text_input];
}


- (void)sendTitle
{
    UIViewController *setPrizeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    if (![setPrizeVC isKindOfClass:[CreateActivityViewController class]]) {
        return;
    }
    
    CreateActivityViewController *vc = (CreateActivityViewController *)setPrizeVC;
    
    NSString *str = _text_input.text;
    vc.activity_title = str;
    
    //使用popToViewController返回并传值到上一页面
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    
    // NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > 20) {
                textField.text = [toBeString substringToIndex:20];
            }
        }
        else{
            
        }
    }
    else{
        if (toBeString.length > 20) {
            textField.text = [toBeString substringToIndex:20];
        }
    }
}

@end
