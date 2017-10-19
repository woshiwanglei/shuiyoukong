//
//  MyAddressTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/5.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MyAddressTableViewController.h"
#import "AddressListTableViewCell.h"
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "FreeSingleton.h"
#import "FreeAddressBook.h"
#import "UserInfoViewController.h"

@interface MyAddressTableViewController ()<UISearchDisplayDelegate>
{
    UISearchDisplayController *searchDisplayController;
}
@property (nonatomic, weak)NSString *identifier;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic, strong)NSMutableArray *modelArray;
@property (nonatomic, strong)NSMutableArray *search_ModelArray;
@end

@implementation MyAddressTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//上传通讯录
- (void) changeModel:(NSNotification *) notification{
    
    if (![_modelArray count]) {
        return;
    }
    
    AddressListCellModel *changeModel = notification.object;;
    for (int i = 0; i < [_modelArray count]; i++) {
        AddressListCellModel *model = _modelArray[i];
        if ([model.friendId isEqualToString:changeModel.friendId]) {
            changeModel.Id = model.Id;
            [_modelArray replaceObjectAtIndex:i withObject:changeModel];
        }
    }
}

- (void)addressListUpload:(NSNotification *) notification
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:MY_CARE_NOTIFICATION_REFRESH object:nil];
    [self.tableView reloadData];
}

#pragma mark - init
- (void)initView
{
    _identifier = @"AddressListTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeModel:) name:ZC_NOTIFICATION_UPDATE_MYCARE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressListUpload:) name:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:nil];
    
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationItem.title = @"通讯录好友";
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn addTarget:self action:@selector(updateAddressList) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"icon_syn_address"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc ] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    [self initSearch];
}

- (void)initSearch
{
    //设置header
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.placeholder = @"搜索通讯录好友";
    [_searchBar setTintColor:FREE_BACKGOURND_COLOR];
    
    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = _searchBar;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    
    // searchResultsDataSource 就是 UITableViewDataSource
    searchDisplayController.searchResultsDataSource = self;
    // searchResultsDelegate 就是 UITableViewDelegate
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.delegate = self;
    
    searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)initData
{
    ABAddressBookRef tmpAddressBook = nil;
    
    tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
        dispatch_semaphore_signal(sema);
    });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    //取得通讯录失败
    if (tmpAddressBook == nil) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 100, [UIScreen mainScreen].bounds.size.height/2 - 25 - 54, 200, 50)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = FREE_BLACK_COLOR;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"未上传通讯录，无法查看通讯录好友";
        label.numberOfLines = 2;
        [self.view addSubview:label];
    }
    else
    {
        [KVNProgress showWithStatus:@"Loading"];
        _modelArray = [NSMutableArray array];
        __weak MyAddressTableViewController *weakSelf = self;
        [[FreeSingleton sharedInstance] getAddressListOnCompletion:^(NSUInteger ret, id data) {
            [KVNProgress dismiss];
            if (ret == RET_SERVER_SUCC) {
                [weakSelf add2Model:_modelArray data:data];
                [weakSelf.tableView reloadData];
            }
        }];
    }
}


-(void)add2Model:(NSMutableArray *)modelArray data:(id)data
{
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
        [modelArray addObject:model];
    }
}
         

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableView) {
        if ([_modelArray count]) {
            return [_modelArray count];
        }
        return 0;
    }
    else
    {
        _search_ModelArray = [NSMutableArray array];
        [self searchText_Already];
        return [_search_ModelArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView == tableView) {
        return [self basicCell:tableView indexPath:indexPath];
    }
    else
    {
        return [self searchCell:tableView indexPath:indexPath];
    }
}

- (UITableViewCell *)basicCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    AddressListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[AddressListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    cell.model = _modelArray[indexPath.row];
    return cell;
}

- (UITableViewCell *)searchCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    AddressListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier];
    if (!cell) {
        cell = [[AddressListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    cell.model = _search_ModelArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    AddressListCellModel *model;
    if (tableView == self.tableView) {
        model = _modelArray[indexPath.row];
    }
    else
    {
        model = _search_ModelArray[indexPath.row];
    }
    vc.friend_id = model.friendId;
    //                vc.friend_name = name;
    vc.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = self.navigationController;
    [navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f + 1;
    return 50.f;
}

#pragma mark -相关功能

- (void)updateAddressList
{
    [KVNProgress showWithStatus:@"通讯录同步中.."];
    [self performSelector:@selector(reloadAndHideHud) withObject:nil afterDelay:10];
    _modelArray = [NSMutableArray array];
    __weak MyAddressTableViewController *weakSelf = self;
    [FreeAddressBook synAddressListData:_modelArray freeblock:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MY_CARE_NOTIFICATION_REFRESH object:nil];
            [weakSelf.tableView reloadData];
        }
    }];
}

//解除loading
- (void)reloadAndHideHud
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
        [KVNProgress dismiss];
    });
}

#pragma mark - search
- (void)searchText_Already
{
    if (![_modelArray count]) {
        return;
    }
    
    NSString *str = searchDisplayController.searchBar.text;
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < [_modelArray count]; i++) {
        
        AddressListCellModel *model = _modelArray[i];
        
        NSRange rangeName = [model.user_name rangeOfString:str];
        
        BOOL tagPinyin = NO;
        
        if ([str length] <= [model.pinyin length]) {
            NSString *strPinyin = [model.pinyin substringWithRange:NSMakeRange(0, [str length])];
            tagPinyin = [strPinyin isEqualToString:str] ? YES:NO;
        }
        
        if (rangeName.length > 0 || tagPinyin) {
            [_search_ModelArray addObject:model];
        }
    }
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.tableView reloadData];
}

@end
