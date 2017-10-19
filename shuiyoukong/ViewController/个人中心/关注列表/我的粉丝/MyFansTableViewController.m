//
//  MyFansTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/4.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MyFansTableViewController.h"
#import "AddressListTableViewCell.h"
#import "FreeSingleton.h"
#import "UserInfoViewController.h"

#define CARE 1

@interface MyFansTableViewController ()
@property (nonatomic, weak)NSString *identifier;
@property (nonatomic, strong)NSMutableArray *modelArray;
@property (nonatomic, strong)UIImageView *notice_view;
@end

@implementation MyFansTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _identifier = @"AddressListTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    NSInteger num = 0;
//    for (AddressListCellModel *model in _modelArray) {
//        if ([model.status intValue] != CARE) {
//            num++;
//        }
//    }
//    
//    if (num != [[[FreeSingleton sharedInstance] getMyFollowerNum] intValue]) {
//        [FreeSingleton sharedInstance].my_Follower_Num = [NSString stringWithFormat:@"%ld", (long)num];
//        [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].my_Follower_Num forKey:KEY_FOLLOWER_NUM];
//        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEW_FRIENDS object:nil];
//    }
}

#pragma mark - initView
- (void)initView
{
    self.navigationItem.title = @"关注我的人";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    
    _notice_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_care_friends"]];
    _notice_view.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 90)/2, ([[UIScreen mainScreen] bounds].size.height - 239)/2 , 90, 119);
    [self.view addSubview:_notice_view];
}

- (void)initData
{
    [KVNProgress showWithStatus:@"Loading"];
    __weak MyFansTableViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] getMyFansListOnCompletion:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            if ([data count]) {
                [weakSelf add2Model:data];
                [weakSelf.tableView reloadData];
            }
        }
    }];
}

- (void)add2Model:(id)data
{
    _modelArray = [NSMutableArray array];
    for (int i = 0; i < [data count]; i++) {
        NSDictionary *dic = data[i];
        AddressListCellModel *model = [[AddressListCellModel alloc] init];
        model.Id = [NSString stringWithFormat:@"%@", dic[@"id"]];
        model.friendId = [NSString stringWithFormat:@"%@", dic[@"friendAccountId"]];
        if (![dic[@"friendName"] isKindOfClass:[NSNull class]]) {
            model.user_name = dic[@"friendName"];
        }
        if (![dic[@"headImg"] isKindOfClass:[NSNull class]]) {
            model.img_url = dic[@"headImg"];
        }
        model.phoneNo = dic[@"phoneNo"];
        if (![dic[@"pinyin"] isKindOfClass:[NSNull class]]) {
            model.pinyin = dic[@"pinyin"];
        }
        else
        {
            NSString *pinyin = [model.user_name mutableCopy];
            CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformMandarinLatin,NO);
            //再转换为不带声调的拼音
            CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformStripDiacritics,NO);
            model.pinyin = pinyin;
        }
        
        model.status = dic[@"status"];
        [_modelArray addObject:model];
    }
    
    NSString *num = [NSString stringWithFormat:@"%lu", (unsigned long)[_modelArray count]];
    if (![[[FreeSingleton sharedInstance] getMyFollowerNum] isEqualToString:num]) {
        [FreeSingleton sharedInstance].my_Follower_Num = num;
        [[NSUserDefaults standardUserDefaults] setObject:num forKey:KEY_FOLLOWER_NUM];
        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEW_FRIENDS object:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([_modelArray count]) {
        _notice_view.hidden = YES;
        return [_modelArray count];
    }
    _notice_view.hidden = NO;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[AddressListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    cell.model = _modelArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    AddressListCellModel *model = _modelArray[indexPath.row];
    vc.friend_id = model.friendId;
    //                vc.friend_name = name;
    vc.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = self.navigationController;
    [navigationController pushViewController:vc animated:YES];
}

@end
