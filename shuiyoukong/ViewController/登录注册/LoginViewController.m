//
//  LoginViewController.m
//  Free
//  Created by 勇拓 李 on 15/5/4.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "LoginViewController.h"
#import "Utils.h"
#import "Error.h"
#import "FreeSingleton.h"
#import <AddressBook/AddressBook.h>
#import "FreeAddressBook.h"
#import "UIChangeIncident.h"
#import "FreeSQLite.h"
#import "FreeTabBarViewController.h"
#import "FreeMap.h"
#import "AMapSearchAPI.h"

#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocial.h"

@interface LoginViewController ()<AMapSearchDelegate>
@property AMapSearchAPI *search;
@property (weak, nonatomic) IBOutlet UIButton *btn_weixin;
@property (weak, nonatomic) IBOutlet UIButton *btn_qq;
@property (weak, nonatomic) IBOutlet UIButton *btn_sina;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [self setLocation];
}

- (void)dealloc
{
     _search.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
  
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
}
- (void)initView
{
    _backgroudView.layer.borderColor = [[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0] CGColor];
    _backgroudView.layer.borderWidth = 1.0;
    _backgroudView.layer.masksToBounds = YES;
    _backgroudView.layer.cornerRadius = 5;
    
    _PWbgView.layer.borderColor = [[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0] CGColor];
    _PWbgView.layer.borderWidth = 1.0;
    _PWbgView.layer.masksToBounds = YES;
    _PWbgView.layer.cornerRadius = 5;
    
    _btn_login.layer.masksToBounds = YES;
    _btn_login.layer.cornerRadius = 6;
    _btn_login.layer.borderWidth = 1;
    _btn_login.layer.borderColor = [[UIColor whiteColor] CGColor];
    _btn_login.backgroundColor = FREE_BLACK_COLOR;
    
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
//    self.navigationController.navigationBar.tintColor = FREE_BACKGOURND_COLOR;
    self.navigationItem.backBarButtonItem=backItem;

//    UIColor *color = FREE_BACKGOURND_COLOR;
//    NSDictionary *dic = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
//    self.navigationController.navigationBar.titleTextAttributes = dic;
    
    [_pwd setBackgroundColor:[UIColor clearColor]];
    [_pwd setTextColor:[UIColor blackColor]];
    [_pwd setTintColor:FREE_BACKGOURND_COLOR];
    [_phone setBackgroundColor:[UIColor clearColor]];
    [_phone setTextColor:[UIColor blackColor]];
    [_phone setTintColor:FREE_BACKGOURND_COLOR];
    _phone.delegate = self;
    _pwd.borderStyle = UITextBorderStyleNone;
    _phone.borderStyle = UITextBorderStyleNone;

    _btn_forget.tintColor = FREE_BACKGOURND_COLOR;
    [_btn_forget setTitleColor:[UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_btn_register setTitleColor:FREE_BACKGOURND_COLOR forState:UIControlStateNormal];
    _btn_register.tintColor = [UIColor whiteColor];
    
    _pwd.delegate = self;
    _pwd.keyboardType = UIKeyboardTypeASCIICapable;
    _pwd.returnKeyType = UIReturnKeyDone;
    _pwd.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    
    [_btn_sina addTarget:self action:@selector(btn_sina_Tapped:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_qq addTarget:self action:@selector(btn_qq_Tapped:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_weixin addTarget:self action:@selector(btn_weixin_Tapped:) forControlEvents:UIControlEventTouchUpInside];
}
/**
 *  登录
 *
 *  @param sender
 */
- (IBAction)btn_Tapped_login:(id)sender
{
    [self.phone resignFirstResponder];
    [self.pwd resignFirstResponder];
    [self login];
  //  [self performSegueWithIdentifier:@"loginSuccSeg" sender:self];
}
/**
 *  注册
 *
 *  @param sender
 */
- (IBAction)registersing:(UIButton *)sender
{//上传通讯录
    [self performSegueWithIdentifier:@"registerSend" sender:self];
}
- (IBAction)regiseSend:(UIButton *)sender {
    [self performSegueWithIdentifier:@"forgetPassword" sender:self];
}

- (void) login
{
    [self.phone resignFirstResponder];
    [self.pwd resignFirstResponder];
    [KVNProgress showWithStatus:@"Loading"];
    __weak LoginViewController *weakSelf = self;
    static FreeSingleton *_freeSingleton = nil;
    _freeSingleton = [FreeSingleton sharedInstance];
    
    NSInteger ret = [_freeSingleton userLoginOnCompletion:self.phone.text pwd:self.pwd.text deviceToken:[[FreeSingleton sharedInstance] getUserDeviceID] block:^(NSUInteger retcode, id data){
        if (retcode == RET_SERVER_SUCC) {
            //检测通讯录
//            [FreeAddressBook getAddressListData];
            [[FreeSingleton sharedInstance] getAddressListOnCompletion:^(NSUInteger retcode1, id dataList) {
                if (retcode1 == RET_SERVER_SUCC) {
                    
//                    [[FreeSingleton sharedInstance] postCityOnCompletion:[[FreeSingleton sharedInstance] getCity] block:^(NSUInteger ret, id data) {
//                        if (ret == RET_SERVER_SUCC) {
//                            NSLog(@"发送城市成功");
//                        }
//                    }];
                    
                    [[FreeSQLite sharedInstance] clearAllTable:ADDRESS_TABLE_NAME];
                    
                    [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:ADDRESS_TABLE tableName:ADDRESS_TABLE_NAME];
                    
                    NSMutableArray *modelArray = [NSMutableArray array];
                    [FreeAddressBook insertFreeDataSource:dataList dataSource:modelArray];
                    [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:modelArray];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KVNProgress dismiss];
                    [KVNProgress showSuccessWithStatus:@"登录成功"
                                                onView:weakSelf.view.window];
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    
                    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HostViewController"];
                    
                    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
                    [UIApplication sharedApplication].keyWindow.rootViewController = viewController;
                });
            }];

            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NOTICE_TABLE tableName:NOTICE_TABLE_NAME];
            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:REMARK_TABLE tableName:REMARK_TABLE_NAME];
            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NEW_FRIENDS_TABLE tableName:NEW_FRIENDS_TABLE_NAME];
            if([[FreeSingleton sharedInstance] getCity])
            {
                [[FreeSingleton sharedInstance] postCityOnCompletion:[[FreeSingleton sharedInstance] getCity] block:^(NSUInteger ret, id data) {
                    if (ret == RET_SERVER_SUCC) {
                        NSLog(@"上传城市成功");
                    }
                    else
                    {
                        NSLog(@"上传城市失败");
                    }
                }];
            }
            
            //定位
            [weakSelf getUserInfo:data];
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress dismiss];
                [KVNProgress showErrorWithStatus:data];
            });
        }
    }];
    
    if (ret != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(ret)];
    }
}
- (IBAction)hidekeyboard:(id)sender
{
    [_phone resignFirstResponder];
    [_pwd resignFirstResponder];
    [_btn_login resignFirstResponder];
}


/**
 *  点击完成收入键盘
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_phone resignFirstResponder];
    [_pwd resignFirstResponder];
    return YES;
}

#pragma mark - 第三方登录
//新浪
- (void)btn_sina_Tapped:(UIButton *)btn
{
    __weak LoginViewController *weakSelf = self;
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        //          获取微博用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            [KVNProgress showWithStatus:@"Loading"];
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
            
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToSina  completion:^(UMSocialResponseEntity *response){
                {
                    NSString *str = @"female";
                    
                    if ([response.data[@"gender"] integerValue] == 1) {
                        str = @"male";
                    }
                    
                    [[FreeSingleton sharedInstance] visitorLoginCompletion:snsAccount.usid nickName:snsAccount.userName headImg:snsAccount.iconURL gender:str type:SINA_TYPE deviceToken:[[FreeSingleton sharedInstance] getUserDeviceID] block:^(NSUInteger ret, id data) {
                        [KVNProgress dismiss];
                        if (ret == RET_SERVER_SUCC) {
                            [[FreeSingleton sharedInstance] getAddressListOnCompletion:^(NSUInteger retcode1, id dataList) {
                                if (retcode1 == RET_SERVER_SUCC) {
                                    
                                    [[FreeSQLite sharedInstance] clearAllTable:ADDRESS_TABLE_NAME];
                                    
                                    [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:ADDRESS_TABLE tableName:ADDRESS_TABLE_NAME];
                                    
                                    NSMutableArray *modelArray = [NSMutableArray array];
                                    [FreeAddressBook insertFreeDataSource:dataList dataSource:modelArray];
                                    [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:modelArray];
                                }
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [KVNProgress dismiss];
                                    [KVNProgress showSuccessWithStatus:@"登录成功"
                                                                onView:weakSelf.view.window];
                                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                    
                                    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HostViewController"];
                                    
                                    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
                                    [UIApplication sharedApplication].keyWindow.rootViewController = viewController;
                                });
                            }];
                            
                            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NOTICE_TABLE tableName:NOTICE_TABLE_NAME];
                            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:REMARK_TABLE tableName:REMARK_TABLE_NAME];
                            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NEW_FRIENDS_TABLE tableName:NEW_FRIENDS_TABLE_NAME];
                            if([[FreeSingleton sharedInstance] getCity])
                            {
                                [[FreeSingleton sharedInstance] postCityOnCompletion:[[FreeSingleton sharedInstance] getCity] block:^(NSUInteger ret, id data) {
                                    if (ret == RET_SERVER_SUCC) {
                                        NSLog(@"上传城市成功");
                                    }
                                    else
                                    {
                                        NSLog(@"上传城市失败");
                                    }
                                }];
                            }
                            //定位
                            [weakSelf getUserInfo:data];
                        }
                    }];
                    
                    NSLog(@"SnsInformation is %@",response.data);
                }
            }];
            
            NSLog(@"username is %@, uid is %@, token is %@ url is %@ , gender is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL, snsAccount);
            
        }});
}

//QQ
- (void)btn_qq_Tapped:(UIButton *)btn
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    __weak LoginViewController *weakSelf = self;
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //          获取微博用户名、uid、token等
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            [KVNProgress showWithStatus:@"Loading"];
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            
//            UMSocialAccountEntity *strongAccount = snsAccount;
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToQQ  completion:^(UMSocialResponseEntity *response){
                NSString *str = @"male";
                
                if ([response.data[@"gender"] isEqualToString:@"女"]) {
                    str = @"female";
                }
                
                [[FreeSingleton sharedInstance] visitorLoginCompletion:snsAccount.usid nickName:snsAccount.userName headImg:snsAccount.iconURL gender:str type:QQ_TYPE deviceToken:[[FreeSingleton sharedInstance] getUserDeviceID] block:^(NSUInteger ret, id data) {
                    [KVNProgress dismiss];
                    if (ret == RET_SERVER_SUCC) {
                        [[FreeSingleton sharedInstance] getAddressListOnCompletion:^(NSUInteger retcode1, id dataList) {
                            if (retcode1 == RET_SERVER_SUCC) {
                                
                                [[FreeSQLite sharedInstance] clearAllTable:ADDRESS_TABLE_NAME];
                                
                                [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:ADDRESS_TABLE tableName:ADDRESS_TABLE_NAME];
                                
                                NSMutableArray *modelArray = [NSMutableArray array];
                                [FreeAddressBook insertFreeDataSource:dataList dataSource:modelArray];
                                [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:modelArray];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [KVNProgress dismiss];
                                [KVNProgress showSuccessWithStatus:@"登录成功"
                                                            onView:weakSelf.view.window];
                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                
                                UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HostViewController"];
                                
                                [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
                                [UIApplication sharedApplication].keyWindow.rootViewController = viewController;
                            });
                        }];
                        
                        [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NOTICE_TABLE tableName:NOTICE_TABLE_NAME];
                        [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:REMARK_TABLE tableName:REMARK_TABLE_NAME];
                        [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NEW_FRIENDS_TABLE tableName:NEW_FRIENDS_TABLE_NAME];
                        if([[FreeSingleton sharedInstance] getCity])
                        {
                            [[FreeSingleton sharedInstance] postCityOnCompletion:[[FreeSingleton sharedInstance] getCity] block:^(NSUInteger ret, id data) {
                                if (ret == RET_SERVER_SUCC) {
                                    NSLog(@"上传城市成功");
                                }
                                else
                                {
                                    NSLog(@"上传城市失败");
                                }
                            }];
                        }
                        
                        //定位
                        [weakSelf getUserInfo:data];
                    }
                }];
                
                NSLog(@"SnsInformation is %@",response.data);
            }];

            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            
        }});
}

- (void)btn_weixin_Tapped:(UIButton *)btn
{
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    __weak LoginViewController *weakSelf = self;
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            [KVNProgress showWithStatus:@"Loading"];
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
            
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
                NSString *str = @"female";
                
                if ([response.data[@"gender"] integerValue] == 1) {
                    str = @"male";
                }
                
                [[FreeSingleton sharedInstance] visitorLoginCompletion:snsAccount.usid nickName:snsAccount.userName headImg:snsAccount.iconURL gender:str type:WEIXIN_TYPE deviceToken:[[FreeSingleton sharedInstance] getUserDeviceID] block:^(NSUInteger ret, id data) {
                    [KVNProgress dismiss];
                    if (ret == RET_SERVER_SUCC) {
                        [[FreeSingleton sharedInstance] getAddressListOnCompletion:^(NSUInteger retcode1, id dataList) {
                            if (retcode1 == RET_SERVER_SUCC) {
                                
                                [[FreeSQLite sharedInstance] clearAllTable:ADDRESS_TABLE_NAME];
                                
                                [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:ADDRESS_TABLE tableName:ADDRESS_TABLE_NAME];
                                
                                NSMutableArray *modelArray = [NSMutableArray array];
                                [FreeAddressBook insertFreeDataSource:dataList dataSource:modelArray];
                                [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:modelArray];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [KVNProgress dismiss];
                                [KVNProgress showSuccessWithStatus:@"登录成功"
                                                            onView:weakSelf.view.window];
                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                
                                UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HostViewController"];
                                
                                [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
                                [UIApplication sharedApplication].keyWindow.rootViewController = viewController;
                            });
                        }];
                        
                        [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NOTICE_TABLE tableName:NOTICE_TABLE_NAME];
                        [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:REMARK_TABLE tableName:REMARK_TABLE_NAME];
                        [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NEW_FRIENDS_TABLE tableName:NEW_FRIENDS_TABLE_NAME];
                        if([[FreeSingleton sharedInstance] getCity])
                        {
                            [[FreeSingleton sharedInstance] postCityOnCompletion:[[FreeSingleton sharedInstance] getCity] block:^(NSUInteger ret, id data) {
                                if (ret == RET_SERVER_SUCC) {
                                    NSLog(@"上传城市成功");
                                }
                                else
                                {
                                    NSLog(@"上传城市失败");
                                }
                            }];
                        }
                        
                        //定位
                        [weakSelf getUserInfo:data];
                    }
                }];
                
                NSLog(@"SnsInformation is %@",response.data);
            }];
            
            NSLog(@"username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
        }
        
    });
}

#pragma mark -地图定位
- (void)setLocation
{
    __weak LoginViewController *weakSelf = self;
    //进行定位
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [FreeMap getPosition:weakSelf block:^(NSUInteger ret, id data) {
        
        if(data)
        {
            //初始化检索对象
            _search = [[AMapSearchAPI alloc] init];
            _search.delegate = self;
            
            //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
            AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
//            regeoRequest.searchType = AMapSearchType_ReGeocode;
            
            NSArray *array = [data componentsSeparatedByString:@"-"];
            
            NSString *longitude = array[0];
            NSString *latitude = array[1];
            
            regeoRequest.location = [AMapGeoPoint locationWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
            regeoRequest.radius = 10000;
            regeoRequest.requireExtension = YES;
            
            //发起逆地理编码
            [_search AMapReGoecodeSearch: regeoRequest];
        }
    }];
    //    });
}

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        NSString *strCity = response.regeocode.addressComponent.city;
        if (!strCity || [strCity length] == 0) {
            strCity = response.regeocode.addressComponent.province;
        }
        
        if (strCity != [[FreeSingleton sharedInstance] getCity]) {
            [FreeSingleton sharedInstance].city = strCity;
            [[NSUserDefaults standardUserDefaults] setObject:strCity forKey:KEY_CITY_NAME];
            [[FreeSingleton sharedInstance] postCityOnCompletion:strCity block:^(NSUInteger ret, id data) {
                if (ret == RET_SERVER_SUCC) {
                    
                }
            }];
        }
    }
}

- (void)getUserInfo:(id)data
{
//    [[FreeSingleton sharedInstance] getUserInfoOnCompletion:^(NSUInteger ret, id data) {
//        if (ret == RET_SERVER_SUCC) {
//            
            if (data) {
                if (![data[@"id"] isKindOfClass:[NSNull class]]) {
                    [FreeSingleton sharedInstance].accountId = [NSString stringWithFormat:@"%@", data[@"id"]];
                    [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].accountId forKey:KEY_ACCOUNT_ID];
                } else {
                    NSLog(@"ID为空");
                }
                if (![data[@"phoneNo"] isKindOfClass:[NSNull class]]) {
                    [FreeSingleton sharedInstance].phoneNo = data[@"phoneNo"];
                    [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"phoneNo"] forKey:KEY_PHONE_NO];
                } else {
                    NSLog(@"PhoneNo为空");
                }
                if (![data[@"nickName"] isKindOfClass:[NSNull class]]) {
                    [FreeSingleton sharedInstance].nickName = data[@"nickName"];
                    [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"nickName"] forKey:KEY_NICK_NAME];
                } else {
                    NSLog(@"昵称为空");
                }
                
                if (![data[@"status"] isKindOfClass:[NSNull class]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"status"] forKey:KEY_USER_STATUS];
                    [FreeSingleton sharedInstance].status = data[@"status"];
                } else {
                    NSLog(@"状态为空");
                }
                
                if (![data[@"headImg"] isKindOfClass:[NSNull class]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"headImg"] forKey:KEY_HEAD_IMG_URL];
                    [FreeSingleton sharedInstance].head_img = data[@"headImg"];
                    
                }//未加判空告警
                
                if (![data[@"gender"] isKindOfClass:[NSNull class]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"gender"] forKey:KEY_GENDER];
                    [FreeSingleton sharedInstance].gender = data[@"gender"];
                }
                else
                {
                    NSLog(@"性别为空");
                }
                
                if (![data[@"tagList"] isKindOfClass:[NSNull class]]) {
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
                
                if (![data[@"inviteCode"] isKindOfClass:[NSNull class]] && [data[@"inviteCode"] length] != 0) {
                    [FreeSingleton sharedInstance].inviteCode = data[@"inviteCode"];
                    [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].inviteCode forKey:KEY_INVITE_CODE];
                }
                
                if (![data[@"erdu"] isKindOfClass:[NSNull class]]) {
                    NSString *erdu_tag = [NSString stringWithFormat:@"%@",data[@"erdu"]];
                    [FreeSingleton sharedInstance].erdu = erdu_tag;
                    [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].erdu forKey:KEY_INVITE_CODE];
                }
                
                if(![data[@"type"] isKindOfClass:[NSNull class]]){
                    NSString *type = [NSString stringWithFormat:@"%@", data[@"type"]];
                    [FreeSingleton sharedInstance].type = type;
                    [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].type forKey:KEY_LOGIN_TYPE];
                }
                
            }
            //登录融云
            [[FreeSingleton sharedInstance] rongyunLogin];
            //开启socket
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DID_LOGIN object:nil];

}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"loginSuccSeg"]) {
//    FreeTabBarViewController* vc = (FreeTabBarViewController *)segue.destinationViewController;
//    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
//    [UIApplication sharedApplication].keyWindow.rootViewController = vc;
//    }
//}

@end