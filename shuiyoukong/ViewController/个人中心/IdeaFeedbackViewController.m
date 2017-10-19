//
//  IdeaFeedbackViewController.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/5/20.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "IdeaFeedbackViewController.h"
#import "FreeSingleton.h"
#import "Utils.h"
#import "PostViewController.h"
#import "FreeWebViewController.h"
#import "MorePostViewController.h"

@interface IdeaFeedbackViewController ()

@property (strong,nonatomic)UILabel *proLable;
@property (assign, nonatomic)BOOL isRepost;
@end

@implementation IdeaFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}
-(void)initView
{
    UIViewController *setPrizeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    if ([setPrizeVC isKindOfClass:[PostViewController class]] || [setPrizeVC isKindOfClass:[FreeWebViewController class]] || [setPrizeVC isKindOfClass:[MorePostViewController class]]) {
        _isRepost = YES;
    }
    
    self.tabBarController.tabBar.hidden = YES;
    _ideaTextview.delegate = self;
    _proLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 300, 15)];
    _proLable.textColor = [UIColor lightGrayColor];
    if (_isRepost) {
        _proLable.text = @"请写出您举报的理由。";
        self.navigationItem.title = @"举报";
    }
    else
    {
        _proLable.text = @"亲，你有什么要求与建议尽管提，我们尽量满足你噢！";
    }
    
    _proLable.font = [UIFont systemFontOfSize:12];
    [_ideaTextview setTintColor:FREE_BACKGOURND_COLOR];
    [_ideaTextview  addSubview:_proLable];
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
//    [_ideaTextview becomeFirstResponder];
    _ideaTextview.returnKeyType = UIReturnKeyDone;
}

- (IBAction)sendidea:(UIBarButtonItem *)sender {
    
    [self sendNewIdea];
}
-(void)sendNewIdea
{
    __weak IdeaFeedbackViewController *weakSelf = self;
    NSInteger ret = [[FreeSingleton sharedInstance] sendIdeaCompletion:_ideaTextview.text block:^(NSUInteger retcode, id data)
    {
        if (retcode == RET_SERVER_SUCC)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_isRepost) {
                    [KVNProgress showSuccessWithStatus:@"举报成功，谢谢您对谁有空的意见与支持"
                                                onView:weakSelf.view.window];
                }
                else
                {
                    [KVNProgress showSuccessWithStatus:@"意见发送成功，谢谢您对谁有空的意见与支持"
                                                onView:weakSelf.view.window];
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showErrorWithStatus:@"意见发送失败"];
            });
        }
    }];
    if (ret != RET_OK)
    {
        [KVNProgress showErrorWithStatus:zcErrMsg(ret)];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        
        [_proLable setHidden:NO];
    }
    else
    {
        [_proLable setHidden:YES];
    }
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    _proLable.hidden = YES;
    
    [_proLable removeFromSuperview];
    
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
