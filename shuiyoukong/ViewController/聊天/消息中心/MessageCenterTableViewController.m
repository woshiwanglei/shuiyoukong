//
//  MessageCenterTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MessageCenterTableViewController.h"
#import "MessageCenterTableViewCell.h"
#import "FreeSQLite.h"
#import "CoupleSuccTableViewController.h"
#import "ActivityInfoViewController.h"
#import "FreeSingleton.h"
#import "LoadMoreTableViewCell.h"
#import "PostViewController.h"
#import "ProductTableViewController.h"
#import "PointsViewController.h"

@interface MessageCenterTableViewController ()
@property (nonatomic, weak)NSString *identifier;
@property (nonatomic, weak)NSString *identifier_loadMore;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, strong)NSMutableArray *modelArray;
@property (nonatomic, assign)NSInteger pageNum;

@property (nonatomic, strong)UIImageView *notice_view;

@end

@implementation MessageCenterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _identifier = @"MessageCenterTableViewCell";
    _identifier_loadMore = @"LoadMoreTableViewCell";
    [self initData];
    [self initView];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNoticeTable:) name:ZC_NOTIFICATION_NEW_NOTICE_UPDATE object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)reloadNoticeTable:(NSNotification *)notification
{
    [self initData];
}

#pragma mark - initView & initData
- (void)initView
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_IF_HAS_NEW_NOTICE];//消除中心红点
    
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_loadMore bundle:nil] forCellReuseIdentifier:_identifier_loadMore];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    //设置tableview滑动速度
    self.tableView.decelerationRate = 0.5;
    
    switch (_type) {
        case OFFICIAL:
            self.navigationItem.title = @"官方通知";
            break;
        case COMMENT:
            self.navigationItem.title = @"评论通知";
            break;
        default:
            self.navigationItem.title = @"活动通知";
            break;
    }
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    _notice_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_notice_background"]];
    _notice_view.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 90)/2, ([[UIScreen mainScreen] bounds].size.height - 239)/2 , 90, 119);
    [self.view addSubview:_notice_view];
}

- (void)initData
{
    _dataSource = [NSMutableArray array];
    _modelArray = [NSMutableArray array];
    _pageNum = 1;
    [[FreeSQLite sharedInstance] selectFreeSQLiteNoticeList:_dataSource page:_pageNum type:_type];
    for (int i = 0; i < [_dataSource count]; i++) {
        [self addModel:_dataSource[i]];
    }
}

- (void)addModel:(id)data
{
    MessageCenterModel *model = [[MessageCenterModel alloc] init];
    model.sessionId = data[@"sessionId"];
    model.headImg_url = data[@"imgUrl"];
    model.freeDate = data[@"freeDate"];
    model.freeStartTime = data[@"freeTimeStart"];
    model.time = data[@"sendTime"];
    model.content = data[@"content"];
    model.activityId = data[@"activityId"];
    model.type = [data[@"type"] integerValue];
    model.isNew = [data[@"newTag"] integerValue] == 1 ? YES:NO;
    [_modelArray addObject:model];
//    switch (_type) {
//        case OFFICIAL:
//            if (model.type == 7 || model.type == 8 || model.type == 9) {
//                [_modelArray addObject:model];
//            }
//            break;
//        case COMMENT:
//            if (model.type == 6) {
//                [_modelArray addObject:model];
//            }
//            break;
//        default:
//            if (model.type == 3 || model.type == 4) {
//                [_modelArray addObject:model];
//            }
//            break;
//    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([_modelArray count] > 0) {
        _notice_view.hidden = YES;
    }
    else
    {
        _notice_view.hidden = NO;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_modelArray && [_modelArray count] > 0) {
        return [_modelArray count] + 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == [_modelArray count])
    {
        //新建一个单元格, 并且将其样式调整成我们需要的样子.
        LoadMoreTableViewCell *cell = (LoadMoreTableViewCell *)[tableView dequeueReusableCellWithIdentifier:_identifier_loadMore forIndexPath:indexPath];
        if (!cell) {
            cell = [[LoadMoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_loadMore];
        }
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    
    MessageCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MessageCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    
    cell.model = _modelArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60.f + 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60.f + 1;
    return 60.f + 1;
}

#pragma mark - 每行触发的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([indexPath row] == [_modelArray count])
    {
        [self performSelectorInBackground:@selector(loadMore) withObject:nil];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    MessageCenterModel *model = _modelArray[indexPath.row];
    [[FreeSQLite sharedInstance] updateFreeSQLiteNoticeList:model.sessionId];
    
    if (model.isNew == YES) {
        MessageCenterTableViewCell* cell = (MessageCenterTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.view_new.hidden = YES;
        model.isNew = NO;
        if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
            [UIApplication sharedApplication].applicationIconBadgeNumber =
            [UIApplication sharedApplication].applicationIconBadgeNumber - 1;
        }
    }
    
    switch (model.type) {
        case FRIENDS_COUPLE:
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
            CoupleSuccTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CoupleSuccTableViewController"];
            vc.freeDate = model.freeDate;
            vc.freeStartTime = model.freeStartTime;
            vc.fromTag = COME_FROM_PUSH;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case FRIENDS_ACITIVTY:
        case FRIENDS_INVITE:
        {
            ActivityInfoViewController *vc = [[ActivityInfoViewController alloc] initWithNibName:@"ActivityInfoViewController" bundle:nil];
            vc.activityId = model.activityId;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case POST_NOTICE:
        case CHOSEN_NOTICE:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            PostViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];
            viewController.postId = model.activityId;
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case PRIZE_NOTICE:
        {
            ProductTableViewController *vc = [[ProductTableViewController alloc] initWithNibName:@"ProductTableViewController" bundle:nil];
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case POINT_PRIZE:
        {
            PointsViewController *vc = [[PointsViewController alloc] initWithNibName:@"PointsViewController" bundle:nil];
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 加载更多
- (void)loadMore
{
    NSMutableArray *data = [NSMutableArray array];
    [[FreeSQLite sharedInstance] selectFreeSQLiteNoticeList:data page:_pageNum + 1 type:_type];
    if ([data count] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showErrorWithStatus:@"没有更多消息了"];
        });
        return;
    }
    _pageNum++;
    [self performSelectorOnMainThread:@selector(appendtablewith:) withObject:data waitUntilDone:NO];
}

- (void)appendtablewith:(NSMutableArray *)data
{
    NSMutableArray *insertindexpaths = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0;i < [data count];i++) {
        [_dataSource addObject:[data objectAtIndex:i]];
        [self addModel:data[i]];
    }
    for (int ind = 0; ind < [data count]; ind++) {
        NSIndexPath   *newpath = [NSIndexPath indexPathForRow:[_dataSource indexOfObject:[data objectAtIndex:ind]] inSection:0];
        NSLog(@"%ld", (long)newpath.row);
        [insertindexpaths addObject:newpath];
    }
    
    //重新调用uitableview的方法, 来生成行.
    [self.tableView insertRowsAtIndexPaths:insertindexpaths withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - 添加滑动删除
//判断是否是删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle result=UITableViewCellEditingStyleNone;
    if ([tableView isEqual:self.tableView]) {
        if (indexPath.row < [_modelArray count]) {
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
            MessageCenterModel *model = _modelArray[indexPath.row];
            [[FreeSQLite sharedInstance] deleteFreeSQLiteNoticeList:model.sessionId];
            [_dataSource removeObjectAtIndex:indexPath.row];
            [_modelArray removeObjectAtIndex:indexPath.row];
            }
        if ([self.dataSource count] == 0) {
            [self.tableView reloadData];
        }
        
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
            [tableView endUpdates];
        }
}

@end
