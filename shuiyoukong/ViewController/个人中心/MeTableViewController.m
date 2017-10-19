//
//  MeTableViewController.m
//  Free
//
//  Created by yangcong on 15/5/5.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MeTableViewController.h"
#import "MyCentreModel.h"
#import "MyCentreTableViewCell.h"
#import "FreeSingleton.h"
#import "Error.h"
#import "HeadTableViewCell.h"
#import "HeadCellModel.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "AppDelegate.h"
#import "ShareInterfaceView.h"
#import "UMSocial.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utils.h"
#import "InterfaceImageView.h"
#import "MBProgressHUD.h"
#import "PointsViewController.h"
#import "MyPostViewController.h"
#import "MyInfoTableViewController.h"
#import "FriendsListTableViewCell.h"
#import "RCDChatViewController.h"
#import "inviteCodeViewController.h"
#import "ThridInviteCodeViewController.h"

@interface MeTableViewController ()<UMSocialUIDelegate>
{
    NSString *img;
    NSString *flowerName;
    NSString *nickName;
    NSString *effect;
    NSString *status;
    BOOL isNeedWaring;
}

@property (nonatomic, weak) NSString *identifier;
@property (nonatomic, weak) NSString *headidentifer;
@property (nonatomic, weak) NSString *care_identifier;
@property (nonatomic, strong) ShareInterfaceView *shareview;
@end

@implementation MeTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerHeadImgChanged];
        [self registerNotificationForNewFans];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    self.tabBarController.tabBar.hidden = NO;
}

-(void)initView
{
    _identifier = @"MyCentreTableViewCell";
    _headidentifer = @"HeadTableViewCell";
    _care_identifier = @"FriendsListTableViewCell";
    
//   self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
//    
//    UIColor *color = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202.0/255.0 alpha:1];
//    NSDictionary *dic = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
//    self.navigationController.navigationBar.titleTextAttributes = dic ;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    [self.tableView registerNib:[UINib nibWithNibName:_care_identifier bundle:nil] forCellReuseIdentifier:_care_identifier];
    [self.tableView registerNib:[UINib nibWithNibName:_headidentifer bundle:nil] forCellReuseIdentifier:_headidentifer];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 12)];
    headerView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    self.tableView.tableHeaderView = headerView;
   // self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1.0f;
    }
    else if (section == 4)
    {
        return 12.0f;
    }
    else
    {
        return 12.0f;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 4;
            break;
            
        case 3:
            return 2;
            break;
        case 4:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 80.0;
            break;
        case 1:
        case 2:
        case 3:
        case 4:
            return 50.0;
            break;
            
        default:
            return 0;
            break;
    }
  
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 0)];
        
    }
    
}
#pragma  mark-每个cell显示样式
/**
 *  每个cell显示
 *
 *  @param tableView
 *  @param indexPath
 *
 *  @return cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section)
    {
        case 0:
        {
            HeadTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_headidentifer forIndexPath:indexPath];
            if (!cell)
            {
                cell = [[HeadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_headidentifer];
            }
      
            if ([[FreeSingleton sharedInstance]getNickName]) {
                
                HeadCellModel *headModel = [[HeadCellModel alloc] init];
                
               [self showImage:cell.headImage withUrl:[[FreeSingleton sharedInstance] getHeadImage]];
                
                headModel.headName = [[FreeSingleton sharedInstance] getNickName];
                
                cell.headCell = headModel;
            }
            return cell;
        }
            break;
        case 1:
        {
            FriendsListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_care_identifier forIndexPath:indexPath];
            if (!cell)
            {
                cell = [[FriendsListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_care_identifier];
            }
            cell.vc = self;
            cell.left_red_point.hidden = YES;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_IF_HAS_NEW_FRIENDS]) {
                cell.right_red_point.hidden = NO;
            }
            else
            {
                cell.right_red_point.hidden = YES;
            }
            cell.my_cared_num.text = [[FreeSingleton sharedInstance] getMyFollowedNum];
            cell.care_me_num.text = [[FreeSingleton sharedInstance] getMyFollowerNum];
            return cell;
        }
            break;
        case 2:
        {
            MyCentreTableViewCell *cellhold = [self.tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
            if (!cellhold)
            {
                cellhold = [[MyCentreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
            }
            MyCentreModel *modelhold = [[MyCentreModel alloc] init];
            
            switch (indexPath.row) {
                case 0:
                    modelhold.cellName = @"我的推荐";
                    modelhold.cellImages = @"icon_tuijian";
                    break;
                case 1:
                    modelhold.cellName = @"我想去的";
                    modelhold.cellImages = @"icon_xiangqu";
                    break;
                case 2:
                    modelhold.cellName = @"活动";
                    modelhold.cellImages = @"huodong";
                    break;
                default:
                    modelhold.cellName = @"积分商城";
                    modelhold.cellImages = @"mall";
                    break;
            }
            
            cellhold.centreModel = modelhold;
            return cellhold;
            
        }
            break;
         case 3:
        {
            if (indexPath.row == 0) {
                MyCentreTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
                if (!cell)
                {
                    cell = [[MyCentreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
                }
                MyCentreModel *model1 = [[MyCentreModel alloc] init];
                model1.cellName = @"分享";
                model1.cellImages = @"share";
                cell.centreModel = model1;
                return cell;
            }
            else
            {
                MyCentreTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
                if (!cell)
                {
                    cell = [[MyCentreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
                }
                MyCentreModel *model1 = [[MyCentreModel alloc] init];
                model1.cellName = @"我的邀请码";
                model1.cellImages = @"icon_inviteCode";
                cell.centreModel = model1;
                return cell;
            }
        }
            break;
        default:
        {
            if (indexPath.row == 0)
            {
                
                MyCentreTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
                MyCentreModel *model2 = [[MyCentreModel alloc] init];
                if (!cell)
                {
                    cell = [[MyCentreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
                }
                model2.cellName = @"设置";
                model2.cellImages = @"setup";
                cell.centreModel = model2;
                
                return cell;
            }
            else
            {
                MyCentreTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
                if (!cell)
                {
                    cell = [[MyCentreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
                }
                MyCentreModel *model4 = [[MyCentreModel alloc] init];
                model4.cellName = @"意见反馈";
                model4.cellImages = @"idea";
                cell.centreModel = model4;
                return cell;
            }
        }
            break;
    }
}


#pragma mark - 每行触发的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
      [self performSegueWithIdentifier:@"MyInfoTableViewController" sender:self];
    }
    else if (indexPath.section == 2)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                MyPostViewController *vc = [[MyPostViewController alloc] initWithNibName:@"MyPostViewController" bundle:nil];
                vc.isMyPost = YES;
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:
            {
                MyPostViewController *vc = [[MyPostViewController alloc] initWithNibName:@"MyPostViewController" bundle:nil];
                vc.isMyPost = NO;
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
            {
                [self performSegueWithIdentifier:@"checkFriendsListSeg" sender:nil];
            }
                break;
            default:
            {
                PointsViewController *game = [[PointsViewController alloc] initWithNibName:@"PointsViewController" bundle:nil];
                
                game.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:game animated:YES];
            }
                break;
        }
    }
    else if (indexPath.section == 3)
    {
        if (indexPath.row == 0) {
            _background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            _background.backgroundColor=[UIColor colorWithRed:190/255.0 green:190/255.0  blue:190/255.0  alpha:.3];
            
            
            //加入点击手势remove分享界面
            UITapGestureRecognizer *tapView=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
            [_background addGestureRecognizer:tapView];
            _shareview = [[[NSBundle mainBundle] loadNibNamed:@"ShareInterfaceView"
                                                        owner:self
                                                      options:nil] objectAtIndex:0];
            _shareview.translatesAutoresizingMaskIntoConstraints = NO;
            [[AppDelegate getMainWindow] addSubview:_background];
            [_background addSubview:_shareview];
            NSDictionary *metrics = @{
                                      @"widthe" : @0,
                                      @"heightd" : @0
                                      };
            NSDictionary *views = NSDictionaryOfVariableBindings(_shareview);
            [_background addConstraints:
             [NSLayoutConstraint
              constraintsWithVisualFormat:@"V:[_shareview(175)]-0-|"
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
        else
        {
            if ([[FreeSingleton sharedInstance] getPhoneNo] && [[FreeSingleton sharedInstance] isMobileNo:[[FreeSingleton sharedInstance] getPhoneNo]]) {
                inviteCodeViewController *vc = [[inviteCodeViewController alloc] initWithNibName:@"inviteCodeViewController" bundle:nil];
                
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                ThridInviteCodeViewController *vc = [[ThridInviteCodeViewController alloc] initWithNibName:@"ThridInviteCodeViewController" bundle:nil];
                
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    else if (indexPath.section == 4)
    {
        switch (indexPath.row)
        {
            case 0:
                
                [self performSegueWithIdentifier:@"setupother" sender:self];
                
                break;
                
            case 1:
            {
                
                RCDChatViewController *chatService = [[RCDChatViewController alloc] init];
                chatService.userName = @"客服";
                chatService.targetId = SERVICE_ID;
                chatService.conversationType = ConversationType_CUSTOMERSERVICE;
                chatService.title = chatService.userName;
                
                //    RCHandShakeMessage* textMsg = [[RCHandShakeMessage alloc] init];
                //    [[RongUIKit sharedKit] sendMessage:ConversationType_CUSTOMERSERVICE targetId:SERVICE_ID content:textMsg delegate:nil];
                //
                chatService.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController :chatService animated:YES];
//                [self performSegueWithIdentifier:@"pushideas" sender:self];
            
            }
                break;
                
            default:
                break;
        }
        
    }
}
/**
 *  动画划出
 */
- (void)fadeIn
{
    _shareview.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _shareview.frame.size.width, _shareview.frame.size.height);

    [UIView animateWithDuration:.1 animations:^{
        _shareview.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height- _shareview.frame.size.height, _shareview.frame.size.width, _shareview.frame.size.height);
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
        [_shareview removeFromSuperview];
        [_background removeFromSuperview];
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
    [_shareview removeFromSuperview];
    
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    [[UMSocialControllerService defaultControllerService] setShareText:@"@谁有空应用 不约而同，轻松参加好友活动，分享身边的吃喝玩乐！这里有更多免费电影票，美食代金卷等你来拿！马上下载谁有空。http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free" shareImage:[UIImage imageNamed:@"weibohaibao"] socialUIDelegate:self];
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
    [UMSocialData defaultData].extConfig.qqData.title = UM_ZC_TITLE;//QQ分享title
    [UMSocialData defaultData].extConfig.qzoneData.title = UM_ZC_TITLE;//QQ空间title
    //微信好友title
    [UMSocialData defaultData].extConfig.wechatSessionData.title = UM_ZC_TITLE;
    //微信朋友圈title
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = UM_ZC_TITLE;
    
    //QQ分享
    [UMSocialQQHandler setQQWithAppId:@"1104634036" appKey:@"Qy4htxEyREjy5RQm" url:@"http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free"];
    //微信分享
    [UMSocialWechatHandler setWXAppId:@"wx978df91e43d81d2f" appSecret:@"eb69505c0114cf45c0079943609922ef" url:@"http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free"];
    
//    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:
//                                        @"http://www.baidu.com/img/bdlogo.gif"];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[shareName] content:UM_SHARE_ME image:[UIImage imageNamed:@"glass"] location:nil urlResource:nil
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


#pragma mark -测试截屏


#pragma mark   获得输入框里的值
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];

    if ([buttonTitle isEqualToString:@"确定"])
    {
        [_shareview removeFromSuperview];
        [_background removeFromSuperview];
    }
    
}

//显示图片
- (void)showImage:(InterfaceImageView *)avatar withUrl:(NSString *)aUrl
{
    avatar.Tag = 1;
    [avatar sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:aUrl sizeSuffix:SIZE_SUFFIX_300X300] placeholderImage:[UIImage imageNamed:@"touxiang"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         
     }];
    
    avatar.imageUrl = aUrl;
}

#pragma  mark-注册通知
- (void)registerHeadImgChanged
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(img_changed:) name:ZC_NOTIFICATION_DID_IMG_CHANGED object:nil];
}

- (void)img_changed:(NSNotification *) notification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

//发送消息
- (void) registerNotificationForNewFans {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFriendsCome:) name:ZC_NOTIFICATION_NEW_FRIENDS object:nil];
}

- (void)newFriendsCome:(NSNotification *) notification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UITableViewController *vc = segue.destinationViewController;
    vc.hidesBottomBarWhenPushed = YES;
}

@end
