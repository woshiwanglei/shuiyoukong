//
//  SearchFriendsTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SearchFriendsTableViewController.h"
#import "FreeSingleton.h"
#import "Account.h"
#import "SearchFriendsTableViewCell.h"
#import "UserInfoViewController.h"
#import "FreeSQLite.h"

@interface SearchFriendsTableViewController ()<UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic,strong) UISearchDisplayController *searchdisplay;
@property (nonatomic, weak)NSString *identifier;
@property (nonatomic, strong)Account *accoutModel;

@property (assign)BOOL searchTag;
@end

@implementation SearchFriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initView
- (void)initView
{
    _identifier = @"SearchFriendsTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    //设置header
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = @"请输入好友手机号码";
    [searchBar setTintColor:FREE_BACKGOURND_COLOR];
    
    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = searchBar;
    _searchdisplay = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    searchBar.delegate = self;
    _searchdisplay.delegate = self;
    // searchResultsDataSource 就是 UITableViewDataSource
    _searchdisplay.searchResultsDataSource = self;
    // searchResultsDelegate 就是 UITableViewDelegate
    _searchdisplay.searchResultsDelegate = self;
    
    _searchdisplay.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.navigationItem.title = @"添加好友";
//    _searchdisplay. .returnKeyType = UIReturnKeyDone;
    _searchdisplay.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - 搜索
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    __weak SearchFriendsTableViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"];
    NSInteger retcode = [[FreeSingleton sharedInstance] getFriendsInfoByPhoneNoOnCompletion:searchBar.text block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC)
        {
            if (data) {
                [weakSelf getFreeAccount:data];
            }
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

//添加好友
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([[FreeSingleton sharedInstance] isMobileNo:searchText]) {
        __weak SearchFriendsTableViewController *weakSelf = self;
        [KVNProgress showWithStatus:@"Loading"];
        NSInteger retcode = [[FreeSingleton sharedInstance] getFriendsInfoByPhoneNoOnCompletion:searchBar.text block:^(NSUInteger ret, id data) {
            [KVNProgress dismiss];
            if (ret == RET_SERVER_SUCC)
            {
                if (data) {
                    [weakSelf getFreeAccount:data];
                }
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

- (void)getFreeAccount:(id)data
{
    _accoutModel = [[Account alloc] init];
    _accoutModel.accountId = data[@"id"];
    _accoutModel.city = data[@"city"];
    _accoutModel.gender = data[@"gender"];
    _accoutModel.nickName = data[@"nickName"];
    _accoutModel.phoneNo = data[@"phoneNo"];
    _accoutModel.headImg = data[@"headImg"];
    NSString *accountId = [NSString stringWithFormat:@"%@", data[@"id"]];
    NSString *friendName = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:accountId];
    _accoutModel.friendName = friendName;
    if (friendName == nil) {
        friendName = data[@"nickName"];
    }
    NSString *pinyin = [friendName mutableCopy];
    CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformStripDiacritics,NO);
    _accoutModel.pinyin = pinyin;
    for (int i = 0; i < [data[@"tagList"] count]; i++) {
        id dict = data[@"tagList"][i];
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:dict[@"tagName"], @"tagName", nil];
        [_accoutModel.tagList addObject:dic];
    }
    _searchTag = YES;
    [_searchdisplay.searchResultsTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.tableView) {
        return 0;
    }
    if (!_searchTag) {
        return 0;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SearchFriendsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier];
    
    if (cell == nil) {
        cell = [[SearchFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    
    cell.url = _accoutModel.headImg;
    cell.label_name.text = _accoutModel.nickName;
    _searchTag = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.f;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    
    vc.friend_id = [NSString stringWithFormat:@"%@", _accoutModel.accountId];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
