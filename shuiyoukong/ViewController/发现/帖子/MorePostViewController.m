//
//  MorePostViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/22.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MorePostViewController.h"
#import "FreeSingleton.h"
#import "RepostTableViewCell.h"
#import "MJRefresh.h"
#import "EditRepostView.h"
#import "AppDelegate.h"
#import "FreeSQLite.h"

#define OTHER 123
#define MY_REPOST 321

@interface MorePostViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIView *bottom_view;
@property (weak, nonatomic) IBOutlet UITextField *input_textfiled;
@property (strong, nonatomic)NSMutableArray *model_array;
@property (weak, nonatomic)NSString *identifier;

@property (strong, nonatomic)EditRepostView *editRepostView;
@property (strong, nonatomic)RepostModel *selectedModel;
@property (strong, nonatomic)UIView *backView;
@end

@implementation MorePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - initView
- (void)initView
{
    self.navigationItem.title = @"评论";
    _identifier = @"RepostTableViewCell";
    [self.mTableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    _input_textfiled.delegate = self;
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    //设置tableview滑动速度
    self.mTableView.decelerationRate = 0.5;
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    self.mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    
    _bottom_view.layer.borderWidth = 0.5;
    _bottom_view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [_mTableView addFooterWithTarget:self action:@selector(footerRereshing)];
    _mTableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
    _mTableView.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    _mTableView.footerRefreshingText = @"正在加载中";
}

#pragma mark - initData
- (void)initData
{
    _model_array = [NSMutableArray array];
    [self footerRereshing];
}

- (void)footerRereshing
{
    NSString *postId = @"0";
    if ([_model_array count]) {
        RepostModel *model = [_model_array lastObject];
        postId = model.repostId;
    }
    
    [KVNProgress showWithStatus:@"Loading"];
    __weak MorePostViewController *weakSelf = self;
    NSInteger retcode = [[FreeSingleton sharedInstance] queryRepostOnCompletion:_postId pageNo:@"1" pageSize:@"20" repostId:postId block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
                [weakSelf addModel2Array:data[@"items"]];
                [_mTableView reloadData];
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"内部错误"];
        }
        [_mTableView footerEndRefreshing];
    }];
    
    if (retcode != RET_OK) {
        [_mTableView footerEndRefreshing];
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
    }
}

- (void)addModel2Array:(id)data
{
    for (int i = 0; i < [data count]; i++) {
        RepostModel *model = [[RepostModel alloc] init];
        NSDictionary *dic = data[i];
//        model.nickName = dic[@"nickName"];
        model.accountId = [NSString stringWithFormat:@"%@", dic[@"accountId"]];
        
        NSString *friendName = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:model.accountId];
        if (friendName) {
            model.nickName = friendName;
        }
        else
        {
            model.nickName = dic[@"nickName"];
        }
        
        model.headImg = dic[@"headImg"];
        model.repostId = [NSString stringWithFormat:@"%@", dic[@"repostId"]];
        model.content = dic[@"content"];
        model.repostTime = [NSString stringWithFormat:@"%@", dic[@"repostTime"]];
        
        if (![dic[@"originalRepostName"] isKindOfClass:[NSNull class]]) {
            model.originalRepostName = dic[@"originalRepostName"];
        }
        
        [_model_array addObject:model];
    }
}

#pragma mark - textfiled
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _selectedModel = nil;
    [self inputViewWillAppear];
    return NO;
}

-(void)keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    _editRepostView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _editRepostView.frame.size.width, 190);
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    _editRepostView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height - keyboardBounds.size.height - 190, _editRepostView.frame.size.width, _editRepostView.frame.size.height);
    
    // commit animations
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    _editRepostView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _editRepostView.frame.size.width, _editRepostView.frame.size.height);
    
    // commit animations
    [UIView commitAnimations];
    _selectedModel = nil;
}

- (void)inputViewWillAppear
{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_backView setBackgroundColor:[UIColor colorWithRed:(0/255.0)
                                                      green:(0/255.0)  blue:(0/255.0) alpha:.4]];
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
        [_backView addGestureRecognizer:tapView];
    }
    
    if (![_backView superview]) {
        [[AppDelegate getMainWindow] addSubview:_backView];
        
        if (!_editRepostView) {
            _editRepostView = [[[NSBundle mainBundle] loadNibNamed:@"EditRepostView"
                                                             owner:self
                                                           options:nil] objectAtIndex:0];
            [_editRepostView.btn_cancel addTarget:self action:@selector(send_cancel:) forControlEvents:UIControlEventTouchDown];
            [_editRepostView.btn_send addTarget:self action:@selector(send_add:) forControlEvents:UIControlEventTouchDown];
        }
        
        if (_selectedModel) {
            _editRepostView.repostName = _selectedModel.nickName;
        }
        
        _editRepostView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 190, [UIScreen mainScreen].bounds.size.width, 190);
        [_backView addSubview:_editRepostView];
        [_editRepostView.text_content becomeFirstResponder];
    }
}

-(void)tapChange:(UITapGestureRecognizer *)gureView
{
    if ([_editRepostView.text_content isFirstResponder]) {
        _input_textfiled.text = _editRepostView.text_content.text;
        [_editRepostView.text_content resignFirstResponder];
        [_editRepostView removeFromSuperview];
        [_backView removeFromSuperview];
        return;
    }
}

#pragma mark - 功能
- (void)send_add:(UIButton *)btn
{
    NSString *repostId = nil;
    if (_selectedModel) {
        repostId = _selectedModel.accountId;
    }
    
    NSString* strContent = [_editRepostView.text_content.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *strContent = _editRepostView.text_content.text;
    
    [_editRepostView.text_content resignFirstResponder];
    [_editRepostView removeFromSuperview];
    [_backView removeFromSuperview];
    
    [KVNProgress showWithStatus:@"Loading"];
    __weak MorePostViewController *weakSelf = self;
    NSInteger retcode = [[FreeSingleton sharedInstance] sendRepostOnCompletion:_postId repostId:repostId content:strContent block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            if (data != nil) {
                [KVNProgress showSuccessWithStatus:data];
            }
            else
            {
                [KVNProgress showSuccessWithStatus:@"评论成功"];
            }
            
            _editRepostView.text_content.text = nil;
            _input_textfiled.text = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_REFRESH_REPOST object:nil];
            [weakSelf initData];
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"评论失败"];
        }
    }];
    
    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
    }
}

- (void)send_cancel:(UIButton *)btn
{
    _input_textfiled.text = _editRepostView.text_content.text;
    [_editRepostView.text_content resignFirstResponder];
    [_editRepostView removeFromSuperview];
    [_backView removeFromSuperview];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_model_array count]) {
        return [_model_array count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RepostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[RepostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    cell.vc = self;
    cell.model = _model_array[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_model_array count]) {
        RepostTableViewCell* cell = (RepostTableViewCell *)[self.mTableView dequeueReusableCellWithIdentifier:_identifier];
        RepostModel *model = _model_array[indexPath.row];
        if (model.originalRepostName) {
            cell.text_content.text = [NSString stringWithFormat:@"@%@ %@", model.originalRepostName, model.content];
        }
        else
        {
            cell.text_content.text = model.content;
        }
        CGSize s = [cell.text_content sizeThatFits:CGSizeMake(self.view.frame.size.width - 56 , FLT_MAX)];
        
        return 36.f + 1 + s.height;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedModel = _model_array[indexPath.row];
    
    UIActionSheet *choiceSheet;
    if ([_selectedModel.accountId isEqual:[[FreeSingleton sharedInstance] getAccountId]]) {
        choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"删除", @"复制", @"举报", nil];
        choiceSheet.tag = MY_REPOST;
    }
    else
    {
        choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"回复", @"复制", @"举报", nil];
        choiceSheet.tag = OTHER;
    }
    
    [choiceSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            if (actionSheet.tag == MY_REPOST) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setString:_selectedModel.content];
                UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"确定要删除这条回复吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alerView.delegate = self;
                [alerView show];
            }
            else
            {
                [self inputViewWillAppear];
            }
        }
            break;
        case 1:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:_selectedModel.content];
            UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"复制成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            alerView.delegate = self;
            [alerView show];
        }
            break;
        case 2:
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
            UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"IdeaFeedbackViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showWithStatus:@"Loading"];
        });
        
        __weak MorePostViewController *weakSelf = self;
        [[FreeSingleton sharedInstance] deleteMyRepost:_selectedModel.repostId block:^(NSUInteger ret, id data) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress dismiss];
            });
            if (ret == RET_SERVER_SUCC) {
                [weakSelf initData];
                [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_REFRESH_REPOST object:nil];
            }
            else
            {
                [KVNProgress showErrorWithStatus:data];
            }
        }];
    }
}


@end
