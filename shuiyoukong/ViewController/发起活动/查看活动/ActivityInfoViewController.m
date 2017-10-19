//
//  ActivityInfoViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/12.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ActivityInfoViewController.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ActiveFriendsView.h"
#import "ActivityTableViewController.h"
#import "RCDChatViewController.h"
#import "ShareWebView.h"
#import "AppDelegate.h"
#import "ActivityInviteFriendsTableViewController.h"
#import "PostViewController.h"
#import "FreeMapViewController.h"
#import "UserInfoViewController.h"
#import "FreeSQLite.h"

#define NORMAL  3
#define NOT_ATTEND 2
#define ALREADY_ATTEND 1
#define MY_HOST 0

#define EXIT_TAG 10
#define CANCEL_TAG 11

@interface ActivityInfoViewController ()<UMSocialUIDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UIImageView *big_img;
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet UILabel *label_time;
@property (weak, nonatomic) IBOutlet UILabel *label_address;
@property (weak, nonatomic) IBOutlet UITextView *text_content;
@property (weak, nonatomic) IBOutlet UIView *friends_view;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *based_view_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *content_view_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ratio_wh;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *equal_width;
@property (weak, nonatomic) IBOutlet UILabel *label_notice_friends;
@property (weak, nonatomic) IBOutlet UIButton *btn_post;
@property (weak, nonatomic) IBOutlet UIView *based_view;

@property (weak, nonatomic) IBOutlet UIView *bottom_view;
@property (weak, nonatomic) IBOutlet UIButton *left_btn;
@property (weak, nonatomic) IBOutlet UIButton *right_btn;
@property (weak, nonatomic) IBOutlet UIView *head_view;

@property (weak, nonatomic) IBOutlet UIButton *btn_time;
@property (weak, nonatomic) IBOutlet UIButton *btn_position;
@property (nonatomic, assign)NSInteger type;

@property (assign, nonatomic)BOOL alreadyAttend;

@property (nonatomic,strong) ShareWebView *sharejoinView;
@property (nonatomic,strong) UIView *backgroundview;
@property (nonatomic,assign) float based_height;
@property (nonatomic,strong)NSMutableArray *friendsArray;

@property (nonatomic,strong) UIScrollView *scrollviewed;
@property (nonatomic, strong) UIImageView *holder;

@end

@implementation ActivityInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _type = NORMAL;
    [self comeFromPush];
    if (_activity_model) {
        [self initView];
    }
    else
    {
        [self initData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!_activity_model) {
        return;
    }
    
    if (_type < NORMAL) {
        NSString *typeStr = [NSString stringWithFormat:@"%ld", (long)_type];
        NSString *activity_Id = _activity_model.activityId;
        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:typeStr,@"type", activity_Id, @"activity_Id", nil];
        
        NSString *countStr = [NSString stringWithFormat:@"%ld", (long)_activity_model.attendCount];
        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DATASOURCE_CHANGE object:dic userInfo:@{@"count":countStr}];
    }
}

#pragma mark - 判断推送
//如果是推送过来则设置返回按钮
- (void)comeFromPush
{
    if (_fromTag == COME_FROM_PUSH) {
        UIBarButtonItem *btnitem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(btn_disMissTapped)];
        btnitem.tintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
        self.navigationItem.leftBarButtonItem = btnitem;
    }
}

- (void)btn_disMissTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - initView
- (void)initView
{
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    self.navigationItem.title = @"活动详情";
    
    if ([_activity_model.promoteAccount.accountId isEqual:[[FreeSingleton sharedInstance] getAccountId]]) {
        UIButton* _btn_more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_btn_more addTarget:self action:@selector(rightItemShare:) forControlEvents:UIControlEventTouchUpInside];
        [_btn_more setImage:[UIImage imageNamed:@"icon_more_normal"] forState:UIControlStateNormal];
        [_btn_more setImage:[UIImage imageNamed:@"icon_more_highlight"] forState:UIControlStateHighlighted];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:_btn_more];
        self.navigationItem.rightBarButtonItem = backItem;
    }
    
    [self initFristView];
    [self initSecondView];
    [self initThirdView];
    [self initFriendsView];
    [self initBottomView];
}

#pragma mark - 各个view的初始化
- (void)initFristView
{
    _label_name.text = _activity_model.promoteAccount.nickName;
    [self showImage:_head_img img_url:_activity_model.promoteAccount.headImg];
    [self showBigImage];
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageTap:)];
    [_head_view addGestureRecognizer:tapImage];
    _head_view.userInteractionEnabled = YES;
}

- (void)initSecondView
{
    _label_title.text = _activity_model.title;
    _label_time.text = [NSString stringWithFormat:@"%@ %@", _activity_model.activityDate, _activity_model.activityTime];
    _label_address.text = _activity_model.address;
    
    if ([_activity_model.postId length]) {
        [_btn_post addTarget:self action:@selector(gotoPost) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        _btn_post.hidden = YES;
    }
    
    [_btn_time addTarget:self action:@selector(gotoPosition:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_position addTarget:self action:@selector(gotoPosition:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initThirdView
{
    _text_content.text = _activity_model.activityContent;
    float height = 0;
    CGSize s =  [_text_content sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 42 , FLT_MAX)];
    if (s.height < 22) {
        height = 22.f;
    }
    else
    {
        height = s.height;
    }
    _based_view_height.constant += height;
    _content_view_height.constant = 74 + height;
    _based_height = _based_view_height.constant;
}

- (void)initFriendsView
{
    float height = _based_height;
    
    NSArray *views = [_friends_view subviews];
    for(UIView *friendsview in views)
    {
        if ([friendsview isKindOfClass:[ActiveFriendsView class]]) {
            [friendsview removeFromSuperview];
        }
    }
    
    if (![_activity_model.attendList count] && _type != ALREADY_ATTEND) {
        _label_notice_friends.text = @"暂无参加好友";
        return;
    }
    else
    {
        _label_notice_friends.text = @"已报名好友";
    }
//    height += 30;
    NSInteger listNum = [_activity_model.attendList count];
    
    //4,5
    if ([UIScreen mainScreen].bounds.size.height < 700) {
        int row = (int)(listNum + 3)/4;
        if (row > 0) {
            height += row * 90.f;
        }
    }
    else
    {
        int row = (int)(listNum + 4)/5;
        if (row > 0) {
            height += row * 90.f;
        }
    }
    
    _based_view_height.constant = height;
    
    for (int i = 0; i < listNum; i ++) {
        ActiveFriendsView *view = [[[NSBundle mainBundle] loadNibNamed:@"ActiveFriendsView"
                                                                 owner:self
                                                               options:nil] objectAtIndex:0];
        if ([UIScreen mainScreen].bounds.size.height < 600)
        {
            view.frame = CGRectMake(0 + 80*(i%4),40 + 80*(i/4), 80, 20);
        }
        else if([UIScreen mainScreen].bounds.size.height < 700)
        {
            view.frame = CGRectMake(30 + 80*(i%4), 40 + 80*(i/4), 80, 20);
        }
        else
        {
            view.frame = CGRectMake(10 + 80*(i%5), 40 + 80*(i/5), 80, 20);
        }
        SelectFriendsModel *model = _activity_model.attendList[i];
        
        view.model = model;
//        view.label_fromInfo.hidden = YES;
        [_friends_view addSubview:view];
    }
}

- (void)initBottomView
{
    _bottom_view.layer.borderColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:0.3].CGColor;
    _bottom_view.layer.borderWidth = 1.f;
    
    switch (_activity_model.type) {
        case MY_HOST:
            _right_btn.titleLabel.text = @"解散活动";
            [_right_btn setTitle:@"解散活动" forState:UIControlStateNormal];;
            [_right_btn removeTarget:self action:@selector(exitActive:) forControlEvents:UIControlEventTouchUpInside];
            [_right_btn addTarget:self action:@selector(cancelActive:) forControlEvents:UIControlEventTouchUpInside];
            [_left_btn removeTarget:self action:@selector(attendActive:) forControlEvents:UIControlEventTouchUpInside];
            [_left_btn addTarget:self action:@selector(gotoChatList:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case ALREADY_ATTEND:
            _left_btn.hidden = NO;
            
            _equal_width.constant = 1;
            
            _right_btn.titleLabel.text = @"退出活动";
            [_right_btn setTitle:@"退出活动" forState:UIControlStateNormal];
            _left_btn.titleLabel.text = @"进入群聊";
            [_left_btn setTitle:@"进入群聊" forState:UIControlStateNormal];
            
            [_right_btn removeTarget:self action:@selector(cancelActive:) forControlEvents:UIControlEventTouchUpInside];
            [_left_btn removeTarget:self action:@selector(attendActive:) forControlEvents:UIControlEventTouchUpInside];
            [_right_btn addTarget:self action:@selector(exitActive:) forControlEvents:UIControlEventTouchUpInside];
            [_left_btn addTarget:self action:@selector(gotoChatList:) forControlEvents:UIControlEventTouchUpInside];
            break;
        default:
            _left_btn.hidden = YES;
            _equal_width.constant = self.view.frame.size.width;
            _right_btn.titleLabel.text = @"加入活动";
            [_right_btn setTitle:@"加入活动" forState:UIControlStateNormal];
            [_right_btn removeTarget:self action:@selector(exitActive:) forControlEvents:UIControlEventTouchUpInside];
            [_right_btn addTarget:self action:@selector(attendActive:) forControlEvents:UIControlEventTouchUpInside];
            break;
    }
}

#pragma mark - initData
- (void)initData
{
    __weak ActivityInfoViewController *weakSelf = self;
    _based_view.hidden = YES;
    [KVNProgress showWithStatus:@"Loading" onView:self.view];
    [[FreeSingleton sharedInstance] activeDetailOnCompletion:_activityId block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            _based_view.hidden = NO;
            [weakSelf addActivityModel:data];
            [weakSelf initView];
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"该活动已失效"];
            _bottom_view.hidden = YES;
        }
    }];
}

- (void)addActivityModel:(id)data
{
    _activity_model = [[ActivityModel alloc] init];
    _activity_model.activityContent = data[@"activityContent"];
    _activity_model.activityDate = data[@"activityDate"];
    _activity_model.activityId = [NSString stringWithFormat:@"%@", data[@"activityId"]];
    
    if (![data[@"activityTime"] isKindOfClass:[NSNull class]] && data[@"activityTime"]!= nil) {
        _activity_model.activityTime = data[@"activityTime"];
    }
    else
    {
        _activity_model.activityTime = [NSString stringWithFormat:@"%ld:00", (long)[data[@"activityTimeStart"] integerValue]];
    }
    
    _activity_model.address = data[@"address"];
    _activity_model.title = data[@"title"];
    _activity_model.groupId = [NSString stringWithFormat:@"%@", data[@"groupId"]];
    
    if (![data[@"position"] isKindOfClass:[NSNull class]]) {
        _activity_model.position = data[@"position"];
    }
    
    _activity_model.type = [data[@"type"] integerValue];
    _activity_model.attendCount = [data[@"attendCount"] integerValue];
    if (![data[@"postId"] isKindOfClass:[NSNull class]] && data[@"postId"] != nil) {
        _activity_model.postId = [NSString stringWithFormat:@"%@", data[@"postId"]];
    }
    
    Account *accountModel = [[Account alloc] init];
    NSDictionary *dic = data[@"promoteAccount"];
    accountModel.headImg = dic[@"headImg"];
    accountModel.nickName = dic[@"nickName"];
    accountModel.accountId = [NSString stringWithFormat:@"%@", dic[@"id"]];
    _activity_model.promoteAccount = accountModel;
    
    if (![data[@"imgUrl"] isKindOfClass:[NSNull class]]) {
        _activity_model.imgUrl = data[@"imgUrl"];
    }
    
    if ([data[@"attendList"] count]) {
        for (int i = 0; i < [data[@"attendList"] count]; i++) {
            NSDictionary *dict = data[@"attendList"][i];
            SelectFriendsModel *model = [[SelectFriendsModel alloc] init];
            
            NSString *attendUserId = [NSString stringWithFormat:@"%@", dict[@"attendUserId"]];
            
            NSString *name = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:attendUserId];
            if (!name) {
                name = dict[@"attendUserName"];
            }
            
            model.accountId = attendUserId;
            model.name = name;
            if (![dict[@"attendUserImg"] isKindOfClass:[NSNull class]]) {
                model.img_url = dict[@"attendUserImg"];
            }
            model.fromInfo = [dict[@"fromInfo"] integerValue];
            [_activity_model.attendList addObject:model];
        }
    }
    
}

#pragma mark - 杂项功能
- (void)showImage:(UIImageView *)avatar img_url:(NSString *)img_url
{
    //set tag
    [avatar sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

//发帖人头像点击
-(void)ImageTap:(UITapGestureRecognizer *)tap
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    
    vc.friend_id = _activity_model.promoteAccount.accountId;
    vc.friend_name = _activity_model.promoteAccount.nickName;
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showBigImage
{
    if (![_activity_model.imgUrl length]) {
        _based_view_height.constant = 47 + 4 + 74 + 8 + 50 + 30;
        _ratio_wh.constant = [UIScreen mainScreen].bounds.size.width - 8*2;
        return;
    }
    else
    {
        _based_view_height.constant = 47 + 4 + [UIScreen mainScreen].bounds.size.width - 8*2 + 74 + 8 + 50 + 30;
    }
    
    _big_img.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageBigTap:)];
    [_big_img addGestureRecognizer:tapImage];
    
    //set tag
    [_big_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_activity_model.imgUrl sizeSuffix:SIZE_SUFFIX_600X600] placeholderImage:[UIImage imageNamed:@"tupian"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         
     }];
}

#pragma mark - 按钮功能
- (void)gotoPost
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PostViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];
    viewController.postId = _activity_model.postId;
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)gotoPosition:(UIButton *)btn
{
    FreeMapViewController *vc = [[FreeMapViewController alloc] initWithNibName:@"FreeMapViewController" bundle:nil];
    
    CLLocationCoordinate2D location;
    if (!_activity_model.position) {
        [KVNProgress showErrorWithStatus:@"该位置异常"];
        return;
    }
    NSArray *arrayPosition = [_activity_model.position componentsSeparatedByString:@"-"];
    location.latitude = [arrayPosition[0] floatValue];
    location.longitude = [arrayPosition[1] floatValue];
    vc.location = location;
    vc.locationName =  _activity_model.address;
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
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
    __weak ActivityInfoViewController *weakSelf = self;
    
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
                [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_GROUP targetId:_activity_model.groupId];
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
    __weak ActivityInfoViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"];
    NSInteger ret = [[FreeSingleton sharedInstance] exitActiveOnCompletion:_activityId block:^(NSUInteger retcode, id data) {
        [KVNProgress dismiss];
        if(retcode == RET_SERVER_SUCC)
        {
            //退出群聊
            [weakSelf exitGroup];
            for (int i = 0; i < [_activity_model.attendList count]; i++) {
                SelectFriendsModel *model = _activity_model.attendList[i];
                NSString *str = [NSString stringWithFormat:@"%@",model.accountId];
                NSString *str2 = [NSString stringWithFormat:@"%@",[[FreeSingleton sharedInstance] getAccountId]];
                if ([str isEqualToString:str2]) {
                    [_activity_model.attendList removeObjectAtIndex:i];
                }
            }
            
            if (_type == ALREADY_ATTEND) {
                _type = NORMAL;
            }
            else
            {
                _type = NOT_ATTEND;//更改类型
            }
            _activity_model.type = NOT_ATTEND;
            [weakSelf initFriendsView];
            [weakSelf initBottomView];
            _alreadyAttend = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showSuccessWithStatus:@"您已经退出该活动" onView:weakSelf.view.window];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showSuccessWithStatus:@"退出活动失败" onView:weakSelf.view.window];
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
    
    __weak ActivityInfoViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"];
    NSInteger ret = [[FreeSingleton sharedInstance] attendActiveOnCompletion:_activityId block:^(NSUInteger retcode, id data) {
        if(retcode == RET_SERVER_SUCC)
        {
            weakSelf.alreadyAttend = YES;
            
            NSString *str = [[FreeSingleton sharedInstance] getHeadImage];
            if (![str length]) {
                str = @"";
            }
            
            SelectFriendsModel *model = [[SelectFriendsModel alloc] init];
            model.img_url = str;
            model.name = [[FreeSingleton sharedInstance] getNickName];
            model.accountId = [[FreeSingleton sharedInstance] getAccountId];
            
            [_activity_model.attendList insertObject:model atIndex:0];
            [[FreeSingleton sharedInstance] joinGroupOnCompletion:_activity_model.groupId block:^(NSUInteger ret, id data) {
                if(ret == RET_SERVER_SUCC)
                {
                    [[RCIMClient sharedRCIMClient] joinGroup:_activity_model.groupId groupName:nil success:^{
                        [KVNProgress dismiss];
                        NSLog(@"加入群组成功");
                        _activity_model.type = ALREADY_ATTEND;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf initFriendsView];
                            [weakSelf initBottomView];
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
    [[FreeSingleton sharedInstance] quitGroupOnCompletion:_activity_model.groupId block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            [[RCIMClient sharedRCIMClient] quitGroup:_activity_model.groupId success:^{
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
    __weak ActivityInfoViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] joinGroupOnCompletion:_activity_model.groupId block:^(NSUInteger ret, id data) {
        if(ret == RET_SERVER_SUCC)
        {
            [[FreeSingleton sharedInstance] joinGroupOnCompletion:_activity_model.groupId block:^(NSUInteger ret, id data) {
                [KVNProgress dismiss];
                if (ret == RET_SERVER_SUCC) {
                    NSLog(@"加入群组成功");
                    [[FreeSingleton sharedInstance] syncGroups:^(NSUInteger ret, id data) {
                    }];
                    
                    RCDChatViewController *_conversationVC = [[RCDChatViewController alloc]init];
                    _conversationVC.conversationType = ConversationType_GROUP;
                    _conversationVC.targetId = _activity_model.groupId;
                    _conversationVC.userName = _label_name.text;
                    _conversationVC.title = _activity_model.title;
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

/**
 *  实现分享界面
 *
 *  @param buttonItem buttonItem description
 */
-(void)rightItemShare:(UIBarButtonItem *)buttonItem
{
    if (!_backgroundview) {
        _backgroundview = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backgroundview.backgroundColor = [UIColor colorWithRed:190/255.0 green:190/255.0  blue:190/255.0  alpha:.3];
        //分享页面remove
        UITapGestureRecognizer *tapRemove = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
        [_backgroundview addGestureRecognizer:tapRemove];
    }
    
    if (!_sharejoinView) {
        _sharejoinView=[[[NSBundle mainBundle] loadNibNamed:@"ShareWebView" owner:self options:nil]objectAtIndex:0 ];
        
        _sharejoinView.translatesAutoresizingMaskIntoConstraints = NO;
        [_sharejoinView.QButton addTarget:self action:@selector(QQshare) forControlEvents:UIControlEventTouchUpInside];//qq分享
        [_sharejoinView.QoButton addTarget:self action:@selector(QoneShare) forControlEvents:UIControlEventTouchUpInside];//空间分享
        [_sharejoinView.WXbutton addTarget:self action:@selector(weixinShare) forControlEvents:UIControlEventTouchUpInside];//微信分享
        [_sharejoinView.WXFbutton addTarget:self action:@selector(friendShare) forControlEvents:UIControlEventTouchUpInside];//朋友圈分享
        [_sharejoinView.SinButton addTarget:self action:@selector(SinaList) forControlEvents:UIControlEventTouchUpInside];//新浪分享
        [_sharejoinView.btn_refresh addTarget:self action:@selector(inviteFriends) forControlEvents:UIControlEventTouchUpInside];//刷新
        [_sharejoinView.btn_refresh setImage:[UIImage imageNamed:@"icon_invite_friends"] forState:UIControlStateNormal];
        _sharejoinView.label_title.text = @"从以下渠道邀请好友";
        _sharejoinView.label_refresh.text = @"邀请好友";
        _sharejoinView.label_height.constant = 18.f;
        _sharejoinView.report_view.hidden = YES;
        _sharejoinView.view_copy.hidden = YES;
    }
    
    [[AppDelegate getMainWindow] addSubview:_backgroundview];
    
    [_backgroundview addSubview:_sharejoinView];
    
    
    NSDictionary *metrics = @{
                              @"widthe" : @0,
                              @"heightd" : @0
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(_sharejoinView);
    [_backgroundview addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:[_sharejoinView(208)]-0-|"
      options:0
      metrics:metrics
      views:views]];
    
    [_backgroundview addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:
                                     @"H:|-widthe-[_sharejoinView]-widthe-|"
                                     options:0
                                     metrics:metrics
                                     views:views]];
    [self fadeIn];
}
/**
 *  qq分享
 */
-(void)QQshare
{
    if (![QQApiInterface isQQInstalled]) {
        [Utils warningUser:self msg:@"请先安装手机QQ"];
        return;
    }
    [self allSharePort:UMShareToQQ];
}
/**
 *  空间分享
 */
-(void)QoneShare
{
    if (![QQApiInterface isQQInstalled]) {
        [Utils warningUser:self msg:@"请先安装手机QQ"];
        return;
    }
    [self allSharePort:UMShareToQzone];
}
/**
 *  微信分享
 */
-(void)weixinShare
{
    [self allSharePort:UMShareToWechatSession];
}
/**
 *  朋友圈分享
 */
-(void)friendShare
{
    [self allSharePort:UMShareToWechatTimeline];
}

-(void)btn_report_Tapped
{
    [_backgroundview removeFromSuperview];
    [_sharejoinView removeFromSuperview];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"IdeaFeedbackViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  新浪分享
 */
-(void)SinaList
{
    [_backgroundview removeFromSuperview];
    [_sharejoinView removeFromSuperview];
    
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    NSString *str1 = @"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxef49c97a732015c0&redirect_uri=http%3a%2f%2fwww.duanzigou.com%2ffreeweb%2fapp%2f%23%2fpostdetail%2f";
    NSString *str2 = @"&response_type=code&scope=snsapi_userinfo&state=1#wechat_redirect";
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@%@%@", _activity_model.title, str1, _activity_model.activityId, str2];
    
    UIImage *img = [UIImage imageNamed:@"glass"];
    if (_activity_model.imgUrl) {
        img = _big_img.image;
    }
    [[UMSocialControllerService defaultControllerService] setShareText:strUrl shareImage:img socialUIDelegate:self];
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
    
}
//实现回调方法（可选）：
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        UIAlertView *alerView =[[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alerView.delegate = self;
        [alerView show];
    }
    else
    {
        UIAlertView *alerViews=[[UIAlertView alloc] initWithTitle:@"分享失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alerViews.delegate = self;
        [alerViews show];
    }
    
}
/**
 *  总体分享接口事件
 *
 *  @return
 */
-(void)allSharePort:(NSString *)shareName
{
    [UMSocialData defaultData].extConfig.qqData.title = _activity_model.title;//QQ分享title
    [UMSocialData defaultData].extConfig.qzoneData.title = _activity_model.title;//QQ空间title
    //微信好友title
    [UMSocialData defaultData].extConfig.wechatSessionData.title = _activity_model.title;
    //微信朋友圈title
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = _activity_model.title;
    
    NSString *str1 = @"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxef49c97a732015c0&redirect_uri=http%3a%2f%2fwww.duanzigou.com%2ffreeweb%2fapp%2f%23%2fpostdetail%2f";
    NSString *str2 = @"&response_type=code&scope=snsapi_userinfo&state=1#wechat_redirect";
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@%@", str1, _activity_model.activityId,str2];
    
    NSString *qqStrUrl = @"http://www.duanzigou.com/GetToken.html?activityId=";
    NSString *qqAllStrUrl = [NSString stringWithFormat:@"%@%@",qqStrUrl,_activity_model.activityId];
    
    //QQ分享
    [UMSocialQQHandler setQQWithAppId:@"1104634036" appKey:@"Qy4htxEyREjy5RQm" url:qqAllStrUrl];
    //微信分享
    [UMSocialWechatHandler setWXAppId:@"wx978df91e43d81d2f" appSecret:@"eb69505c0114cf45c0079943609922ef" url:strUrl];
    
    //    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:
    //                                        @"http://www.baidu.com/img/bdlogo.gif"];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    
    UIImage *img = [UIImage imageNamed:@"glass"];
    if (_activity_model.imgUrl) {
        img = _big_img.image;
    }
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[shareName] content:_activity_model.activityContent image:img location:nil urlResource:nil
                                            presentedController:nil completion:^(UMSocialResponseEntity *response){
                                                if (response.responseCode == UMSResponseCodeSuccess)
                                                {
                                                    UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                                    alerView.delegate = self;
                                                    [alerView show];
                                                }
                                                else
                                                {
                                                    UIAlertView *alerViews=[[UIAlertView alloc] initWithTitle:@"分享失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                                    alerViews.delegate=self;
                                                    [alerViews show];
                                                }
                                            }];
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [_backgroundview removeFromSuperview];
        [_sharejoinView removeFromSuperview];
    }
}

/**
 *  动画划出
 */
- (void)fadeIn
{
    _sharejoinView.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _sharejoinView.frame.size.width, _sharejoinView.frame.size.height);
    
    [UIView animateWithDuration:.1 animations:^{
        _sharejoinView.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height- _sharejoinView.frame.size.height, _sharejoinView.frame.size.width, _sharejoinView.frame.size.height);
    }];
}
/**
 *  动画关闭
 *
 *  @param gureView
 */
-(void)tapChange:(UITapGestureRecognizer *)gureView
{
    
    [UIView animateWithDuration:.2 animations:^{
        _sharejoinView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _sharejoinView.frame.size.width, _sharejoinView.frame.size.height);
    } completion:^(BOOL finished) {
        [_sharejoinView removeFromSuperview];
        [_backgroundview removeFromSuperview];
    }];
    
    
}

#pragma makr - 邀请好友
- (void)inviteFriends
{
    [_sharejoinView removeFromSuperview];
    [_backgroundview removeFromSuperview];
    
    if (!_friendsArray) {
        [KVNProgress showWithStatus:@"Loading"];
        __weak ActivityInfoViewController *weakSelf = self;
        [[FreeSingleton sharedInstance] getMyFansListOnCompletion:^(NSUInteger ret, id data) {
            [KVNProgress dismiss];
            if (ret == RET_SERVER_SUCC) {
                if ([data count]) {
                    [weakSelf add2Model:data];
                }
            }
            else
            {
                [KVNProgress showErrorWithStatus:data];
            }
        }];
    }
    else
    {
        ActivityInviteFriendsTableViewController *vc = [[ActivityInviteFriendsTableViewController alloc] initWithNibName:@"ActivityInviteFriendsTableViewController" bundle:nil];
        vc.activity_Id = _activity_model.activityId;
        vc.modelArray = _friendsArray;
        UINavigationController *nav = [[UINavigationController alloc]
                                       initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)add2Model:(id)dataSource
{
    _friendsArray = [NSMutableArray array];
    
    for (int i = 0; i < [dataSource count]; i++) {
        SelectFriendsModel *model = [[SelectFriendsModel alloc] init];
        model.img_url = dataSource[i][@"headImg"];
        model.name = dataSource[i][@"friendName"];
        model.accountId = [NSString stringWithFormat:@"%@", dataSource[i][@"friendAccountId"]];
        model.status = [dataSource[i][@"status"] integerValue];
        model.isSelected = NO;
        
        if (![dataSource[i][@"pinyin"] isKindOfClass:[NSNull class]]) {
            model.pinyin = dataSource[i][@"pinyin"];
        }
        else
        {
            NSString *pinyin = [model.name mutableCopy];
            CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformMandarinLatin,NO);
            //再转换为不带声调的拼音
            CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformStripDiacritics,NO);
            model.pinyin = pinyin;
        }
        
        [_friendsArray addObject:model];
    }
    
    ActivityInviteFriendsTableViewController *vc = [[ActivityInviteFriendsTableViewController alloc] initWithNibName:@"ActivityInviteFriendsTableViewController" bundle:nil];
    vc.activity_Id = _activity_model.activityId;
    vc.modelArray = _friendsArray;
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - 显示大图
//显示大图
- (void)ImageBigTap:(UITapGestureRecognizer *)gesture {
    
    UIImageView *imgView = (UIImageView *)gesture.view;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;//防止看大图时手势滑动引起的bug
    _scrollviewed = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height)];
    
    self.scrollviewed.backgroundColor = [UIColor blackColor];
    [self.navigationController.view addSubview:self.scrollviewed];
    self.scrollviewed.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapped:)];
    _scrollviewed.tag = imgView.tag;
    [self.scrollviewed addGestureRecognizer:tapGes];
    
    NSString* url = _activity_model.imgUrl;
    
    NSInteger height = 300;
    NSInteger width = 300;
    //直接附图片  holder是图片的大小
    if (width > self.scrollviewed.frame.size.width) {
        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width-width)/2, (self.scrollviewed.frame.size.height - height)/2, self.scrollviewed.bounds.size.width,height*(self.scrollviewed.bounds.size.width/width))];
        self.scrollviewed.contentSize=CGSizeMake(self.scrollviewed.bounds.size.width,height*(self.scrollviewed.bounds.size.width/width));
    }
    else if(height > self.scrollviewed.bounds.size.height)
    {
        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width - width)/2, (self.scrollviewed.frame.size.height - height)/2, width*(self.scrollviewed.bounds.size.height/height),height)];
        self.scrollviewed.contentSize=CGSizeMake(width*(self.scrollviewed.bounds.size.height/height),height);
    }
    else
    {
        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width - width)/2, (self.scrollviewed.frame.size.height - height)/2, width, height)];
        
        self.scrollviewed.contentSize = CGSizeMake(width, height);
    }
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.scrollviewed animated:YES];
    [self.holder sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         if (iamgeUrl == nil) {
             [_holder setImage:[UIImage imageNamed:@"tupian"]];
         }
         [Utils hideHUD:hud];
     }];
    
    // 等比例缩放
    self.holder.center = self.view.center;
    float scalex= self.view.frame.size.width/self.holder.frame.size.width;
    float scaley= self.view.frame.size.height/self.holder.frame.size.height;
    //最小的范围
    float scale = MIN(scalex, scaley);
    self.holder.transform=CGAffineTransformMakeScale(scale, scale);
    self.holder.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollviewed.delegate = self;
    self.scrollviewed.maximumZoomScale=3.0;
    self.scrollviewed.minimumZoomScale=1.0;
    [self.scrollviewed addSubview:self.holder];
    
    //实例化长按手势监听
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleImgLongPressed:)];
    //代理
    longPress.delegate = self;
    longPress.minimumPressDuration = 1.0;
    //将长按手势添加到需要实现长按操作的视图里
    [self.scrollviewed addGestureRecognizer:longPress];
}

- (void) bgTapped:(UITapGestureRecognizer *)gesture{
    UIView *view = gesture.view;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [view removeFromSuperview];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.holder;
}
//缩小时图片居中显示
- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
    CGFloat offsetX = (self.scrollviewed.bounds.size.width > self.scrollviewed.contentSize.width)?
    (self.scrollviewed.bounds.size.width - self.scrollviewed.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.scrollviewed.bounds.size.height > self.scrollviewed.contentSize.height)?
    (self.scrollviewed.bounds.size.height - self.scrollviewed.contentSize.height) * 0.5 : 0.0;
    self.holder.center = CGPointMake(self.scrollviewed.contentSize.width * 0.5 + offsetX,
                                     self.scrollviewed.contentSize.height * 0.5 + offsetY);
}

//长按事件
- (void)handleImgLongPressed:(UILongPressGestureRecognizer *)gesture
{
    UIScrollView *scroll_View = (UIScrollView *)gesture.view;
    if (_activity_model.imgUrl && gesture.state == UIGestureRecognizerStateBegan) {
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机相册", nil];
        sheet.tag = scroll_View.tag;
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

// 功能：保存图片到手机
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.numberOfButtons - 1 == buttonIndex) {
        return;
    }
    NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"保存到手机相册"]) {
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_activity_model.imgUrl]];
        UIImage* image = [UIImage imageWithData:data];
        
        //UIImageWriteToSavedPhotosAlbum(image, nil, nil,nil);
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

// 功能：显示对话框
-(void)showAlert:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@""
                          message:msg
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles: nil];
    [alert show];
}

// 功能：显示图片保存结果
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error){
        [self showAlert:@"保存失败..."];
    }else {
        [self showAlert:@"图片保存成功！"];
    }
}

@end
