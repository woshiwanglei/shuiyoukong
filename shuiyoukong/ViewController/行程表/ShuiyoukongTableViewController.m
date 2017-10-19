//
//  ShuiyoukongTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/7.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ShuiyoukongTableViewController.h"
#import "ShuiyoukongHeader.h"
#import "FreeSingleton.h"
#import "FreePostTableViewCell.h"
#import "CoupleSuccTableViewCell.h"
#import "PostViewController.h"
#import "ShuiyoukongMenuTableViewCell.h"
#import "CreateActivityViewController.h"
#import "ShuiyoukongActivityTableViewCell.h"
#import "ActivityInfoViewController.h"
#import "SharePictureNoFriendsView.h"
#import "SharePictureViewController.h"
#import "AppDelegate.h"
#import "RCDChatViewController.h"
#import "FreeWebViewController.h"
#import "FreeSQLite.h"
#import "MJRefresh.h"
#import "FreeMap.h"
#import "NearByTableViewCell.h"
#import "GuideView1.h"
#import "GuideView3.h"
#import "BothNearByViewController.h"

#import "GrayTableViewCell.h"

#define NORMAL  3
#define NOT_ATTEND 2
#define ALREADY_ATTEND 1
#define MY_HOST 0

#define ONCE_BE_FREE 3

@interface ShuiyoukongTableViewController ()

@property (nonatomic, strong)NSMutableArray *postModelArray;
@property (nonatomic, weak)NSString *identifier_post;

@property (nonatomic, strong)NSMutableArray *friendModelArray;
@property (nonatomic, weak)NSString *identifier_friend;

@property (nonatomic, strong)NSMutableArray *activityModelArray;
@property (nonatomic, weak)NSString *identifier_activity;

@property (nonatomic, strong)NSMutableArray *nearByModelArray;
@property (nonatomic, weak)NSString *identifier_nearby;

@property (nonatomic, weak)NSString *identifier_gray;

//@property (weak, nonatomic)NSString *remark;

@property (assign, nonatomic)BOOL isFree;//判断是否是有空状态

@property (strong, nonatomic)ShuiyoukongHeader *shuiyoukongHeader;
@property (weak, nonatomic)NSString *identifier_menu;
@property (nonatomic, strong)UITableView *menuTableview;
@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)UIView *blackBackView;
@property (nonatomic, assign)BOOL isMenu;

@property (nonatomic, assign)BOOL isFirstGuide;

@end

@implementation ShuiyoukongTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _identifier_post = @"FreePostTableViewCell";
    _identifier_friend = @"CoupleSuccTableViewCell";
    _identifier_activity = @"ShuiyoukongActivityTableViewCell";
    _identifier_nearby = @"NearByTableViewCell";
    _identifier_gray = @"GrayTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_post bundle:nil] forCellReuseIdentifier:_identifier_post];
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_friend bundle:nil] forCellReuseIdentifier:_identifier_friend];
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_activity bundle:nil] forCellReuseIdentifier:_identifier_activity];
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_nearby bundle:nil] forCellReuseIdentifier:_identifier_nearby];
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_gray bundle:nil] forCellReuseIdentifier:_identifier_gray];
    [self initGuide];
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freeStatusSwitch:) name:FREE_NOTIFICATION_UPDATE_FREE_STATUS object:nil];
        [self registerNotificationDataSource];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRemark:) name:ZC_NOTIFICATION_CHANGE_REMARK object:nil];
        //全局删除帖子注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPost:) name:FREE_NOTIFICATION_RELOAD_MYPOST object:nil];
    }
    return self;
}

- (void)reloadPost:(NSNotification *)notification
{
    [self headerRefreshing];
}

- (void)changeRemark:(NSNotification *)notification {
    
    _shuiyoukongHeader.content = notification.object;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_isMenu) {
        self.tableView.scrollEnabled = YES;
        _isMenu = NO;

        [_backView removeFromSuperview];
        [_menuTableview removeFromSuperview];
    }
    
//    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isFirstGuide) {
        _isFirstGuide = NO;
        return;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:KEY_IF_NOT_NEED_GUIDED_RIGHT_UP] && !_isFirstGuide) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IF_NOT_NEED_GUIDED_RIGHT_UP];
        GuideView3 *view = [[[NSBundle mainBundle] loadNibNamed:@"GuideView3"
                                                          owner:self
                                                        options:nil] objectAtIndex:0];
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [[AppDelegate getMainWindow] addSubview:view];
        [view.btn addTarget:self action:@selector(guideRightUp:) forControlEvents:UIControlEventTouchDown];
    }
}

- (void)guideRightUp:(UIButton *)btn
{
    UIView *view = btn.superview;
    [view removeFromSuperview];
    [self functionIncident];
}

- (void)freeStatusSwitch:(NSNotification *)notification
{
    _isFree = [notification.object boolValue];
    //&& [_friendModelArray count] == 0
    if (_isFree) {
        [self headerRefreshing];
    }
    else
    {
        [self.tableView reloadData];
    }
}

#pragma mark - 引导图
- (void)initGuide
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:KEY_IF_NOT_NEED_GUIDED]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IF_NOT_NEED_GUIDED];
        GuideView1 *view = [[[NSBundle mainBundle] loadNibNamed:@"GuideView1"
                                                    owner:self
                                                  options:nil] objectAtIndex:0];
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//        [[AppDelegate getMainWindow] addSubview:view];
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        backView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0  blue:0/255.0  alpha:.5];
        
        [backView addSubview:view];
        [[AppDelegate getMainWindow] addSubview:backView];
        
        view.vc = self;
        _isFirstGuide = YES;
    }
}

#pragma mark - initView
- (void)initView
{
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.navigationItem.title = @"谁有空";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    [self.tabBarController.tabBar setTranslucent:NO];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    //设置tableview滑动速度
    self.tableView.decelerationRate = 0.5;
    
    self.tableView.backgroundColor = FREE_LIGHT_COLOR;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    
    _shuiyoukongHeader = [[[NSBundle mainBundle] loadNibNamed:@"ShuiyoukongHeader"
                                                                      owner:self
                                                                    options:nil] objectAtIndex:0];
    _shuiyoukongHeader.vc = self;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    _shuiyoukongHeader.frame = CGRectMake(0, 0, self.view.bounds.size.width, 80);
    headerView.backgroundColor = FREE_BACKGOURND_COLOR;
    self.tableView.tableHeaderView = headerView;
    [headerView addSubview:_shuiyoukongHeader];
    
    [self initMenuTable];
}

- (void)initMenuTable
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn addTarget:self action:@selector(functionIncident) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = backItem;
    UIButton *btred= [[UIButton alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+self.tableView.contentSize.height)];

    _backView = [[UIView alloc] initWithFrame:CGRectMake(self.tableView.frame.origin.x, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+self.tableView.contentSize.height)];
    _backView.backgroundColor = [UIColor clearColor];
    _menuTableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, 120, 98) style:UITableViewStylePlain];
    _identifier_menu = @"ShuiyoukongMenuTableViewCell";
    [_menuTableview registerNib:[UINib nibWithNibName:_identifier_menu bundle:nil] forCellReuseIdentifier:_identifier_menu];
    UISwipeGestureRecognizer *swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switGesView:)];
    [swipeGes setDirection:(UISwipeGestureRecognizerDirectionUp)];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switGesView:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [btred addTarget:self action:@selector(btnView) forControlEvents:UIControlEventTouchUpInside];
    [_backView addGestureRecognizer:swipeGes];
    [_backView addGestureRecognizer:swipe];
    [_backView addSubview:btred];

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_menuTableview.bounds];

    _menuTableview.layer.masksToBounds = NO;

    _menuTableview.layer.shadowColor = [UIColor blackColor].CGColor;

    _menuTableview.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);

    _menuTableview.layer.shadowOpacity = 0.5f;

    _menuTableview.layer.shadowPath = shadowPath.CGPath;


    [_menuTableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    _menuTableview.delegate = self;
    _menuTableview.dataSource = self;

    _menuTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    _menuTableview.scrollEnabled = NO;

    if ([_menuTableview respondsToSelector:@selector(setSeparatorInset:)]) {

        [_menuTableview setSeparatorInset:UIEdgeInsetsZero];

    }

    if ([_menuTableview respondsToSelector:@selector(setLayoutMargins:)]) {

        [_menuTableview setLayoutMargins:UIEdgeInsetsZero];

    }
}

#pragma mark - initData
- (void)initData
{
    [self setupRefresh];
}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    //自动刷新(一进入程序就下拉刷新)
    [self.tableView  headerBeginRefreshing];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    self.tableView.headerPullToRefreshText = @"下拉可以刷新了";
    self.tableView.headerReleaseToRefreshText = @"松开马上刷新了";
    self.tableView.headerRefreshingText = @"正在刷新中";
    
}

- (void)headerRefreshing
{
    __weak ShuiyoukongTableViewController *weakSelf = self;
    
    NSDate *date = [NSDate date];
    NSString *freeDate = [self changeDate2String:date];
    
    //进行定位
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [FreeMap getPosition:weakSelf block:^(NSUInteger ret, id data) {
        NSString *positionStr = nil;
        if(data)
        {
            NSArray *arrayPosition = [data componentsSeparatedByString:@"-"];
            if([arrayPosition count] > 1)
            {
                positionStr = [NSString stringWithFormat:@"%@-%@", arrayPosition[1], arrayPosition[0]];
            }
        }
        
        //初始化检索对象
        NSInteger retcode = [[FreeSingleton sharedInstance] getCoupleFriendsAndActivityOnCompletion:freeDate freeTimeStart:nil position:positionStr block:^(NSUInteger ret, id data) {
            if (ret == RET_SERVER_SUCC) {
                
                if ([data[@"postList"] count]) {
                    [weakSelf addPostModel:data[@"postList"]];
                }
                
                [weakSelf judgeIsFree:data[@"id"] status:data[@"status"] remark:data[@"remark"]];
                
                if ([data[@"userActivityList"] count]) {
                    [weakSelf addActivityModel:data[@"userActivityList"]];
                }
                
                //            if ([data[@"freeMatchList"] count]) {
                [weakSelf addFriendModel:data[@"freeMatchList"]];
                //            }
                if ([data[@"nearByPostList"] count])
                {
                    [weakSelf addNearByModel:data[@"nearByPostList"]];
                }
                
                [weakSelf.tableView reloadData];
                //            [KVNProgress dismiss];
            }
            else
            {
                //            [KVNProgress dismiss];
                [KVNProgress showErrorWithStatus:data];
                NSLog(@"匹配好友列表 error:%@",data);
            }
            [weakSelf.tableView headerEndRefreshing];
        }];
        
        if (retcode != RET_OK) {
            [weakSelf.tableView headerEndRefreshing];
            [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
        }
    }];
}

- (void)judgeIsFree:(id)data status:(NSString *)status remark:(id)remark
{
    if ([data isKindOfClass:[NSNull class]] || data == nil) {
        _isFree = NO;
    }
    else
    {
        if([status integerValue] == 0)
        {
            _isFree = YES;
        }
        else
        {
            _isFree = NO;
        }
    }
    
    _shuiyoukongHeader.isFree = _isFree;
    
    if (![remark isKindOfClass:[NSNull class]] && [remark length]) {
        _shuiyoukongHeader.content = remark;
    }
    
}
//添加匹配好友数据
- (void)addFriendModel:(id)data
{
    _friendModelArray = [NSMutableArray array];
    for (int i = 0; i < [data count]; i++) {
        NSDictionary *dic = data[i];
        CoupleSuccCellModel *model = [[CoupleSuccCellModel alloc] init];
        model.headImg_url = dic[@"account"][@"headImg"];
        model.friend_name = dic[@"account"][@"friendName"];
        model.type = dic[@"type"];
        NSString *str = [NSString stringWithFormat:@"%@", dic[@"account"][@"id"]];
        model.friend_accountId = str;
        if (dic[@"remark"] != nil) {
            model.friend_tag = dic[@"remark"];
        }
        else
        {
            model.friend_tag = [[FreeSingleton sharedInstance] changeTagsToString:dic[@"sameTags"]];
        }
        if ([dic[@"free"][@"time"] integerValue] > 0 && [dic[@"free"][@"status"] integerValue] == ONCE_BE_FREE) {
            model.str_time = [NSString stringWithFormat:@"%@", dic[@"free"][@"time"]];
        }
        
        [_friendModelArray addObject:model];
    }
}

//添加活动数据
- (void)addActivityModel:(id)data
{
    _activityModelArray = [NSMutableArray array];
    
    NSMutableArray *noticeList = [NSMutableArray array];
    
    for (int i = 0; i < [data count]; i++) {
        ActivityModel *model = [[ActivityModel alloc] init];
        NSDictionary *dic = data[i];
        if (![dic[@"activityDate"] isKindOfClass:[NSNull class]] && [dic[@"activityDate"] length]) {
            model.activityDate = dic[@"activityDate"];
        }
        model.activityTime = dic[@"activityTime"];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        NSDate *date = [NSDate date];
        if (model.activityDate) {
            NSString *dateString1 = [NSString stringWithFormat:@"%@ %@", model.activityDate, model.activityTime];
            NSDate *date1 = [dateFormatter dateFromString:dateString1];
            NSTimeInterval time = [date1 timeIntervalSinceDate:date];
            if (time > 30 * 60) {
                [noticeList addObject:model];
            }
        }
        
        model.activityId = [NSString stringWithFormat:@"%@", dic[@"activityId"]];
        if (![dic[@"imgUrl"] isKindOfClass:[NSNull class]]) {
            model.imgUrl = dic[@"imgUrl"];
        }
        model.address = dic[@"address"];
        
        model.headImg = dic[@"promoteAccount"][@"headImg"];
        model.promoteAccount.accountId = [NSString stringWithFormat:@"%@", dic[@"promoteAccount"][@"id"]];
        model.promoteAccount.nickName = dic[@"promoteAccount"][@"nickName"];
        if (![dic[@"title"] isKindOfClass:[NSNull class]] && dic[@"title"] != nil) {
            model.title = dic[@"title"];
        }
        else
        {
            model.title = dic[@"activityContent"];
        }
        
        model.attendCount = [dic[@"attendCount"] integerValue];
        [_activityModelArray addObject:model];
    }
    
    if ([noticeList count] > 0) {
        [self addLocalNotice:noticeList];
    }
}


//添加帖子数据
- (void)addPostModel:(id)data
{
    _postModelArray = [NSMutableArray array];
    for (int i = 0; i < [data count]; i++) {
        DiscoverModel *model = [[DiscoverModel alloc] init];
        
        NSDictionary *dict = data[i];
        
        model.postId = [NSString stringWithFormat:@"%@",dict[@"postId"]];
        model.type = CHOSEN_TYPE;
        model.accountId = [NSString stringWithFormat:@"%@",dict[@"accountId"]];
        model.isUp = [dict[@"upOrDown"] integerValue];
        
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
        
        NSString *friendName = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:model.accountId];
        if (friendName) {
            model.name = friendName;
        }
        else
        {
            model.name = dict[@"nickName"];
        }
        
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
        [_postModelArray addObject:model];
    }
}

//添加帖子数据
- (void)addNearByModel:(id)data
{
    _nearByModelArray = [NSMutableArray array];
    for (int i = 0; i < [data count]; i++) {
        DiscoverModel *model = [[DiscoverModel alloc] init];
        
        NSDictionary *dict = data[i];
        
        model.postId = [NSString stringWithFormat:@"%@",dict[@"postId"]];
        model.type = CHOSEN_TYPE;
        model.accountId = [NSString stringWithFormat:@"%@",dict[@"accountId"]];
        model.isUp = [dict[@"upOrDown"] integerValue];
        
        if (![dict[@"distance"] isKindOfClass:[NSNull class]] && dict[@"distance"] != nil) {
            model.distance = dict[@"distance"];
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
        
        NSString *friendName = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:model.accountId];
        if (friendName) {
            model.name = friendName;
        }
        else
        {
            model.name = dict[@"nickName"];
        }
        
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
        [_nearByModelArray addObject:model];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == self.tableView) {
        return 7;
    }
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView != self.tableView) {
        return 1;
    }
    
    switch (section) {
        case 0:
            if ([_friendModelArray count] && _isFree) {
                return [_friendModelArray count];
            }
            return 0;
            break;
        case 1:
            return 1;
        case 2:
            if ([_nearByModelArray count]) {
                return [_nearByModelArray count];
            }
            return 0;
            break;
        case 3:
            return 1;
            break;
        case 4:
            if ([_postModelArray count]) {
                return [_postModelArray count];
            }
            return 0;
            break;
        case 5:
            return 1;
            break;
        case 6:
            if ([_activityModelArray count]) {
                return [_activityModelArray count];
            }
            return 0;
            break;
        default:
            return 1;
            break;
    }
}

//设置Section的Header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (self.tableView != tableView) {
        return nil;
    }
    
    if (section%2) {
        return nil;
    }
    
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, [UIScreen mainScreen].bounds.size.width - 10, 25.0)];
    customView.backgroundColor = [UIColor whiteColor];
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = FREE_LIGHT_GRAY_COLOR;
    headerLabel.font = [UIFont systemFontOfSize:14];
    headerLabel.frame = CGRectMake(10.0, 2.0, [UIScreen mainScreen].bounds.size.width - 10, 18);
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 24, [UIScreen mainScreen].bounds.size.width - 10, 1)];
    line.backgroundColor = FREE_LIGHT_COLOR;
    [customView addSubview:line];
    switch (section) {
        case 0:
            headerLabel.text = @"有空好友";
            if (!_isFree) {
                UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
                label.backgroundColor = [UIColor clearColor];
                label.opaque = NO;
                label.textColor = FREE_LIGHT_GRAY_COLOR;
                label.font = [UIFont systemFontOfSize:13];
                label.frame = CGRectMake(75.0, 2.0, 150, 18.0);
                label.text = @"(有空状态下可查看)";
                [customView addSubview:label];
            }
            else
            {
                if(![_friendModelArray count])
                {
                    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
                    label.backgroundColor = [UIColor clearColor];
                    label.opaque = NO;
                    label.textColor = FREE_LIGHT_GRAY_COLOR;
                    label.font = [UIFont systemFontOfSize:13];
                    label.frame = CGRectMake(75.0, 2.0, 170, 18.0);
                    label.text = @"暂无有空好友,等一会吧:）";
                    [customView addSubview:label];
                }
            }
            break;
        case 2:
            headerLabel.text = @"附近推荐";
            if (![_nearByModelArray count]) {
                headerLabel.text = @"请开启定位，查看附近的精彩";
            }
            break;
        case 4:
            headerLabel.text = @"好友想去";
            if (![_postModelArray count]) {
                headerLabel.text = @"暂无好友想去,去玩什么看看吧!";
            }
            break;
        case 6:
            headerLabel.text = @"好友活动";
            if (![_activityModelArray count]) {
                headerLabel.text = @"暂无好友活动,唱K,桌游…组织一个?";
            }
            break;
        default:
            break;
    }
    
    [customView addSubview:headerLabel];
    
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == _menuTableview)
        return 0;
    
    if (section%2) {
        return 0;
    }
    
    return 24.f;
}

//设置Section的Header
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    
//    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 12.0)];
//    customView.backgroundColor = FREE_LIGHT_COLOR;
//    
//    return customView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if(tableView == _menuTableview)
//        return 0;
//    return 12.f;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section%2 && tableView != _menuTableview) {
        return 12.f;
    }
    
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView != self.tableView) {
        return [self menuCellAtIndexPath:indexPath];
    }
    
    
    switch (indexPath.section) {
        case 0:
            return [self friendCellAtIndexPath:indexPath];
            break;
        case 2:
            return [self nearByCellAtIndexPath:indexPath];
            break;
        case 4:
            return [self postCellAtIndexPath:indexPath];
            break;
        case 6:
            return [self activityCellAtIndexPath:indexPath];
        default:
            return [self grayCellAtIndexPath:indexPath];
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _menuTableview) {
        [self selectedMenu:tableView indexPath:indexPath];
        return;
    }
    
    switch (indexPath.section) {
        case 0:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            CoupleSuccCellModel *model = _friendModelArray[indexPath.row];
            
            BothNearByViewController *vc = [[BothNearByViewController alloc] initWithNibName:@"BothNearByViewController" bundle:nil];
            
            vc.accountId = model.friend_accountId;
            vc.friendName = model.friend_name;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            //创建会话
//            RCDChatViewController *chatViewController = [[RCDChatViewController alloc] init];
//            chatViewController.conversationType = ConversationType_PRIVATE;
//            chatViewController.targetId = model.friend_accountId;
//            chatViewController.title = model.friend_name;
//            chatViewController.hidesBottomBarWhenPushed = YES;
//            UINavigationController *navigationController = self.navigationController;
//            [navigationController popToRootViewControllerAnimated:NO];
//            [navigationController pushViewController:chatViewController animated:YES];
        }
            break;
        //附近推荐
        case 2:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            PostViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];
            viewController.model = _nearByModelArray[indexPath.row];
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        //好友想去
        case 4:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            PostViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];
            viewController.model = _postModelArray[indexPath.row];
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        //好友活动
        case 6:
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            ActivityInfoViewController *vc = [[ActivityInfoViewController alloc] initWithNibName:@"ActivityInfoViewController" bundle:nil];
            ActivityModel *model = _activityModelArray[indexPath.row];
            vc.activityId = model.activityId;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat sectionHeaderHeight = 26;//设置你footer高度
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
    
}

#pragma mark - configCell

//灰色cell
- (UITableViewCell *)grayCellAtIndexPath:(NSIndexPath *)indexPath
{
    GrayTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_gray forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[GrayTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_gray];
    }
    
    return cell;
}

//好友信息
- (UITableViewCell *)friendCellAtIndexPath:(NSIndexPath *)indexPath
{
    CoupleSuccTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_friend forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[CoupleSuccTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_friend];
    }
    cell.vc = self;
    cell.model = _friendModelArray[indexPath.row];
    return cell;
}

//活动信息
- (UITableViewCell *)activityCellAtIndexPath:(NSIndexPath *)indexPath
{
    ShuiyoukongActivityTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_activity forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[ShuiyoukongActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_activity];
    }
    cell.model = _activityModelArray[indexPath.row];
    return cell;
}

//帖子信息
- (UITableViewCell *)postCellAtIndexPath:(NSIndexPath *)indexPath
{
    FreePostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_post forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[FreePostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_post];
    }
    cell.model = _postModelArray[indexPath.row];
    return cell;
}

//附近推荐
- (UITableViewCell *)nearByCellAtIndexPath:(NSIndexPath *)indexPath
{
    NearByTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_nearby forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[NearByTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_nearby];
    }
    cell.model = _nearByModelArray[indexPath.row];
    return cell;
}

#pragma mark - 本地通知
//添加本地通知
- (void)addLocalNotice:(NSMutableArray *)array
{
    NSArray *myArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    
    for (int j = 0; j < [array count]; j++) {
        ActivityModel *model = array[j];
        if ([myArray count] == 0) {
            [self addNoticeToList:model];
        }
        else
        {
            for (int i = 0; i < [myArray count]; i++) {
                UILocalNotification    *myUILocalNotification=[myArray objectAtIndex:i];
                if (![[[myUILocalNotification userInfo] objectForKey:@"activityId"] isEqualToString:model.activityId]) {
                    // 初始化本地通知对象
                    [self addNoticeToList:model];
                    
                }
            }
        }
    }
}

//添加通知
- (void)addNoticeToList:(ActivityModel *)model
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        // 设置通知的提醒时间
        //                    NSDate *currentDate   = [NSDate date];
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        NSDate *date = [NSDate date];
        NSString *dateString1 = [NSString stringWithFormat:@"%@ %@", model.activityDate, model.activityTime];
        NSDate *date1 = [dateFormatter dateFromString:dateString1];
        NSTimeInterval time = [date1 timeIntervalSinceDate:date];
        
        notification.fireDate = [date dateByAddingTimeInterval:time - 30 * 60];
        
        // 设置重复间隔
        notification.repeatInterval = kCFCalendarUnitDay;
        
        // 设置提醒的文字内容
        if ([model.promoteAccount.accountId isEqualToString:[[FreeSingleton sharedInstance] getAccountId]]) {
            notification.alertBody = [NSString stringWithFormat:@"您的活动%@还有半个小时就要开始了喔",  model.title];
        }
        else
        {
            notification.alertBody = [NSString stringWithFormat:@"您的好友%@的活动%@还有半个小时就要开始了喔", model.promoteAccount.nickName, model.title];
        }
        notification.alertAction = NSLocalizedString(@"活动要开始了", nil);
        
        // 通知提示音 使用默认的
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        // 设置应用程序右上角的提醒个数
        notification.applicationIconBadgeNumber++;
        
        // 设定通知的userInfo，用来标识该通知
        NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
        aUserInfo[@"activityId"] = model.activityId;
        notification.userInfo = aUserInfo;
        
        // 将通知添加到系统中
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

#pragma mark - 分享时间

- (void)shareActivity
{
    if (!_blackBackView) {
        _blackBackView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _blackBackView.backgroundColor = [UIColor colorWithRed:(0/255.0)
                                                         green:(0/255.0)  blue:(0/255.0) alpha:.4];
        _blackBackView.userInteractionEnabled = YES;
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundColorDisapper:)];
        [_blackBackView addGestureRecognizer:tapGes];
    }
    
    if (![_blackBackView superview])
    {
        [[AppDelegate getMainWindow] addSubview:_blackBackView];
        
        SharePictureNoFriendsView* shareView =
        [[[NSBundle mainBundle] loadNibNamed:@"SharePictureNoFriendsView"
                                       owner:self
                                     options:nil] objectAtIndex:0];
        shareView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [shareView.btn_commit addTarget:self action:@selector(sharePic:) forControlEvents:UIControlEventTouchDown];
        
        [shareView.btn_cancel addTarget:self action:@selector(cancelShare:) forControlEvents:UIControlEventTouchDown];
        
        [shareView.text_input becomeFirstResponder];
        
        [_blackBackView addSubview:shareView];
        
        NSDictionary *metrics = @{
                                  @"height" : @(([UIScreen mainScreen].bounds.size.height - 175)/2 - 100),
                                  @"width" : @([UIScreen mainScreen].bounds.size.width)
                                  };
        NSDictionary *views = NSDictionaryOfVariableBindings(shareView);
        
        [_blackBackView addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:@"H:|-30-[shareView]-30-|"
          options:0
          metrics:metrics
          views:views]];
        [_blackBackView addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:
                                         @"V:|-height-[shareView(175)]"
                                         options:0
                                         metrics:metrics
                                         views:views]];
    }
}

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
    
    UIView *view = [sender superview];
    [view removeFromSuperview];
    [_blackBackView removeFromSuperview];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    SharePictureViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SharePictureViewController"];
    
    vc.content = shareView.text_input.text;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
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
    UIView *view = [sender superview];
    [view removeFromSuperview];
    [_blackBackView removeFromSuperview];
}


#pragma mark - prepareForeSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UITableViewController *vc = segue.destinationViewController;
    vc.hidesBottomBarWhenPushed = YES;
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
    NSString *activity_Id = dic[@"activity_Id"];
    NSInteger index = -1;
    for (int i = 0; i < [_activityModelArray count]; i++) {
        ActivityModel *model = _activityModelArray[i];
        if ([model.activityId isEqual:activity_Id]) {
            index = i;
            break;
        }
    }
    if (index < 0) {
        return;
    }
    
    switch (type) {
        case MY_HOST:
        {
            [_activityModelArray removeObjectAtIndex:index];
            NSIndexSet *indexSet=[[NSIndexSet alloc] initWithIndex:6];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        }
            break;
        case NOT_ATTEND:
        {
            ActivityModel *model = _activityModelArray[index];
            model.attendCount = count - 1;
            [_activityModelArray replaceObjectAtIndex:index withObject:model];//替换数据
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:6];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }
            break;
        default:
        {
            ActivityModel *model = _activityModelArray[index];
            model.attendCount = count + 1;
            [_activityModelArray replaceObjectAtIndex:index withObject:model];//替换数据
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:6];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }
            break;
    }
    
    [self.tableView reloadData];
}

#pragma mark -菜单栏目
-(void)functionIncident
{
    
    _isMenu = !(_isMenu);
    
    if (_isMenu)
    {
        self.tableView.scrollEnabled = NO;
        _menuTableview.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,self.tableView.contentOffset.y, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
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

-(void)switGesView:(UISwipeGestureRecognizer *)swipeges
{
    if (swipeges.direction == UISwipeGestureRecognizerDirectionUp)
    {
        if (_isMenu) {
            
            _isMenu = NO;
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
        if (_isMenu) {
            
            _isMenu = NO;
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
-(void)btnView
{
    if (_isMenu) {
        
        _isMenu = NO;
        self.tableView.scrollEnabled = YES;
        [UIView animateWithDuration:.2 animations:^{
            _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
        } completion:^(BOOL finished) {
            [_backView removeFromSuperview];
            [_menuTableview removeFromSuperview];
        }];
    }
}

- (UITableViewCell *)menuCellAtIndexPath:(NSIndexPath *)indexPath
{
    ShuiyoukongMenuTableViewCell *cell = [_menuTableview dequeueReusableCellWithIdentifier:_identifier_menu forIndexPath:indexPath];

    if (!cell)
    {
        cell = [[ShuiyoukongMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_menu];
    }
    switch (indexPath.section) {
        case 0:
        {
            cell.img.image = [UIImage imageNamed:@"icon_activity"];
            cell.label_title.text = @"发起活动";
        }
            break;

        default:
        {
            cell.img.image = [UIImage imageNamed:@"icon_share_time"];
            cell.label_title.text = @"分享时间";
        }
            break;
    }
    return cell;
}

- (void)selectedMenu:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            [_backView removeFromSuperview];
            [_menuTableview removeFromSuperview];
            self.tableView.scrollEnabled = YES;
            _isMenu = NO;
            
            CreateActivityViewController *vc = [[CreateActivityViewController alloc] initWithNibName:@"CreateActivityViewController" bundle:nil];
            vc.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;

        default:
        {
            self.tableView.scrollEnabled = YES;
            [_backView removeFromSuperview];
            [_menuTableview removeFromSuperview];
            self.tableView.scrollEnabled = YES;
            _isMenu = NO;
            [self shareActivity];
        }
            break;
    }
}

@end
