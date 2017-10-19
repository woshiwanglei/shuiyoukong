//
//  MyCaredTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/4.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MyCaredTableViewController.h"
#import "AddressListTableViewCell.h"
#import "NewFriendsCell.h"
#import "FreeSingleton.h"
#import "menuTableViewCell.h"
#import "MyAddressTableViewController.h"
#import "SearchFriendsTableViewController.h"
#import "FreeAddressBook.h"
#import "UserInfoViewController.h"

#define NO_CARE 2

@interface MyCaredTableViewController ()<UISearchDisplayDelegate>
{
    UISearchDisplayController *searchDisplayController;
}

@property (nonatomic, strong)NSMutableArray *modelArray;
@property (nonatomic, strong)NSMutableArray *search_ModelArray;
@property (nonatomic, weak)NSString *identifier;
@property (nonatomic, weak)NSString *identifier_address;
@property (nonatomic, weak)NSString *identifier_menu;
//@property (nonatomic,strong) UISearchDisplayController *searchdisplay;
@property (nonatomic,strong) UISearchBar *searchBar;
//@property (nonatomic, strong)UITableView *menuTableview;
//@property (nonatomic, strong)UIView *backView;

@property (nonatomic, strong)UIImageView *notice_view;

@end

@implementation MyCaredTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initData];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeModel:) name:ZC_NOTIFICATION_UPDATE_MYCARE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressListUpload:) name:MY_CARE_NOTIFICATION_REFRESH object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [searchDisplayController setActive:NO animated:YES];
    NSInteger num = 0;
    for (AddressListCellModel *model in _modelArray) {
        if ([model.status intValue] != NO_CARE) {
            num++;
        }
    }
    
    if (num != [[[FreeSingleton sharedInstance] getMyFollowedNum] intValue]) {
        [FreeSingleton sharedInstance].my_Followed_Num = [NSString stringWithFormat:@"%ld", (long)num];
        [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].my_Followed_Num forKey:KEY_FOLLOWED_NUM];
        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEW_FRIENDS object:nil];
    }
}

//上传通讯录
- (void) changeModel:(NSNotification *) notification{
    
    if (![_modelArray count]) {
        return;
    }
    
    AddressListCellModel *changeModel = notification.object;
    NSInteger num = [_modelArray count];
    for (int i = 0; i < num; i++) {
        AddressListCellModel *model = _modelArray[i];
        if ([model.friendId isEqualToString:changeModel.friendId]) {
            changeModel.Id = model.Id;
            [_modelArray replaceObjectAtIndex:i withObject:changeModel];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:1];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        
        if (i == num - 1) {
            [_modelArray addObject:changeModel];
            NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:1];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)addressListUpload:(NSNotification *) notification
{
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init
- (void)initView
{
    _identifier = @"AddressListTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    _identifier_address = @"NewFriendsCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_address bundle:nil] forCellReuseIdentifier:_identifier_address];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationItem.title = @"我的关注";
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    
    _notice_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_care_friends"]];
    _notice_view.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 90)/2, ([[UIScreen mainScreen] bounds].size.height - 239)/2 , 90, 119);
    [self.view addSubview:_notice_view];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn addTarget:self action:@selector(addFriends) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"icon_add_friends"] forState:UIControlStateNormal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc ] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self initSearch];
//    [self initMenuTable];
}

- (void)initSearch
{
    //设置header
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.placeholder = @"搜索";
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

//- (void)initMenuTable
//{
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [btn addTarget:self action:@selector(functionIncident) forControlEvents:UIControlEventTouchUpInside];
//    [btn setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:btn];
//    self.navigationItem.rightBarButtonItem = backItem;
//    UIButton *btred= [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+self.tableView.contentSize.height)];
//    
//    _backView = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+self.tableView.contentSize.height)];
//    _backView.backgroundColor = [UIColor clearColor];
//    _menuTableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, 150, 98) style:UITableViewStylePlain];
//    _identifier_menu = @"menuTableViewCell";
//    [_menuTableview registerNib:[UINib nibWithNibName:_identifier_menu bundle:nil] forCellReuseIdentifier:_identifier_menu];
//    UISwipeGestureRecognizer *swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switGesView:)];
//    [swipeGes setDirection:(UISwipeGestureRecognizerDirectionUp)];
//    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switGesView:)];
//    [swipe setDirection:(UISwipeGestureRecognizerDirectionDown)];
//    [btred addTarget:self action:@selector(btnView:) forControlEvents:UIControlEventTouchUpInside];
//    [_backView addGestureRecognizer:swipeGes];
//    [_backView addGestureRecognizer:swipe];
//    [_backView addSubview:btred];
//    
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_menuTableview.bounds];
//    
//    _menuTableview.layer.masksToBounds = NO;
//    
//    _menuTableview.layer.shadowColor = [UIColor blackColor].CGColor;
//    
//    _menuTableview.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
//    
//    _menuTableview.layer.shadowOpacity = 0.5f;
//    
//    _menuTableview.layer.shadowPath = shadowPath.CGPath;
//    
//    
//    [_menuTableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
//    _menuTableview.delegate = self;
//    _menuTableview.dataSource = self;
//    
//    _menuTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
//    _menuTableview.scrollEnabled = NO;
//    
//    if ([_menuTableview respondsToSelector:@selector(setSeparatorInset:)]) {
//        
//        [_menuTableview setSeparatorInset:UIEdgeInsetsZero];
//        
//    }
//    
//    if ([_menuTableview respondsToSelector:@selector(setLayoutMargins:)]) {
//        
//        [_menuTableview setLayoutMargins:UIEdgeInsetsZero];
//        
//    }
//}

- (void)initData
{
    [KVNProgress showWithStatus:@"Loading"];
    __weak MyCaredTableViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] getCareFriendsListOnCompletion:^(NSUInteger ret, id data) {
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
//    NSString *num = [NSString stringWithFormat:@"%lu", (unsigned long)[_modelArray count]];
//    if (![[[FreeSingleton sharedInstance] getMyFollowedNum] isEqualToString:num]) {
//        [FreeSingleton sharedInstance].my_Followed_Num = num;
//        [[NSUserDefaults standardUserDefaults] setObject:num forKey:KEY_FOLLOWED_NUM];
//        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEW_FRIENDS object:nil];
//    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    _notice_view.hidden = YES;
    
    if (tableView == self.tableView) {
        switch (section) {
            case 0:
                return 1;
                break;
            default:
            {
                if ([_modelArray count]) {
                    return [_modelArray count];
                }
                _notice_view.hidden = NO;
                return 0;
            }
                break;
        }
    }
    else
    {
        _search_ModelArray = [NSMutableArray array];
        [self searchText_Already];
        return [_search_ModelArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
        return [self basicCell:tableView indexPath:indexPath];
    }
    else
    {
        return [self searchCell:tableView indexPath:indexPath];
    }
}

- (UITableViewCell *)basicCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NewFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier_address forIndexPath:indexPath];
        if (!cell) {
            cell = [[NewFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_address];
        }
        cell.btn_newFriends.imageView.image = [UIImage imageNamed:@"xinzeng"];
        cell.label_name.text = @"通讯录好友";
        return cell;
    }
    else
    {
        AddressListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[AddressListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
        }
        cell.model = _modelArray[indexPath.row];
        return cell;
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (section == 1)
            return 10;
        return 0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f + 1;
    return 50.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(tableView == self.tableView)
    {
        switch (indexPath.section) {
            case 0:
            {
                MyAddressTableViewController *vc = [[MyAddressTableViewController alloc] initWithNibName:@"MyAddressTableViewController" bundle:nil];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
            {
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
                break;
        }
    }
    else
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                     bundle:nil];
        UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
        AddressListCellModel *model = _search_ModelArray[indexPath.row];
        vc.friend_id = model.friendId;
        //                vc.friend_name = name;
        vc.hidesBottomBarWhenPushed = YES;
        UINavigationController *navigationController = self.navigationController;
        [navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - 选择
//- (void)selectedMenu:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    switch (indexPath.section) {
//        case 0:
//        {
//            SearchFriendsTableViewController *vc = [[SearchFriendsTableViewController alloc] initWithNibName:@"SearchFriendsTableViewController" bundle:nil];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//            [_backView removeFromSuperview];
//            [_menuTableview removeFromSuperview];
//            self.tableView.scrollEnabled = YES;
//            _ifMenu = NO;
//        }
//            break;
//            
//        default:
//            self.tableView.scrollEnabled = YES;
//            [_backView removeFromSuperview];
//            [_menuTableview removeFromSuperview];
//            self.tableView.scrollEnabled = YES;
//            [self updateAddressList];
//            _ifMenu = NO;
//            break;
//    }
//}

#pragma mark -菜单栏目

- (void)addFriends
{
    SearchFriendsTableViewController *vc = [[SearchFriendsTableViewController alloc] initWithNibName:@"SearchFriendsTableViewController" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//- (UITableViewCell *)menuCellAtIndexPath:(NSIndexPath *)indexPath
//{
//    menuTableViewCell *cell = [_menuTableview dequeueReusableCellWithIdentifier:_identifier_menu forIndexPath:indexPath];
//    
//    if (!cell)
//    {
//        
//        cell = [[menuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_menu];
//    }
//    switch (indexPath.section) {
//        case 0:
//        {
//            cell.imageView.image = [UIImage imageNamed:@"icon_add_friends"];
//            cell.menuName.text = @"添加好友";
//        }
//            break;
//            
//        default:
//        {
//            cell.imageView.image = [UIImage imageNamed:@"icon_syn_address"];
//            cell.menuName.text = @"同步通讯录";
//        }
//            break;
//    }
//    return cell;
//}

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
