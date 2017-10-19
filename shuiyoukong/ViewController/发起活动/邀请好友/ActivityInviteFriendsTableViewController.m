//
//  ActivityInviteFriendsTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ActivityInviteFriendsTableViewController.h"
#import "SelectFriendsCell.h"
#import "CreateActivityViewController.h"
#import "FreeSingleton.h"

#define CARE 3
#define FANS 2
@interface ActivityInviteFriendsTableViewController ()<UISearchDisplayDelegate>
{
    UISearchDisplayController *searchDisplayController;
}
@property (nonatomic, weak)NSString *identifier;
@property (nonatomic,strong)UISearchBar *searchBar;

@property (nonatomic, strong)NSMutableArray *care_ModelArray;
@property (nonatomic, strong)NSMutableArray *fans_ModelArray;

@property (nonatomic, strong)NSMutableArray *search_care_ModelArray;
@property (nonatomic, strong)NSMutableArray *search_fans_ModelArray;

@property (nonatomic, assign)BOOL isChooseAll_CARE;
@property (nonatomic, assign)BOOL isChooseAll_FANS;
@end

@implementation ActivityInviteFriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initView
- (void)initView
{
    self.navigationItem.title = @"邀请好友";
    _identifier = @"SelectFriendsCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(sendFriends)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    if (_activity_Id) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backToInfo)];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    [self initSearch];
}

- (void)initSearch
{
    //设置header
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.placeholder = @"搜索好友";
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

#pragma mark - initData
- (void)initData
{
    _fans_ModelArray = [NSMutableArray array];
    _care_ModelArray = [NSMutableArray array];
    
    for (SelectFriendsModel *model in _modelArray) {
        if (model.status == FANS) {
            [_fans_ModelArray addObject:model];
        }
        else
        {
            [_care_ModelArray addObject:model];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tableView == tableView) {
        switch (section) {
            case 0:
                if ([_care_ModelArray count]) {
                    return [_care_ModelArray count];
                }
                break;
            default:
                if ([_fans_ModelArray count]) {
                    return [_fans_ModelArray count];
                }
                break;
        }
    }
    else
    {
        switch (section) {
            case 0:
                {
                    if ([_care_ModelArray count]) {
                        _search_care_ModelArray = [NSMutableArray array];
                        [self searchText_Already:_care_ModelArray searchModelArray:_search_care_ModelArray];
                        return [_search_care_ModelArray count];
                        
                    }
                }
                break;
            default:
                {
                    if ([_fans_ModelArray count]) {
                        _search_fans_ModelArray = [NSMutableArray array];
                        [self searchText_Already:_fans_ModelArray searchModelArray:_search_fans_ModelArray];
                        return [_search_fans_ModelArray count];
                    }
                }
                break;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.tableView)
    {
        return [self cellForBasicTable:tableView indexPath:indexPath];
    }
    else
    {
        return [self cellForSearchTable:tableView indexPath:indexPath];
    }
}

//基本table
- (UITableViewCell *)cellForBasicTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    SelectFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SelectFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    
    if (indexPath.section == 0) {
        cell.model = _care_ModelArray[indexPath.row];
    }
    else
    {
        cell.model = _fans_ModelArray[indexPath.row];
    }
    
    return cell;
}

//
- (UITableViewCell *)cellForSearchTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    SelectFriendsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier];
    if (!cell) {
        cell = [[SelectFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    
    if (indexPath.section == 0) {
        cell.model = _search_care_ModelArray[indexPath.row];
    }
    else
    {
        cell.model = _search_fans_ModelArray[indexPath.row];
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.f;
    
}

//获取分组标题并显示
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    headView.layer.borderWidth = 1;
    headView.layer.borderColor = [[UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1] CGColor];
    headView.backgroundColor = [UIColor colorWithRed:239/255.0 green:237/255.0 blue:239/255.0 alpha:1];
    UILabel *leftlable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
    if (section == 0) {
        leftlable.text = @"互相关注";
    }
    else
    {
        leftlable.text = @"关注我的人";
    }
    leftlable.font = [UIFont systemFontOfSize:14.0];
    [headView addSubview:leftlable];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-48, 0, 50, 30)];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    if (section == 0) {
        btn.tag = CARE;
        if (_isChooseAll_CARE) {
            [btn setTitle:@"反选" forState:UIControlStateNormal];
        }
        else
        {
            [btn setTitle:@"全选" forState:UIControlStateNormal];
        }
    }
    else
    {
        btn.tag = FANS;
        if (_isChooseAll_FANS) {
            [btn setTitle:@"反选" forState:UIControlStateNormal];
        }
        else
        {
            [btn setTitle:@"全选" forState:UIControlStateNormal];
        }
    }
    
    [btn setTitleColor:FREE_BLACK_COLOR forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(chooseAll:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btn];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
    return 50.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.tableView == tableView) {
        SelectFriendsCell* cell = (SelectFriendsCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        SelectFriendsModel *model;
        if (indexPath.section == 0) {
            model = _care_ModelArray[indexPath.row];
        }
        else
        {
            model = _fans_ModelArray[indexPath.row];
        }
        model.isSelected = !model.isSelected;
        
        cell.model = model;
    }
    else
    {
        [self selectedSearchTableView:tableView indexPath:indexPath];
    }
}

- (void)selectedSearchTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    SelectFriendsModel *model;
    if (indexPath.section == 0) {
        model = _search_care_ModelArray[indexPath.row];
        
        if (!model.isSelected) {
            for (int i = 0; i < [_care_ModelArray count]; i++) {
                SelectFriendsModel *tmpModel = _care_ModelArray[i];
                if ([model.accountId isEqualToString:tmpModel.accountId]) {
                    [_care_ModelArray removeObjectAtIndex:i];
                }
            }
            [_care_ModelArray insertObject:model atIndex:0];
        }
    }
    else
    {
        model = _search_fans_ModelArray[indexPath.row];
        
        if (!model.isSelected) {
            for (int i = 0; i < [_fans_ModelArray count]; i++) {
                SelectFriendsModel *tmpModel = _fans_ModelArray[i];
                if ([model.accountId isEqualToString:tmpModel.accountId]) {
                    [_fans_ModelArray removeObjectAtIndex:i];
                }
            }
            [_fans_ModelArray insertObject:model atIndex:0];
        }
    }
    model.isSelected = !model.isSelected;
    SelectFriendsCell* cell = (SelectFriendsCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.model = model;
}

#pragma mark - 功能
//全选
- (void)chooseAll:(UIButton *)sender
{
    if (sender.tag == CARE) {
        _isChooseAll_CARE = !_isChooseAll_CARE;
        [self setAllChoose:_care_ModelArray isChoose:_isChooseAll_CARE];
    }
    else
    {
        _isChooseAll_FANS = !_isChooseAll_FANS;
        [self setAllChoose:_fans_ModelArray isChoose:_isChooseAll_FANS];
    }
}

- (void)setAllChoose:(NSMutableArray *)array isChoose:(BOOL)isChoose
{
    for (int i = 0; i < [array count]; i++) {
        SelectFriendsModel *model = array[i];
        model.isSelected = isChoose;
        [array replaceObjectAtIndex:i withObject:model];
    }
    [self.tableView reloadData];
}

- (void)sendFriends
{
    NSMutableArray *friendsArray = [NSMutableArray array];
    for (SelectFriendsModel *model in _care_ModelArray) {
        if (model.isSelected) {
            [friendsArray addObject:model];
        }
    }
    for (SelectFriendsModel *model in _fans_ModelArray) {
        if (model.isSelected) {
            [friendsArray addObject:model];
        }
    }
    
    if(_activity_Id)
    {
        NSMutableArray *friendsList = [NSMutableArray array];
        for (int i = 0; i < [friendsArray count]; i++) {
            SelectFriendsModel *model = friendsArray[i];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:model.accountId forKey:@"attendUserId"];
            [dic setObject:[NSNumber numberWithInt:0] forKey:@"fromInfo"];
            [friendsList addObject:dic];
        }
        
        NSSet *set = [NSSet setWithArray:friendsList];
        __weak ActivityInviteFriendsTableViewController *weakSelf = self;
        NSInteger retcode = [[FreeSingleton sharedInstance] inviteAcitiveInfoOnCompletion:_activity_Id friendsList:[set allObjects] block:^(NSUInteger ret, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress dismiss];
            });
            if (ret == RET_SERVER_SUCC) {
                [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                    [KVNProgress showSuccessWithStatus:@"邀请好友成功"];
                }];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KVNProgress showErrorWithStatus:data onView:weakSelf.view];
                });
            }
        }];
        
        if (retcode != RET_OK) {
            [KVNProgress dismiss];
            [KVNProgress showErrorWithStatus:zcErrMsg(retcode) onView:self.view];
        }
    }
    else
    {
        UIViewController *setPrizeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        //初始化其属性
        if ([setPrizeVC isKindOfClass:[CreateActivityViewController class]]) {
            CreateActivityViewController *vc = (CreateActivityViewController *)setPrizeVC;
            vc.friendsArray = nil;
            vc.friendsArray = friendsArray;
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//返回
- (void)backToInfo
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - search
- (void)searchText_Already:(NSMutableArray *)modelArray searchModelArray:(NSMutableArray *)searchModelArray
{
    NSString *str = searchDisplayController.searchBar.text;
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < [modelArray count]; i++) {
        
        SelectFriendsModel *model = modelArray[i];
        
        NSRange rangeName = [model.name rangeOfString:str];
        
        BOOL tagPinyin = NO;
        
        if ([str length] <= [model.pinyin length]) {
            NSString *strPinyin = [model.pinyin substringWithRange:NSMakeRange(0, [str length])];
            tagPinyin = [strPinyin isEqualToString:str] ? YES:NO;
        }
        
        if (rangeName.length > 0 || tagPinyin) {
            [searchModelArray addObject:model];
        }
    }
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.tableView reloadData];
}

@end
