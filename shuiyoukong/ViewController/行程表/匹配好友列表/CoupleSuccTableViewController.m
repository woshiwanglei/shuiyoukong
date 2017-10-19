//
//  CoupleSuccTableViewController.m
//  Free
//
//  Created by 勇拓 李 on 15/5/14.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "CoupleSuccTableViewController.h"
#import "CoupleSuccTableViewCell.h"
#import "CoupleActivityCell.h"
#import "CoupleRemarkTableViewCell.h"
#import "FreeSQLite.h"
#import "RCDChatViewController.h"

#import "SharePictureViewController.h"
#import "SharePictureNoFriendsView.h"
#import "FreeSingleton.h"
#import "AppDelegate.h"

#import "UpdateRemarkViewController.h"
#import "CoupleSuccBottomView.h"
#import "ActiveDetailViewController.h"

@interface CoupleSuccTableViewController ()

@property (nonatomic, strong) NSMutableArray *modelArray;

@property (nonatomic, strong) NSMutableArray *activeDataSource;

@property (nonatomic, weak)NSString *identifier;
@property (nonatomic, weak)NSString *identifier_activity;
@property (nonatomic, weak)NSString *identifier_remark;

@property (nonatomic, strong)UIView *backgroundView;

@property (nonatomic, strong)CoupleSuccBottomView *bottomView;

@end

@implementation CoupleSuccTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRemark:) name:ZC_NOTIFICATION_CHANGE_REMARK object:nil];
    }
    return self;
}

- (void)changeRemark:(NSNotification *)notification {
    _remark = notification.object;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    CoupleRemarkTableViewCell* cell = (CoupleRemarkTableViewCell *)[self.mTableView cellForRowAtIndexPath:indexPath];
    cell.remark = _remark;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle =  UIBarStyleDefault;
    self.navigationController.navigationBar.alpha = 1.0;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.2f]];
}

- (void)initView
{
    _identifier = @"CoupleSuccTableViewCell";
    _identifier_activity = @"CoupleActivityCell";
    _identifier_remark = @"CoupleRemarkTableViewCell";
    
    [self.mTableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    [self.mTableView registerNib:[UINib nibWithNibName:_identifier_activity bundle:nil] forCellReuseIdentifier:_identifier_activity];
    [self.mTableView registerNib:[UINib nibWithNibName:_identifier_remark bundle:nil] forCellReuseIdentifier:_identifier_remark];
    
    self.mTableView.backgroundColor = FREE_LIGHT_COLOR;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    //设置返回按钮
//    [self comeFromPush];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:FREE_BACKGOURND_COLOR forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dic;
    
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    //设置tableview滑动速度
    self.mTableView.decelerationRate = 0.5;
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    self.mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    
    NSArray * arrayStartTime = [NSArray arrayWithObjects:@"上午",@"下午",@"晚上", nil];
    NSInteger index = [_freeStartTime integerValue]/6 - 1;
    
    NSArray *array = [_freeDate componentsSeparatedByString:@"-"];
    self.navigationItem.title = [NSString stringWithFormat:@"%@月%@日%@", array[1], array[2], [arrayStartTime objectAtIndex:index]];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120)];
    _bottomView = [[[NSBundle mainBundle] loadNibNamed:@"CoupleSuccBottomView"
                                                                owner:self
                                                              options:nil] objectAtIndex:0];
    _bottomView.frame = CGRectMake(0, 0, headerView.bounds.size.width, headerView.bounds.size.height);
    [_bottomView.btn_share addTarget:self action:@selector(shareActivity:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.btn_cancel addTarget:self action:@selector(cancelFree:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_bottomView];
    self.mTableView.tableFooterView = headerView;
    
    if([_modelArray count] <= 0)
    {
        self.mTableView.tableFooterView.hidden = YES;
    }
    
}

//如果是推送过来则设置返回按钮
//- (void)comeFromPush
//{
//    if (_fromTag == COME_FROM_PUSH) {
//        UIBarButtonItem *btnitem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(btn_disMissTapped)];
//        btnitem.tintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
//        self.navigationItem.leftBarButtonItem = btnitem;
//    }
//}
//
//- (void)btn_disMissTapped
//{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (void)initData
{
    [KVNProgress showWithStatus:@"Loading"];
    __weak CoupleSuccTableViewController *weakSelf = self;
    NSInteger retcode = [[FreeSingleton sharedInstance] getCoupleFriendsAndActivityOnCompletion:_freeDate freeTimeStart:_freeStartTime position:nil block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            
            _dataSource = [NSMutableArray array];
            _dataSource = data[@"freeMatchList"];
            _remark = data[@"remark"];
            [weakSelf insertToRemarkList];
            [weakSelf selectActivityByFreeTime:data[@"userActivityList"]];
                _modelArray = [NSMutableArray array];
            for (int i = 0; i < [_dataSource count]; i++) {
                [self insert2ModelArray:_dataSource[i]];
            }
            weakSelf.mTableView.tableFooterView.hidden = NO;
            [weakSelf.mTableView reloadData];
            [KVNProgress dismiss];
        }
        else
        {
            [KVNProgress dismiss];
           [KVNProgress showErrorWithStatus:data];
            NSLog(@"匹配好友列表 error:%@",data);
        }
    }];
    
    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
    }
    
}


//插入或更新到数据库
- (void)insertToRemarkList
{
    NSString *str = [[FreeSQLite sharedInstance] selectFreeSQLiteRemarkList:_freeDate freeTimeStart:_freeStartTime];
    if (str == nil) {
        [[FreeSQLite sharedInstance] insertFreeSQLiteRemarkList:_freeDate freeTimeStart:_freeStartTime remark:_remark];
        return;
    }
    if (![str isEqualToString:_remark]) {
        [[FreeSQLite sharedInstance] updateFreeSQLiteRemarkList:_freeDate freeTimeStart:_freeStartTime remark:_remark];
    }
}

//查询相应时间段的活动
- (void)selectActivityByFreeTime:(id)data
{
    if (!_activeDataSource) {
        _activeDataSource = [NSMutableArray array];
    }
    
    for (int i = 0; i < [data count]; i++) {
            CoupleSuccActivityModel *model = [[CoupleSuccActivityModel alloc] init];
            model.activityTitle = data[i][@"activityContent"];
            model.isMyActivity = [self setRightTag:data[i][@"type"]];
            model.peopleNum = data[i][@"attendCount"];
            model.activityId = data[i][@"activityId"];
            NSString *str = [NSString stringWithFormat:@"%@", data[i][@"promoterId"]];
            if ([str isEqual:[[FreeSingleton sharedInstance] getAccountId]]) {
                model.friendName = [[FreeSingleton sharedInstance] getNickName];
                model.img_url = [[FreeSingleton sharedInstance] getHeadImage];
                [_activeDataSource addObject:model];
            }
            else
            {
                NSDictionary *dict = [[FreeSQLite sharedInstance] selectFreeSQLiteUserInfo:str];
                if (dict) {
                    model.friendName = dict[@"friendName"];
                    model.img_url = dict[@"imgUrl"];
                    [_activeDataSource addObject:model];
                }
                else
                {
                    model.friendName = data[i][@"promoteAccount"][@"nickName"];
                    model.img_url = data[i][@"promoteAccount"][@"headImg"];
                    [_activeDataSource addObject:model];
                }
            }
//        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (_modelArray || _activeDataSource)
        return 3;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [_modelArray count];
            break;
        default:
            return [_activeDataSource count];
            break;
    }
}

//设置Section的Header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.frame.size.width, 40.0)];
    customView.backgroundColor = FREE_LIGHT_COLOR;
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1];
    headerLabel.font = [UIFont systemFontOfSize:15];
    headerLabel.frame = CGRectMake(10.0, 0.0, self.view.frame.size.width, 20.0);
    
    switch (section) {
        case 0:
            headerLabel.text = @"我的状态";
            break;
        case 1:
            headerLabel.text = @"有空好友";
            break;
        default:
            headerLabel.text = @"好友活动";
            break;
    }
    
    [customView addSubview:headerLabel];
    
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 20;
            break;
        case 1:
            if ([_modelArray count] == 0) {
                return 0;
            }
            return 20;
        default:
            if ([_activeDataSource count] == 0) {
                return 0;
            }
            return 20;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self basicCellAtIndexPath:indexPath tableView:tableView];
}


- (UITableViewCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    switch (indexPath.section) {
        case 0:
        {
            CoupleRemarkTableViewCell *cell = [self.mTableView dequeueReusableCellWithIdentifier:_identifier_remark forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[CoupleRemarkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_remark];
            }
            cell.remark = _remark;
            return cell;
        }
            break;
        case 1:
        {
            CoupleSuccTableViewCell *cell = [self.mTableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[CoupleSuccTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
            }
            cell.model = _modelArray[indexPath.row];
            if(indexPath.row != [_modelArray count] - 1)
            {
                cell.bottom_line.hidden = NO;
            }
            else
            {
                cell.bottom_line.hidden = YES;
            }
            return cell;
        }
            break;
        default:
        {
            CoupleActivityCell *cell = [self.mTableView dequeueReusableCellWithIdentifier:_identifier_activity forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[CoupleActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_activity];
            }
            cell.model = _activeDataSource[indexPath.row];
            return cell;
        }
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2) {
        return 60.f + 1;
    }
    return 50.f + 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.mTableView.rowHeight = UITableViewAutomaticDimension;
    self.mTableView.estimatedRowHeight = 50.f + 1;
    return 50.f + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section) {
        case 0:
            [self selectRemarkUpdate];
            break;
        case 1:
            [self selectFriendsCell:tableView indexPath:indexPath];
            break;
        default:
            [self selectActivityCell:indexPath];
            break;
    }
}

//更新remark
- (void)selectRemarkUpdate
{
    UpdateRemarkViewController *vc = [[UpdateRemarkViewController alloc] initWithNibName:@"UpdateRemarkViewController" bundle:nil];
    vc.remark = _remark;
//    vc.freeDate = _freeDate;
//    vc.freeStartTime = _freeStartTime;
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

//选择好友
- (void)selectFriendsCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    CoupleSuccCellModel *model = _modelArray[indexPath.row];
    
    //创建会话
    RCDChatViewController *chatViewController = [[RCDChatViewController alloc] init];
    chatViewController.conversationType = ConversationType_PRIVATE;
    chatViewController.targetId = model.friend_accountId;
    chatViewController.title = model.friend_name;
    
    UINavigationController *navigationController = self.navigationController;
    [navigationController pushViewController:chatViewController animated:YES];
}


//选择活动
- (void)selectActivityCell:(NSIndexPath *)indexPath
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    ActiveDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ActiveDetailViewController"];
    
    CoupleSuccActivityModel *model = _activeDataSource[indexPath.row];
    
    vc.activityId = model.activityId;
    vc.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark -添加model
- (void)insert2ModelArray:(id)data
{
    CoupleSuccCellModel *model = [[CoupleSuccCellModel alloc] init];
    model.headImg_url = data[@"account"][@"headImg"];
    model.friend_name = data[@"account"][@"friendName"];
    NSString *str = [NSString stringWithFormat:@"%@", data[@"account"][@"id"]];
    model.friend_accountId = str;
    if (data[@"remark"] != nil) {
        model.friend_tag = data[@"remark"];
    }
    else
    {
        model.friend_tag = [[FreeSingleton sharedInstance] changeTagsToString:data[@"sameTags"]];
    }
    
    [_modelArray addObject:model];
}

#pragma mark - 小功能
- (BOOL)setRightTag:(NSString *)type
{
    if ([type integerValue] == 0) {
        return YES;
    }
    return NO;
}

- (void)changeState
{
    NSString *Id = [[FreeSingleton sharedInstance] getAccountId];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:_freeDate, @"freeDate", _freeStartTime, @"freeTimeStart", Id, @"id",nil];

    //通知状态变化
    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DID_STATE_CHANGE object:DELETEMODEL userInfo:dic];
}

- (void)changeBackGroundColor:(SubCalendarViewModel *)model
{
    _cell_view.backgroundColor = [UIColor whiteColor];
    if (model.isTurnOn == YES) {
        _cell_view.layer.borderColor =  [[UIColor colorWithRed:32/255.0 green:186/255.0 blue:148/255.0 alpha:.7] CGColor];
        _cell_view.layer.borderWidth = .8f;
    }
    else
    {
        if (model.typeNum == FRIENDSHERE) {
            _cell_view.btn_free.hidden = NO;
        }
        else
        {
            _cell_view.btn_free.hidden = YES;
        }
        _cell_view.layer.borderColor = [[UIColor clearColor] CGColor];
        _cell_view.layer.borderWidth = .8f;
    }
}

#pragma mark - 删除和分享
- (void)cancelFree:(id)sender
{
    if (_fromTag == COME_FROM_PUSH) {
        [self cancelComeOnFromPush];
    }
    else
    {
        [self cancelNormal];
    }
}

- (void)cancelComeOnFromPush
{
    __weak CoupleSuccTableViewController *weakSelf = self;
    _bottomView.userInteractionEnabled = NO;
    NSInteger ret = [[FreeSingleton sharedInstance] cancelCalendarOnCompletion:_freeDate freeTimeStart:_freeStartTime block:^(NSUInteger retcode, id data) {
        _bottomView.userInteractionEnabled = YES;
        if (retcode == RET_SERVER_SUCC) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:_freeDate, @"freeDate", _freeStartTime, @"freeTimeStart", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DID_PUSH_CHANGE object:dic];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }
    }];
    
    if (ret != RET_OK)
    {
        _bottomView.userInteractionEnabled = YES;
        NSLog(@"sendFreeDate error is :%@", zcErrMsg(ret));
    }
}

- (void)cancelNormal
{
    _cell_view.backgroundColor = [UIColor whiteColor];
    _cell_view.model.isTurnOn = NO;
    _cell_view.btn_free.hidden = YES;
    _cell_view.layer.borderColor = [[UIColor clearColor] CGColor];
    _cell_view.layer.borderWidth = .8f;
    
    _bottomView.userInteractionEnabled = NO;
    
    __weak CoupleSuccTableViewController *weakSelf = self;
    
    NSInteger ret = [[FreeSingleton sharedInstance] cancelCalendarOnCompletion:_freeDate freeTimeStart:_freeStartTime block:^(NSUInteger retcode, id data) {
         _bottomView.userInteractionEnabled = YES;
        if (retcode == RET_SERVER_SUCC) {
            
            [weakSelf changeState];
            //消除已读状态
        }
        else
        {
            _cell_view.model.isTurnOn = YES;
            _cell_view.btn_free.hidden = NO;
            [_cell_view.btn_free setImage:[UIImage imageNamed:@"gou"] forState:UIControlStateNormal];
            NSLog(@"sendFreeDate error is :%@", data);
            [weakSelf changeBackGroundColor:_cell_view.model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
    
    if (ret != RET_OK)
    {
        _bottomView.userInteractionEnabled = YES;
        NSLog(@"sendFreeDate error is :%@", zcErrMsg(ret));
    }
}

- (void)shareActivity:(id)sender
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backgroundView.backgroundColor = [UIColor colorWithRed:(0/255.0)
                                                          green:(0/255.0)  blue:(0/255.0) alpha:.4];
        _backgroundView.userInteractionEnabled = YES;
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundColorDisapper:)];
        [_backgroundView addGestureRecognizer:tapGes];
    }
    
    if (![_backgroundView superview])
    {
        [[AppDelegate getMainWindow] addSubview:_backgroundView];
        
        SharePictureNoFriendsView* shareView =
        [[[NSBundle mainBundle] loadNibNamed:@"SharePictureNoFriendsView"
                                       owner:self
                                     options:nil] objectAtIndex:0];
        shareView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [shareView.btn_commit addTarget:self action:@selector(sharePic:) forControlEvents:UIControlEventTouchUpInside];
        
        [shareView.btn_cancel addTarget:self action:@selector(cancelShare:) forControlEvents:UIControlEventTouchUpInside];
        
        [shareView.text_input becomeFirstResponder];
        
        [_backgroundView addSubview:shareView];
        
        NSDictionary *metrics = @{
                                  @"height" : @(([UIScreen mainScreen].bounds.size.height - 175)/2 - 100),
                                  @"width" : @([UIScreen mainScreen].bounds.size.width)
                                  };
        NSDictionary *views = NSDictionaryOfVariableBindings(shareView);
        
        [_backgroundView addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:@"H:|-30-[shareView]-30-|"
          options:0
          metrics:metrics
          views:views]];
        [_backgroundView addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:
                                         @"V:|-height-[shareView(175)]"
                                         options:0
                                         metrics:metrics
                                         views:views]];
    }
}

#pragma mark - 分享图片相关
//分享图片
- (void)sharePic:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    SharePictureNoFriendsView *shareView = (SharePictureNoFriendsView *)btn.superview;
    
    if (shareView.text_input.text.length > 20) {
        shareView.label_notice.text = @"不能超过20个字";
        shareView.label_notice.hidden = NO;
        return;
    }
    else if (shareView.text_input.text.length <= 0)
    {
        shareView.label_notice.text = @"不能输入空内容";
        shareView.label_notice.hidden = NO;
        return;
    }
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:_freeDate, @"freeDate", _freeStartTime, @"freeTimeStart", shareView.text_input.text, @"text",nil];
    
    UIView *view = [sender superview];
    [view removeFromSuperview];
    [_backgroundView removeFromSuperview];
    [self performSegueWithIdentifier:@"sharePic" sender:dic];
    
}

- (void)backgroundColorDisapper:(UITapGestureRecognizer *)gesture
{
    NSArray *views = [gesture.view subviews];
    for(UIView *view in views)
    {
        [view removeFromSuperview];
    }
    [gesture.view removeFromSuperview];
}

//退出分享
- (void)cancelShare:(id)sender
{
    SharePictureNoFriendsView *view = (SharePictureNoFriendsView *)[sender superview];
    [view.text_input resignFirstResponder];
    [view removeFromSuperview];
    [_backgroundView removeFromSuperview];
}


#pragma mark - 添加滑动删除


#pragma makr -跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"sharePic"])
    {
        SharePictureViewController* vc = (SharePictureViewController *)segue.destinationViewController;

        vc.content = sender[@"text"];
        vc.hidesBottomBarWhenPushed = YES;
    }
    
}

@end
