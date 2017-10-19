//
//  inviteCodeViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/22.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "inviteCodeViewController.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "convertMyCodeViewController.h"
#import "FreeSingleton.h"
#import "Base64codeFunc.h"
#import "ShareInterfaceView.h"
#import "PointsViewController.h"
#import "inviteCodeDetailViewController.h"

#define PROGRESS_WIDTH 50

@interface inviteCodeViewController ()<UMSocialUIDelegate>
@property (weak, nonatomic) IBOutlet UIView *invite_view;

@property (weak, nonatomic) IBOutlet UIButton *btn_detail;
@property (weak, nonatomic) IBOutlet UITextView *label_inviteCode;
@property (weak, nonatomic) IBOutlet UILabel *label_inviteNum;
@property (weak, nonatomic) IBOutlet UIButton *btn_market;
@property (weak, nonatomic) IBOutlet UIButton *btn_invite;
@property (weak, nonatomic) IBOutlet UILabel *label_invite;
@property (weak, nonatomic) IBOutlet UIView *progress_view;
@property (weak, nonatomic) IBOutlet UIView *track_view;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progress_length;

@property (nonatomic,strong) UIView *background;
@property (nonatomic, strong) ShareInterfaceView *shareview;
@property (nonatomic, assign)BOOL changeNameshare;

@property (nonatomic, assign)NSInteger invitedNum;

@end

@implementation inviteCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
//    if ([[FreeSingleton sharedInstance] getInviteCode] == nil) {
        [KVNProgress showWithStatus:@"Loading"];
        [[FreeSingleton sharedInstance] queryMyInviteCodeOnCompletion:^(NSUInteger ret, id data) {
            [KVNProgress dismiss];
            if (ret == RET_SERVER_SUCC) {
                
                if (![data isKindOfClass:[NSNull class]] && data != nil) {
                    NSArray *array = [data componentsSeparatedByString:@"-"];

                    if ([array count] > 1) {
                        [FreeSingleton sharedInstance].inviteCode = array[0];
                        [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].inviteCode forKey:KEY_INVITE_CODE];
                        _label_inviteCode.text = array[0];
                        
                        _label_inviteNum.text = array[1];
                        _invitedNum = [array[1] integerValue];
                        if ([array[1] integerValue] > 5) {
                            NSString *strNum = [NSString stringWithFormat:@"已成功邀请 %ld 人，继续成功邀请至50人，斩获1000元红包积分。", (long)[array[1] integerValue]];
                            
                            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strNum];
                            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:219/255.0 green:64/255.0 blue:77/255.0 alpha:1.0] range:NSMakeRange(5,[array[1] length])];
                            _progress_length.constant = 5 * PROGRESS_WIDTH;
                            _label_invite.attributedText = str;
                        }
                        else if ([array[1] integerValue] == 5)
                        {
                            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"成功邀请 5 人，100元红包积分已放入你的兑换清单。继续成功邀请至50人，斩获1000元红包积分。"];
                            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:219/255.0 green:64/255.0 blue:77/255.0 alpha:1.0] range:NSMakeRange(5,1)];
                            _label_invite.attributedText = str;
                            _progress_length.constant = 5 * PROGRESS_WIDTH;
                        }
                        else
                        {
                            _progress_length.constant = [array[1] integerValue] * PROGRESS_WIDTH;
                            NSString *strNum = [NSString stringWithFormat:@"再邀请 %ld 人可获得100元的积分红包", (long)(5 - [array[1] integerValue])];
                            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strNum];
                            [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:219/255.0 green:64/255.0 blue:77/255.0 alpha:1.0] range:NSMakeRange(4,1)];
                            _label_invite.attributedText = str;
                        }
                    }
                }
            }
            else
            {
                NSLog(@"%@", data);
            }
        }];
//    }
}

- (void)initView
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    _progress_view.layer.cornerRadius = 5.f;
    _track_view.layer.cornerRadius = 5.f;
    _track_view.layer.masksToBounds = YES;
    
    self.navigationItem.title = @"我的邀请码";
    
    if ([[FreeSingleton sharedInstance] getInviteCode]) {
        _label_inviteCode.text = [[FreeSingleton sharedInstance] getInviteCode];
    }
    
    _btn_invite.layer.cornerRadius = 5.f;
    _btn_invite.layer.masksToBounds = YES;
    [_btn_invite addTarget:self action:@selector(btn_Tappedshare:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteTap:)];
    [_invite_view addGestureRecognizer:tapImage];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [_btn_detail addTarget:self action:@selector(gotoDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_market addTarget:self action:@selector(gotoMarket:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)inviteTap:(UITapGestureRecognizer *)tap
{
    convertMyCodeViewController *vc = [[convertMyCodeViewController alloc] initWithNibName:@"convertMyCodeViewController" bundle:nil];
    
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoDetail:(id)sender
{
    inviteCodeDetailViewController *vc = [[inviteCodeDetailViewController alloc] initWithNibName:@"inviteCodeDetailViewController" bundle:nil];
    vc.inviteNum = _invitedNum;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//分享
- (void)btn_Tappedshare:(id)sender
{
    if ([_background superview]) {
        return;
    }
    
    _changeNameshare = NO;
    
    _background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _background.backgroundColor=[UIColor colorWithRed:190/255.0 green:190/255.0  blue:190/255.0  alpha:.3];
    [[AppDelegate getMainWindow] addSubview:_background];
    
    UITapGestureRecognizer *tapView =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
    [_background addGestureRecognizer:tapView];
    _shareview = [[[NSBundle mainBundle] loadNibNamed:@"ShareInterfaceView"
                                                owner:self
                                              options:nil] objectAtIndex:0];
    _shareview.translatesAutoresizingMaskIntoConstraints = NO;
    [_background addSubview:_shareview];
    NSDictionary *metrics = @{
                              @"widthe" : @0,
                              @"heightd" : @0
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(_shareview);
    [_background addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:[_shareview(190)]-0-|"
      options:0
      metrics:metrics
      views:views]];
    
    [_background addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:
                                 @"H:|-widthe-[_shareview]-widthe-|"
                                 options:0
                                 metrics:metrics
                                 views:views]];
    [self fadeIn];
    [_shareview.QQButton addTarget:self action:@selector(QQshare) forControlEvents:UIControlEventTouchDown];//qq分享
    [_shareview.QQqone addTarget:self action:@selector(QoneShare) forControlEvents:UIControlEventTouchDown];//空间分享
    [_shareview.weixinButton addTarget:self action:@selector(weixinShare) forControlEvents:UIControlEventTouchDown];//微信分享
    [_shareview.FriendButton addTarget:self action:@selector(friendShare) forControlEvents:UIControlEventTouchDown];//朋友圈分享
    [_shareview.sinaButton addTarget:self action:@selector(SinaList) forControlEvents:UIControlEventTouchDown];//新浪分享
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [_label_inviteCode resignFirstResponder];
}

#pragma mark - 去往商城
- (void)gotoMarket:(id)sender
{
    PointsViewController *vc = [[PointsViewController alloc] initWithNibName:@"PointsViewController" bundle:nil];
    
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 分享
/**
 *  动画划出
 */
- (void)fadeIn
{
    _shareview.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _shareview.frame.size.width, _shareview.frame.size.height);
    
    [UIView animateWithDuration:.1 animations:^{
        _shareview.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height- _shareview.frame.size.height, _shareview.frame.size.width, _shareview.frame.size.height);
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
        _shareview.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _shareview.frame.size.width, _shareview.frame.size.height);
    } completion:^(BOOL finished) {
        [_background removeFromSuperview];
        [_shareview removeFromSuperview];
    }];
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


/**
 *  新浪分享
 */
-(void)SinaList
{
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    NSString *SinaShare = [NSString stringWithFormat:@"@谁有空应用 不约而同分享身边的吃喝玩乐！更多免费电影票美食卷等你拿！用我的邀请码%@注册谁有空，你我各获5元代金卷", _label_inviteCode.text];
    
//    NSString *SinaTitle = @"@谁有空应用 不约而同，分享身边的吃喝玩乐！更多免费电影票，美食代金卷等你来拿！用我的邀请码XXXXXX 注册谁有空，你我各获5元红包~";
    NSString *SinaTail = @"http://www.rufree.cn/share/invite.html?inviteCode=";
    
    NSString *headImgurl = [Base64codeFunc base64StringFromText:[[FreeSingleton sharedInstance] getHeadImage]];
    
    NSString *SinaHeadUrl = [NSString stringWithFormat:@"&headImg=%@", headImgurl];
    
    NSString *SinaUrl = [NSString stringWithFormat:@"%@%@%@", SinaTail, [[FreeSingleton sharedInstance] getInviteCode], SinaHeadUrl];
    
    NSString *SinaContent = [NSString stringWithFormat:@"%@%@", SinaShare, SinaUrl];
    [[UMSocialControllerService defaultControllerService] setShareText:SinaContent shareImage:[UIImage imageNamed:@"icon_weibohongbao"] socialUIDelegate:self];
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
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
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
    [UMSocialData defaultData].extConfig.qqData.title = @"5元请收下！你有我才有";//QQ分享title
    [UMSocialData defaultData].extConfig.qzoneData.title = @"5元请收下！你有我才有";//QQ空间title
    //微信好友title
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"5元请收下！你有我才有";
    //微信朋友圈title
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"5元请收下！你有我才有";
    
    NSString *headImgurl = [Base64codeFunc base64StringFromText:[[FreeSingleton sharedInstance] getHeadImage]];
    
    NSString *url;
    if ([[FreeSingleton sharedInstance] getHeadImage]) {
        headImgurl = [NSString stringWithFormat:@"&headImg=%@", headImgurl];
        url = [NSString stringWithFormat:@"%@%@%@", @"http://www.rufree.cn/share/invite.html?inviteCode=", [[FreeSingleton sharedInstance] getInviteCode], headImgurl];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@%@", @"http://www.rufree.cn/share/invite.html?inviteCode=", [[FreeSingleton sharedInstance] getInviteCode]];
    }
    
    //QQ分享
    [UMSocialQQHandler setQQWithAppId:@"1104634036" appKey:@"Qy4htxEyREjy5RQm" url:url];
    //微信分享
    [UMSocialWechatHandler setWXAppId:@"wx978df91e43d81d2f" appSecret:@"eb69505c0114cf45c0079943609922ef" url:url];
    
    //    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:
    //                                        @"http://www.baidu.com/img/bdlogo.gif"];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[shareName] content:@"召唤5个小伙伴，送你100元抵金券！" image:[UIImage imageNamed:@"icon_hongbao"] location:nil urlResource:nil
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

@end
