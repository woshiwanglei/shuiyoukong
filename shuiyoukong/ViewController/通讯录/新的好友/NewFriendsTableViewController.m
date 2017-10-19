//
//  NewFriendsTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/20.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "NewFriendsTableViewController.h"
//#import "AddressListTableViewCell.h"
#import "FreeSQLite.h"
#import "settings.h"
#import "showUserInfoViewController.h"
#import "followFriendsTableViewCell.h"
#import "FreeSingleton.h"

@interface NewFriendsTableViewController ()

@property (strong, nonatomic)NSMutableArray *modelArray;
@property (strong, nonatomic)NSMutableArray *friendsModelArray;
@property (weak, nonatomic)NSString *identifier;

@end

@implementation NewFriendsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (void)initView
{
    _identifier = @"followFriendsTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    //设置tableview滑动速度
    self.tableView.decelerationRate = 0.5;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIColor *color = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202.0/255.0 alpha:1];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dic ;
    self.navigationItem.title = @"新的朋友";
    
    if (_modelArray.count == 0)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_newfriends"]];
        imageView.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 90)/2, ([[UIScreen mainScreen] bounds].size.height - 239)/2 , 100, 120);
        
        [self.tableView addSubview:imageView];
    }
}

- (void)initData
{
    NSMutableArray *dataSource = [NSMutableArray array];
    [[FreeSQLite sharedInstance] selectFreeSQLiteAddressListNew:dataSource];
    [[FreeSQLite sharedInstance] updateFreeSQLiteAddressListNewFriends];
    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:nil];//刷新第一个表
    NSMutableArray *dataArray = [NSMutableArray array];
    [[FreeSQLite sharedInstance] selectFreeSQLiteNewFriends:dataArray];
    
    _modelArray = [NSMutableArray array];
    _friendsModelArray = [NSMutableArray array];
    for (int i = 0; i < [dataSource count]; i++) {
        [self add2ModelArray:dataSource[i]];
    }
    for (int i = 0; i < [dataArray count]; i++) {
        [self add2FriendsArray:dataArray[i]];
    }
}

- (void)add2ModelArray:(id)data
{
    AddressListCellModel *model = [[AddressListCellModel alloc] init];
    model.user_name = data[@"friendName"];
    model.img_url = data[@"imgUrl"];
    model.Id = data[@"id"];
    model.status = data[@"status"];
    model.isTurnOn = YES;
    
    [_modelArray addObject:model];
}

- (void)add2FriendsArray:(id)data
{
    AddressListCellModel *model = [[AddressListCellModel alloc] init];
    model.session_id = data[@"SessionId"];
    model.user_name = data[@"friendName"];
    model.img_url = data[@"headImg"];
    model.Id = data[@"friendAccountId"];
    model.status = data[@"status"];
    model.pinyin = data[@"pinyin"];
    model.phoneNo = data[@"phoneNo"];
    [_modelArray addObject:model];
}

#pragma -mark tableview controller

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_modelArray) {
        return [_modelArray count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    followFriendsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[followFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    
    cell.model = _modelArray[indexPath.row];
    cell.tag = indexPath.row;
    
    [cell.btn_add addTarget:self action:@selector(addFriendMothed:) forControlEvents:UIControlEventTouchDown];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    showUserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"showUserInfoSID"];
    AddressListCellModel *model = _modelArray[indexPath.row];
    vc.friend_id = model.Id;
    vc.friend_name = model.user_name;
    vc.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = self.navigationController;
    [navigationController pushViewController:vc animated:YES];
}

#pragma mark - 添加朋友
- (void)addFriendMothed:(UIButton *)btn
{
    AddressListCellModel *model = _modelArray[btn.tag];
    if (model.session_id) {
        [self addFriend:model button:btn];
    }
}

- (void)addFriend:(AddressListCellModel *)model button:(UIButton *)btn
{
    btn.userInteractionEnabled = NO;
    
    NSInteger retcode = [[FreeSingleton sharedInstance] addFriendOnCompletion:model.Id friendName:model.user_name pinyin:model.pinyin phoneNo:model.phoneNo headImg:model.img_url block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            [[FreeSQLite sharedInstance] updateFreeSQLiteNewFriends:data[@"friendAccountId"] status:data[@"status"]];
            [[FreeSQLite sharedInstance] deleteFreeSQLiteAddressList:data[@"friendAccountId"]];
            [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:data[@"friendAccountId"] friendName:data[@"friendName"] nickName:data[@"friendName"] headImg:data[@"headImg"] Id:data[@"id"] phoneNo:data[@"phoneNo"] pinyin:data[@"pinyin"] status:data[@"status"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:nil];//触发刷新通知
            [btn setTitle:@"已关注" forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor clearColor];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        else
        {
            btn.userInteractionEnabled = YES;
            [KVNProgress showErrorWithStatus:data];
        }
        
    }];
    
    if (retcode != RET_OK) {
        btn.userInteractionEnabled = YES;
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
    }
}

#pragma mark - 添加滑动删除
//判断是否是删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;
    if ([tableView isEqual:self.tableView]) {
        AddressListCellModel *model = _modelArray[indexPath.row];
        if (indexPath.row < [_modelArray count] && model.session_id) {
            result = UITableViewCellEditingStyleDelete;
        }
    }
    return result;
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}
//进行删除用户数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{//请求数据源提交的插入或删除指定行接收者。
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        if (indexPath.row < [_modelArray count]) {
            //移除数据源的数据
            AddressListCellModel *model = _modelArray[indexPath.row];
            
            [[FreeSQLite sharedInstance] deleteFreeSQLiteNewFriends:model.session_id];
            
            [_modelArray removeObjectAtIndex:indexPath.row];
        }
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
        [tableView endUpdates];
    }
}

@end