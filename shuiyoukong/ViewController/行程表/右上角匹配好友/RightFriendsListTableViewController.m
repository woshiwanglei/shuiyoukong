//
//  RightFriendsListTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/25.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "RightFriendsListTableViewController.h"
#import "FreeSQLite.h"
#import "RightFriendsListView.h"
#import "CoupleSuccTableViewCell.h"
#import "SwitchListView.h"
#import "FreeSingleton.h"
#import "ActiveDetailViewController.h"
#import "RCDChatViewController.h"
#import "ActivityInfoViewController.h"

#import "RightTableViewCell.h"

@interface RightFriendsListTableViewController ()

//@property (strong, nonatomic)NSMutableArray *dataSource;
@property (strong, nonatomic)NSMutableArray *activeDataSource;

@property (strong, nonatomic)NSMutableArray *modelArray;

@property (weak, nonatomic)NSString *identifier;
@property (strong, nonatomic)NSMutableArray *tagArray;

//@property (nonatomic, assign)BOOL buttonLock;

@property (nonatomic, assign)NSInteger index;

@property (nonatomic, strong)UIImageView *notice_view;

@property (nonatomic, copy) NSString *idenerter;

@end

@implementation RightFriendsListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self registerNotificationDataSource];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initView
{
    self.navigationItem.title = @"活动";
    _idenerter = @"RightTableViewCell";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:_idenerter bundle:nil] forCellReuseIdentifier:_idenerter];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    //设置tableview滑动速度
    self.tableView.decelerationRate = 0.5;
   
}

- (void)initData
{
    //获取活动数据
    [self initActiveData];
}

//初始化活动数据
- (void)initActiveData
{
    __weak RightFriendsListTableViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] getActiveInfoOnCompletion:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            weakSelf.activeDataSource = [NSMutableArray arrayWithArray:data];
                [weakSelf.tableView reloadData];
            
            if ([_activeDataSource count] == 0)
            {
                _notice_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_activity_background"]];
                _notice_view.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 90)/2, ([[UIScreen mainScreen] bounds].size.height - 239)/2 , 90, 119);
                [self.view addSubview:_notice_view];
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showErrorWithStatus:@"网络错误"];
            });
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_activeDataSource count];
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    RightTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_idenerter forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[RightTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    
    NSString *freeTime;
    if (![_activeDataSource[indexPath.row][@"activityTime"] isKindOfClass:[NSNull class]]) {
        freeTime = _activeDataSource[indexPath.row][@"activityTime"];
    }
    else
    {
        freeTime = [NSString stringWithFormat:@"%ld:00", (long)[_activeDataSource[indexPath.row][@"activityTimeStart"] integerValue]];
    }
    
    [self initHeaderView:cell.timeLable section:indexPath.row freeDate:_activeDataSource[indexPath.row][@"activityDate"] freeStartTime:freeTime];
    
    if (![_activeDataSource[indexPath.row][@"title"] isKindOfClass:[NSNull class]]) {
        cell.neirongLbale.text = _activeDataSource[indexPath.row][@"title"];
    }
    else
    {
        cell.neirongLbale.text = _activeDataSource[indexPath.row][@"activityContent"];
    }
    
    cell.pelopeNumber.text =[NSString stringWithFormat:@"%@ 人", _activeDataSource[indexPath.row][@"attendCount"]];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f + 1;
    return 50.f + 1;
}
#pragma mark - 每行触发的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _index = indexPath.row;
    
    ActivityInfoViewController *vc = [[ActivityInfoViewController alloc] initWithNibName:@"ActivityInfoViewController" bundle:nil];
    vc.activityId = _activeDataSource[_index][@"activityId"];
    [self.navigationController pushViewController:vc animated:YES];
    
//    [self performSegueWithIdentifier:@"ActiveDetailViewSeg" sender:self];
}

- (void)initHeaderView:(UILabel *)label_time section:(NSInteger)section freeDate:(NSString *)freeDate freeStartTime:(NSString *)freeStartTime
{
    label_time.text = [NSString stringWithFormat:@"%@ %@", freeDate, freeStartTime];
}



#pragma mark -辅助功能

- (NSString *)changeDate2String:(NSDate *)date
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date_str = [dateformatter stringFromDate:date];
    return date_str;
}


#pragma mark -通知
- (void) registerNotificationDataSource {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceDIdChange:) name:ZC_NOTIFICATION_DATASOURCE_CHANGE object:nil];
}

- (void) dataSourceDIdChange:(NSNotification *) notification{
    NSDictionary *dic = notification.object;
    NSInteger type = [dic[@"type"] integerValue];
    NSInteger count = [notification.userInfo[@"count"] integerValue];
    switch (type) {
        case MY_HOST:
            [_activeDataSource removeObjectAtIndex:_index];
            break;
        case NOT_ATTEND:
        {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:_activeDataSource[_index]];
            dic[@"attendCount"] = [NSString stringWithFormat:@"%ld", (long)(count - 1)];
            [_activeDataSource replaceObjectAtIndex:_index withObject:dic];//替换数据
            
        }
            break;
        default:
        {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:_activeDataSource[_index]];
            dic[@"attendCount"] = [NSString stringWithFormat:@"%ld", (long)(count + 1)];
            [_activeDataSource replaceObjectAtIndex:_index withObject:dic];//替换数据
        }
            break;
    }
    
    [self.tableView reloadData];
}

#pragma mark -跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}

@end