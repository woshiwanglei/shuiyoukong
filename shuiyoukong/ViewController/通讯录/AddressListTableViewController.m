//
//  AddressListTableViewController.m
//  Free
//
//  Created by 勇拓 李 on 15/5/5.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "AddressListTableViewController.h"
#import "AddressListTableViewCell.h"

#import "FreeSQLite.h"
#import "FreeSingleton.h"
#import "NewFriendsCell.h"
#import "NewFriendsTableViewController.h"
#import "inviteFriendsViewController.h"
#import "showUserInfoViewController.h"
#import "menuTableViewCell.h"
#import "FreeAddressBook.h"
#import "SearchFriendsTableViewController.h"

@interface AddressListTableViewController ()

@property (nonatomic,weak) NSString* identifier_already;

@property (nonatomic,weak) NSString* identifier_newFriends;

@property (nonatomic, strong) NSMutableArray* dataSource;

@property (nonatomic, strong) NSMutableArray *modelArray;

@property (nonatomic, strong) NSMutableArray* search_dataSource;

@property (nonatomic, strong) NSMutableArray *search_ModelArray;

@property (nonatomic,strong) UISearchDisplayController *searchdisplay;

@property (nonatomic,assign) float viewHeight;

@property (nonatomic,strong) UISearchBar *searchBar;

@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)UITableView *menuTableview;
@property (nonatomic, copy) NSString *inderfiter;

@property BOOL search_tag;
@property BOOL ifMenu;
@end

@implementation AddressListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _identifier_already = @"AddressListTableViewCell";
    _identifier_newFriends = @"NewFriendsCell";
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_ifMenu) {
        _ifMenu = NO;
         self.tableView.scrollEnabled = YES;
        [UIView animateWithDuration:.2 animations:^{
            _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
        } completion:^(BOOL finished) {
            [_backView removeFromSuperview];
            [_menuTableview removeFromSuperview];
        }];
    }
    
    //设置header
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.placeholder = @"搜索";
    [_searchBar setTintColor:FREE_BACKGOURND_COLOR];
    
    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = _searchBar;
    _searchdisplay = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    
    // searchResultsDataSource 就是 UITableViewDataSource
    _searchdisplay.searchResultsDataSource = self;
    // searchResultsDelegate 就是 UITableViewDelegate
    _searchdisplay.searchResultsDelegate = self;
    
    _searchdisplay.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    _searchdisplay.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_searchdisplay setActive:NO animated:YES];
    if (_ifMenu) {
        _ifMenu = NO;
         self.tableView.scrollEnabled = YES;
        [UIView animateWithDuration:.2 animations:^{
            _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
        } completion:^(BOOL finished) {
            [_backView removeFromSuperview];
            [_menuTableview removeFromSuperview];
        }];
    }
    
    [_searchdisplay setActive:NO animated:YES];
}

#pragma mark -注册和注销通知
- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self registerNotificationForAddressList];
    }
    return self;
}

- (void)registNotice
{
    [self registerNotificationForAddressList];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -init

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) initView
{
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:ZC_NOTIFICATION_LOADING]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [KVNProgress showWithStatus:@"通讯录同步中.."];
//        });
//        [self performSelector:@selector(reloadAndHideHud) withObject:nil afterDelay:10];
//    }
    
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_already bundle:nil] forCellReuseIdentifier:_identifier_already];
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_newFriends bundle:nil] forCellReuseIdentifier:_identifier_newFriends];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
    
    self.navigationItem.backBarButtonItem=backItem;
    
    UIColor *color = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202.0/255.0 alpha:1];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dic ;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    //设置tableview滑动速度
    self.tableView.decelerationRate = 0.5;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initMenuTable];
}

- (void)initMenuTable
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn addTarget:self action:@selector(functionIncident) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = backItem;
    UIButton *btred= [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, _viewHeight,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+self.tableView.contentSize.height)];
    
     _backView = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, _viewHeight,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+self.tableView.contentSize.height)];
    _backView.backgroundColor = [UIColor clearColor];
    _menuTableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, 150, 98) style:UITableViewStylePlain];
    UISwipeGestureRecognizer *swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switGesView:)];
    [swipeGes setDirection:(UISwipeGestureRecognizerDirectionUp)];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switGesView:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [btred addTarget:self action:@selector(btnView:) forControlEvents:UIControlEventTouchUpInside];
    [_backView addGestureRecognizer:swipeGes];
    [_backView addGestureRecognizer:swipe];
    [_backView addSubview:btred];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_menuTableview.bounds];
    
    _menuTableview.layer.masksToBounds = NO;
    
    _menuTableview.layer.shadowColor = [UIColor blackColor].CGColor;
    
    _menuTableview.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    
    _menuTableview.layer.shadowOpacity = 0.5f;
    
    _menuTableview.layer.shadowPath = shadowPath.CGPath;
    
    _ifMenu = NO;
    
    [_menuTableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    _menuTableview.delegate = self;
    _menuTableview.dataSource = self;
    
    _menuTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    _menuTableview.scrollEnabled = NO;
    _inderfiter = @"menuTableViewCell";
    [_menuTableview registerNib:[UINib nibWithNibName:_inderfiter bundle:nil] forCellReuseIdentifier:_inderfiter];
    if ([_menuTableview respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [_menuTableview setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([_menuTableview respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [_menuTableview setLayoutMargins:UIEdgeInsetsZero];
        
    }
}
-(void)switGesView:(UISwipeGestureRecognizer *)swipeges
{
    
    if (swipeges.direction == UISwipeGestureRecognizerDirectionUp)
    {
        if (_ifMenu) {
            
            _ifMenu = NO;
            self.tableView.scrollEnabled = YES;
            [UIView animateWithDuration:.2 animations:^{
                _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
            } completion:^(BOOL finished) {
                [_backView removeFromSuperview];
                [_menuTableview removeFromSuperview];
            }];
        }
    }
    else
    {
        if (_ifMenu) {
            
            _ifMenu = NO;
            self.tableView.scrollEnabled = YES;
            [UIView animateWithDuration:.2 animations:^{
                _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
            } completion:^(BOOL finished) {
                [_backView removeFromSuperview];
                [_menuTableview removeFromSuperview];
            }];
        }
    }
}
-(void)btnView:(UIButton *)btn
{
    if (_ifMenu) {
        
        _ifMenu = NO;
        self.tableView.scrollEnabled = YES;
        [UIView animateWithDuration:.2 animations:^{
            _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
        } completion:^(BOOL finished) {
            [_backView removeFromSuperview];
            [_menuTableview removeFromSuperview];
        }];
    }
}

- (void)initData
{
    _dataSource = [[NSMutableArray alloc] init];
    
    [[FreeSQLite sharedInstance] selectFreeSQLiteAddressList:_dataSource tag:MY_FRIENDS];
    
    [self addData2Model];
    
}
//添加数据
- (void)addData2Model
{
    _modelArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_dataSource count]; i++)
    {
        [self add2AlreadyModel:_dataSource[i] tag:NORMAL_TAG];
    }
}
#pragma mark -TextFiled

- (void)searchText_Already
{
    _search_dataSource = [[NSMutableArray alloc] init];
    _search_ModelArray = [[NSMutableArray alloc] init];

    NSString *str = _searchdisplay.searchBar.text;
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];

    for (int i = 0; i < [_dataSource count]; i++) {
        
        NSMutableDictionary *dataDict = _dataSource[i];
        
        NSRange rangeName = [dataDict[@"friendName"] rangeOfString:str];
        
        BOOL tagPinyin = NO;

        if ([str length] <= [dataDict[@"pinyin"] length]) {
            NSString *strPinyin = [dataDict[@"pinyin"] substringWithRange:NSMakeRange(0, [str length])];
            tagPinyin = [strPinyin isEqualToString:str] ? YES:NO;
        }

        if (rangeName.length > 0 || tagPinyin) {
            [_search_dataSource addObject:[dataDict mutableCopy]];
            [self add2AlreadyModel:dataDict tag:SEARCH_TAG];
        }
    }

}
#pragma mark -菜单栏目
-(void)functionIncident
{
    
    _ifMenu = !(_ifMenu);
    
    if (_ifMenu)
    {
         self.tableView.scrollEnabled = NO;
       _menuTableview.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,_viewHeight+64, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
    }
    else
    {
         self.tableView.scrollEnabled = YES;
        [UIView animateWithDuration:.2 animations:^{
            _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
        } completion:^(BOOL finished) {
            [_backView removeFromSuperview];
            [_menuTableview removeFromSuperview];
        }];
        
        return;
    }
    
    [self.view addSubview:_backView];
    [_backView addSubview:_menuTableview];
    
}


#pragma mark -添加model数据
- (void)add2AlreadyModel:(id)dataDict tag:(NSInteger)tag
{
    AddressListCellModel *model = [[AddressListCellModel alloc] init];
    model.user_name = dataDict[@"friendName"];
    model.img_url = dataDict[@"imgUrl"];
    model.Id = dataDict[@"friendAccountId"];
    model.friendId = dataDict[@"id"];
    model.status = dataDict[@"status"];
    
    if ([model.status integerValue] == CONCERN) {
        model.isTurnOn = YES;
    }
    else if ([model.status integerValue] == NO_CONCERN)
    {
        model.isTurnOn = NO;
    }
    
    if (tag == NORMAL_TAG) {
        [_modelArray addObject:model];
    }
    else
    {
        [_search_ModelArray addObject:model];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _viewHeight = self.tableView.contentOffset.y;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (tableView == self.tableView || tableView == _menuTableview) {
        return 2;
    }
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == _menuTableview) {
        return 1;
    }
    else if (tableView == self.tableView) {
        switch (section) {
            case 0:
                return 2;
                break;
            case 1:
                return [_modelArray count];
                break;
            default:
                return 0;
                break;
        }
    }
    else
    {
        switch (section) {
            case 0:
                _search_ModelArray = [NSMutableArray array];
                [self searchText_Already];
                return [_search_ModelArray count];
                break;
            default:
                return 0;
                break;
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _menuTableview) {
        return 0;
    }
    else if (tableView == self.tableView && section == 0) {
        return 0;
    }
    else
        return 30.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    view.backgroundColor = FREE_LIGHT_COLOR;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 30)];
    label.text = @"已加入的好友";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = FREE_LABEL_NAME_COLOR;
    [view addSubview:label];
    return view;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (tableView == _menuTableview) {
//        return nil;
//    }
//    
//    NSString *result = @"已加入的好友";
//    return result;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self basicCellAtIndexPath:indexPath tableView:tableView];
}


- (UITableViewCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if(tableView == _menuTableview)
    {
    switch (indexPath.section) {
        case 0:
        {
            menuTableViewCell *cell = [_menuTableview dequeueReusableCellWithIdentifier:_inderfiter forIndexPath:indexPath];
            
            if (!cell)
            {
                if (cell == nil)
                {
                    cell = [[menuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_inderfiter];
                }            }
            cell.imageView.image = [UIImage imageNamed:@"icon_add_friends"];
            cell.menuName.text = @"添加好友";

            return cell;
        }
            break;
        default:
        {
            menuTableViewCell *cell = [_menuTableview dequeueReusableCellWithIdentifier:_inderfiter forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, _menuTableview.bounds.size.width);
            if (!cell)
            {
                cell = [[menuTableViewCell alloc] init];
            }
            cell.imageView.image = [UIImage imageNamed:@"icon_syn_address"];
            cell.menuName.text = @"同步通讯录";
            return cell;
        }
            break;
    }
    }
    else if (tableView == self.tableView) {
        
        switch (indexPath.section) {
            case 0:
            {
                NewFriendsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_newFriends forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[NewFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_newFriends];
                }
                if (indexPath.row == 0) {
                    cell.isNew = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_IF_HAS_NEW_FRIENDS];
                    cell.label_name.text = @"新的好友";
                    cell.isFirst = YES;
                }
                else
                {
                    cell.btn_newFriends.imageView.image = [UIImage imageNamed:@"xinzeng"];
                    cell.label_name.text = @"邀请好友";
                    cell.isFirst = NO;
                }
                return cell;
            }
                break;
            case 1:
            {
                AddressListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_already forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[AddressListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_already];
                }
                cell.model = _modelArray[indexPath.row];
                return cell;
            }
                break;
            default:
                return nil;
                break;
        }
    }
    else
    {
        switch (indexPath.section) {
            case 0:
            {
                AddressListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_already];
                if (cell == nil) {
                    cell = [[AddressListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_already];
                }
                cell.model = _search_ModelArray[indexPath.row];
                return cell;
            }
                break;
            default:
                return nil;
                break;
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.f;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (tableView != _menuTableview) {
        return;
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f + 1;
    return 50.f + 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (tableView == _menuTableview) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            switch (indexPath.section) {
                case 0:
                {
                    //            PhoneGameTableViewController *game = [[PhoneGameTableViewController alloc] initWithNibName:@"PhoneGameTableViewController" bundle:nil];
                    //
                    //            game.hidesBottomBarWhenPushed = YES;
                    //
                    //            [self.navigationController pushViewController:game animated:YES];
                    
                    SearchFriendsTableViewController *vc = [[SearchFriendsTableViewController alloc] initWithNibName:@"SearchFriendsTableViewController" bundle:nil];
                    self.tableView.scrollEnabled = YES;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                    [_backView removeFromSuperview];
                    [_menuTableview removeFromSuperview];
                    self.tableView.scrollEnabled = YES;
                    _ifMenu = NO;
                }
                    break;
                    
                default:
                    self.tableView.scrollEnabled = YES;
                    [_backView removeFromSuperview];
                    [_menuTableview removeFromSuperview];
                    self.tableView.scrollEnabled = YES;
                    [self updateAddressList];
                    _ifMenu = NO;
                    break;
            }
    }
    else if (tableView == self.tableView ) {
    
        switch (indexPath.section) {
            case 0:
            {
                if (indexPath.row == 0) {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_IF_HAS_NEW_FRIENDS]) {
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_IF_HAS_NEW_FRIENDS];
                        NewFriendsCell* cell = (NewFriendsCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                        cell.isNew = NO;
                    }
                    
                    [self performSegueWithIdentifier:@"newFriendsSg" sender:self];
                }
                else
                {
                    [self performSegueWithIdentifier:@"inviteFriendsSeg" sender:self];
                }
                
            }
                break;
                
            default:
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
                break;
        }
        
    }
    else
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                     bundle:nil];
        showUserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"showUserInfoSID"];
        AddressListCellModel *model = _search_ModelArray[indexPath.row];
        vc.friend_id = model.Id;
        vc.friend_name = model.user_name;
        vc.hidesBottomBarWhenPushed = YES;
        [_searchdisplay setActive:NO animated:YES];
        UINavigationController *navigationController = self.navigationController;
        [navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -相关功能

- (void)updateAddressList
{
    [KVNProgress showWithStatus:@"通讯录同步中.."];
    [self performSelector:@selector(reloadAndHideHud) withObject:nil afterDelay:10];
    [FreeAddressBook getAddressListData];
}

#pragma mark 注册通知
//上传通讯录
- (void) registerNotificationForAddressList {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressListUpload:) name:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:nil];
}

//上传通讯录
- (void) addressListUpload:(NSNotification *) notification{
    [self reloadAndHideHud];
}

//解除loading
- (void)reloadAndHideHud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initData];
        [self.tableView reloadData];
        //设置通讯录loading
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];
        [KVNProgress dismiss];
    });
}

#pragma mark -跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"newFriendsSg"]) {
        NewFriendsTableViewController* vc = (NewFriendsTableViewController *)segue.destinationViewController;
        vc.hidesBottomBarWhenPushed = YES;
    }
    else if ([segue.identifier isEqualToString:@"inviteFriendsSeg"]) {
        inviteFriendsViewController* vc = (inviteFriendsViewController *)segue.destinationViewController;
        vc.hidesBottomBarWhenPushed = YES;
    }
}

@end