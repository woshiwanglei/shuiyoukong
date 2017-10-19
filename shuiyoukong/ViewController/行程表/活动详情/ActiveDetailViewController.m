//
//  ActiveDetailViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ActiveDetailViewController.h"
#import "FreeSingleton.h"
#import "ActiveFriendsView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ActivityInviteTableViewController.h"
#import "AppDelegate.h"
#import "RCDChatViewController.h"
#import "FreeSQLite.h"
#import "ActivityTableViewController.h"
#import "UserInfoViewController.h"

#define SCROLLVIEW_HEIGHT 170.f
#define EXIT_TAG 10
#define CANCEL_TAG 11

@interface ActiveDetailViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_content;
@property (weak, nonatomic) IBOutlet UILabel *label_time;
@property (weak, nonatomic) IBOutlet UIView *friendsList_scrollView;
@property (weak, nonatomic) IBOutlet UIButton *btn_commit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn_center_x;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left_btn_width;
@property (weak, nonatomic) IBOutlet UIButton *btn_left;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollView_height;
//两个按钮之间的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn_to_btn_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *total_scrollView_hegiht;

@property (strong, nonatomic)NSMutableArray *dataSource;
@property (assign, nonatomic)BOOL alreadyAttend;
//返回类型
@property (nonatomic, assign)NSInteger type;
@property (nonatomic, strong)NSString *groupId;
@property (nonatomic, strong)NSString *activityName;
@property (nonatomic, strong)NSString *week;
@property (nonatomic, strong)NSString *noon;
@property (nonatomic, strong)NSString *promoteId;
@property (nonatomic, strong)NSString *promoterName;

@end

@implementation ActiveDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_type < NORMAL) {
        NSString *typeStr = [NSString stringWithFormat:@"%ld", (long)_type];
        NSString *countStr = [NSString stringWithFormat:@"%ld", (long)([_dataSource count] + 1)];
        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DATASOURCE_CHANGE object:typeStr userInfo:@{@"count":countStr}];
    }
}

- (void)initData
{
    //初始化类型
    _type = NORMAL;
    
    __weak ActiveDetailViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"];
    [[FreeSingleton sharedInstance] activeDetailOnCompletion:_activityId block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            _dataSource = [NSMutableArray arrayWithArray:data[@"attendList"]];
            _groupId = [NSString stringWithFormat:@"%@", data[@"groupId"]];
            _activityName = data[@"activityContent"];
            [weakSelf setViewText:data];
            [weakSelf initScrollView:[data[@"attendList"] count]];
            //获取数据成功后显示按钮
            _btn_left.hidden = NO;
            _btn_commit.hidden = NO;
            [weakSelf initBtn:[data[@"type"] integerValue]];
            [weakSelf initShareBtn:[data[@"type"] integerValue]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
        });
    }];
}

- (void)initView
{
    [self initBasicView];
    [self adjustPhone];
    [self comeFromPush];
}

- (void)initBasicView
{
    _head_img.layer.masksToBounds = YES;
    _head_img.layer.cornerRadius = 50.f;
    _btn_commit.layer.cornerRadius = 5.f;
    _btn_left.layer.cornerRadius = 5.f;
    //未载入成功时隐藏按钮
    _btn_left.hidden = YES;
    _btn_commit.hidden = YES;
    
    self.navigationItem.title = @"活动信息";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
//    _friendsList_scrollView.delegate = self;
//    _friendsList_scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _friendsList_scrollView.backgroundColor = [UIColor whiteColor];
//    [_friendsList_scrollView setShowsVerticalScrollIndicator:YES];
//    [_friendsList_scrollView setShowsHorizontalScrollIndicator:NO];

}

- (void)adjustPhone
{
    if([UIScreen mainScreen].bounds.size.height < 600)
    {
        _btn_width.constant = 120.f;
        _left_btn_width.constant = 120.f;
    }
    else {
        if (_btn_center_x.constant != 0) {
            _btn_center_x.constant = -100.f;
        }
    }
}

//如果是推送过来则设置返回按钮
- (void)comeFromPush
{
    if (_fromTag == COME_FROM_PUSH) {
        UIBarButtonItem *btnitem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(btn_disMissTapped)];
        btnitem.tintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
        [self adjustFontForIPhone:btnitem];
        self.navigationItem.leftBarButtonItem = btnitem;
    }
}

- (void)initShareBtn:(NSInteger)type
{
    if (type != MY_HOST) {
        return;
    }
    UIBarButtonItem *btnitem = [[UIBarButtonItem alloc] initWithTitle:@"邀请好友" style:UIBarButtonItemStylePlain target:self action:@selector(btn_inviteTapped)];
    btnitem.tintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
    [self adjustFontForIPhone:btnitem];
    self.navigationItem.rightBarButtonItem = btnitem;
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
                                                                       boldSystemFontOfSize:18], NSFontAttributeName,nil] forState:UIControlStateNormal];    }
    else
    {
        [btnitem setTitleTextAttributes:[NSDictionary
                                         dictionaryWithObjectsAndKeys:[UIFont
                                                                       boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
    }
}

#pragma mark - 初始化
- (void)setViewText:(id)data
{
    //头像
    [self showImage:data[@"promoteAccount"][@"headImg"]];
    _head_img.userInteractionEnabled = YES;
    
    _promoteId = [NSString stringWithFormat:@"%@", data[@"promoteAccount"][@"id"]];
    NSString *name = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:_promoteId];
    
    if (name == nil) {
        name = data[@"promoteAccount"][@"nickName"];
    }
    
    _promoterName = name;
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageTap:)];
    
    [_head_img addGestureRecognizer:tapImage];
    
    //名字
    _label_name.text = name;
    
    _label_content.text = data[@"activityContent"];
    NSArray *array = [data[@"activityDate"] componentsSeparatedByString:@"-"];
    NSArray * arrayStartTime = [NSArray arrayWithObjects:@"上午",@"下午",@"晚上", nil];
    NSInteger index = [data[@"activityTimeStart"] integerValue]/6 - 1;
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *inputDate = [dateformatter dateFromString:data[@"activityDate"]];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSWeekdayCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:inputDate];
    NSInteger week = [comps weekday];
    NSInteger year = [comps year];
    
    NSArray * arrWeek = [NSArray arrayWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六", nil];
    _week = [arrWeek objectAtIndex:week - 1];
    _noon = [arrayStartTime objectAtIndex:index];
    _label_time.text = [NSString stringWithFormat:@"%ld年%@月%@日星期%@%@", (long)year, array[1], array[2],[arrWeek objectAtIndex:week - 1], [arrayStartTime objectAtIndex:index]];
}

- (void)initScrollView:(NSInteger) listNum
{
    float height = SCROLLVIEW_HEIGHT/2;
    
    NSArray *views = [_friendsList_scrollView subviews];
    for(UIView *friendsview in views)
    {
        [friendsview removeFromSuperview];
    }
    
    if (listNum == 0) {
        _scrollView_height.constant = 0.f;
        return;
    }
    
    //4,5
    if ([UIScreen mainScreen].bounds.size.height < 700) {
        int row = (int)(listNum - 1)/4;
        if (row > 0) {
            height += row * 80.f;
            _total_scrollView_hegiht.constant += row * 80.f;
        }
    }
    else
    {
        int row = (int)(listNum - 1)/5;
        if (row > 0) {
            height += row * 80.f;
            _total_scrollView_hegiht.constant += row * 80.f;
        }
    }
//    else if(listNum < 5)
//    {
//        _scrollView_height.constant = SCROLLVIEW_HEIGHT/2;
//    }
    _scrollView_height.constant = height;
    
    UIView *fview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _friendsList_scrollView.bounds.size.width, height)];
    [_friendsList_scrollView addSubview:fview];
    
    for (int i = 0; i < listNum; i ++) {
        ActiveFriendsView *view = [[[NSBundle mainBundle] loadNibNamed:@"ActiveFriendsView"
                                                                 owner:self
                                                               options:nil] objectAtIndex:0];
        if ([UIScreen mainScreen].bounds.size.height < 600)
        {
            view.frame = CGRectMake(0 + 80*(i%4),10 + 80*(i/4), 80, 80);
        }
        else if([UIScreen mainScreen].bounds.size.height < 700)
        {
            view.frame = CGRectMake(30 + 80*(i%4), 10 + 80*(i/4), 80, 80);
        }
        else
        {
            view.frame = CGRectMake(10 + 80*(i%5), 10 + 80*(i/5), 80, 80);
        }
        [_friendsList_scrollView addSubview:view];
        
        SelectFriendsModel *model = [[SelectFriendsModel alloc] init];
        
        NSString *attendUserId = [NSString stringWithFormat:@"%@", _dataSource[i][@"attendUserId"]];
        NSString *name = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:attendUserId];
        
        if (name == nil) {
            name = _dataSource[i][@"attendUserName"];
        }
        model.accountId = attendUserId;
        model.name = name;
        model.img_url = _dataSource[i][@"attendUserImg"];
        model.fromInfo = [_dataSource[i][@"fromInfo"] integerValue];
        view.model = model;
        
        [fview addSubview:view];
    }
}

- (void)initBtn:(NSInteger)type
{
    switch (type) {
        case MY_HOST:
            _btn_left.titleLabel.text = @"解散活动";
            [_btn_left removeTarget:self action:@selector(exitActive:) forControlEvents:UIControlEventTouchUpInside];
            [_btn_left addTarget:self action:@selector(cancelActive:) forControlEvents:UIControlEventTouchUpInside];
            [_btn_commit removeTarget:self action:@selector(attendActive:) forControlEvents:UIControlEventTouchUpInside];
            [_btn_commit addTarget:self action:@selector(gotoChatList:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case ALREADY_ATTEND:
            _btn_left.hidden = NO;
            
            if ([UIScreen mainScreen].bounds.size.height < 700) {
                _btn_center_x.constant = -90.f;
            }
            else
            {
                _btn_center_x.constant = -100.f;
            }
            [_btn_left setTitle:@"退出活动" forState:UIControlStateNormal];
            [_btn_commit setTitle:@"进入群聊" forState:UIControlStateNormal];
            
            [_btn_left removeTarget:self action:@selector(cancelActive:) forControlEvents:UIControlEventTouchUpInside];
            [_btn_commit removeTarget:self action:@selector(attendActive:) forControlEvents:UIControlEventTouchUpInside];
            [_btn_left addTarget:self action:@selector(exitActive:) forControlEvents:UIControlEventTouchUpInside];
            [_btn_commit addTarget:self action:@selector(gotoChatList:) forControlEvents:UIControlEventTouchUpInside];
            break;
        default:
            _btn_left.hidden = YES;
            _btn_center_x.constant = 0;
            [_btn_commit setTitle:@"加入活动" forState:UIControlStateNormal];
            [_btn_commit removeTarget:self action:@selector(gotoChatList:) forControlEvents:UIControlEventTouchUpInside];
            [_btn_commit addTarget:self action:@selector(attendActive:) forControlEvents:UIControlEventTouchUpInside];
            break;
    }
}

#pragma mark - 按钮事件
//解散活动
- (void)cancelActive:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认要解散该活动吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"解散", nil];
    alertView.tag = CANCEL_TAG;
    [alertView show];
}

- (void)cancelAlert
{
    __weak ActiveDetailViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress showWithStatus:@"Loading"];
    });
    NSInteger ret = [[FreeSingleton sharedInstance] cancelActiveOnCompletion:_activityId block:^(NSUInteger retcode, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
        });
        if(retcode == RET_SERVER_SUCC)
        {
            //退出群聊
            [weakSelf exitGroup];
            _type = MY_HOST;//更改类型
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showSuccessWithStatus:@"您已解散该活动"
                                            onView:weakSelf.view.window];
                [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_GROUP targetId:_groupId];
                NSMutableArray *viewControlles = [NSMutableArray arrayWithArray:weakSelf.navigationController.viewControllers];
                if ([viewControlles count] == 1) {
                    UINavigationController *navi = weakSelf.navigationController;
                    [weakSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                        [navi popToRootViewControllerAnimated:NO];
                    }];
                }
                else if ([viewControlles[[viewControlles count] - 2] isKindOfClass:[ActivityTableViewController class]])
                {
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                }
                else
                {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showErrorWithStatus:@"散该活动失败"
                                            onView:weakSelf.view.window];
            });
        }
    }];
    
    if (ret != RET_OK) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
            [KVNProgress showErrorWithStatus:zcErrMsg(ret)];
        });
    }
}

//退出活动
- (void)exitActive:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认要退出该活动吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
    alertView.tag = EXIT_TAG;
    [alertView show];
}

- (void)exitAlert
{
    __weak ActiveDetailViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"];
    NSInteger ret = [[FreeSingleton sharedInstance] exitActiveOnCompletion:_activityId block:^(NSUInteger retcode, id data) {
        [KVNProgress dismiss];
        if(retcode == RET_SERVER_SUCC)
        {
            //退出群聊
            [weakSelf exitGroup];
            for (int i = 0; i < [_dataSource count]; i++) {
                NSString *str = [NSString stringWithFormat:@"%@",_dataSource[i][@"attendUserId"]];
                NSString *str2 = [NSString stringWithFormat:@"%@",[[FreeSingleton sharedInstance] getAccountId]];
                if ([str isEqualToString:str2]) {
                    [_dataSource removeObjectAtIndex:i];
                }
            }
            
            [weakSelf initScrollView:[_dataSource count]];
            [weakSelf initBtn:NOT_ATTEND];
            _alreadyAttend = NO;
            
            if (_type == ALREADY_ATTEND) {
                _type = NORMAL;
            }
            else
            {
                _type = NOT_ATTEND;//更改类型
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showSuccessWithStatus:@"您已经退出该活动" onView:weakSelf.view.window];
            });
        }
    }];
    
    if (ret != RET_OK) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
            [KVNProgress showErrorWithStatus:zcErrMsg(ret)];
        });
    }
}

//参加活动
- (void)attendActive:(id)sender
{
    if (_alreadyAttend) {
        [KVNProgress showErrorWithStatus:@"您已经报名了该活动"];
        return;
    }
    
    __weak ActiveDetailViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"];
    NSInteger ret = [[FreeSingleton sharedInstance] attendActiveOnCompletion:_activityId block:^(NSUInteger retcode, id data) {
        if(retcode == RET_SERVER_SUCC)
        {
            weakSelf.alreadyAttend = YES;
            
            NSString *str = [[FreeSingleton sharedInstance] getHeadImage];
            if (![str length]) {
                str = @"";
            }
            
            NSDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:str, @"attendUserImg", [[FreeSingleton sharedInstance] getNickName], @"attendUserName", [[FreeSingleton sharedInstance] getAccountId], @"attendUserId", nil];
            [_dataSource insertObject:dict atIndex:0];
            [[FreeSingleton sharedInstance] joinGroupOnCompletion:_groupId block:^(NSUInteger ret, id data) {
                if(ret == RET_SERVER_SUCC)
                {
                    [[RCIMClient sharedRCIMClient] joinGroup:_groupId groupName:nil success:^{
                        [KVNProgress dismiss];
                        NSLog(@"加入群组成功");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf initScrollView:[_dataSource count]];
                            [weakSelf initBtn:ALREADY_ATTEND];
                            [KVNProgress showSuccessWithStatus:@"您已成功报名该活动"];
                        });
                        [[FreeSingleton sharedInstance] syncGroups:^(NSUInteger ret, id data) {
                        }];
                    } error:^(RCErrorCode status) {
                        [KVNProgress dismiss];
                        NSLog(@"加入群组失败");
                    }];
                    
                }
                else
                {
                    [KVNProgress dismiss];
                    NSLog(@"加入群组失败");
                }
                
            }];
            
            if (_type == NOT_ATTEND) {
                _type = NORMAL;
            }
            else
            {
                _type = ALREADY_ATTEND;//更改类型
            }
        }
        else
        {
            [KVNProgress dismiss];
            [KVNProgress showErrorWithStatus:data];
        }
    }];
    
    if (ret != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(ret)];
    }
}

//退出群聊
- (void)exitGroup
{
    [[FreeSingleton sharedInstance] quitGroupOnCompletion:_groupId block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            [[RCIMClient sharedRCIMClient] quitGroup:_groupId success:^{
                NSLog(@"退出群聊成功");
                [[FreeSingleton sharedInstance] syncGroups:^(NSUInteger ret, id data) {
                }];
            } error:^(RCErrorCode status) {
                NSLog(@"退出群聊失败");
            }];
        }
        else
        {
            NSLog(@"退出群聊失败");
        }
    }];
}

//进入群聊
- (void)gotoChatList:(id)sender
{
    NSMutableArray *viewControlles = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if ([viewControlles count] > 1) {
        if ([viewControlles[[viewControlles count] - 2] isKindOfClass:[ActivityTableViewController class]])
        {
            UINavigationController *navigationController = self.navigationController;
            [navigationController popViewControllerAnimated:NO];
            [navigationController popViewControllerAnimated:YES];
            return;
        }
    }
    
    
    [KVNProgress showWithStatus:@"Loading"];
    __weak ActiveDetailViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] joinGroupOnCompletion:_groupId block:^(NSUInteger ret, id data) {
        if(ret == RET_SERVER_SUCC)
        {
            [[FreeSingleton sharedInstance] joinGroupOnCompletion:_groupId block:^(NSUInteger ret, id data) {
                [KVNProgress dismiss];
                if (ret == RET_SERVER_SUCC) {
                    NSLog(@"加入群组成功");
                    [[FreeSingleton sharedInstance] syncGroups:^(NSUInteger ret, id data) {
                    }];

                    RCDChatViewController *_conversationVC = [[RCDChatViewController alloc]init];
                    _conversationVC.conversationType = ConversationType_GROUP;
                    _conversationVC.targetId = _groupId;
                    _conversationVC.userName = _label_content.text;
                    _conversationVC.title = _label_content.text;
                    //    _conversationVC.conversation = model;
                    _conversationVC.hidesBottomBarWhenPushed = YES;
                    UINavigationController *navigationController = weakSelf.navigationController;
                    [navigationController popToRootViewControllerAnimated:NO];
                    [navigationController pushViewController:_conversationVC animated:YES];
                    [[FreeSingleton sharedInstance] syncGroups:^(NSUInteger ret, id data) {
                    }];
                }
                else
                {
                    [KVNProgress showErrorWithStatus:@"加入群聊失败"];
                   NSLog(@"加入群聊失败");
                }
            }];
        }
        else
        {
            [KVNProgress dismiss];
            NSLog(@"加入群聊失败");
        }
        
    }];
}

- (void)btn_disMissTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -头像
- (void)showImage:(NSString *)img_url
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_300X300] placeholderImage:[UIImage imageNamed:@"waiguoren"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

-(void)ImageTap:(UITapGestureRecognizer *)tap
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    
    vc.friend_id = _promoteId;
    vc.friend_name = _promoterName;
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 跳转
- (void)btn_inviteTapped
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    ActivityInviteTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ActivityInviteTableViewController"];
    vc.groupId = _groupId;
    vc.activeId = [NSString stringWithFormat:@"%@", _activityId];
    vc.activiName = _activityName;
    vc.week = _week;
    vc.noon = _noon;
    vc.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = self.navigationController;
    [navigationController pushViewController:vc animated:YES];
}

#pragma mark -警告
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (alertView.tag == EXIT_TAG) {
            [self exitAlert];
        }
        else if (alertView.tag == CANCEL_TAG)
        {
            [self cancelAlert];
        }
    }
    
}

@end
