//
//  DiscoverViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "DiscoverViewController.h"
#import "FreeSingleton.h"
#import "DiscoverTableViewCell.h"
#import "SquareTableViewCell.h"
#import "SwitichLineView.h"
#import "VPImageCropperViewController.h"
#import "FreeImageScale.h"
#import "WritePostViewController.h"
#import "MJRefresh.h"
#import "PostViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BannerModel.h"
#import "FreeWebViewController.h"
#import "menuTableViewCell.h"
#import "AddTagsToPIcViewController.h"
#import "FreeSQLite.h"
#import "AppDelegate.h"
#import "GuideView2.h"

#define BANNER_NUM [_modelArray_banner count]

@interface DiscoverViewController ()<UIActionSheetDelegate,UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate,VPImageCropperDelegate>

@property (weak, nonatomic)NSString *identifier_chosen;

@property (weak, nonatomic)NSString *identifier_square;

@property (strong, nonatomic)NSMutableArray *modelArray_chosen;

@property (strong, nonatomic)NSMutableArray *modelArray_square;

@property (strong, nonatomic)NSMutableArray *modelArray_banner;

@property (strong, nonatomic)NSMutableArray *dataSource_square;

@property (nonatomic, strong)UITableView *tableview_chosen;

@property (nonatomic, strong)UITableView *tableview_square;

@property (nonatomic, strong)UIScrollView *mainScrollView;

@property (nonatomic, strong)SwitichLineView *switch_view;

@property (nonatomic, strong)UIScrollView *headerScrollView;

@property UIPageControl *pageControl;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong)UITableView *menuTableview;
@property (nonatomic, copy) NSString *identifier_menu;
@property (nonatomic, strong)UIView *backgroudView;
@property (nonatomic, strong)UIButton *left_btn;
@property BOOL isSuccees;//判断左上角table

@property (nonatomic, assign)NSInteger pageNum;

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initGuide];
    [self whenPushCome];
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCOUNTName:) name:ZC_NOTIFICATION_UPDATE_UPDATE_COUNT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDianZanNum:) name:ZC_NOTIFICATION_UPDATE_DIANZAN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPost:) name:FREE_NOTIFICATION_RELOAD_MYPOST object:nil];
    }
    return self;
}

//重置所有数据
- (void)reloadPost:(NSNotification *)notification
{
    __weak DiscoverViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] getPostInfoOnCompletion:@"1" pageSize:@"10" postStatus:CHOSEN_TYPE postId:nil upOrDown:@"up" city:_city block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
                _modelArray_chosen = [NSMutableArray array];
                [weakSelf addChosenModel:data[@"items"] orderTag:NO modelArray:_modelArray_chosen];
                [_tableview_chosen reloadData];
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:data];
        }
    }];
    
    [[FreeSingleton sharedInstance] getPostInfoOnCompletion:@"1" pageSize:@"10" postStatus:SQUARE_TYPE postId:@"0" upOrDown:@"up" city:_city block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
                _dataSource_square = [NSMutableArray arrayWithArray:data[@"items"]];
                [weakSelf addSquareModel:_dataSource_square];
                [_tableview_square reloadData];
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:data];
        }
    }];
}

- (void)updateDianZanNum:(NSNotification *)notification {
    DiscoverModel *model = notification.object;
    for (int i = 0; i < [_dataSource_square count]; i++) {
        NSString *str = [NSString stringWithFormat:@"%@", _dataSource_square[i][@"postId"]];
        if ([str isEqualToString:model.postId]) {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:_dataSource_square[i]];
            if (model.isUp) {
                dic[@"upOrDown"] = @"1";
            }
            else
            {
                dic[@"upOrDown"] = @"0";
            }
            dic[@"upCount"] = model.num;
            [_dataSource_square replaceObjectAtIndex:i withObject:dic];
            NSMutableArray *arrayObj = _modelArray_square[i/2];
            DiscoverModel *modelObj = arrayObj[i%2];
            modelObj.num = model.num;
            modelObj.isUp = model.isUp;
            [arrayObj replaceObjectAtIndex:i%2 withObject:modelObj];
            [_modelArray_square replaceObjectAtIndex:i/2 withObject:arrayObj];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i/2 inSection:1];
            [_tableview_square reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            
            return;
        }
    }
}

- (void)updateCOUNTName:(NSNotification *)notification {
    NSArray *array = notification.object;
    NSString *isChosen = array[0];
    NSString* postId = array[1];
    if ([isChosen isEqualToString:CHOSEN_TYPE]) {
        for (int i = 0; i < [_modelArray_chosen count]; i++) {
            DiscoverModel *modelObj = _modelArray_chosen[i];
            if ([modelObj.postId isEqualToString:postId]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [_tableview_chosen reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                return;
            }
        }
    }
    else
    {
        for (int i = 0; i < [_modelArray_square count]; i++) {
            NSMutableArray *arrayObj = _modelArray_square[i];
            for (int j = 0; j < [arrayObj count]; j++) {
                DiscoverModel *modelObj = arrayObj[j];
                if ([modelObj.postId isEqualToString:postId]) {
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:1];
                    [_tableview_square reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:_dataSource_square[i]];
                    dic[@"upOrDown"] = [NSString stringWithFormat:@"%d", modelObj.isUp];
                    dic[@"upCount"] = modelObj.num;
                    [_dataSource_square replaceObjectAtIndex:i withObject:dic];
                    return;
                }
            }
        }
    }
    
}

- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isNeedReload) {
        [_tableview_square headerBeginRefreshing];
        _isNeedReload = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_isSuccees) {
        _isSuccees = NO;
        [UIView animateWithDuration:.2 animations:^{
            _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
        } completion:^(BOOL finished) {
            [_backgroudView removeFromSuperview];
            [_menuTableview removeFromSuperview];
        }];
    }
}

#pragma mark - 收到推送跳转
- (void)whenPushCome
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.isComeFromPush == PUSH_FRIENDS)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                     bundle:nil];
        FreeWebViewController *vc = [sb instantiateViewControllerWithIdentifier:@"FreeWebViewController"];
        vc.url = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_BANNER_URL];
        vc.imgUrl = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_BANNER_IMGURL];
        vc.url_title = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_BANNER_TITLE];
        vc.content = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_BANNER_CONTENT];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_BANNER_URL];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_BANNER_IMGURL];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_BANNER_TITLE];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_BANNER_CONTENT];
        vc.fromTag = COME_FROM_PUSH;
        UINavigationController *nav = [[UINavigationController alloc]
                                       initWithRootViewController:vc];
        
        [self presentViewController:nav animated:NO completion:nil];
        appDelegate.isComeFromPush = 0;
    }
}

#pragma mark - 引导图
- (void)initGuide
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:KEY_IF_DISCOVER_NOT_NEED_GUIDED]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IF_DISCOVER_NOT_NEED_GUIDED];
        GuideView2 *view = [[[NSBundle mainBundle] loadNibNamed:@"GuideView2"
                                                          owner:self
                                                        options:nil] objectAtIndex:0];
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        backView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0  blue:0/255.0  alpha:.5];
        [view.btn_4 addTarget:self action:@selector(removeGuideView:) forControlEvents:UIControlEventTouchDown];
        [backView addSubview:view];
        [[AppDelegate getMainWindow] addSubview:backView];
    }
}

- (void)removeGuideView:(UIButton *)btn
{
    UIView *view = btn.superview;
    [view.superview removeFromSuperview];
    [view removeFromSuperview];
    [self writePost];
}

#pragma mark - init
- (void)initView
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn addTarget:self action:@selector(writePost) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"icon_camera"] forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = backItem;
    
    UIBarButtonItem *backIteme = [[UIBarButtonItem alloc]init];
    backIteme.title = @" ";
    self.navigationItem.backBarButtonItem = backIteme;
    
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    [self initScrollView];
    [self initSwitchLine];
    [self initMenuTable];
}

- (void)initSwitchLine
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    view.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = view;
    
    _switch_view =
    [[[NSBundle mainBundle] loadNibNamed:@"SwitichLineView"
                                   owner:self
                                 options:nil] objectAtIndex:0];
    _switch_view.frame = view.frame;
    [view addSubview:_switch_view];
    UITapGestureRecognizer *tapGestureRecognizer_left = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(right_2_left:)];
    
    [_switch_view.left_view addGestureRecognizer:tapGestureRecognizer_left];
    
    UITapGestureRecognizer *tapGestureRecognizer_right = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(left_2_right:)];
    
    [_switch_view.right_view addGestureRecognizer:tapGestureRecognizer_right];
    
    [_switch_view.label_left setTextColor:[UIColor whiteColor]];
    [_switch_view.label_right setTextColor:FREE_LIGHT_GRAY_COLOR];
}

- (void)initScrollView
{
    _mainScrollView = [[UIScrollView alloc] init];
    _mainScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    _mainScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 2, 0);
    _mainScrollView.delegate = self;
    _mainScrollView.pagingEnabled = YES;
    [_mainScrollView setShowsVerticalScrollIndicator:NO];
    [_mainScrollView setShowsHorizontalScrollIndicator:NO];
    _mainScrollView.backgroundColor = FREE_LIGHT_COLOR;
    [self.view addSubview:_mainScrollView];
    
    _tableview_chosen = [[UITableView alloc] init];
    _tableview_chosen.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 110);
    _tableview_chosen.delegate = self;
    _tableview_chosen.dataSource = self;
    [_mainScrollView addSubview:_tableview_chosen];
    _tableview_chosen.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview_chosen.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    //设置tableview滑动速度
    _tableview_chosen.decelerationRate = 0.5;
    _tableview_chosen.backgroundColor = FREE_LIGHT_COLOR;
    
    _tableview_square = [[UITableView alloc] init];
    _tableview_square.frame = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height - 110);
    _tableview_square.delegate = self;
    _tableview_square.dataSource = self;
    _tableview_square.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainScrollView addSubview:_tableview_square];
    _tableview_square.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    //设置tableview滑动速度
    _tableview_square.decelerationRate = 0.5;
    _tableview_square.backgroundColor = FREE_LIGHT_COLOR;
    _identifier_chosen = @"DiscoverTableViewCell";
    _identifier_square = @"SquareTableViewCell";
    [_tableview_chosen registerNib:[UINib nibWithNibName:_identifier_chosen bundle:nil] forCellReuseIdentifier:_identifier_chosen];
    [_tableview_square registerNib:[UINib nibWithNibName:_identifier_square bundle:nil] forCellReuseIdentifier:_identifier_square];
    
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
}

- (void)initMenuTable
{
    _left_btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    _left_btn.titleEdgeInsets = UIEdgeInsetsMake(0, -_left_btn.titleLabel.bounds.size.width-50, 0, 0);
    _left_btn.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
    [_left_btn addTarget:self action:@selector(functionIncident) forControlEvents:UIControlEventTouchUpInside];
    
    if([[[FreeSingleton sharedInstance] getCity] isEqualToString:@"北京"] || [[[FreeSingleton sharedInstance] getCity] isEqualToString:@"上海"] || [[[FreeSingleton sharedInstance] getCity] isEqualToString:@"广州"])
    {
        [_left_btn setTitle:[[FreeSingleton sharedInstance] getCity] forState:UIControlStateNormal];
    }
    else
    {
        [_left_btn setTitle:@"成都" forState:UIControlStateNormal];
    }
    
    [_left_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//设置title在一般情况下为白色字体
    _left_btn.titleLabel.font = [UIFont systemFontOfSize:15];//title字体大小
//    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];//设置title在button被选中情
    [_left_btn setImage:[UIImage imageNamed:@"icon_more_city"] forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:_left_btn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _backgroudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _backgroudView.backgroundColor = [UIColor clearColor];
    _menuTableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, 120, 245) style:UITableViewStylePlain];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_menuTableview.bounds];
    
    _menuTableview.layer.masksToBounds = NO;
    
    _menuTableview.layer.shadowColor = [UIColor blackColor].CGColor;
    
    _menuTableview.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    
    _menuTableview.layer.shadowOpacity = 0.5f;
    
    _menuTableview.layer.shadowPath = shadowPath.CGPath;
    
    _isSuccees = NO;
    
    [_menuTableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    _menuTableview.delegate = self;
    _menuTableview.dataSource = self;
    
    _menuTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    _menuTableview.scrollEnabled = NO;
    
    _identifier_menu = @"menuTableViewCell";
    [_menuTableview registerNib:[UINib nibWithNibName:_identifier_menu bundle:nil] forCellReuseIdentifier:_identifier_menu];
    
    if ([_menuTableview respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [_menuTableview setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([_menuTableview respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [_menuTableview setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)initHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width/2)];
    self.tableview_chosen.tableHeaderView = headerView;
    
    headerView.backgroundColor = [UIColor whiteColor];
    
    _headerScrollView = [[UIScrollView alloc] init];
    _headerScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _headerScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width/2);
    _headerScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3, 0);
    _headerScrollView.delegate = self;
    _headerScrollView.pagingEnabled = YES;
    
    _headerScrollView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _headerScrollView.layer.borderWidth = 0.5f;
//
    [_headerScrollView setShowsVerticalScrollIndicator:NO];
    [_headerScrollView setShowsHorizontalScrollIndicator:NO];
    [headerView addSubview:_headerScrollView];
//
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * i, 0, self.view.frame.size.width, self.view.frame.size.width/2)];
        imageView.tag = i;
        BannerModel *model = _modelArray_banner[i];
        NSString *imageStr = model.imgUrl;
        [self showBigImage:imageView url:imageStr];
        UITapGestureRecognizer* tapGes2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPostDetail:)];
        [imageView addGestureRecognizer:tapGes2];
        imageView.userInteractionEnabled = YES;
        [_headerScrollView addSubview:imageView];
    }
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 60, self.view.frame.size.width/2 - 30, self.view.frame.size.width, 40)];
    [_pageControl setCurrentPage:0];
    _pageControl.numberOfPages = BANNER_NUM;//指定页面个数
    [_pageControl setBackgroundColor:[UIColor clearColor]];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(changeBanner:) userInfo:nil repeats:YES];// 在longConnectToSocket方法中进行长连接需要向服务器发送的讯息
    
    [_timer fire];
    
    [headerView addSubview:_pageControl];
}

- (void)initData
{
    _pageNum = 0;
    _modelArray_chosen = [NSMutableArray array];
    [self setupRefresh];
    
    _modelArray_banner = [NSMutableArray array];
    __weak DiscoverViewController *weakSelf = self;
    
    [[FreeSingleton sharedInstance] getBannerOnCompletion:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            if (![data isKindOfClass:[NSNull class]] && [data count]) {
                [weakSelf addBannerModel:data];
                [weakSelf initHeaderView];
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:data];
        }
    }];
}

- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [_tableview_chosen addHeaderWithTarget:self action:@selector(headerRereshing_chosen)];
    //自动刷新(一进入程序就下拉刷新)
    [_tableview_chosen headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_tableview_chosen addFooterWithTarget:self action:@selector(footerRereshing_chose)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _tableview_chosen.headerPullToRefreshText = @"下拉可以刷新了";
    _tableview_chosen.headerReleaseToRefreshText = @"松开马上刷新了";
    _tableview_chosen.headerRefreshingText = @"正在刷新中";
    
    _tableview_chosen.footerPullToRefreshText = @"上拉可以加载更多数据了";
    _tableview_chosen.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    _tableview_chosen.footerRefreshingText = @"正在加载中";
    
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [_tableview_square addHeaderWithTarget:self action:@selector(headerRereshing_square)];
    //自动刷新(一进入程序就下拉刷新)
    [_tableview_square headerBeginRefreshing];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_tableview_square addFooterWithTarget:self action:@selector(footerRereshing_square)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    _tableview_square.headerPullToRefreshText = @"下拉可以刷新了";
    _tableview_square.headerReleaseToRefreshText = @"松开马上刷新了";
    _tableview_square.headerRefreshingText = @"正在刷新中";
    
    _tableview_square.footerPullToRefreshText = @"上拉可以加载更多数据了";
    _tableview_square.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    _tableview_square.footerRefreshingText = @"正在加载中";
}

//添加bannerModel
- (void)addBannerModel:(id)data
{
    for (int i = 0; i < [data count]; i++) {
        BannerModel *model = [[BannerModel alloc] init];
        NSDictionary *dic = data[i];
        model.bannerId = [NSString stringWithFormat:@"%@", dic[@"bannerId"]];
        model.title = dic[@"title"];
        model.imgUrl = dic[@"imgUrl"];
        model.url = dic[@"url"];
        if (![dic[@"content"] isKindOfClass:[NSNull class]]) {
            model.content = dic[@"content"];
        }
        [_modelArray_banner addObject:model];
    }
}


//添加精选model
- (void)addChosenModel:(id)data orderTag:(BOOL)orderTag modelArray:(NSMutableArray *)modelArray
{
    for (int i = 0; i < [data count]; i++) {
        DiscoverModel *model = [[DiscoverModel alloc] init];
        
        NSDictionary *dict;
        if (orderTag)
        {
            dict = data[[data count] - 1 - i];
        }
        else
        {
            dict = data[i];
        }
        
        model.postId = [NSString stringWithFormat:@"%@",dict[@"postId"]];
        model.type = CHOSEN_TYPE;
        model.accountId = [NSString stringWithFormat:@"%@",dict[@"accountId"]];
        model.isUp = [dict[@"upOrDown"] integerValue];
        
        if ([dict[@"recommendTime"] isKindOfClass:[NSNull class]]) {
            model.recommendTime = nil;
        }
        else
        {
//            NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[NSString stringWithFormat:@"%@",dict[@"recommendTime"]] doubleValue]/1000.0];
//            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
//            [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS"];
//            NSString *date_str = [dateformatter stringFromDate:date];
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
            if ([arrayPosition count] > 1)
            {
                model.latitude = [arrayPosition[0] floatValue];
                model.longitude = [arrayPosition[1] floatValue];
            }
        }
        
        [self addImgTags2Model:dict model:model];
        
        //新数据
        if (orderTag) {
            [modelArray insertObject:model atIndex:0];
        }
        else
        {
            [modelArray addObject:model];//老数据
        }
    }
}

- (void)addSquareModel:(id)data
{
    _modelArray_square = [NSMutableArray array];
    
    int num = [data count]%2;
    
    for (int i = 0; i < [data count] - num; i = i + 2) {
        NSMutableArray *array = [NSMutableArray array];
        for (int j = 0; j < 2; j++) {
            DiscoverModel *model = [[DiscoverModel alloc] init];
            NSDictionary *dict = data[i + j];
            model.type = SQUARE_TYPE;
            model.postId = [NSString stringWithFormat:@"%@",dict[@"postId"]];
            model.accountId = [NSString stringWithFormat:@"%@",dict[@"accountId"]];
            NSArray *arrayUrl = [dict[@"url"] componentsSeparatedByString:@"#%#"];
            model.big_Img = arrayUrl[0];
            for (int k = 0; k < [arrayUrl count]; k++)
            {
                if ([arrayUrl[k] isKindOfClass:[NSNull class]] || [arrayUrl[k] length] == 0) {
                    continue;
                }
                
                [model.img_array addObject:arrayUrl[k]];
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
            
            model.isUp = [dict[@"upOrDown"] integerValue];
            model.num = [NSString stringWithFormat:@"%@",dict[@"upCount"]];
            model.reCount = [NSString stringWithFormat:@"%@",dict[@"reCount"]];
            
            if (![dict[@"position"] isKindOfClass:[NSNull class]] && [dict[@"position"] length])
            {
                NSArray *arrayPosition = [dict[@"position"] componentsSeparatedByString:@"-"];
                
                if ([arrayPosition count] > 1) {
                    model.latitude = [arrayPosition[0] floatValue];
                    model.longitude = [arrayPosition[1] floatValue];
                }
            }
            [self addImgTags2Model:dict model:model];
            
            [array addObject:model];
        }
        [_modelArray_square addObject:array];
    }
    
    if (num) {
        NSMutableArray *array = [NSMutableArray array];
        NSDictionary *dic = data[[data count] - 1];
        DiscoverModel *model = [[DiscoverModel alloc] init];
        model.type = SQUARE_TYPE;
        model.postId = [NSString stringWithFormat:@"%@",dic[@"postId"]];
        model.accountId = [NSString stringWithFormat:@"%@",dic[@"accountId"]];
        NSArray *arrayUrl = [dic[@"url"] componentsSeparatedByString:@"#%#"];
        model.big_Img = arrayUrl[0];
        for (int k = 0; k < [arrayUrl count]; k++)
        {
            if ([arrayUrl[k] isKindOfClass:[NSNull class]] || [arrayUrl[k] length] == 0) {
                continue;
            }
            
            [model.img_array addObject:arrayUrl[k]];
        }
        model.head_Img = dic[@"headImg"];
        NSString *friendName = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:model.accountId];
        if (friendName) {
            model.name = friendName;
        }
        else
        {
            model.name = dic[@"nickName"];
        }
        
        if (![dic[@"title"] isKindOfClass:[NSNull class]] && [dic[@"title"] length]) {
            model.title = dic[@"title"];
        }
        else
        {
            model.title = @"";
        }
        if (![dic[@"address"] isKindOfClass:[NSNull class]] && [dic[@"address"] length]) {
            model.address = dic[@"address"];
        }
        else
        {
            model.title = @"";
        }
        model.content = dic[@"content"];

        if (![dic[@"tag"] isKindOfClass:[NSNull class]] && [dic[@"tag"] length]) {
            NSArray *arrayTags = [dic[@"tag"] componentsSeparatedByString:@"#%#"];
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
        model.num = [NSString stringWithFormat:@"%@",dic[@"upCount"]];
        model.reCount = [NSString stringWithFormat:@"%@",dic[@"reCount"]];
        model.isUp = [dic[@"upOrDown"] integerValue];
        
        if (![dic[@"position"] isKindOfClass:[NSNull class]] && [dic[@"position"] length])
        {
            NSArray *arrayPosition = [dic[@"position"] componentsSeparatedByString:@"-"];
            model.latitude = [arrayPosition[0] floatValue];
            model.longitude = [arrayPosition[1] floatValue];
        }
        [self addImgTags2Model:dic model:model];
        
        [array addObject:model];
        [_modelArray_square addObject:array];
    }
}

- (void)addImgTags2Model:(id)dict model:(DiscoverModel *)model
{
    if (![dict[@"postImg"] isKindOfClass:[NSNull class]] && [dict[@"postImg"] length]) {
        NSError *jsonError;
        id data = [NSJSONSerialization JSONObjectWithData:[dict[@"postImg"] dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:NSJSONReadingMutableContainers
                                                    error:&jsonError];
        
        if (jsonError) {
            NSLog(@"%@",jsonError);
        }
        
        for (int j = 0; j < [data count]; j++) {
            
            id tmpdata;
            if ([data[j] isKindOfClass:[NSString class]]) {
                
                NSArray* array = [[FreeSingleton sharedInstance] strToJson:data[j]];
                tmpdata = array;
            }
            else
            {
                tmpdata = data[j];
            }
            
            if ([tmpdata count]) {
                PicTagsModel *picModel = [[PicTagsModel alloc] init];
                picModel.imgUrl = tmpdata[@"imgUrl"];
                for (int i = 0; i < [tmpdata[@"imgTagList"] count]; i++) {
                    addTagsModel *tagsModel = [[addTagsModel alloc] init];
                    NSDictionary *dic = tmpdata[@"imgTagList"][i];
                    if (![dic[@"name"] isKindOfClass:[NSNull class]] && [dic[@"name"] length]) {
                        tagsModel.fristLabel = dic[@"name"];
                    }
                    if (![dic[@"address"] isKindOfClass:[NSNull class]]  && [dic[@"address"] length]) {
                        tagsModel.secondLabel = dic[@"address"];
                    }
                    if (![dic[@"price"] isKindOfClass:[NSNull class]] && [dic[@"price"] length]) {
                        tagsModel.thirdLabel = dic[@"price"];
                    }
                    if (![dic[@"item"] isKindOfClass:[NSNull class]] && [dic[@"item"] length]) {
                        tagsModel.forthLabel = dic[@"item"];
                    }
                    if (![dic[@"x"] isKindOfClass:[NSNull class]] && ![dic[@"y"] isKindOfClass:[NSNull class]] && dic[@"x"] && dic[@"y"]) {
                        tagsModel.point = CGPointMake([dic[@"x"] floatValue] * ([UIScreen mainScreen].bounds.size.width - 20), [dic[@"y"] floatValue] * ([UIScreen mainScreen].bounds.size.width - 20));
                    }
                    
                    [picModel.imgTagList addObject:tagsModel];
                }
                
                [model.imgTagsArray addObject:picModel];
            }
        }
    }
}

#pragma mark - 获取数据
- (void)headerRereshing_chosen
{
    __weak DiscoverViewController *weakSelf = self;
    
    NSString *postIdStr = nil;
    if ([_modelArray_chosen count]) {
        DiscoverModel *model = [_modelArray_chosen firstObject];
        postIdStr = model.recommendTime;
    }
    BOOL tag = YES;
    if (postIdStr == nil) {
        tag = NO;
    }
    
    if (_isCityChange)
    {
        postIdStr = nil;
    }
    
    [[FreeSingleton sharedInstance] getPostInfoOnCompletion:@"1" pageSize:@"10" postStatus:CHOSEN_TYPE postId:postIdStr upOrDown:@"up" city:_city block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
                if (_isCityChange) {
                    _modelArray_chosen = [NSMutableArray array];
                    [weakSelf addChosenModel:data[@"items"] orderTag:NO modelArray:_modelArray_chosen];
                    _isCityChange--;
                    [_tableview_chosen reloadData];
                }
                else
                {
                    if ([data[@"items"] count] >= 10) {
                        [_modelArray_chosen removeAllObjects];
                    }
                    [weakSelf addChosenModel:data[@"items"] orderTag:tag modelArray:_modelArray_chosen];
                    [_tableview_chosen reloadData];
                }
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"网络异常"];
        }
        [_tableview_chosen headerEndRefreshing];
    }];
}

- (void)footerRereshing_chose
{
    __weak DiscoverViewController *weakSelf = self;
    
    NSString *postIdStr = nil;
    if ([_modelArray_chosen count]) {
        DiscoverModel *model = [_modelArray_chosen lastObject];
        postIdStr = model.recommendTime;
    }
    
    [[FreeSingleton sharedInstance] getPostInfoOnCompletion:@"1" pageSize:@"10" postStatus:CHOSEN_TYPE postId:postIdStr upOrDown:@"down" city:_city block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
                
                [weakSelf addChosenModel:data[@"items"] orderTag:NO modelArray:_modelArray_chosen];
                [_tableview_chosen reloadData];
            }
            else
            {
                [KVNProgress showErrorWithStatus:@"没有更多了"];
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"网络异常"];
        }
        [_tableview_chosen footerEndRefreshing];
    }];
}

- (void)headerRereshing_square
{
    __weak DiscoverViewController *weakSelf = self;
    
    NSString *postIdStr = @"0";
    if ([_modelArray_square count]) {
        NSArray *modelArray = _modelArray_square[0];
        DiscoverModel *model = modelArray[0];
        postIdStr = model.postId;
    }
    
    if (_isCityChange)
    {
        postIdStr = @"0";
    }
    
    [[FreeSingleton sharedInstance] getPostInfoOnCompletion:@"1" pageSize:@"10" postStatus:SQUARE_TYPE postId:postIdStr upOrDown:@"up" city:_city block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
            
                if (_isCityChange) {
                    _dataSource_square = [NSMutableArray arrayWithArray:data[@"items"]];
                    _isCityChange--;
                }
                else
                {
                    if ([data[@"items"] count] >= 10) {
                        _dataSource_square = [NSMutableArray arrayWithArray:data[@"items"]];
                    }
                    else
                    {
                        NSArray *dataArray = [data[@"items"] arrayByAddingObjectsFromArray:_dataSource_square];
                        _dataSource_square = [NSMutableArray arrayWithArray:dataArray];
                        if ([_dataSource_square count]%2 && [_dataSource_square count] >= 10) {
                            [_dataSource_square removeLastObject];
                        }
                    }
                }
                
                [weakSelf addSquareModel:_dataSource_square];
                [_tableview_square reloadData];
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"网络异常"];
        }
        [_tableview_square headerEndRefreshing];
    }];
}

- (void)footerRereshing_square
{
    __weak DiscoverViewController *weakSelf = self;
    NSArray *array = [_modelArray_square lastObject];
    DiscoverModel *model = [array lastObject];
    
    [[FreeSingleton sharedInstance] getPostInfoOnCompletion:@"1" pageSize:@"10" postStatus:SQUARE_TYPE postId:model.postId upOrDown:@"down" city:_city block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
                NSArray *dataArray = [_dataSource_square arrayByAddingObjectsFromArray:data[@"items"]];
                _dataSource_square = [NSMutableArray arrayWithArray:dataArray];
                [weakSelf addSquareModel:_dataSource_square];
                [_tableview_square reloadData];
            }
            else
            {
                [KVNProgress showErrorWithStatus:@"没有更多了"];
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"网络异常"];
        }
        [_tableview_square footerEndRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (tableView == _tableview_chosen) {
        return 1;
    }
    if (tableView == _menuTableview)
    {
        return 5;
    }
    
    return 2;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _tableview_square && section == 0) {
        return 8.f;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 8)];
    view.backgroundColor = FREE_LIGHT_COLOR;
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if (tableView == _tableview_chosen) {
        if(_modelArray_chosen)
            return [_modelArray_chosen count];
        return 0;
    }
    else if(tableView == _tableview_square)
    {
        if (section == 0) {
            return 0;
        }
        
        if (_modelArray_square) {
            return [_modelArray_square count];
        }
        return 0;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _menuTableview) {
        return [self menuCellAtIndexPath:indexPath];
    }
    else if (tableView == _tableview_chosen) {
        return [self discoverCellAtIndexPath:indexPath];
    }
    else
    {
        return [self squareCellAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView == _tableview_chosen) {
        return 132.f + [UIScreen mainScreen].bounds.size.width + 1 - 20;
    }
    else if(tableView == _tableview_square)
    {
        return [UIScreen mainScreen].bounds.size.width/2 + 66 - 12 + 6;
    }
    else
    {
        return 49;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _menuTableview) {
        switch (indexPath.section) {
            case 0:
                if (!_city) {
                    _city = @"成都市";
                }
                [self selectMenuCity:@"成都"];
                break;
            case 1:
                [self selectMenuCity:@"北京"];
                break;
            case 2:
                [self selectMenuCity:@"上海"];
                break;
            case 3:
                [self selectMenuCity:@"广州"];
                break;
            default:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"目前版本只开放了成都北京上海广州，更多城市会陆续开放" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                [alert show];
                [_backgroudView removeFromSuperview];
                [_menuTableview removeFromSuperview];
                _isSuccees = NO;
            }
                break;
        }
    }
    else
    {
        if (tableView == _tableview_chosen) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            PostViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];
            viewController.model = _modelArray_chosen[indexPath.row];
            viewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

#pragma mark - 菜单处理函数
- (void)selectMenuCity:(NSString *)city
{
    [_backgroudView removeFromSuperview];
    [_menuTableview removeFromSuperview];
    _isSuccees = NO;
    
    NSString *cityName = [NSString stringWithFormat:@"%@市", city];
    
    if(![_city isEqualToString:cityName])
    {
        _isCityChange = 2;//因为要刷新两个表，所以设为2
        [_left_btn setTitle:city forState:UIControlStateNormal];
        _city = cityName;
        [_tableview_chosen headerBeginRefreshing];
        [_tableview_square headerBeginRefreshing];
    }
}

#pragma mark - 切换相关操作
- (UITableViewCell *)menuCellAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            menuTableViewCell *cell = [_menuTableview dequeueReusableCellWithIdentifier:_identifier_menu forIndexPath:indexPath];
            
            if (!cell)
            {

                cell = [[menuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_menu];
            }
            cell.menuName.font = [UIFont systemFontOfSize:15.f];
            cell.menuName.text = @"成都";
            return cell;
        }
            break;
        case 1:
        {
            menuTableViewCell *cell = [_menuTableview dequeueReusableCellWithIdentifier:_identifier_menu forIndexPath:indexPath];
            
            if (!cell)
            {
                
                cell = [[menuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_menu];
            }
            cell.menuName.font = [UIFont systemFontOfSize:15.f];
            cell.menuName.text = @"北京";
            return cell;
        }
            break;
        case 2:
        {
            menuTableViewCell *cell = [_menuTableview dequeueReusableCellWithIdentifier:_identifier_menu forIndexPath:indexPath];
            
            if (!cell)
            {
                
                cell = [[menuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_menu];
            }
            cell.menuName.font = [UIFont systemFontOfSize:15.f];
            cell.menuName.text = @"上海";
            return cell;
        }
            break;
        case 3:
        {
            menuTableViewCell *cell = [_menuTableview dequeueReusableCellWithIdentifier:_identifier_menu forIndexPath:indexPath];
            
            if (!cell)
            {
                
                cell = [[menuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_menu];
            }
            cell.menuName.font = [UIFont systemFontOfSize:15.f];
            cell.menuName.text = @"广州";
            return cell;
        }
            break;
            
        default:
        {
            menuTableViewCell *cell = [_menuTableview dequeueReusableCellWithIdentifier:_identifier_menu forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, _menuTableview.bounds.size.width);
            if (!cell)
            {
                cell = [[menuTableViewCell alloc] init];
            }
            cell.menuName.font = [UIFont systemFontOfSize:14.f];
            cell.menuName.text = @"更多城市敬请期待";
            return cell;
        }
            break;
    }
}

//初始化精选cell
- (UITableViewCell *)discoverCellAtIndexPath:(NSIndexPath *)indexPath
{
    DiscoverTableViewCell *cell = [_tableview_chosen dequeueReusableCellWithIdentifier:_identifier_chosen forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DiscoverTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_chosen];
    }
    cell.model = _modelArray_chosen[indexPath.row];
    return cell;
}
//初始化广场cell
- (UITableViewCell *)squareCellAtIndexPath:(NSIndexPath *)indexPath
{
    SquareTableViewCell *cell = [_tableview_square dequeueReusableCellWithIdentifier:_identifier_square forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[SquareTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_square];
    }
    cell.discover_vc = self;
    cell.modelArray = _modelArray_square[indexPath.row];
    return cell;
}

- (void)left_2_right:(UITapGestureRecognizer *)tap
{
    
    [UIView animateWithDuration:0.4f animations:^{
        _switch_view.left_constrain.constant = 70.0f;
        [_switch_view.bottom_view setNeedsUpdateConstraints];
        [_switch_view.bottom_view layoutIfNeeded];
        [_mainScrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0)];
    } completion:^(BOOL finished) {
        [_switch_view.label_right setTextColor:[UIColor whiteColor]];
        [_switch_view.label_left setTextColor:FREE_LIGHT_GRAY_COLOR];
    }];
}

- (void)right_2_left:(UITapGestureRecognizer *)tap
{
//    [UIView animateWithDuration:0.4f animations:^{
//        _switch_view.left_constrain.constant = 10.0f;
//        [_switch_view.bottom_view setNeedsUpdateConstraints];
//        [_switch_view.bottom_view layoutIfNeeded];
//        [_mainScrollView setContentOffset:CGPointMake(0, 0)];
//    }];
    
    
    [UIView animateWithDuration:0.4f animations:^{
        _switch_view.left_constrain.constant = 10.0f;
        [_switch_view.bottom_view setNeedsUpdateConstraints];
        [_switch_view.bottom_view layoutIfNeeded];
        [_mainScrollView setContentOffset:CGPointMake(0, 0)];
    } completion:^(BOOL finished) {
        [_switch_view.label_left setTextColor:[UIColor whiteColor]];
        [_switch_view.label_right setTextColor:FREE_LIGHT_GRAY_COLOR];
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView == _mainScrollView) {
        float percent = (_mainScrollView.contentOffset.x + self.view.frame.size.width/2.0) / self.view.frame.size.width - 0.5;
        
        //    [UIView animateWithDuration:0.2f animations:^{
        if (percent > 0 && percent <= 1) {
            _switch_view.left_constrain.constant = 10.0f + 60.f * percent;
        }
        
        if (percent == 0) {
            [_switch_view.label_left setTextColor:[UIColor whiteColor]];
            [_switch_view.label_right setTextColor:FREE_LIGHT_GRAY_COLOR];
        }
        else if (percent == 1)
        {
            [_switch_view.label_right setTextColor:[UIColor whiteColor]];
            [_switch_view.label_left setTextColor:FREE_LIGHT_GRAY_COLOR];
        }
    }
//    else if (scrollView == _headerScrollView)
//    {
//        int page = (_headerScrollView.contentOffset.x + self.view.frame.size.width/2.0) / self.view.frame.size.width;
//        
//        _pageControl.currentPage = page;
//    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView != _headerScrollView) {
        return;
    }
    
    if (scrollView.contentOffset.x >= self.view.frame.size.width) {
        
        _pageNum = (_pageNum + 1)%BANNER_NUM;
        [self resetScrollView];
        [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:NO];
        
    }
    else if (scrollView.contentOffset.x < self.view.frame.size.width)
    {
        _pageNum = (_pageNum + BANNER_NUM - 1)%BANNER_NUM;
        [self resetScrollView];
        [scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:NO];
    }
    
    _pageControl.currentPage = _pageNum;
}

- (void)resetScrollView
{
    NSArray *imgArray = _headerScrollView.subviews;
    UIImageView *imageView1 = imgArray[0];
    UIImageView *imageView2 = imgArray[1];
    UIImageView *imageView3 = imgArray[2];
    
    BannerModel *model1 = _modelArray_banner[(_pageNum + BANNER_NUM - 1)%BANNER_NUM];
    BannerModel *model2 = _modelArray_banner[_pageNum];
    BannerModel *model3 = _modelArray_banner[(_pageNum + 1)%BANNER_NUM];
    
    [self showBigImage:imageView1 url:model1.imgUrl];
    [self showBigImage:imageView2 url:model2.imgUrl];
    [self showBigImage:imageView3 url:model3.imgUrl];
}

//自动切换banner
- (void)changeBanner:(NSTimer *)timer
{
    _pageNum = (_pageNum + 1)%BANNER_NUM;
    [self resetScrollView];
    [_headerScrollView setContentOffset:CGPointMake(0, 0)];
    [UIView animateWithDuration:0.4f animations:^{
        [_headerScrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0)];
        _pageControl.currentPage = _pageNum;
    }];
}

#pragma mark - 相关功能
- (void)writePost
{    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

- (void)showBigImage:(UIImageView *)imgView url:(NSString *)url
{
    //set tag
    [imgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"tupian"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

#pragma mark -菜单栏目
-(void)functionIncident
{
    
    _isSuccees = !(_isSuccees);
    
    if (_isSuccees)
    {
        _menuTableview.frame = CGRectMake(0, 0, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
    }
    else
    {
        [UIView animateWithDuration:.2 animations:^{
            _menuTableview.frame = CGRectMake(0,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
        } completion:^(BOOL finished) {
            [_backgroudView removeFromSuperview];
            [_menuTableview removeFromSuperview];
        }];
        
        return;
    }
    
    [self.view addSubview:_backgroudView];
    
    [_backgroudView addSubview:_menuTableview];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    _isSuccees = NO;
    [UIView animateWithDuration:.2 animations:^{
        _menuTableview.frame=CGRectMake(0,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
    } completion:^(BOOL finished) {
        [_backgroudView removeFromSuperview];
        [_menuTableview removeFromSuperview];
    }];
    
}


-(void)gotoPostDetail:(UITapGestureRecognizer *)tap
{
    UIImageView *imageView = (UIImageView *)tap.view;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    FreeWebViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"FreeWebViewController"];
    BannerModel *model = _modelArray_banner[_pageNum];
    viewController.url = model.url;
    viewController.url_title = model.title;
    viewController.content = model.content;
    viewController.img = imageView.image;
    viewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //设置tabbar消失时不能删除通知
    //    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZC_NOTIFICATION_NEED_DELETE_NOTIFICATION];
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [FreeImageScale imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    //    UIImage *scaleImage = [self scaleImage:editedImage toScale:0.5];
    [cropperViewController dismissViewControllerAnimated:NO completion:^{
//        WritePostViewController *vc =
//        [[WritePostViewController alloc] initWithNibName:@"WritePostViewController" bundle:nil];
//        vc.cover_url = editedImage;
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
        AddTagsToPIcViewController *vc = [[AddTagsToPIcViewController alloc] initWithNibName:@"AddTagsToPIcViewController" bundle:nil];
        vc.img = editedImage;
        vc.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // bug fixes: UIIMagePickerController使用中偷换StatusBar颜色的问题
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}

#pragma mark camera utility

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}
@end
