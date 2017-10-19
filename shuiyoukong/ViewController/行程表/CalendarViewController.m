//
//  CalendarViewController.m
//  Free
//
//  Created by 勇拓 李 on 15/4/30.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "CalendarViewController.h"
#import "CalendarCollectionViewCell.h"
#import "CoupleSuccView.h"
#import "FreeSingleton.h"
#import "FreeSQLite.h"
#import "CoupleSuccTableViewController.h"
#import "BottomCalendarView.h"
#import "SubBottonCalendarView.h"
#import "AppDelegate.h"
#import "PhoneGameTableViewController.h"//测试用
#import "AppDelegate.h"
#import "ActiveDetailViewController.h"

#define ONE_DAY 24*60*60

#define PAGE_NUM 3

#define SUB_TAG 123

#define FIRST_LABEL_WITDH 40

@interface CalendarViewController () <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *weekDays;
@property (weak, nonatomic) IBOutlet UICollectionView *collection_view;
@property UIPageControl *pageControl;
@property (nonatomic, strong)UIScrollView *bottomView;
@property (nonatomic, strong)UILabel *label_month;
//@property (nonatomic, strong)UIButton *btn_send;
@property (nonatomic, weak) NSString* identifier;

@property (nonatomic, strong)NSMutableArray *modelArray;
@property (nonatomic, strong)NSMutableArray *dataSource;
//判断是否有新好友
//@property (nonatomic, strong)NSMutableArray *FriendsArray;

@property (assign, nonatomic)NSInteger nowDay;
@property (strong, nonatomic)NSString *nowDate;

@property (assign, nonatomic)BOOL hasNew;
@property (nonatomic, strong)UIView *backgroundView;

@property (nonatomic, strong)UITableView *menuTableview;
@property (nonatomic, copy) NSString *inderfiter;
@property (nonatomic, strong)UIView *backgroudView;
@property BOOL isSuccees;

@property (nonatomic, weak)NSString *global_freeDate;
@property (nonatomic, weak)NSString *global_freeStartTime;
@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self whenPushCome];
    [self initData];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;

    [super viewWillAppear:animated];
}


- (void)whenPushCome
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.isComeFromPush == PUSH_ACITITY) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                     bundle:nil];
        ActiveDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ActiveDetailViewController"];
        vc.activityId = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_ACTIVITY_ID];
        vc.fromTag = COME_FROM_PUSH;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_ACTIVITY_ID];
        UINavigationController *nav = [[UINavigationController alloc]
                                       initWithRootViewController:vc];
        
        [self presentViewController:nav animated:NO completion:nil];
        appDelegate.isComeFromPush = 0;
    }
    else if (appDelegate.isComeFromPush == PUSH_FRIENDS)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                     bundle:nil];
        CoupleSuccTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CoupleSuccTableViewController"];
        vc.freeDate = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_FREE_DATE_PUSH];
        vc.freeStartTime = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_FREE_START_TIME_PUSH];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_FREE_DATE_PUSH];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_FREE_START_TIME_PUSH];
        vc.fromTag = COME_FROM_PUSH;
        UINavigationController *nav = [[UINavigationController alloc]
                                       initWithRootViewController:vc];
        
        [self presentViewController:nav animated:NO completion:nil];
        appDelegate.isComeFromPush = 0;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self registerNotificationForCouple];
        [self registerNotificationGotoCoupleSucc];
        [self registerNotificationChooseDate];
        [self registerNotificationStateChange];
        [self registerNotificationPushChange];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalendar:)
//                                                     name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initView
{
    _backgroudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _backgroudView.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.title = @"谁有空";
    
    UIColor *color = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202.0/255.0 alpha:1];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dic;
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    //初始化右边上角
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"发起活动" style:UIBarButtonItemStylePlain target:self action:@selector(createActivity) ];
    [self adjustFontForIPhone:rightItem];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _collection_view.delegate = self;
    _collection_view.dataSource = self;
    _identifier = @"CalendarCollectionViewCell";
    [_collection_view registerNib:[UINib nibWithNibName:@"CalendarCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:_identifier];
    _collection_view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self initBottomView];
    
    NSDictionary *metrics = @{
                              @"height" : @(80),
                              @"width" : @(40)
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(_collection_view, _bottomView);
    [self.view addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-0-[_bottomView]-0-|"
      options:0
      metrics:metrics
      views:views]];
    [self.view addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|-0-[_collection_view]-0-[_bottomView]-0-|"
                          options:0
                          metrics:metrics
                          views:views]];
    
    [self loadScrollView];
    
}
- (void)adjustFontForIPhone:(UIBarButtonItem *)btnitem
{
    if (SCREEN_HEIGHT == 480)
    {
        [btnitem setTitleTextAttributes:[NSDictionary
                                         dictionaryWithObjectsAndKeys:[UIFont
                                                                       boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
    }
    else if(SCREEN_HEIGHT == 568)
    {
        [btnitem setTitleTextAttributes:[NSDictionary
                                         dictionaryWithObjectsAndKeys:[UIFont
                                                                       boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
    }
    else if(SCREEN_HEIGHT == 667)
    {
        [btnitem setTitleTextAttributes:[NSDictionary
                                         dictionaryWithObjectsAndKeys:[UIFont
                                                                       boldSystemFontOfSize:17], NSFontAttributeName,nil] forState:UIControlStateNormal];
    }
    else if(SCREEN_HEIGHT == 736)
    {
        [btnitem setTitleTextAttributes:[NSDictionary
                                         dictionaryWithObjectsAndKeys:[UIFont
                                                                       boldSystemFontOfSize:18], NSFontAttributeName,nil] forState:UIControlStateNormal];
    }
}
- (void)initBottomView
{
    _bottomView = [[UIScrollView alloc] init];
    _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomView.contentSize = CGSizeMake(self.view.frame.size.width * PAGE_NUM, 60);
    _bottomView.delegate = self;
    _bottomView.pagingEnabled = YES;
    _bottomView.layer.borderWidth = 1;
    _bottomView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _bottomView.backgroundColor = [UIColor whiteColor];
    [_bottomView setShowsVerticalScrollIndicator:NO];
    [_bottomView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:_bottomView];
}

#pragma mark -重新进入应用刷新
//重新进来后响应
- (void)reloadCalendar:(NSNotification *)notification
{
    [self initData];
    [self initView];
}

#pragma mark -scrollView
- (void)scrollViewDidScroll:(UIScrollView *)sender{
    
    int page = (_bottomView.contentOffset.x + self.view.frame.size.width/2.0) / self.view.frame.size.width;
    if (_bottomView.contentOffset.x > 600) {
        page = 0;
        _nowDay ++;
        [_bottomView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:NO];
        [self resetScrollView];
        
    }
    else if (_bottomView.contentOffset.x < 0 && _nowDay > 0)
    {
        page = 2;
        _nowDay --;
        [_bottomView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:NO];
        [self resetScrollView];
    }
    
    _pageControl.currentPage = page;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        CGFloat targetX = _bottomView.contentOffset.x + _bottomView.frame.size.width;
        targetX = (int)(targetX/self.view.frame.size.width) * self.view.frame.size.width;
        [_bottomView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    }
}

- (void)changePage:(id)sender {
//    [_bottomView setContentOffset:CGPointMake(self.view.frame.size.width * page, 0)];//根据pagecontroll的值来改变scrollview的滚动位置，以此切换到指定的页面
//    _pageChangeType = NOCHANGE;
//    _pageControl.currentPage = page;
}

- (void)initData
{
    _modelArray = [NSMutableArray array];
    if (!_nowDate) {
        NSDate *date = [NSDate date];
        _nowDate = [self changeDate2String:date];
    }
    
    [self initHeaderOfDate];
//    [self initFooterOfDate];
    [self initMonthLabel];
    [self initCellData];
}

- (void)reloadCalendarData
{
    if (_dataSource == nil) {
        [self initCellData];
    }
    
    _modelArray = [NSMutableArray array];
    [self initHeaderOfDate];
    [self getCanlendarData:_dataSource];
}

#pragma mark -ScrollView和PageControll
- (void)loadScrollView
{
    NSInteger tmpNum = _nowDay;
    for (int i = 0; i< PAGE_NUM; i++) {
        BottomCalendarView *fview = [[[NSBundle mainBundle] loadNibNamed:@"BottomCalendarView"
                                                                   owner:self
                                                                 options:nil] objectAtIndex:0];
        _bottomView.translatesAutoresizingMaskIntoConstraints = NO;
        fview.frame = CGRectMake(self.view.frame.size.width*i, 15, self.view.frame.size.width, 40);
        [fview setBackgroundColor:[UIColor clearColor]];
        [self initFooterOfDate:fview];
        [_bottomView addSubview:fview];
        _nowDay ++;
    }
    _nowDay = tmpNum;
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 60)];
    [_pageControl setCurrentPage:0];
    _pageControl.numberOfPages = PAGE_NUM;//指定页面个数
    [_pageControl setBackgroundColor:[UIColor clearColor]];
    _pageControl.hidden = YES;
    [_pageControl addTarget:self action:@selector(changePage:)forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageControl];
}

- (void)resetScrollView
{
    NSInteger tmpNum = _nowDay;
    NSArray *viewArray = [_bottomView subviews];
    
    for (int i = 0; i< PAGE_NUM; i++) {
        BottomCalendarView *fview = viewArray[i];
        [self initFooterOfDate:fview];
        _nowDay ++;
    }
    
    _nowDay = tmpNum;
}

#pragma mark -初始化header星期
- (void)initHeaderOfDate
{
    //日程
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSDayCalendarUnit;
    
    [self initMonthLabel];
    
    //初始化第一个空白view
    SubCalendarViewModel *firstModel = [[SubCalendarViewModel alloc] init];
    firstModel.isFristGrid = YES;
    firstModel.timeTitle = nil;
    firstModel.isTurnOn = NO;
    firstModel.typeNum = NOTHING;
    [_modelArray addObject:firstModel];
    
    for (int i = 0; i < 3; i++) {
        
        SubCalendarViewModel *model = [[SubCalendarViewModel alloc] init];
        NSDate *sinceDate = [self changeString2Date:_nowDate];
        NSDate *date = [NSDate dateWithTimeInterval:+(i* ONE_DAY) sinceDate:sinceDate];
        NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
        NSInteger day = [comps day];
        if (i == 0 && [self isCurrentDay:sinceDate]) {
            model.isToday = YES;
        }
        model.isFristGrid = YES;
        model.timeTitle = [NSString stringWithFormat:@"%ld 日", (long)day];
        model.isTurnOn = NO;
        firstModel.typeNum = NOTHING;
        [_modelArray addObject:model];
    }
}

- (void)initFooterOfDate:(BottomCalendarView *)bcView
{
    //日程
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSArray * arrWeek = [NSArray arrayWithObjects:@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六", nil];
    
    NSMutableArray *bottomModelArray = [NSMutableArray array];
    
    for (int i = 0; i < 7; i++) {
        
        SubBottomCalendarModel *model = [[SubBottomCalendarModel alloc] init];
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow: + ((i + _nowDay*7)* ONE_DAY)];
        NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
        NSInteger day = [comps day];
        NSInteger week = [comps weekday];
        model.date = [self changeDate2String:date];
        model.week = [arrWeek objectAtIndex:week - 1];
        model.date_time = [NSString stringWithFormat:@"%ld", (long)day];
        
        model.isSelected = i == 0 && _nowDay == 0 ? YES:NO;
        model.isToday = i == 0 && _nowDay == 0 ? YES:NO;
        [bottomModelArray addObject:model];
    }
    
    bcView.modelArray = bottomModelArray;
}

- (void)initCellData
{
    __weak CalendarViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] getCalendarOnCompletion:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            weakSelf.dataSource = [NSMutableArray arrayWithArray:data];
            [weakSelf getCanlendarData:data];
            [weakSelf.collection_view reloadData];
        }
        else
        {
            if (ret != ERR_SERVER_401)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KVNProgress showErrorWithStatus:@"网络可能有问题哦～"];
                });
            }
        }
    }];
}

- (void)getCanlendarData:(id)data
{
    for (int i = 0; i < 3; i++) {
        
        SubCalendarViewModel *fristModel = [[SubCalendarViewModel alloc] init];
        
        fristModel.isTurnOn = NO;
        fristModel.weekDay = nil;
        fristModel.timeTag = i + 1;
        fristModel.isFristGrid = YES;
        fristModel.typeNum = NOTHING;
        [_modelArray addObject:fristModel];
        //日程
        
        for (int j = 0; j < 3; j++) {
            SubCalendarViewModel *model = [[SubCalendarViewModel alloc] init];
            
            NSDate *sinceDate = [self changeString2Date:_nowDate];
            NSDate *date = [NSDate dateWithTimeInterval:+(j* ONE_DAY) sinceDate:sinceDate];
            
            NSString *locationString = [self changeDate2String:date];
            model.isTurnOn = NO;
            model.freeTime = locationString;
            model.timeTag = i + 1;
            model.isFristGrid = NO;
            model.typeNum = NOTHING;
            
            NSArray * arrayStartTime = [NSArray arrayWithObjects:@"6",@"12",@"18", nil];
            for (NSInteger k = 0; k < [data count]; k++)
            {
                NSString *str = data[k][@"freeDate"];
                NSInteger numTime = [[arrayStartTime objectAtIndex:i] integerValue];
                NSInteger numStart = [data[k][@"freeTimeStart"] integerValue];
                if ([str isEqualToString:locationString] && numTime == numStart) {
                    model.isTurnOn = NO;
                    model.typeNum = FRIENDSHERE;
                    if (![data[k][@"id"] isKindOfClass:[NSNull class]] && data[k][@"id"] != nil) {
                        model.isTurnOn = YES;
                        model.typeNum = NOTHING;
                        break;
                    }
                }
            }
            
            [_modelArray addObject:model];
        }
        
    }
}

- (void)initMonthLabel
{
    if (_label_month == nil) {
        _label_month = [[UILabel alloc] initWithFrame:CGRectMake(12, self.view.frame.size.height - 200, 60, 20)];
        
        NSLog(@"%f", self.view.bounds.size.height);
        if (self.view.bounds.size.height < 500 ) {
            _label_month.font = [UIFont systemFontOfSize:14.f];
        }
        _label_month.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
        [self.view addSubview:_label_month];
        [self.view bringSubviewToFront:_label_month];
    }
    
    //日程
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *comps = [NSDateComponents alloc];
    NSInteger unitFlags = NSMonthCalendarUnit;
    NSDate *sinceDate = [self changeString2Date:_nowDate];
    NSDate *date = [NSDate dateWithTimeInterval:0 sinceDate:sinceDate];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    _label_month.text = [NSString stringWithFormat:@"%ld 月", (long)[comps month]];
}

#pragma mark - CollectionView Controll

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ([_modelArray count] > 4) {
        return 4;
    }
    else
    {
        return 1;
    }
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CalendarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    
    cell.model = _modelArray[indexPath.row + indexPath.section * 4];
    
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat height;
    CGFloat width;
    
    
    if (self.view.bounds.size.height < 400 ) {
        height = 60;
        width = 60;
    }
    else
    {
        height = (self.view.frame.size.width - FIRST_LABEL_WITDH)/4;
        width = (self.view.frame.size.width - FIRST_LABEL_WITDH)/4;
    }
    
    if (indexPath.section == 0) {
        height = 20;
    }
    if (indexPath.row % 4 == 0) {
        width = FIRST_LABEL_WITDH;
    }
    
    return CGSizeMake(width, height);
}

//返回头headerView的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    CGSize size = {self.view.frame.size.width, 20};
    return size;
}

//每个item之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (self.view.bounds.size.height < 400 ) {
        return 30;
    }
    return (self.view.frame.size.width - FIRST_LABEL_WITDH)/16;
}

#pragma mark -右上角功能

-(void)createActivity
{
    [self performSegueWithIdentifier:@"createActivitySeg" sender:nil];
}


// 自绘分割线
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0xE2/255.0f green:0xE2/255.0f blue:0xE2/255.0f alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 1, rect.size.width, 1));
}


#pragma mark -辅助功能

- (NSString *)changeDate2String:(NSDate *)date
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date_str = [dateformatter stringFromDate:date];
    return date_str;
}

- (NSDate *)changeString2Date:(NSString *)str
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *inputDate = [dateformatter dateFromString:str];
    return inputDate;
}

- (BOOL)isCurrentDay:(NSDate *)aDate
{
    if (aDate == nil) return NO;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:aDate];
    NSDate *otherDate = [cal dateFromComponents:components];
    if([today isEqualToDate:otherDate])
        return YES;
    
    return NO;
}

////是否需要右上角显示小红点
//- (BOOL)isNeedToRight
//{
//    NSMutableArray *dataArray = [NSMutableArray array];
//    [[FreeSQLite sharedInstance] searchNewInFreeSQLiteCoupleList:dataArray];
//    for (NSString *timeStr in dataArray) {
//        if ([self isInFristThreeDay:[self changeString2Date:timeStr]] == NO) {
//            return YES;
//        }
//    }
//    return NO;
//}
//
////判断是否在前三天
//- (BOOL)isInFristThreeDay:(NSDate *)sinceDate
//{
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *compsNow = [[NSDateComponents alloc] init];
//    NSDateComponents *compsSince = [[NSDateComponents alloc] init];
//    NSInteger unitFlags = NSDayCalendarUnit | NSWeekdayCalendarUnit;
//    NSDate *nowDate = [NSDate date];
//    compsNow = [calendar components:unitFlags fromDate:nowDate];
//    compsSince = [calendar components:unitFlags fromDate:sinceDate];
//    NSInteger dayNow = [compsNow day];
//    NSInteger daySince = [compsSince day];
//    
//    if (daySince - dayNow > 2) {
//        return NO;
//    }
//    return YES;
//}



#pragma mark -注册通知
//匹配成功
- (void) registerNotificationForCouple {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coupleDIdChange:) name:ZC_NOTIFICATION_COUPLE_FRIEND object:nil];
}

//匹配成功
- (void) registerNotificationGotoCoupleSucc {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoCoupleSucc:) name:ZC_NOTIFICATION_GOTO_COUPLE_LIST object:nil];
}

//选择日期
- (void) registerNotificationChooseDate {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseDate:) name:ZC_NOTIFICATION_CHOOSE_DATE object:nil];
}

//状态转换
- (void) registerNotificationStateChange {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateDidChange:) name:ZC_NOTIFICATION_DID_STATE_CHANGE object:nil];
}


//点击推送通知事件
- (void) registerNotificationPushChange
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource:) name:ZC_NOTIFICATION_DID_PUSH_CHANGE object:nil];
}

#pragma mark -通知处理函数
//
- (void) coupleDIdChange:(NSNotification *) notification{
    NSMutableArray *array = notification.object;
    [self coupleSucc:array[0]];
}

- (void)coupleSucc:(id)data
{
    
    NSString *tagStr = nil;
    
    if (data[@"remark"] != nil) {
        tagStr = data[@"remark"];
    }
    else
    {
        for (int k = 0; k < [data[@"sameTags"] count]; k++) {
            if (k == 0) {
                tagStr = data[@"sameTags"][k][@"tagName"];
            }
            else
            {
                tagStr = [NSString stringWithFormat:@"%@-%@", tagStr,data[@"sameTags"][k][@"tagName"]];
            }
        }
    }
    CoupleSuccModel *model = [CoupleSuccModel alloc];
    model.friend_name = data[@"account"][@"friendName"];
    model.friend_tags = tagStr;
    model.friend_img = data[@"account"][@"headImg"];
    model.friend_accountId = data[@"account"][@"id"];
    model.view_Controller = self;
    
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
        NSArray *array =  [AppDelegate getMainWindow].subviews;
        
        if ([array count] > 1) {
            UIView *view = array[1];
            if (view.tag == SETTINGVIEW) {
                [array[1] removeFromSuperview];
            }
        }
        
        [[AppDelegate getMainWindow] addSubview:_backgroundView];
        CoupleSuccView *cview = [[[NSBundle mainBundle] loadNibNamed:@"CoupleSuccView"
                                                               owner:self
                                                             options:nil] objectAtIndex:0];
        
        cview.translatesAutoresizingMaskIntoConstraints = NO;
        cview.model = model;
        
        [_backgroundView addSubview:cview];
        
        NSDictionary *metrics = @{
                                  @"height" : @(([UIScreen mainScreen].bounds.size.height - 135)/2 - 100),
                                  @"width" : @((_backgroundView.bounds.size.width - 280)/2)
                                  };
        NSDictionary *views = NSDictionaryOfVariableBindings(cview);
        [_backgroundView addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:@"H:|-width-[cview(280)]-width-|"
          options:0
          metrics:metrics
          views:views]];
        [_backgroundView addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:
                                         @"V:|-height-[cview(135)]"
                                         options:0
                                         metrics:metrics
                                         views:views]];
    }
    
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

//跳转
- (void) gotoCoupleSucc:(NSNotification *) notification{
    
    NSMutableArray *dataArray = notification.object;
    
    [self performSegueWithIdentifier:@"coupleSucc" sender:dataArray];
}

//选择时间段
- (void) chooseDate:(NSNotification *) notification{
    
    _nowDate = notification.object;
    [self reloadCalendarData];
    [_collection_view reloadData];
}

- (void)stateDidChange:(NSNotification *) notification{
    
    NSString *str = notification.userInfo[@"freeDate"];
    NSInteger num = [notification.userInfo[@"freeTimeStart"] integerValue];
//    NSString *Id = notification.userInfo[@"id"];
    NSDictionary *dic = notification.userInfo;

    for (int i = 0; i < [_dataSource count]; i++) {
        if ([str isEqualToString:_dataSource[i][@"freeDate"]] && num == [_dataSource[i][@"freeTimeStart"] integerValue]) {
            [_dataSource removeObjectAtIndex:i];
        }
    }
    
    if ([notification.object isEqualToString:ADDMODEL]) {
        [_dataSource addObject:dic];
    }
}

- (void) reloadDataSource:(NSNotification *) notification{
    NSDictionary *dict = notification.object;
    
    NSString *str = dict[@"freeDate"];
    NSInteger num = [dict[@"freeTimeStart"] integerValue];
    //    NSString *Id = notification.userInfo[@"id"];
    
    for (int i = 0; i < [_dataSource count]; i++) {
        if ([str isEqualToString:_dataSource[i][@"freeDate"]] && num == [_dataSource[i][@"freeTimeStart"] integerValue]) {
            [_dataSource removeObjectAtIndex:i];
        }
    }
    
    [self reloadCalendarData];
    [_collection_view reloadData];
}

#pragma mark - prepareForeSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"coupleSucc"]) {
    CoupleSuccTableViewController* vc = (CoupleSuccTableViewController *)segue.destinationViewController;
    vc.freeDate = sender[0];
    vc.freeStartTime = sender[1];
    vc.cell_view = sender[2];
    vc.hidesBottomBarWhenPushed = YES;
    }
    else
    {
        UITableViewController *vc = segue.destinationViewController;
        vc.hidesBottomBarWhenPushed = YES;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    _isSuccees = NO;
    [UIView animateWithDuration:.2 animations:^{
        _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
    } completion:^(BOOL finished) {
        [_backgroudView removeFromSuperview];
        [_menuTableview removeFromSuperview];
    }];
    
}
@end

