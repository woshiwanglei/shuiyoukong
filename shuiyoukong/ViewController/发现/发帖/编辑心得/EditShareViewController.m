//
//  EditShareViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/17.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "EditShareViewController.h"
#import "WritePostViewController.h"
#import "CreateActivityViewController.h"
#import "settings.h"

@interface EditShareViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *text_view;
@property (weak, nonatomic) IBOutlet UILabel *label_num;

@property (assign,nonatomic)BOOL isPost;

@end

@implementation EditShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_text_view resignFirstResponder];
}

- (void)dealloc
{
    _text_view.delegate = nil;
}

- (void)initView
{
    _text_view.delegate = self;
    _text_view.tintColor = FREE_BACKGOURND_COLOR;
    _text_view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _text_view.layer.borderWidth = 0.5f;
    
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(sendShare)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIViewController *setPrizeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    if ([setPrizeVC isKindOfClass:[WritePostViewController class]]) {
        self.navigationItem.title = @"心得推荐";
        _isPost = YES;
    }
    else if ([setPrizeVC isKindOfClass:[CreateActivityViewController class]])
    {
        _label_num.text = @"200";
        self.navigationItem.title = @"活动内容";
        _isPost = NO;
    }
    
    //自定义返回键
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"style:UIBarButtonItemStylePlain target:self action:@selector(btn_back)];
    
    if ([_text_content length]) {
        _text_view.text = _text_content;
        int num = _isPost ? 1000:200;
        _label_num.text = [NSString stringWithFormat:@"%lu", (long)(num - [_text_content length])];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [_text_view becomeFirstResponder];
}

- (void)sendShare
{
//    [_text_view resignFirstResponder];
    UIViewController *setPrizeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
        //初始化其属性
    NSString *str = _text_view.text;
    
    if ([setPrizeVC isKindOfClass:[WritePostViewController class]]) {
        WritePostViewController *vc = (WritePostViewController *)setPrizeVC;
        vc.share_Content = str;
    }
    else if ([setPrizeVC isKindOfClass:[CreateActivityViewController class]])
    {
        CreateActivityViewController *vc = (CreateActivityViewController *)setPrizeVC;
        vc.activity_content = str;
    }
    
    //使用popToViewController返回并传值到上一页面
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btn_back
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"要放弃这次编辑吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];

    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 其他
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [_text_view resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView
{
    int num = _isPost ? 1000:200;
    if ([textView.text length] > num) {
        textView.text = [textView.text substringToIndex:num];
    }
    _label_num.text = [NSString stringWithFormat:@"%lu", (long)(num - [textView.text length])];
}

@end
