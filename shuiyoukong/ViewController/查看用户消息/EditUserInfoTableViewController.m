//
//  EditUserInfoTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "EditUserInfoTableViewController.h"
#import "ShutTableViewCell.h"
#import "UpdateNickNameViewController.h"
#import "FreeSingleton.h"
#import "FreeSQLite.h"

@interface EditUserInfoTableViewController ()<UIActionSheetDelegate>

@property (weak, nonatomic)NSString *identifier;

@end

@implementation EditUserInfoTableViewController

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
   self.navigationItem.title = @"修改备注名";
    _identifier = @"ShutTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 140)];
//    
//    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width - 50, 35)];
//    button.layer.masksToBounds = YES;
//    button.layer.cornerRadius = 6.0;
//    [button setBackgroundColor:[UIColor redColor]];
//    [button setTitle:@"删除好友" forState:UIControlStateNormal];
//    [button setCenter:CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2)];
//    [button addTarget:self action:@selector(buttonDeleteFriend:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:button];
//    self.tableView.tableFooterView = view;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShutTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[ShutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    cell.cellName.text = @"修改昵称";
    cell.cellSwitch.hidden = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Push the view controller.
    UpdateNickNameViewController *vc = [[UpdateNickNameViewController alloc] initWithNibName:@"UpdateNickNameViewController" bundle:nil];
    vc.accountId = _accountId;
    vc.friendName = _friendName;
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 20;
            break;
        default:
            return 0;
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 40;
            break;
        default:
            return 0;
            break;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
#pragma mark - 其他功能
- (void)buttonDeleteFriend:(id)sender
{
    UIActionSheet  *actionsheet = [[UIActionSheet alloc] initWithTitle:@"是否删除该好友?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
    [actionsheet showInView:self.view];
}

#pragma mark-UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(0 == buttonIndex)
    {
        __weak EditUserInfoTableViewController *weakSelf = self;
        [KVNProgress showWithStatus:@"Loading"];
        NSString *accountId = [NSString stringWithFormat:@"%@", _accountId];
        NSInteger retcode = [[FreeSingleton sharedInstance] deleteFriendOnCompletion:accountId block:^(NSUInteger ret, id data) {
            [KVNProgress dismiss];
            if(ret == RET_SERVER_SUCC)
            {
                [[FreeSQLite sharedInstance] updateFreeSQLiteNewFriends:_accountId status:[NSNumber numberWithInt:2]];
                [[FreeSQLite sharedInstance] deleteFreeSQLiteAddressList:accountId];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:nil];//触发刷新通知
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [KVNProgress showErrorWithStatus:data];
            }
        }];
        
        if (retcode != RET_OK) {
            [KVNProgress dismiss];
            [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
        }
    }
}


@end
