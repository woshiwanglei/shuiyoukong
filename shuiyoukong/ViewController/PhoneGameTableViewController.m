//
//  PhoneGameTableViewController.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "PhoneGameTableViewController.h"
#import "FreeSQLite.h"
#import "FreeSingleton.h"
#import "AddressListCellModel.h"
#import "AddressListInviteCellModel.h"
#import "SelectFriendsCell.h"
#import "SelectFriendsModel.h"
#import "GameViewController.h"

#define NORMAL_TAG 0
#define SEARCH_TAG 1


@interface PhoneGameTableViewController ()<UISearchDisplayDelegate>
{
    UISearchDisplayController *searchDisplayController;
}

@property (nonatomic,copy)NSString *indentfier;
@property (nonatomic,strong) NSMutableArray *allarry;
@property (nonatomic,strong) NSMutableArray *allarryModel;

@property (nonatomic, strong) NSMutableArray* search_dataSource;

@property (nonatomic, strong) NSMutableArray *search_ModelArray;

@property (nonatomic,strong) NSMutableArray *choosearry;

@end

@implementation PhoneGameTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _indentfier = @"SelectFriendsCell";
    
    [self initDate];
    [self initView];
}

-(void)initView
{
    _choosearry = [NSMutableArray array];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:_indentfier bundle:nil] forCellReuseIdentifier:_indentfier];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"开始游戏" style: UIBarButtonItemStylePlain target:self action:@selector(leftcilck:)];
    self.navigationItem.rightBarButtonItem = left;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width
                                                                           , 44)];
    searchBar.placeholder = @"搜索";
    [searchBar setTintColor:FREE_BACKGOURND_COLOR];
    
    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = searchBar;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    // searchResultsDataSource 就是 UITableViewDataSource
    searchDisplayController.searchResultsDataSource = self;
    searchDisplayController.delegate = self;
    // searchResultsDelegate 就是 UITableViewDelegate
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}


-(void)leftcilck:(UIBarButtonItem *)sender
{
    if (_choosearry) {
        _choosearry = nil;
        _choosearry = [NSMutableArray array];
    }
    for (SelectFriendsModel *model in _allarryModel)
    {
        
        if (model.isSelected)
        {
            
            [_choosearry addObject: model];
        }
    }
    if ([_choosearry count] == 0 || [_choosearry count] > 9)
    {
//        UIAlertView *promptalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择好友或人数已经超过九人！" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
//        
//        [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(timeOver:) userInfo:promptalert repeats:YES];
//        
//        [promptalert show];
        [KVNProgress showErrorWithStatus:@"请选择好友或人数已经超过九人！"];
       
    }
    else
    {
        GameViewController *game = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
        
        game.playsName = _choosearry;
        
        [self.navigationController pushViewController:game animated:YES];
    }
}

-(void)timeOver:(NSTimer *)theTimer
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    [promptAlert removeFromSuperview];
    
}

-(void)initDate
{
    NSMutableArray *already = [NSMutableArray array];
    NSMutableArray *no_already = [NSMutableArray array];
    _allarry = [NSMutableArray array];
    
    [[FreeSQLite sharedInstance] selectFreeSQLiteAddressList:already tag:MY_FRIENDS];
    //未加入的好友
    [[FreeSQLite sharedInstance] selectFreeSQLiteAddressList:no_already tag:INVITE_FRIENDS];
    
    for (int i = 0; i < [already count]; i++) {
        
        [_allarry addObject:already[i]];
    }
    [_allarry mutableCopy];
    
    for (int i = 0; i < [no_already count]; i++) {
        
        [_allarry addObject:no_already[i]];
        
    }
//   [_allarry mutableCopy];
    
    [self addData2Model];
}

//添加数据 已加入
- (void)addData2Model
{
    _allarryModel = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_allarry count]; i++)
    {
        [self add2AlreadyModel:_allarry[i]];
    }
    
}

#pragma mark -搜索算法
- (void)searchText_Already
{
    _search_dataSource = [[NSMutableArray alloc] init];
    _search_ModelArray = [[NSMutableArray alloc] init];
    
    NSString *str = searchDisplayController.searchBar.text;
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < [_allarry count]; i++) {
        
        NSMutableDictionary *dataDict = _allarry[i];
        
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

#pragma mark -排序数组
#pragma mark 数组排序2
- (void)sortDataSource
{
    
}

#pragma mark -添加model数据
- (void)add2AlreadyModel:(id)dataDict
{
    SelectFriendsModel *model = [[SelectFriendsModel alloc] init];
    model.name = dataDict[@"friendName"];
    model.img_url = dataDict[@"imgUrl"];
    model.isSelected = NO;
    
    [_allarryModel addObject:model];
    
}

- (void)add2AlreadyModel:(id)dataDict tag:(NSInteger)tag
{
    SelectFriendsModel *model = [[SelectFriendsModel alloc] init];
    model.name = dataDict[@"friendName"];
    model.img_url = dataDict[@"imgUrl"];
    model.isSelected = NO;
    
    if (tag == NORMAL_TAG) {
        [_allarryModel addObject:model];
    }
    else
    {
        [_search_ModelArray addObject:model];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        switch (section) {
            case 0:
                return [_allarryModel count];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    SelectFriendsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_indentfier];

    if (cell == nil) {
        cell = [[SelectFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_indentfier];
    }
    
    if (tableView == self.tableView) {
        cell.model = _allarryModel[indexPath.row];
    }
    else
    {
        cell.model = _search_ModelArray[indexPath.row];
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 50.f + 1;;
    
}
#pragma mark - 每行触发的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.tableView) {
        SelectFriendsModel *model = _allarryModel[indexPath.row];
        model.isSelected = !model.isSelected;
        SelectFriendsCell* cell = (SelectFriendsCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.model = model;
    }
    else
    {
        SelectFriendsModel *model = _search_ModelArray[indexPath.row];
        
        for (int i = 0; i < [_allarryModel count]; i++) {
            SelectFriendsModel *tmpModel = _allarryModel[i];
            if ([model.name isEqualToString:tmpModel.name] && [model.img_url isEqualToString:tmpModel.img_url]) {
                [_allarryModel removeObjectAtIndex:i];
            }
        }
        model.isSelected = !model.isSelected;
        SelectFriendsCell* cell = (SelectFriendsCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.model = model;
        [_allarryModel insertObject:model atIndex:0];
    }
}


- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.tableView reloadData];
}



@end
