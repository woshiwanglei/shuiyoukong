//
//  inviteFriendsViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/22.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "inviteFriendsViewController.h"
#import "AddressListInviteTableViewCell.h"
#import "FreeSQLite.h"
#import "settings.h"

@interface inviteFriendsViewController ()
{
    UISearchDisplayController *searchDisplayController;
}

@property (nonatomic,weak) NSString* identifier;

@property (nonatomic, strong) NSMutableArray* dataSource;
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) NSMutableArray* search_dataSource;
@property (nonatomic, strong) NSMutableArray *search_ModelArray;
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation inviteFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initView];
}

#pragma mark -init

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initView
{
    _identifier = @"AddressListInviteTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    
    UIColor *color = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202.0/255.0 alpha:1];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dic ;
    self.navigationItem.title = @"邀请好友";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    //设置tableview滑动速度
    self.tableView.decelerationRate = 0.5;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //设置header
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width
                                                                           , 44)];
    _searchBar.placeholder = @"搜索";
    [_searchBar setTintColor:FREE_BACKGOURND_COLOR];
    
    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = _searchBar;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    
    // searchResultsDataSource 就是 UITableViewDataSource
    searchDisplayController.searchResultsDataSource = self;
    // searchResultsDelegate 就是 UITableViewDelegate
    searchDisplayController.searchResultsDelegate = self;
    
    searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)initData
{
    _dataSource = [[NSMutableArray alloc] init];
    
    [[FreeSQLite sharedInstance] selectFreeSQLiteAddressList:_dataSource tag:INVITE_FRIENDS];
    
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

#pragma mark -添加model数据
- (void)add2AlreadyModel:(id)dataDict tag:(NSInteger)tag
{
    AddressListInviteCellModel *model = [[AddressListInviteCellModel alloc] init];
    
    model.user_name = dataDict[@"friendName"];
    
    model.img_url = dataDict[@"imgUrl"];
    model.phoneNo = dataDict[@"phoneNo"];
    if (tag == NORMAL_TAG) {
        [_modelArray addObject:model];
    }
    else
    {
        [_search_ModelArray addObject:model];
    }
}

#pragma mark -TextFiled

- (void)searchText
{
    _search_dataSource = [[NSMutableArray alloc] init];
    _search_ModelArray = [[NSMutableArray alloc] init];
    
    NSString *str = searchDisplayController.searchBar.text;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.tableView) {
        switch (section) {
            case 0:
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
                [self searchText];
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
    return 0.f;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *result = @"邀请好友";
//    return result;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self basicCellAtIndexPath:indexPath tableView:tableView];
}


- (UITableViewCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    switch (indexPath.section) {
        case 0:
        {
            AddressListInviteTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
            [cell.btn_invite addTarget:self action:@selector(inviter) forControlEvents:UIControlEventTouchUpInside];
            
            if (cell == nil) {
                cell = [[AddressListInviteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
            }
            if (tableView == self.tableView)
            {
                cell.model = _modelArray[indexPath.row];
                
                
            }
            else
            {
                cell.model = _search_ModelArray[indexPath.row];
                
            }
            return cell;
        }
            break;
        default:
            return nil;
            break;
    }
}
-(void)inviter
{
    [_searchBar resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.f;
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f;
    return 50.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
}

@end