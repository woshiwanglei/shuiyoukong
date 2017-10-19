//
//  ActivityViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/2.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ActivityViewController.h"
#import "ActivityCalendarParentView.h"
#import "SuperSquareView.h"
#import "ActivityInviteTableViewController.h"
#import "FreeSingleton.h"

#define ONE_DAY 24*60*60

#define PAGE_NUM 3

#define CARLENDAR 123

@interface ActivityViewController()<UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *square_superView;
@property (weak, nonatomic) IBOutlet UIView *backgroud_view;
@property (weak, nonatomic) IBOutlet UIButton *btn_commit;
@property (weak, nonatomic) IBOutlet UITextField *text_time;
@property (weak, nonatomic) IBOutlet UILabel *label_month;

@property UIPageControl *pageControl;
@property (assign, nonatomic)NSInteger nowDay;

@property (strong, nonatomic)ActivityCalendarSubModel *activeModel;

@property (assign, nonatomic)NSString *freeNoon;
@property (strong, nonatomic)NSString *activity_Id;
@property (strong, nonatomic)NSString *groupId;
@property (assign, nonatomic)BOOL isEdit;

@end

@implementation ActivityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (void)initView
{
    [self initBasic];
    [self initCalendarView];
    [self loadScrollView];
    [self initSquareView];
}

- (void)initData
{
    //初始化时间model
    _activeModel = [[ActivityCalendarSubModel alloc] init];
}

- (void)dealloc
{
    _activity_scrollview.delegate = nil;
    _super_scrollview.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:_text_input];
}


- (void)initBasic
{
    self.text_input.returnKeyType = UIReturnKeyDone;
    self.text_input.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    self.text_input.delegate = self;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    _backgroud_view.backgroundColor = [UIColor colorWithRed:239/255.0 green:237/255.0 blue:239/255.0 alpha:1];
    _backgroud_view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _btn_commit.layer.cornerRadius = 5.f;
    _text_input.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0 ];
    _text_time.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0 ];
    _text_input.borderStyle = UITextBorderStyleNone;
    _text_input.clearButtonMode = UITextFieldViewModeAlways;
    
    _filedView.backgroundColor = [UIColor whiteColor];
    _filedView.layer.borderWidth = 1;
    _filedView.layer.borderColor =[[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0] CGColor];
    _text_time.borderStyle = UITextBorderStyleRoundedRect;
    _text_time.layer.borderWidth = 1.f;
    _text_time.layer.borderColor = [[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0] CGColor];
    self.navigationItem.title = @"发起活动";
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [_btn_commit addTarget:self action:@selector(btn_commitTapped) forControlEvents:UIControlEventTouchUpInside];
    [_text_input setTintColor:FREE_BACKGOURND_COLOR];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_text_input];
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    
    // NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > 30) {
                textField.text = [toBeString substringToIndex:30];
            }
        }
        else{
            
        }
    }
    else{
        if (toBeString.length > 30) {
            textField.text = [toBeString substringToIndex:30];
        }
    }
}
- (void)initCalendarView
{
    
    _activity_scrollview.frame = CGRectMake(_activity_scrollview.frame.origin.x,_activity_scrollview.frame.origin.x, [UIScreen mainScreen].bounds.size.width, 60);
    _activity_scrollview.contentSize = CGSizeMake(self.view.frame.size.width * PAGE_NUM, 60);
    _activity_scrollview.delegate = self;
    _activity_scrollview.tag = CARLENDAR;
    _activity_scrollview.pagingEnabled = YES;
    _activity_scrollview.layer.borderWidth = 1;
    _activity_scrollview.layer.borderColor = [[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0] CGColor];;
    
    _activity_scrollview.backgroundColor = [UIColor whiteColor];
    [_activity_scrollview setShowsVerticalScrollIndicator:NO];
    [_activity_scrollview setShowsHorizontalScrollIndicator:NO];
}


#pragma mark -ScrollviewControll
- (void)scrollViewDidScroll:(UIScrollView *)sender{
    
    if (sender.tag == CARLENDAR) {
        int page = (_activity_scrollview.contentOffset.x + self.view.frame.size.width/2.0) / self.view.frame.size.width;
        if (_activity_scrollview.contentOffset.x > 600) {
            page = 0;
            _nowDay ++;
            [_activity_scrollview setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:NO];
            [self resetScrollView];
            
        }
        else if (_activity_scrollview.contentOffset.x < 0 && _nowDay > 0)
        {
            page = 2;
            _nowDay--;
            [_activity_scrollview setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:NO];
            [self resetScrollView];
        }
        
        _pageControl.currentPage = page;
    }
}

#pragma mark -日历处理
- (void)initFooterOfDate:(ActivityCalendarParentView *)bcView isFrist:(BOOL)isFrist
{
    //日程
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSDayCalendarUnit | NSWeekdayCalendarUnit | NSMonthCalendarUnit;
    NSArray * arrWeek = [NSArray arrayWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六", nil];
    
    NSMutableArray *bottomModelArray = [NSMutableArray array];
    
    for (int i = 0; i < 7; i++) {
        
        ActivityCalendarSubModel *model = [[ActivityCalendarSubModel alloc] init];
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow: + ((i + _nowDay*7)* ONE_DAY)];
        NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
        NSInteger day = [comps day];
        NSInteger week = [comps weekday];
        NSInteger month = [comps month];
        model.day = [NSString stringWithFormat:@"%ld", (long)day];
        model.week = [arrWeek objectAtIndex:week - 1];
        model.month = month;
        model.freeDate = [self changeDate2String:date];
        
        if (isFrist && i == 0) {
            _activeModel.freeDate = model.freeDate;
            _activeModel.week = model.week;
            _activeModel.day = model.day;
            _activeModel.month = model.month;
            model.isSelected = YES;
            [self changeLabelMonth];
        }
        else
        {
            model.isSelected = NO;
        }
        
        [bottomModelArray addObject:model];
    }
    
    bcView.modelArray = bottomModelArray;
}

//日历滚动
- (void)loadScrollView
{
    NSInteger tmpNum = _nowDay;
    for (int i = 0; i< PAGE_NUM; i++) {
        ActivityCalendarParentView *fview = [[[NSBundle mainBundle] loadNibNamed:@"ActivityCalendarParentView"
                                                                           owner:self
                                                                         options:nil] objectAtIndex:0];
        fview.frame = CGRectMake(self.view.frame.size.width*i, 0, self.view.frame.size.width, _activity_scrollview.frame.size.width);
        
        [fview setBackgroundColor:[UIColor clearColor]];
        fview.userInteractionEnabled = YES;
        
        for (int j = 0; j < [fview.subViewArray count]; j++) {
            ActivityCalendarSubView *subView = fview.subViewArray[j];
            subView.userInteractionEnabled = YES;
            UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseDate:)];
            [subView addGestureRecognizer:tapGes];
        }
        
        if (i == 0) {
            //第一次默认选择第一格
            [self initFooterOfDate:fview isFrist:YES];
        }
        else
        {
            [self initFooterOfDate:fview isFrist:NO];
        }
        
        [_activity_scrollview addSubview:fview];
        _nowDay ++;
    }
    _nowDay = tmpNum;
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 60)];
    [_pageControl setCurrentPage:0];
    _pageControl.numberOfPages = PAGE_NUM;//指定页面个数
    [_pageControl setBackgroundColor:[UIColor clearColor]];
    _pageControl.hidden = YES;
    [self.view addSubview:_pageControl];
}

- (void)resetScrollView
{
    NSInteger tmpNum = _nowDay;
    NSArray *viewArray = [_activity_scrollview subviews];
    
    for (int i = 0; i< PAGE_NUM; i++) {
        ActivityCalendarParentView *fview = viewArray[i];
        [self initFooterOfDate:fview isFrist:NO];
        _nowDay ++;
    }
    
    _nowDay = tmpNum;
}

#pragma mark -日期方块
- (void)initSquareView
{
    SuperSquareView *subview = [[[NSBundle mainBundle] loadNibNamed:@"SuperSquareView"
                                                                       owner:self
                                                                     options:nil] objectAtIndex:0];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    
    subview.modelArray = [self orignSquareData];
    
    for (int i = 0; i < [subview.subViewArray count]; i++) {
        CarlendSquaresView *carlendView = subview.subViewArray[i];
        carlendView.userInteractionEnabled = YES;
        UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseSquare:)];
        [carlendView addGestureRecognizer:tapGes];
    }
    
    [_square_superView addSubview:subview];
    
    NSDictionary *metrics = @{
                              @"height" : @(_square_superView.bounds.size.height),
                              @"width" : @(_square_superView.bounds.size.width)
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
    [_square_superView addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|[subview(width)]"
      options:0
      metrics:metrics
      views:views]];
    [_square_superView addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|[subview(height)]"
                          options:0
                          metrics:metrics
                          views:views]];
    
    [subview setBackgroundColor:[UIColor clearColor]];
}

//初始化下方方块
- (NSMutableArray *)orignSquareData
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 3; i++) {
        CarlendSquaresModel *model = [[CarlendSquaresModel alloc] init];
        if (i == 2) {
            model.isSelected = YES;
            _freeNoon = @"晚上";
            _text_time.text = [NSString stringWithFormat:@"  %ld月 %@日 星期%@ %@", (long)_activeModel.month, _activeModel.day, _activeModel.week, _freeNoon];
        }
        else
        {
            model.isSelected = NO;
        }
        model.freeTag = i + 1;
        [array addObject:model];
    }
    
    return array;
}

#pragma mark -响应函数
//响应日历
- (void)chooseDate:(UITapGestureRecognizer *)gesture
{
    ActivityCalendarSubView *view = (ActivityCalendarSubView *)gesture.view;
    _activeModel.freeDate = view.model.freeDate;
    _activeModel.week = view.model.week;
    _activeModel.day = view.model.day;
    _activeModel.month = view.model.month;
    
    NSArray *array3 = _activity_scrollview.subviews;
    for (UIView *view3 in array3) {
        ActivityCalendarParentView *activeView = (ActivityCalendarParentView *)view3;
        NSArray *array7 = activeView.subviews;
        for (UIView *view7 in array7) {
            ActivityCalendarSubView *subView = (ActivityCalendarSubView *)view7;
//            subView.btn_little.hidden = YES;
//            subView.view_circle.layer.borderColor = [[UIColor clearColor] CGColor];
//            [subView.label_day setFont:[UIFont systemFontOfSize:15]];
            subView.bottomView.hidden = YES;
            subView.label_day.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0  blue:128/255.0  alpha:1.0];
        }
    }
    
    view.bottomView.hidden = NO;
//    view.view_circle.layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
//    [view.label_day setFont:[UIFont systemFontOfSize:19]];
    view.label_day.textColor = [UIColor redColor];
    
    _text_time.text = [NSString stringWithFormat:@"  %ld月 %@日 星期%@ %@", (long)_activeModel.month, _activeModel.day, _activeModel.week, _freeNoon];
    [self changeLabelMonth];
    
}
//响应下方时间块
- (void)chooseSquare:(UITapGestureRecognizer *)gesture
{
    CarlendSquaresView *view = (CarlendSquaresView *)gesture.view;
    NSArray *array = view.superview.subviews;
    for (UIView *subView in array) {
        CarlendSquaresView *carlendView = (CarlendSquaresView *)subView;
        carlendView.btn_choose.hidden = YES;
        carlendView.view_square.layer.borderColor =  [[UIColor clearColor] CGColor];
    }
    view.btn_choose.hidden = NO;
    view.view_square.layer.borderColor = [[UIColor colorWithRed:32/255.0 green:186/255.0 blue:148/255.0 alpha:.7] CGColor];
    
    NSArray *arrayNoon = [NSArray arrayWithObjects:@"上午",@"下午",@"晚上", nil];
    _freeNoon = [arrayNoon objectAtIndex:(view.model.freeTag - 1)];
    _text_time.text = [NSString stringWithFormat:@"  %ld月 %@日 星期%@ %@", (long)_activeModel.month, _activeModel.day, _activeModel.week, _freeNoon];
}

//修改月份
- (void)changeLabelMonth
{
    _label_month.text = [NSString stringWithFormat:@"%ld 月", (long)_activeModel.month];
}

//提交按钮
- (void)btn_commitTapped
{
    NSString *freeNoon;
    
    if ([_freeNoon isEqualToString:@"上午"]) {
        freeNoon = @"6";
    }
    else if ([_freeNoon isEqualToString:@"下午"])
    {
        freeNoon = @"12";
    }
    else
    {
        freeNoon = @"18";
    }
    
    if (_isEdit == NO) {
        [KVNProgress showWithStatus:@"Loading"];
        __weak ActivityViewController *weakSelf = self;
        
        NSInteger retcode = [[FreeSingleton sharedInstance] postAcitiveInfoOnCompletion:_activeModel.freeDate freeStartTime:freeNoon activeContent:_text_input.text block:^(NSUInteger ret, id data) {
            if (ret == RET_SERVER_SUCC) {
                _activity_Id = [NSString stringWithFormat:@"%@", data[@"activityId"]];
                _groupId = [NSString stringWithFormat:@"%@", data[@"groupId"]];
                
                [[FreeSingleton sharedInstance] joinGroupOnCompletion:_groupId block:^(NSUInteger ret, id data) {
                    if (ret == RET_SERVER_SUCC) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [KVNProgress dismiss];
                        });
                        NSLog(@"加入群组成功");
                        [[FreeSingleton sharedInstance] syncGroups:^(NSUInteger ret, id data) {
                        }];
                        _isEdit = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf performSegueWithIdentifier:@"gotoInviteFriendsSeg" sender:weakSelf];
                        });
                    }
                    else
                    {
                       NSLog(@"加入群组失败");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [KVNProgress dismiss];
                            [KVNProgress showErrorWithStatus:@"创建活动失败" onView:weakSelf.view];
                        });
                    }
                }];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KVNProgress dismiss];
                    [KVNProgress showErrorWithStatus:@"创建活动失败"];
                });
            }
        }];
        
        if (retcode != RET_OK) {
            [KVNProgress dismiss];
            [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
        }
    }
    else
    {
        __weak ActivityViewController *weakSelf = self;
        [KVNProgress showWithStatus:@"Loading"];
        NSInteger retcode = [[FreeSingleton sharedInstance] editAcitiveInfoOnCompletion:_activeModel.freeDate freeStartTime:freeNoon activeContent:_text_input.text activityId:_activity_Id block:^(NSUInteger ret, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress dismiss];
            });
            if (ret == RET_SERVER_SUCC) {
                [weakSelf performSegueWithIdentifier:@"gotoInviteFriendsSeg" sender:weakSelf];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KVNProgress showErrorWithStatus:data];
                });
            }
        }];
        
        if (retcode != RET_OK) {
            [KVNProgress dismiss];
            [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
        }
    }
    
    
}

////创建群聊
//- (void)createGroup
//{
//    __weak ActivityViewController *weakSelf = self;
//    NSInteger retcode = [[FreeSingleton sharedInstance] createGroup:_text_input.text block:^(NSUInteger ret, id data) {
//        [KVNProgress dismiss];
//        if (ret == RET_SERVER_SUCC) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                _isEdit = YES;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf performSegueWithIdentifier:@"gotoInviteFriendsSeg" sender:weakSelf];
//                });
//            });
//        }
//        else
//        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [KVNProgress showErrorWithStatus:data onView:weakSelf.view];
//            });
//        }
//    }];
//    
//    if (retcode != RET_OK) {
//        [KVNProgress dismiss];
//        [KVNProgress showErrorWithStatus:zcErrMsg(retcode) onView:self.view];
//    }
//}


#pragma mark -辅助函数

- (NSString *)changeDate2String:(NSDate *)date
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date_str = [dateformatter stringFromDate:date];
    return date_str;
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [_text_input resignFirstResponder];
}
/**
 *  点击完成收入键盘
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_text_input resignFirstResponder];
    
    return YES;
}

#pragma mark - 跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"gotoInviteFriendsSeg"]) {
        ActivityInviteTableViewController* vc = (ActivityInviteTableViewController *)segue.destinationViewController;
        vc.activeId = _activity_Id;
        vc.groupId = _groupId;
         vc.activiName = _text_input.text;
        vc.week = _activeModel.week;
        vc.noon = _freeNoon;
        
    }
}

@end