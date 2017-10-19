//
//  MyPostViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/31.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MyPostViewController.h"
#import "PostViewController.h"
#import "FreeSingleton.h"
#import "MJRefresh.h"
#import "MyPostTableViewCell.h"

@interface MyPostViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic)NSMutableArray *modelArray;
@property (weak, nonatomic)NSString *identifier;
@property (assign, nonatomic)NSInteger cellIndex;
@property (strong, nonatomic)UIImageView *notice_view;
@end

@implementation MyPostViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPost:) name:FREE_NOTIFICATION_RELOAD_MYPOST object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadPost:(NSNotification *)notification
{
    [self initData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _identifier = @"MyPostTableViewCell";
    [_mTableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([_modelArray count] && _cellIndex < [_modelArray count]) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_cellIndex inSection:0];
        [_mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - initView
- (void)initView
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    
    if (_isMyPost) {
        self.navigationItem.title = @"我的推荐";
        _notice_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_newpost"]];
    }
    else
    {
        self.navigationItem.title = @"我想去的";
        _notice_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_wanted_go"]];
    }
    
    _notice_view.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 90)/2, ([[UIScreen mainScreen] bounds].size.height - 239)/2 , 90, 119);
    [self.view addSubview:_notice_view];
}

- (void)initData
{
    _modelArray = [NSMutableArray array];
    
    __weak MyPostViewController *weakSelf = self;
    if (_isMyPost) {
        [KVNProgress showWithStatus:@"Loading"];
        [[FreeSingleton sharedInstance] queryMyPostList:@"1" pageSize:@"10" postId:@"0" block:^(NSUInteger ret, id data) {
            [KVNProgress dismiss];
            if (ret == RET_SERVER_SUCC) {
                if ([data[@"items"] count]) {
                    [weakSelf initModelArray:data[@"items"]];
                    [_mTableView reloadData];
                }
            }
        }];
    }
    else
    {
        [KVNProgress showWithStatus:@"Loading"];
        [[FreeSingleton sharedInstance] queryMyLikeList:@"1" pageSize:@"10" postId:@"0" block:^(NSUInteger ret, id data) {
            [KVNProgress dismiss];
            if (ret == RET_SERVER_SUCC) {
                if ([data[@"items"] count]) {
                    [weakSelf initModelArray:data[@"items"]];
                    [_mTableView reloadData];
                }
            }
        }];
    }
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_mTableView addFooterWithTarget:self action:@selector(footerRereshing_MyPost)];
    _mTableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
    _mTableView.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    _mTableView.footerRefreshingText = @"正在加载中";
}

- (void)footerRereshing_MyPost
{
    __weak MyPostViewController *weakSelf = self;
    
    NSString *postIdStr = @"0";
    if ([_modelArray count]) {
        DiscoverModel *model = [_modelArray lastObject];
        postIdStr = model.postId;
    }
    
    if (_isMyPost) {
        [[FreeSingleton sharedInstance] queryMyPostList:@"1" pageSize:@"10" postId:postIdStr block:^(NSUInteger ret, id data) {
            if (ret == RET_SERVER_SUCC) {
                if ([data[@"items"] count]) {
                    [weakSelf initModelArray:data[@"items"]];
                    [_mTableView reloadData];
                }
                else
                {
                    [KVNProgress showErrorWithStatus:@"没有更多了"];
                }
            }
            else
            {
                [KVNProgress showErrorWithStatus:data];
            }
            [_mTableView footerEndRefreshing];
        }];
    }
    else
    {
        [[FreeSingleton sharedInstance] queryMyLikeList:@"1" pageSize:@"10" postId:postIdStr block:^(NSUInteger ret, id data) {
            if (ret == RET_SERVER_SUCC) {
                if ([data[@"items"] count]) {
                    [weakSelf initModelArray:data[@"items"]];
                    [_mTableView reloadData];
                }
                else
                {
                    [KVNProgress showErrorWithStatus:@"没有更多了"];
                }
            }
            else
            {
                [KVNProgress showErrorWithStatus:data];
            }
            [_mTableView footerEndRefreshing];
        }];
    }
}

- (void)initModelArray:(id)data
{
    for (int i = 0; i < [data count]; i++) {
        DiscoverModel *model = [[DiscoverModel alloc] init];
        
        NSDictionary *dict = data[i];
        
        model.postId = [NSString stringWithFormat:@"%@",dict[@"postId"]];
        model.type = [NSString stringWithFormat:@"%@", dict[@"type"]];
        model.accountId = [NSString stringWithFormat:@"%@",dict[@"accountId"]];
        
        if(_isMyPost)
        {
            model.isUp = [dict[@"upOrDown"] integerValue];
        }
        else
        {
            model.isUp = YES;
        }
        
        if ([dict[@"recommendTime"] isKindOfClass:[NSNull class]]) {
            model.recommendTime = nil;
        }
        else
        {
            model.recommendTime = [NSString stringWithFormat:@"%@", dict[@"recommendTime"]];
        }
        
        NSArray *array = [dict[@"url"] componentsSeparatedByString:@"#%#"];
        model.big_Img = array[0];
        for (int k = 0; k < [array count]; k++)
        {
            if ([array[k] isKindOfClass:[NSNull class]] || [array[k] length] == 0) {
                continue;
            }
            [model.img_array addObject:array[k]];
        }
        model.head_Img = dict[@"headImg"];
        model.name = dict[@"nickName"];
        
        if (![dict[@"title"] isKindOfClass:[NSNull class]] && [dict[@"title"] length]) {
            model.title = dict[@"title"];
        }
        else
        {
            model.title = @"";
        }
        
        if (![dict[@"address"] isKindOfClass:[NSNull class]] && [dict[@"address"] length]) {
            model.address = dict[@"address"];
        }
        else
        {
            model.title = @"";
        }
        
        model.content = dict[@"content"];
        
        if (![dict[@"tag"] isKindOfClass:[NSNull class]] && [dict[@"tag"] length]) {
            NSArray *arrayTags = [dict[@"tag"] componentsSeparatedByString:@"#%#"];
            model.editor_comment = arrayTags[0];
            for (int j = 1; j < [arrayTags count]; j++) {
                if ([arrayTags[j] length]) {
                model.editor_comment = [NSString stringWithFormat:@"%@ %@", model.editor_comment, arrayTags[j]];
                }
            }
        }
        else
        {
            model.editor_comment = @"";
        }
        
        model.num = [NSString stringWithFormat:@"%@",dict[@"upCount"]];
        model.reCount = [NSString stringWithFormat:@"%@",dict[@"reCount"]];
        
        if (![dict[@"position"] isKindOfClass:[NSNull class]] && [dict[@"position"] length])
        {
            NSArray *arrayPosition = [dict[@"position"] componentsSeparatedByString:@"-"];
            model.latitude = [arrayPosition[0] floatValue];
            model.longitude = [arrayPosition[1] floatValue];
        }
        
        
        [_modelArray addObject:model];//老数据
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([_modelArray count]) {
        _notice_view.hidden = YES;
        return [_modelArray count];
    }
    _notice_view.hidden = NO;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyPostTableViewCell *cell = [_mTableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[MyPostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    cell.model = _modelArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 64.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _cellIndex = indexPath.row;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PostViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];
    viewController.model = _modelArray[indexPath.row];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
