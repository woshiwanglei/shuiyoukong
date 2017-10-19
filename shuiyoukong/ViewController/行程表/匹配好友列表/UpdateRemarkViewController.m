//
//  UpdateRemarkViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/9.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "UpdateRemarkViewController.h"
#import "FreeSingleton.h"

@interface UpdateRemarkViewController ()<UITextViewDelegate>

@end

@implementation UpdateRemarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initView
{
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    _input_textView.delegate = self;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(commitRemark:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelRemark:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    self.navigationItem.title = @"状态编辑";
    
    if (_remark != nil && [_remark length]!= 0) {
        _input_textView.text = _remark;
        _label_placeholder.hidden = YES;
        _label_num.text = [NSString stringWithFormat:@"%lu", (long)(30 - [_remark length])];
    }
    else
    {
        _label_placeholder.hidden = NO;
    }
    _input_textView.returnKeyType = UIReturnKeyDone;
    _input_textView.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    [self.input_textView becomeFirstResponder];
    
}


- (void)commitRemark:(id)sender
{
//    [KVNProgress showWithStatus:@"loading" onView:self.view.window];
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress showWithStatus:@"Loading" onView:self.view.window];
    });
    
    NSString *dateStr = [[FreeSingleton sharedInstance] changeDate2StringDD:[NSDate date]];
    
    __weak UpdateRemarkViewController *weakSelf = self;
    NSInteger retcode = [[FreeSingleton sharedInstance] updateRemarkOnCompletion:_input_textView.text freeDate:dateStr block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_CHANGE_REMARK object:_input_textView.text];//修改remark
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                [KVNProgress showSuccessWithStatus:@"保存成功"];
            }];
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"修改失败" onView:weakSelf.view.window];
        }
        
    }];
    
    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode) onView:weakSelf.view.window];
        NSLog(@"%@", zcErrMsg(retcode));
    }
}

- (void)cancelRemark:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        [_label_placeholder setHidden:NO];
    }
    else
    {
        [_label_placeholder setHidden:YES];
    }
    
    if ([textView.text length] > 30) {
        textView.text = [textView.text substringToIndex:30];
    }
    _label_num.text = [NSString stringWithFormat:@"%lu", (long)(30 - [textView.text length])];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
