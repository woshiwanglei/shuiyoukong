//
//  AppDelegate.m
//  shuiyoukong
//
//  Created by 勇拓 李 on 15/4/28.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "AppDelegate.h"
#import <MAMapKit/MAMapKit.h>
#import "settings.h"
#import "UMessage.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "MobClick.h"
#import "FreeAddressBook.h"
#import "SRWebSocket.h"
#import "ActivityInfoViewController.h"
#import "CoupleSuccTableViewController.h"
#import "FreeTabBarViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "FreeWebViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AMapSearchServices.h"

@interface AppDelegate ()<SRWebSocketDelegate>

@property (strong, nonatomic) SRWebSocket* ws;
@property (nonatomic, retain) NSTimer  *connectTimer;

@end

@implementation AppDelegate

+ (AppDelegate*)getAppDelegate
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}
+ (UIWindow*)getMainWindow
{
    AppDelegate* app = [AppDelegate getAppDelegate];
    return app.window;
    
    //    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    //    return window;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _ws.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RCKitDispatchMessageNotification object:nil];
    [_connectTimer invalidate];
    _connectTimer = nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
            
    //设置通讯录loading
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZC_NOTIFICATION_LOADING];
    //白色状态栏
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSocketTalk:) name:ZC_NOTIFICATION_DID_LOGIN object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage:) name:ZC_NOTIFICATION_SEND_MESSAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveFree:)
                                                 name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveFree:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序
    
    //删除所有本地通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //判断是否是第一次登陆
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    }
    
    //注册重复登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotifyNeedLogin:)
                                                 name:ZC_NOTIFICATION_NEED_LOGIN
                                               object:nil];
    //设置融云
    [self setRongyun];
    
    //注册高德地图
    [MAMapServices sharedServices].apiKey = GAODE_MAP_KEY;
    [AMapSearchServices sharedServices].apiKey = GAODE_MAP_KEY;
    
    //友盟分享
    [UMSocialData setAppKey:UMENG_KEY];
    
    //微信分享
    [UMSocialWechatHandler setWXAppId:@"wx978df91e43d81d2f" appSecret:@"eb69505c0114cf45c0079943609922ef" url:@"http://www.baidu.com"];
    
    //微信好友title
    [UMSocialData defaultData].extConfig.wechatSessionData.title = UM_ZC_TITLE;
    //微信朋友圈title
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = UM_ZC_TITLE;
    
    //QQ分享
    [UMSocialQQHandler setQQWithAppId:@"1104634036" appKey:@"Qy4htxEyREjy5RQm" url:@"http://www.baidu.com"];
    
    [UMSocialData defaultData].extConfig.qqData.title = UM_ZC_TITLE;//QQ分享title
    [UMSocialData defaultData].extConfig.qzoneData.title = UM_ZC_TITLE;//QQ空间title
    //新浪分享
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline]];
    
    //注册友盟
    [MobClick startWithAppkey:UMENG_KEY reportPolicy:BATCH   channelId:@""];
    //禁止前台弹框
    [UMessage setAutoAlert:NO];
    
    //友盟推送
    [UMessage startWithAppkey:UMENG_KEY launchOptions:launchOptions];
    if ([[[UIDevice currentDevice] systemVersion] integerValue] < 8.0)
    {
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert];
    }
    
    //注册通知
    if ([UIDevice currentDevice].systemVersion.doubleValue < 8.0) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil]];
    }
    
    [UMessage setLogEnabled:NO];
    
    if (launchOptions) {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo[@"activityId"] != nil)
        {
            _isComeFromPush = PUSH_ACITITY;
            [[NSUserDefaults standardUserDefaults] setObject:userInfo[@"activityId"] forKey:KEY_ACTIVITY_ID];
        }
        else if (userInfo[@"url"] != nil)
        {
            _isComeFromPush = PUSH_FRIENDS;
            [[NSUserDefaults standardUserDefaults] setObject:userInfo[@"url"] forKey:KEY_BANNER_URL];
            
            if (userInfo[@"imgUrl"] != nil) {
                [[NSUserDefaults standardUserDefaults] setObject:userInfo[@"imgUrl"] forKey:KEY_BANNER_IMGURL];
            }
            
            if (userInfo[@"name"] != nil) {
                [[NSUserDefaults standardUserDefaults] setObject:userInfo[@"name"] forKey:KEY_BANNER_TITLE];
            }
            
            if (userInfo[@"content"] != nil)
            {
                [[NSUserDefaults standardUserDefaults] setObject:userInfo[@"content"] forKey:KEY_BANNER_CONTENT];
            }
        }
    }
    
    //统一导航条样式
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:dic];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:FREE_NAVI_BACKGOURND_COLOR];
//    [[UINavigationBar appearance] setTranslucent:NO];
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        
        [[UINavigationBar appearance] setTranslucent:NO];
    }
//    [[UIBarButtonItem appearance] setTintColor:FREE_BACKGOURND_COLOR];
    
//    UIBarButtonItem *appearance = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    //判断是否不是第一次登录
  if ([self isFirstLaunch])
  {
        [self skipIntroduction];
   }

    if ([self isLogin])
    {
        [self skipLogin];
        //检测通讯录
        [self synAddress];
        [self getUserData];
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];
    
    [self initLaunchScreen];
    
    return YES;
}

#pragma mark 设置loading界面
//设置登录界面
- (void)initLaunchScreen
{
    if ([[NSUserDefaults standardUserDefaults] stringForKey:KEY_APP_LUANCH]) {
        UIView *LaunchView = [[UIView alloc] init];
        LaunchView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:KEY_APP_LUANCH]] placeholderImage:[UIImage imageNamed:@"loginBackground"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
         {
             //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
         }];
        
        [LaunchView addSubview:imageView];
        
        [[AppDelegate getMainWindow] addSubview:LaunchView];
        [[AppDelegate getMainWindow] bringSubviewToFront:LaunchView];
        
        [self performSelector:@selector(delayLuanch:) withObject:LaunchView afterDelay:1.5f];
    }
    
    [[FreeSingleton sharedInstance] getAppLaunchUrl:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            if (data) {
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                
                [manager downloadImageWithURL:[NSURL URLWithString:data] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    
                    NSLog(@"显示当前进度");
                    
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    
                    NSLog(@"下载完成");
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:KEY_APP_LUANCH];
                }];
            }
        }
    }];
}

- (void)delayLuanch:(UIView *)LaunchView
{
//    CABasicAnimation *theAnimation;
//    theAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    theAnimation.duration = 2;
//    theAnimation.fromValue = [NSNumber numberWithFloat:1.0];
//    theAnimation.toValue = [NSNumber numberWithFloat:0.0];
//    [LaunchView.layer addAnimation:theAnimation forKey:@"animateOpacity"];
//    
//    [NSTimer scheduledTimerWithTimeInterval:theAnimation.duration
//                                     target:self
//                                   selector:@selector(removeLun:)
//                                   userInfo:LaunchView
//                                    repeats:NO];
    
    [UIView animateWithDuration:2 animations:^{
        CGAffineTransform newTransform = CGAffineTransformMakeScale(2, 2);
        [LaunchView setTransform:newTransform];
        
        CATransform3D transform = CATransform3DMakeScale(1.5, 1.5, 1.0);
        LaunchView.layer.transform = transform;
        LaunchView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [LaunchView removeFromSuperview];
    }];
}

//- (void)removeLun:(NSTimer *)timer
//{
//    UIView *view = (UIView *)timer.userInfo;
//    view.alpha = 0.f;
//    [view removeFromSuperview];
//}

#pragma mark 启动判断

- (BOOL)isFirstLaunch {
    //判断是否是第一次登陆
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isLogin {
    
    NSString* flag = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_LOGIN_STATUS];
    
    if (!flag || flag.length == 0 || [[FreeSingleton sharedInstance] getRongyunToken].length == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
/**
 *  未登录
 */
- (void)skipIntroduction {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UINavigationController * vc = (UINavigationController *)[sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
    //[vc setModalPresentationStyle:UIModalPresentationFullScreen];
    self.window.rootViewController = vc;
    
//    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
//    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    
//    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//    self.window.rootViewController = viewController;
//    [self.window makeKeyAndVisible];//ChooseLRViewController
}

#pragma mark -改变主window
//- (void) reloadWindow:(NSNotification*) notification {
//    if (!self.window) {
//        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
//    }
//    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    
//    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//    self.window.rootViewController = viewController;
//    
//    [self.window makeKeyAndVisible];
//}

/**
 *  已经登录
 */
-(void)skipLogin {
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HostViewController"];
    
    self.window.rootViewController = viewController;
    
    [self.window makeKeyAndVisible];
    
}

#pragma mark -推送
//推送
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [UMessage registerDeviceToken:deviceToken];
    
    NSString *device_token = [NSString stringWithFormat:@"ios_%@", [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]                  stringByReplacingOccurrencesOfString: @">" withString: @""]                 stringByReplacingOccurrencesOfString: @" " withString: @""]];
    
    NSString *tokenStr = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]                  stringByReplacingOccurrencesOfString: @">" withString: @""]                 stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:tokenStr forKey:RONGYUN_DeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:tokenStr];
    
    [[NSUserDefaults standardUserDefaults] setObject:device_token forKey:KEY_DEVICE_ID];
    [FreeSingleton sharedInstance].deviceID = device_token;
}

//推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([self isLogin])
    {
        if (application.applicationState != UIApplicationStateActive)
        {
            if (userInfo[@"activityId"] != nil) {
                
                ActivityInfoViewController *vc = [[ActivityInfoViewController alloc] initWithNibName:@"ActivityInfoViewController" bundle:nil];
                vc.activityId = userInfo[@"activityId"] ;
                vc.fromTag = COME_FROM_PUSH;
                UINavigationController *nav = [[UINavigationController alloc]
                                               initWithRootViewController:vc];
                    
                [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
                    
                }
            else if (userInfo[@"url"] != nil) {
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                FreeWebViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"FreeWebViewController"];

                viewController.url = userInfo[@"url"];
                if (userInfo[@"name"] != nil)
                {
                    viewController.url_title = userInfo[@"name"];
                }
                
                if (userInfo[@"content"] != nil)
                {
                    viewController.content = userInfo[@"content"];
                }
                if (userInfo[@"imgUrl"] != nil)
                {
                    viewController.imgUrl = userInfo[@"imgUrl"];
                }

                viewController.fromTag = COME_FROM_PUSH;
                UINavigationController *nav = [[UINavigationController alloc]
                                               initWithRootViewController:viewController];
                
                [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
                
            }
        }
        
    [UMessage didReceiveRemoteNotification:userInfo];
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{

    [[UIApplication sharedApplication] cancelLocalNotification:notification];
            
}

//注册用户通知设置
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSString *error_str = [NSString stringWithFormat: @"%@", err];
    NSLog(@"Failed to get token, error:%@", error_str);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                         @(ConversationType_PRIVATE),
                                                                         @(ConversationType_DISCUSSION),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_GROUP)
                                                                         ]];
    application.applicationIconBadgeNumber = unreadMsgCount;
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma 分享回调

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}
//禁止横屏
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - 设置融云
- (void)setRongyun
{
//    NSString *_deviceTokenCache = [[NSUserDefaults standardUserDefaults] objectForKey:RONGYUN_DeviceToken];
    
    //初始化融云SDK
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
//    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY deviceToken:_deviceTokenCache];
    //设置会话列表头像和会话界面头像
    
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    if (iPhone6Plus) {
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(56, 56);
    }else{
        NSLog(@"iPhone6 %d", iPhone6);
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
    }
    
}
#pragma mark - 重复登录处理
-(void) onNotifyNeedLogin:(NSNotification*) notification
{
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
    
    //关闭socket
    [self closeSocket];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UINavigationController * vc = (UINavigationController *)[sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    self.window.rootViewController = vc;
    [[RCIMClient sharedRCIMClient] logout];
    
    if (!notification.object) {
        [self removeUserInfo];
        [KVNProgress showErrorWithStatus:@"您的帐号在别的设备上登录，您被迫下线！" onView:self.window];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SERVICE_FOR_SS_KEYCHAIN_TOKEN];
    }
}

#pragma mark - RCIMConnectionStatusDelegate

/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status
{
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的帐号在别的设备上登录，您被迫下线！" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
//        [alert show];
        //关闭socket
        [self closeSocket];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        self.window.rootViewController = loginVC;
        [[RCIMClient sharedRCIMClient] logout];
        [self removeUserInfo];
        [KVNProgress showErrorWithStatus:@"您的帐号在别的设备上登录，您被迫下线！" onView:self.window];
    }
}


#pragma mark 删除用户消息
- (void)removeUserInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_ACCOUNT_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_NICK_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_USER_STATUS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_HEAD_IMG_URL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_GENDER];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_FOLLOWED_NUM];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_FOLLOWER_NUM];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_INVITE_CODE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_LEVEL];
    
    [FreeSingleton sharedInstance].head_img = nil;
}

#pragma mark -socket
- (void) startSocketTalk:(NSNotification*) notification {
    [self createWS];
}

- (void) createWS {
    if (_ws) {//防止重复连接
        if (_ws.readyState == SR_CLOSED || _ws.readyState == SR_CLOSING) {
            _ws = nil;
        }
        else
        {
            return;
        }
    }
    NSString *token = nil;
    token = [[NSUserDefaults standardUserDefaults] stringForKey:SERVICE_FOR_SS_KEYCHAIN_TOKEN];
    if (token == nil) {
        NSLog(@"token is nil");
        return;
    }
    
    NSString *strUrl = [token stringByReplacingOccurrencesOfString:@"#%#" withString:@"___"];
    
    _ws = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", URL_SOCKET, strUrl]]];
    _ws.delegate = self;
    [_ws open];
}

- (void) webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"socket is stopped reason is %@", reason);
    //    [self createWS];//断开重连
}


- (void) webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"socket err is %@", error);
    if (error.code == 50) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showErrorWithStatus:@"没有网呢~~"];
        });
        return;
    } else if (error.code == 61){
        return;//Connection refused
    }
    [self createWS];//断开重连
}

- (void) webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    NSError *jsonError;
    id data = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                              options:NSJSONReadingMutableContainers
                                                error:&jsonError];
    
    if (jsonError) {
        NSLog(@"%@",jsonError);
    }
    
    
    switch ([data[@"type"] intValue]) {
            //私信
            //新的好友
        case 1:
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IF_HAS_NEW_FRIENDS];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEW_FRIENDS object:nil];//新朋友的小红点
        }
            break;
            //匹配空闲好友
        case 2:
        {
            NSArray *noticeList = data[@"noticeList"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IF_HAS_NEW_NOTICE];//通知中心红点
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEW_NOTICE object:nil];//新通知的小红点
            for (int i = 0; i < [noticeList count]; i++) {
                NSArray* array = [[FreeSingleton sharedInstance] strToJson:noticeList[i][@"jsonObjStr"]];
                double time;
                time = [[NSString stringWithFormat:@"%@",noticeList[i][@"time"]] doubleValue];
                NSDate* date = [NSDate dateWithTimeIntervalSince1970:time/1000.0];
                NSString* strDate = [[FreeSingleton sharedInstance] changeDate2String:date];
                id dataTmp = array;
                [[FreeSQLite sharedInstance] insertFreeSQLiteNoticeList:noticeList[i][@"headImg"] freeDate:dataTmp[@"freeDate"] freeTimeStart:dataTmp[@"freeTimeStart"] sendTime:strDate activityId:@"" type:[NSNumber numberWithInt:2] content:noticeList[i][@"text"]];
                [UIApplication sharedApplication].applicationIconBadgeNumber =
                [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEW_NOTICE_UPDATE object:nil];//刷新消息
        }
            break;
        //别人邀请你参加
        case 3:
        //别人参加你
        case 4:
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IF_HAS_NEW_NOTICE];//通知中心红点
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IS_HAS_NEW_ACTIVITY];//活动通知红点
            UIViewController *viewController = self.window.rootViewController;
            if ([viewController isKindOfClass:[FreeTabBarViewController class]]) {
                FreeTabBarViewController *freeTabBarVC = (FreeTabBarViewController *)viewController;
                if (freeTabBarVC.selectedIndex != 2)
                {
                    [freeTabBarVC.tabBar.items[2] setImage:[[UIImage imageNamed:@"message_new"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEW_NOTICE object:nil];//新通知的小红点
            NSString *typeStr = KEY_IS_HAS_NEW_ACTIVITY;
            [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_NEW_NOTICE object:typeStr];//新通知的小红点
            
            NSArray *noticeList = data[@"noticeList"];
            for (int i = 0; i < [noticeList count]; i++) {
                NSArray* array = [[FreeSingleton sharedInstance] strToJson:noticeList[i][@"jsonObjStr"]];
                double time;
                time = [[NSString stringWithFormat:@"%@",noticeList[i][@"time"]] doubleValue];
                NSDate* date = [NSDate dateWithTimeIntervalSince1970:time/1000.0];
                NSString* strDate = [[FreeSingleton sharedInstance] changeDate2String:date];
                    id dataTmp = array;
                [[FreeSQLite sharedInstance] insertFreeSQLiteNoticeList:noticeList[i][@"headImg"] freeDate:@"" freeTimeStart:@"" sendTime:strDate activityId:dataTmp[@"activityId"] type:[NSNumber numberWithInt:3] content:noticeList[i][@"text"]];
                [UIApplication sharedApplication].applicationIconBadgeNumber =
                [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
            }
        }
            break;
        case 5:
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IF_HAS_NEW_FRIENDS];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEW_FRIENDS object:nil];//新朋友的小红点
        }
            break;
        case 6:
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IF_HAS_NEW_NOTICE];//通知中心红点
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IS_HAS_NEW_COMMENT];//评论通知红点
            
            UIViewController *viewController = self.window.rootViewController;
            if ([viewController isKindOfClass:[FreeTabBarViewController class]]) {
                FreeTabBarViewController *freeTabBarVC = (FreeTabBarViewController *)viewController;
                if (freeTabBarVC.selectedIndex != 2)
                {
                    [freeTabBarVC.tabBar.items[2] setImage:[[UIImage imageNamed:@"message_new"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEW_NOTICE object:nil];//新通知的小红点
            NSString *typeStr = KEY_IS_HAS_NEW_COMMENT;
            [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_NEW_NOTICE object:typeStr];//新通知的小红点
            NSArray *noticeList = data[@"noticeList"];
            for (int i = 0; i < [noticeList count]; i++) {
                NSArray* array = [[FreeSingleton sharedInstance] strToJson:noticeList[i][@"jsonObjStr"]];
                double time;
                time = [[NSString stringWithFormat:@"%@",noticeList[i][@"time"]] doubleValue];
                NSDate* date = [NSDate dateWithTimeIntervalSince1970:time/1000.0];
                NSString* strDate = [[FreeSingleton sharedInstance] changeDate2String:date];
                id dataTmp = array;
                [[FreeSQLite sharedInstance] insertFreeSQLiteNoticeList:noticeList[i][@"headImg"] freeDate:@"" freeTimeStart:@"" sendTime:strDate activityId:dataTmp[@"postId"] type:[NSNumber numberWithInt:6] content:noticeList[i][@"text"]];
                [UIApplication sharedApplication].applicationIconBadgeNumber =
                [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
            }
        }
            break;
        case 7:
        case 8:
        case 9:
        case 10:
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IF_HAS_NEW_NOTICE];//通知中心红点
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IS_HAS_NEW_OFFICIAL];//官方通知红点
            UIViewController *viewController = self.window.rootViewController;
            if ([viewController isKindOfClass:[FreeTabBarViewController class]]) {
                FreeTabBarViewController *freeTabBarVC = (FreeTabBarViewController *)viewController;
                if (freeTabBarVC.selectedIndex != 2)
                {
                    [freeTabBarVC.tabBar.items[2] setImage:[[UIImage imageNamed:@"message_new"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEW_NOTICE object:nil];//新通知的小红点
            NSString *typeStr = KEY_IS_HAS_NEW_OFFICIAL;
            [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_NEW_NOTICE object:typeStr];//新通知的小红点
            NSArray *noticeList = data[@"noticeList"];
            for (int i = 0; i < [noticeList count]; i++) {
                
                double time;
                time = [[NSString stringWithFormat:@"%@",noticeList[i][@"time"]] doubleValue];
                NSDate* date = [NSDate dateWithTimeIntervalSince1970:time/1000.0];
                NSString* strDate = [[FreeSingleton sharedInstance] changeDate2String:date];
                
                if (noticeList[i][@"jsonObjStr"]) {
                    NSArray* array = [[FreeSingleton sharedInstance] strToJson:noticeList[i][@"jsonObjStr"]];
                    id dataTmp = array;
                    [[FreeSQLite sharedInstance] insertFreeSQLiteNoticeList:noticeList[i][@"headImg"] freeDate:@"" freeTimeStart:@"" sendTime:strDate activityId:dataTmp[@"postId"] type:[NSNumber numberWithInt:[data[@"type"] intValue]] content:noticeList[i][@"text"]];
                }
                else
                {
                    [[FreeSQLite sharedInstance] insertFreeSQLiteNoticeList:noticeList[i][@"headImg"] freeDate:@"" freeTimeStart:@"" sendTime:strDate activityId:@"" type:[NSNumber numberWithInt:[data[@"type"] intValue]] content:noticeList[i][@"text"]];
                }
                
                [UIApplication sharedApplication].applicationIconBadgeNumber =
                [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
            }
        }
            break;
        default:
            break;
    }
}

- (void) webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"socket opened %@", webSocket);
    // 每隔60s像服务器发送心跳包
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(heartBeating) userInfo:nil repeats:YES];// 在longConnectToSocket方法中进行长连接需要向服务器发送的讯息
    
    [self.connectTimer fire];
}

//心跳
- (void)heartBeating
{
    if (_ws.readyState == SR_OPEN) {
        [_ws send:@""];//发送空串
    }
}

- (void) closeWs {
    [_ws close];
}

- (void) sendMessage:(NSNotification*) notification
{
    NSString *jsonString = [[NSString alloc] initWithData:[[FreeSingleton sharedInstance] dictToJsonData:notification.userInfo[@"message"]] encoding:NSUTF8StringEncoding];
    
    if (_ws.readyState == SR_OPEN) {
        [_ws send:jsonString];
    }
}

- (void)openSocket
{
    if (_ws.readyState == SR_CLOSED || _ws.readyState == SR_CLOSING) {
        [self createWS];
    }
    //获取应用程序消息通知标记数（即小红圈中的数字）
    //    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    //    if (badge>0) {
    //        //如果应用程序消息通知标记数（即小红圈中的数字）大于0，清除标记。
    //        badge = 0;
    //        //清除标记。清除小红圈中数字，小红圈中数字为0，小红圈才会消除。
    //        [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    //    }
}

- (void)closeSocket
{
    if (_ws == nil) {
        return;
    }
    //挂起就关闭连接
    if (_ws.readyState == SR_CONNECTING || _ws.readyState == SR_OPEN) {
        [self closeWs];
    }
}

#pragma mark -home键监听socket链接
//触发home按下
- (void)applicationWillResignActiveFree:(NSNotification *)notification

{
    //挂起就关闭连接
    if (_ws.readyState == SR_CONNECTING || _ws.readyState == SR_OPEN) {
        [self closeWs];
    }
}
//重新进来后响应
- (void)applicationDidBecomeActiveFree:(NSNotification *)notification
{
    //切换进来则重新连接
    if (_ws.readyState == SR_CLOSED || _ws.readyState == SR_CLOSING) {
        [self createWS];
    }
}

#pragma mark -小红点
//- (void)didReceiveMessageNotification:(NSNotification *)notification {
//    [UIApplication sharedApplication].applicationIconBadgeNumber =
//    [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
//}

#pragma mark - 获取通讯录数据
- (void)synAddress
{
    [[FreeSingleton sharedInstance] getAddressListOnCompletion:^(NSUInteger retcode1, id dataList) {
        if (retcode1 == RET_SERVER_SUCC) {
            
            [[FreeSQLite sharedInstance] clearAllTable:ADDRESS_TABLE_NAME];
            
            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:ADDRESS_TABLE tableName:ADDRESS_TABLE_NAME];
            
            NSMutableArray *modelArray = [NSMutableArray array];
            [FreeAddressBook insertFreeDataSource:dataList dataSource:modelArray];
            [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:modelArray];
        }
    }];
}
    

#pragma mark -获得用户信息
- (void)getUserData
{
    [[FreeSingleton sharedInstance] getUserInfoOnCompletion:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            //登录
            [[FreeSingleton sharedInstance] rongyunLogin];
            //开启socket
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DID_LOGIN object:nil];
            
            //与服务器同步群信息
            [[FreeSingleton sharedInstance] syncGroupsInfo:^(NSUInteger ret1, id data1) {
                if (ret1 == RET_SERVER_SUCC) {
                    NSLog(@"群信息同步成功");
                }
                else
                {
                    NSLog(@"群信息同步失败");
                }
            }];
            
            if (data) {
                if (![[data mutableCopy][@"id"] isKindOfClass:[NSNull class]]) {
                    [FreeSingleton sharedInstance].accountId = [NSString stringWithFormat:@"%@",data[@"id"]];
                    [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].accountId forKey:KEY_ACCOUNT_ID];
                } else {
                    NSLog(@"ID为空");
                }
                if (![[data mutableCopy][@"phoneNo"] isKindOfClass:[NSNull class]]) {
                    [FreeSingleton sharedInstance].phoneNo = data[@"phoneNo"];
                    [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"phoneNo"] forKey:KEY_PHONE_NO];
                } else {
                    NSLog(@"PhoneNo为空");
                }
                if (![[data mutableCopy][@"nickName"] isKindOfClass:[NSNull class]]) {
                    [FreeSingleton sharedInstance].nickName = data[@"nickName"];
                    [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"nickName"] forKey:KEY_NICK_NAME];
                } else {
                    NSLog(@"昵称为空");
                }
                
                if (![[data mutableCopy][@"status"] isKindOfClass:[NSNull class]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"status"] forKey:KEY_USER_STATUS];
                    [FreeSingleton sharedInstance].status = data[@"status"];
                } else {
                    NSLog(@"状态为空");
                }
                
                if (![[data mutableCopy][@"headImg"] isKindOfClass:[NSNull class]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"headImg"] forKey:KEY_HEAD_IMG_URL];
                    [FreeSingleton sharedInstance].head_img = data[@"headImg"];
                    
                }//未加判空告警
                
                if (![[data mutableCopy][@"gender"] isKindOfClass:[NSNull class]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"gender"] forKey:KEY_GENDER];
                    [FreeSingleton sharedInstance].gender = data[@"gender"];
                }
                else
                {
                    NSLog(@"性别为空");
                }
                if (![[data mutableCopy][@"tagList"] isKindOfClass:[NSNull class]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"tagList"] forKey:KEY_LABLE_NUM];
                    [FreeSingleton sharedInstance].lableArray = data[@"tagList"];
                }
                if (![data[@"level"] isKindOfClass:[NSNull class]]) {
                    [FreeSingleton sharedInstance].level = data[@"level"];
                    [[NSUserDefaults standardUserDefaults] setObject:data[@"level"] forKey:KEY_LEVEL];
                } else {
                    NSLog(@"Lv为空");
                }
                
                if (![data[@"point"] isKindOfClass:[NSNull class]]) {
                    [FreeSingleton sharedInstance].point = [NSString stringWithFormat:@"%@", data[@"point"]];
                    [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].point forKey:KEY_POINT];
                } else {
                    NSLog(@"point为空");
                }
                
                if (![data[@"followNum"] isKindOfClass:[NSNull class]]) {
                    [FreeSingleton sharedInstance].my_Followed_Num = [NSString stringWithFormat:@"%@", data[@"followNum"]];
                    [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].my_Followed_Num forKey:KEY_FOLLOWED_NUM];
                }
                else
                {
                    NSLog(@"关注为空");
                }
                
                if (![data[@"followerNum"] isKindOfClass:[NSNull class]]) {
                    [FreeSingleton sharedInstance].my_Follower_Num = [NSString stringWithFormat:@"%@", data[@"followerNum"]];
                    [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].my_Follower_Num forKey:KEY_FOLLOWER_NUM];
                }
                else
                {
                    NSLog(@"关注者为空");
                }
                
                if (![data[@"erdu"] isKindOfClass:[NSNull class]]) {
                    NSString *erdu_tag = [NSString stringWithFormat:@"%@",data[@"erdu"]];
                    [FreeSingleton sharedInstance].erdu = erdu_tag;
                    [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].erdu forKey:KEY_INVITE_CODE];
                }
                
                if (![data[@"inviteCode"] isKindOfClass:[NSNull class]] && [data[@"inviteCode"] length] != 0) {
                    [FreeSingleton sharedInstance].inviteCode = data[@"inviteCode"];
                    [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].inviteCode forKey:KEY_INVITE_CODE];
                }
                
                if(![data[@"type"] isKindOfClass:[NSNull class]]){
                    NSString *type = [NSString stringWithFormat:@"%@", data[@"type"]];
                    [FreeSingleton sharedInstance].type = type;
                    [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].type forKey:KEY_LOGIN_TYPE];
                }
                
            }
            
            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NOTICE_TABLE tableName:NOTICE_TABLE_NAME];
            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:REMARK_TABLE tableName:REMARK_TABLE_NAME];
            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NEW_FRIENDS_TABLE tableName:NEW_FRIENDS_TABLE_NAME];
            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                //开启数据库
//            [FreeAddressBook updateData];
//            });
            
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
        }
    }];
}


@end
