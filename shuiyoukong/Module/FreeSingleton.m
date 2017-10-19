//
//  FreeSingleton.m
//  Free
//
//  Created by 勇拓 李 on 15/4/29.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FreeSingleton.h"
#import "settings.h"
#import "Error.h"
#import <CommonCrypto/CommonDigest.h>
#import "FreeImageScale.h"
#import "FreeSQLite.h"
#import "Group.h"
#import "JSONKit.h"

#define NOTIFY_IF_NEED_LOGIN(ret) \
if ((ret) == ERR_SERVER_401) \
{ \
[[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEED_LOGIN object:nil userInfo:nil]; \
}


@implementation FreeSingleton
{
    AFHTTPSessionManager *manager;
}

+ (FreeSingleton *)sharedInstance
{
    static FreeSingleton *_zhichunSingleton = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _zhichunSingleton = [[FreeSingleton alloc] initSingleton];
    });
    
    return _zhichunSingleton;
}

- (id) initSingleton {
    self = [super init];
    if (self) {
        self.token = [[NSUserDefaults standardUserDefaults] stringForKey:SERVICE_FOR_SS_KEYCHAIN_TOKEN];//初始化 token
        [self setAFHTTPSessionManagerToken:self.token];//初始化 manager
        _lableArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark -private methods

- (void) setAFHTTPSessionManagerToken:(NSString *)token {
    
#warning -设置版本号
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    if(token)
    {
        [config setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json",
                                           @"version" : @"ios_3.5.0",
                                           @"access_token" : self.token}];
    }
    else
    {
        [config setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json",
                                           @"version" : @"ios_3.5.0"}];
    }
    manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];

}

//生成 request
- (NSMutableURLRequest *)getRequest:(NSString*)method body:(NSData *)data strUrl:(NSString *)strUrl{
#warning -设置版本号
    NSURL *url = [NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"ios_3.5.0" forHTTPHeaderField:@"version"];
    if (self.token || self.token.length > 0) {
        //here should have a get token method
        [request setValue:self.token forHTTPHeaderField:@"access_token"];
    }
    return request;
}

#pragma mark -工具类
//用于判断短信验证码的合法性

- (BOOL) isSMSCode:(NSString*)smsCode
{
    return [self matchRegex:SMSCODE_REGEX string:smsCode];
}

- (BOOL) matchRegex:(NSString*)regexStr string:(NSString*)str
{
    NSError *err = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&err];
    NSUInteger numOfMatch = [regex numberOfMatchesInString:str
                                                   options:NSMatchingAnchored
                                                     range:NSMakeRange(0, [str length])];
    
    return (numOfMatch>0);
    
}

//验证是否是合法手机号
- (BOOL) isMobileNo: (NSString*)text
{
    /* check phone number */
    
    // remove all spaces
    NSString* trimmedMobileNo = [text stringByReplacingOccurrencesOfString:@"[\\s]+"
                                                                withString:@""
                                                                   options:NSRegularExpressionSearch
                                                                     range:NSMakeRange(0, [text length])];
    
    
    // remove the leading "+86"
    NSString* noCountryCodeMobileNo = [trimmedMobileNo stringByReplacingOccurrencesOfString:@"^\\+86"
                                                                                 withString:@""
                                                                                    options:NSRegularExpressionSearch
                                                                                      range:NSMakeRange(0, [trimmedMobileNo length])];
    
    
    // remove the hyphen in mobile
    NSString* hyphenRemovedMobileNo = [noCountryCodeMobileNo stringByReplacingOccurrencesOfString:@"[\\-]"
                                                                                       withString:@""
                                                                                          options:NSRegularExpressionSearch
                                                                                            range:NSMakeRange(0, [noCountryCodeMobileNo length])];
    
    
    // It is nither an email address nor mobile number
    if ( [hyphenRemovedMobileNo length] != 11 )
        return NO;
    
    return [self matchRegex:MOBILE_NUM_REGEX string:hyphenRemovedMobileNo];
}

//md5加密
- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

//dict to jsonData
- (NSData *) dictToJsonData:(NSDictionary *)dict {
    NSError* err;
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
    return data;
}

//字典转jsonStr
- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

//str to json
- (NSArray *) strToJson:(NSString *)stringData {
    
    NSError *jsonError;
    NSData *objectData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&jsonError];
    return json;
}

- (NSString *)arrayToStr:(NSMutableArray *)array
{
    NSString *str = [array componentsJoinedByString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"{" withString:@"[{"];
    str = [str stringByReplacingOccurrencesOfString:@"}" withString:@"}]"];
    str = [str stringByReplacingOccurrencesOfString:@"] [" withString:@","];
    str = [str stringByReplacingOccurrencesOfString:@";" withString:@","];
    str = [str stringByReplacingOccurrencesOfString:@",\n}" withString:@"}"];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    str = [str stringByReplacingOccurrencesOfString:@"U" withString:@"u"];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\\\"" withString:@""];
    
    return str;
}

//请求压缩图
+ (NSURL *) handleImageUrlWithSuffix:(NSString *)imageUrl sizeSuffix:(NSString *)size {
    
    if ([imageUrl isEqual:[NSNull null]]) {
        return nil;
    }
    
    if ([imageUrl length] < 19) {
        return nil;
    }
    
    if (![[imageUrl substringToIndex:19] isEqualToString:@"http://121.42.8.202"])
    {
        return [NSURL URLWithString:imageUrl];
    }
    
    NSString* prefix = [imageUrl componentsSeparatedByString:@".png"][0];
    if ([[[imageUrl componentsSeparatedByString:@"."] lastObject] isEqualToString:@"jpg"]) {
        prefix = [imageUrl componentsSeparatedByString:@".jpg"][0];
        imageUrl = [NSString stringWithFormat:@"%@%@.jpg", prefix, size];
        return [NSURL URLWithString:imageUrl];
    }
    
    if ([[[imageUrl componentsSeparatedByString:@"."] lastObject] isEqualToString:@"gif"]) {
        return [NSURL URLWithString:imageUrl];
    }
    imageUrl = [NSString stringWithFormat:@"%@%@.png", prefix, size];
    return [NSURL URLWithString:imageUrl];
    
}

+ (UIImage *)zipImg:(UIImage *)photo {
    NSData *fData = UIImageJPEGRepresentation(photo, 0.5);
    return [UIImage imageWithData:fData];
}
//时间戳
- (NSString *) getTimeStamp {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
    NSInteger i=time;      //NSTimeInterval返回的是double类型
    int value = arc4random_uniform(9999 + 1);//生成0到9999的随机数

    return [NSString stringWithFormat:@"%ld%d",(long)i,value];
    //    return [NSString stringWithFormat:@"%ld%d%@",(long)i,value,@"mazong"];
}

//时间是否过期
- (BOOL)isPostTime:(NSDate *)aDate freeStartTime:(NSInteger)freeStartTime
{
    if (aDate == nil) return NO;
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSHourCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:[NSDate date]];
    NSInteger dayNow = [components day];
    NSInteger hourNow = [components hour];
    NSInteger monthNow = [components month];
    NSInteger yearNow = [components year];
    
    components = [cal components:(NSHourCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:aDate];
    NSInteger dayDate = [components day];
    NSInteger monthDate = [components month];
    NSInteger yearDate = [components year];
    
    if(dayNow == dayDate && monthNow == monthDate && yearNow == yearDate && freeStartTime < hourNow)
        return YES;
    
    return NO;
}
//转换string到date
- (NSDate *)changeString2Date:(NSString *)str
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSDate *inputDate = [dateformatter dateFromString:str];
    return inputDate;
}
//转换date到string
- (NSString *)changeDate2String:(NSDate *)date
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *date_str = [dateformatter stringFromDate:date];
    return date_str;
}

//转换date到string HH-dd
- (NSString *)changeDate2StringDD:(NSDate *)date
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date_str = [dateformatter stringFromDate:date];
    return date_str;
}

//判断是否是今天
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

- (NSString *) changeTagsToString:(id)data;
{
    NSString *tagStr = nil;
    for (int k = 0; k < [data count]; k++) {
        if (k == 0) {
            tagStr = data[k][@"tagName"];
        }
        else
        {
            tagStr = [NSString stringWithFormat:@"%@-%@", tagStr,data[k][@"tagName"]];
        }
    }
    return tagStr;
}

#pragma mark - 融云token登录
- (void)rongyunLogin
{
    if ([[FreeSingleton sharedInstance] getRongyunToken].length) {
        [[RCIM sharedRCIM] connectWithToken:[[FreeSingleton sharedInstance] getRongyunToken] success:^(NSString *userId) {
            
            NSString *userName = [[FreeSingleton sharedInstance] getNickName];
            //设置当前的用户信息
            RCUserInfo *_currentUserInfo = [[RCUserInfo alloc] initWithUserId:userId name:userName portrait:[[FreeSingleton sharedInstance] getHeadImage]];
            [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
            
            [[RCIM sharedRCIM] setUserInfoDataSource:self];
            [[RCIM sharedRCIM] setGroupInfoDataSource:self];
            //同步群组
            [self syncGroups:^(NSUInteger ret, id data) {
            }];
        }
                                      error:^(RCConnectErrorCode status) {
                                          NSLog(@"connect error %ld", (long)status);
                                          //                                          dispatch_async(dispatch_get_main_queue(), ^{
                                          //                                              UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                          //                                              UINavigationController *rootNavi = [storyboard instantiateViewControllerWithIdentifier:@"rootNavi"];
                                          //                                              self.window.rootViewController = rootNavi;
                                          //                                          });
                                      } tokenIncorrect:^{
                                          NSLog(@"connect error");
                                          [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEED_LOGIN object:nil userInfo:nil]; 
                                      }];
        
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEED_LOGIN object:nil userInfo:nil]; 
    }
}

//同步群组
-(void)syncGroups:(FreeBlock)block
{
    //开发者调用自己的服务器接口获取所属群组信息，同步给融云服务器，也可以直接
    //客户端创建，然后同步
    [self getMyGroups:^(NSUInteger ret, id data) {
        
        if (ret == RET_SERVER_SUCC) {
            if ([data count]) {
                NSMutableArray *result = [NSMutableArray array];
                
                for (int i = 0; i < [data count]; i++) {
                    if ([data[i] isKindOfClass:[NSNull class]]) {
                        continue;
                    }
                    Group *group = [[Group alloc] init];
                    group.groupId = [data[i][@"groupId"] integerValue];
//                    [result addObject:group];
                }

                //同步群组
                [[RCIMClient sharedRCIMClient] syncGroups:result
                                                  success:^{
                                                      block(RET_SERVER_SUCC, nil);
                                                  } error:^(RCErrorCode status) {
                                                      block(RET_SERVER_FAIL, nil);
                                                      
                                                  }];
            }
        }
    }];
}


//获取群消息
- (void)getMyGroups:(FreeBlock)block
{
    NSString *strUrl = URL_QUERY_GROUP;
    
    if (!block) {
        return;
    }
    
    [manager GET:strUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
            
            if ([(NSHTTPURLResponse *)task.response statusCode] == ERR_SERVER_401) {
                block(ERR_SERVER_401,@"异地登录");
                NOTIFY_IF_NEED_LOGIN(ERR_SERVER_401);
            }
            else
            {
                block(RET_SERVER_FAIL, err.description);
                NSLog(@"err is %@", err.description);
            }
        }
    }];
}

//同步群信息
- (void)syncGroupsInfo:(FreeBlock)block
{
    NSString *strUrl = URL_SYNC_GROUP;
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            if (block) {
                NSLog(@"同步成功");
                block(RET_SERVER_SUCC, nil);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"同步失败%@",operation.responseString);
        if (block) {
                block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString*)userId completion:(void (^)(RCUserInfo*))completion
{
    if ([userId length] == 0)
        return;
    RCUserInfo *userInfo = [[RCUserInfo alloc] init];
    if ([userId isEqual:[self getAccountId]]) {
        userInfo.name = [self getNickName];
        userInfo.userId = [self getAccountId];
        userInfo.portraitUri = [self getHeadImage];
        completion(userInfo);
    }
    else
    {
        if([userId isEqualToString:SERVICE_ID])
        {
            userInfo.name = @"空君";
            userInfo.userId = SERVICE_ID;
//            userInfo.portraitUri = ;
            completion(userInfo);
            return;
        }
        
        NSDictionary *dic = [[FreeSQLite sharedInstance] selectFreeSQLiteUserInfo:userId];
        if (dic != nil) {
            userInfo.name = dic[@"friendName"];
            userInfo.userId = dic[@"friendAccountId"];
            userInfo.portraitUri = dic[@"imgUrl"];
            completion(userInfo);
        }
        else
        {
            [self getOtherUserInfoCompletion:userId block:^(NSUInteger ret, id data) {
                if(ret == RET_SERVER_SUCC)
                {
                    userInfo.name = data[@"nickName"];
                    userInfo.userId = userId;
                    userInfo.portraitUri = data[@"headImg"];
                    completion(userInfo);
                }
            }];
        }
    }
    
}

- (void)getGroupInfoWithGroupId:(NSString*)groupId completion:(void (^)(RCGroup*))completion
{
    if ([groupId length] == 0)
        return;
    //开发者调自己的服务器接口根据userID异步请求数据
    [self getGroupInfoById:groupId block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            RCGroup *RCgroup = [[RCGroup alloc] init];
            RCgroup.groupId = groupId;
            if (![data[@"groupName"] isKindOfClass:[NSNull class]]) {
                RCgroup.groupName = data[@"groupName"];
            }
            if (![data[@"groupUrl"] isKindOfClass:[NSNull class]]) {
                RCgroup.portraitUri = data[@"groupUrl"];
            }
            
            completion(RCgroup);
        }
    }];
}

#pragma mark -图片相关
- (NSInteger) userSubmitImgOnCompletion:(UIImage *)photo ratio:(float)ratio block:(FreeBlock)block {
    
    NSString* strUrl = URL_UPLOAD_IMG;
    
    //validate params
    
    if (!photo) {
        
        return ERR_HEAD_IMG_IS_NIL;
    }
    
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    AFHTTPRequestOperationManager *mger = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:strUrl]];
    //    NSData *imageData = UIImageJPEGRepresentation(photo, 1);
    NSData *imageData = UIImagePNGRepresentation(photo);
    
    while (imageData.length > ratio * 1024 * 1024) {
        photo = [FreeImageScale compressImage:photo ratio:0.3];
        imageData = UIImagePNGRepresentation(photo);
        //        imageData = UIImageJPEGRepresentation(photo, 1);
    }
    
    
    
    AFHTTPRequestOperation *op = [mger POST:strUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        [formData appendPartWithFileData:imageData name:@"564" fileName:[NSString stringWithFormat:@"%@.png",[self getTimeStamp]] mimeType:@"image/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            if (block) {
                NSString* headUrl;
                NSString* suffix = [[responseObject objectForKey:@"entity"] componentsSeparatedByString:@"#%#"][0];
                headUrl = [NSString stringWithFormat:@"%@/photos/%@",IMG_ROOT_URL,suffix];
                
                block(RET_SERVER_SUCC, headUrl);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
    }];
    [op start];
    
    return RET_OK;
}

//上传多张图片
- (NSInteger) userSubmitImgArrayOnCompletion:(NSMutableArray *)photoArray block:(FreeBlock)block {
    
    NSString* strUrl = URL_UPLOAD_IMG;
    
    //validate params
    
    if (![photoArray count]) {
        
        return ERR_COVER_IMG_IS_NIL;
    }
    
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    AFHTTPRequestOperationManager *mger = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:strUrl]];
    NSMutableArray *picArray = [NSMutableArray array];
    for (int i = 0; i < [photoArray count]; i++) {
        UIImage *pic = photoArray[i];
        NSData *imageData = UIImagePNGRepresentation(pic);
        
        while (imageData.length > 1.0 * 1024 * 1024) {
            pic = [FreeImageScale compressImage:pic ratio:1.0];
            imageData = UIImagePNGRepresentation(pic);
        }
        
        [picArray addObject:imageData];
        
    }
    //    NSData *imageData = UIImageJPEGRepresentation(photo, 1);
    
    
    AFHTTPRequestOperation *op = [mger POST:strUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for (NSData *imgData in picArray) {
            [formData appendPartWithFileData:imgData name:@"564" fileName:[NSString stringWithFormat:@"%@.png",[self getTimeStamp]] mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            if (block) {
                NSString* headUrl;
                NSArray *array = [[responseObject objectForKey:@"entity"] componentsSeparatedByString:@"#%#"]; //从字符A中分隔成2个元素的数组；
                NSString* suffix = [[responseObject objectForKey:@"entity"] componentsSeparatedByString:@"#%#"][0];
                NSString *str = @"#%#";
                headUrl = [NSString stringWithFormat:@"%@/photos/%@",IMG_ROOT_URL,suffix];
                for(int i = 1; i < [array count] - 1; i++)
                {
                    NSString* url = [NSString stringWithFormat:@"%@/photos/%@",IMG_ROOT_URL,array[i]];
                    headUrl = [NSString stringWithFormat:@"%@%@%@", headUrl, str, url];
                }
                
                block(RET_SERVER_SUCC, headUrl);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
    }];
    [op start];
    
    return RET_OK;
}

#pragma mark -注册登录
//注册
- (NSInteger) userRegisterOnCompletion:(NSString *)sms nickname:(NSString *)nickname pwd:(NSString *)pwd gender:(NSString *)gender phone:(NSString *)phone_num headUrl:(NSString *)headUrl inviteCode:(NSString *)inviteCode deviceToken:(NSString *)deviceToken block:(FreeBlock)block
{
    NSString* strUrl = URL_REGISTER;
    
    //validate params
    if (!nickname || nickname.length == 0) {
        return ERR_NICK_NAME_IS_NIL;
    }
    
    if (nickname.length > 8) {
        return ERR_NICKNAME_TOO_LONG;
    }
    
    if (![self isSMSCode:sms]) {
        return ERR_INVALID_SMS_CODE;
    }
    if (!gender || gender.length == 0) {
        return ERR_SEX_IS_NIL;
    }
    if (pwd.length < 6) {
        return ERR_PASSWORD_TOO_SHORT;
    }
    
    if ([inviteCode length] < 5 && [inviteCode length] > 0) {
        return ERR_INVITE_CODE_LENGTH_TOO_SHORT;
    }
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    //MD5 handle pwd
    NSString* md5Pwd = [self md5:pwd];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:phone_num, @"phoneNo", nickname, @"nickName", gender,@"gender", md5Pwd, @"password", sms, @"validateCode", headUrl, @"headImg", deviceToken, @"deviceToken",nil];
    
    if (inviteCode) {
        [dict setObject:inviteCode forKey:@"inviteCode"];
    }
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            if (block) {
                id data = [self strToJson:operation.responseString];
                
                _token = data[@"accessToken"];
                //存储到 keychain
                [[NSUserDefaults standardUserDefaults] setObject:_token forKey:SERVICE_FOR_SS_KEYCHAIN_TOKEN];
                
                if (![data[@"imToken"] isKindOfClass:[NSNull class]] && data[@"imToken"] != nil) {
                    _rongyunToken = data[@"imToken"];
                    //存储融云token
                    [[NSUserDefaults standardUserDefaults] setObject:_rongyunToken forKey:SERVICE_FOR_RONGYUN_TOKEN];
                }
                
                _phoneNo = phone_num;
                [self setAFHTTPSessionManagerToken:_token];
                block(RET_SERVER_SUCC, data[@"account"]);
            }
        }
        else
        {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//用于申请验证码
- (NSInteger) userGetSmsOnCompletion:(NSString *)phone_num block:(FreeBlock)block {
    
    NSString* strUrl = URL_GET_SMS;
    
    //validate params
    if (!phone_num || ![self isMobileNo:phone_num]) {
        return ERR_INVALID_MOBILE_NO;
    }
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    //prepare data for posting
    NSData* bodyData = [phone_num dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:bodyData strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            if (block) {
                block(RET_SERVER_SUCC, operation.responseString);
                _phoneNo = phone_num;
                //  [[NSUserDefaults standardUserDefaults] setObject:self.accountId forKey:KEY_ACCOUNT_ID];
                
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    
    return RET_OK;
    
}

//登录
- (NSInteger) userLoginOnCompletion:(NSString *)phone_num pwd:(NSString *)pwd deviceToken:(NSString *)deviceToken block:(FreeBlock)block
{
    
    NSString* strUrl = URL_LOGIN;
    
#warning 运营登陆，记得修改
    //validate params
    if (!phone_num || ![self isMobileNo:phone_num]) {
        return ERR_INVALID_MOBILE_NO;
    }
    
    if (pwd.length < 6) {
        return ERR_PASSWORD_TOO_SHORT;
    }
    
    if (pwd.length > 20)
    {
        return ERR_PASSWORD_TOO_LONG;
    }
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    //MD5 handle pwd
    NSString* md5Pwd = [self md5:pwd];
    
    //prepare data for posting
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:phone_num, @"phoneNo", md5Pwd, @"password", deviceToken, @"deviceToken",nil];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            if (block) {
                id data = [self strToJson:operation.responseString];
                
                self.token = data[@"accessToken"];
                self.rongyunToken = data[@"imToken"];
                //存储到 keychain
                [[NSUserDefaults standardUserDefaults] setObject:_token forKey:SERVICE_FOR_SS_KEYCHAIN_TOKEN];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (![_rongyunToken isKindOfClass:[NSNull class]] && [_rongyunToken length]) {
                    //存储融云token
                    [[NSUserDefaults standardUserDefaults] setObject:_rongyunToken forKey:SERVICE_FOR_RONGYUN_TOKEN];
                }
                _phoneNo = phone_num;
                [[NSUserDefaults standardUserDefaults] setObject:phone_num forKey:KEY_PHONE_NO];
                [self setAFHTTPSessionManagerToken:_token];
                block(RET_SERVER_SUCC, data[@"account"]);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
    
}
//获取我的信息
- (NSInteger) getUserInfoOnCompletion:(FreeBlock)block {
    
    NSString* strUrl = URL_GET_USERINFO;
    
    [manager GET:strUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
            
            if ([(NSHTTPURLResponse *)task.response statusCode] == ERR_SERVER_401) {
                block(ERR_SERVER_401,@"异地登录");
                NOTIFY_IF_NEED_LOGIN(ERR_SERVER_401);
            }
            else
            {
                block(RET_SERVER_FAIL, err.description);
                NSLog(@"err is %@", err.description);
            }
        }
    }];
    
    return RET_OK;
}

//更换头像
- (NSInteger ) userEditHeadImgOnCompletion:(NSString *)img_url block:(FreeBlock)block {
    
    NSString* strUrl = URL_EDIT_HEADIMG;
    
    //prepare data for posting
    NSData* bodyData = [img_url dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:bodyData strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            if (block) {
                if ([operation.responseString isEqualToString:img_url]) {
                    block(RET_SERVER_SUCC, operation.responseString);
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    
    return RET_OK;
}
//更换昵称
- (NSInteger) userEditNickNameOnCompletion:(NSString *)nickName block:(FreeBlock)block {
   
    NSString* strUrl = URL_EDIT_NICKNAME;
    
    //check params
    if (!nickName || nickName.length == 0) {
        return ERR_NICK_NAME_IS_NIL;
    }
    if (nickName.length > 8) {
        return ERR_NICKNAME_TOO_LONG;
    }
    //prepare data for posting
    NSData* bodyData = [nickName dataUsingEncoding:NSUTF8StringEncoding];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:bodyData strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            if (block) {
                block(RET_SERVER_SUCC, operation.responseString);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    
    return RET_OK;
}
//退出登录
- (NSInteger) userLoginOutCompletion:(FreeBlock)block
{
    NSString *strUrl = URL_LOGOUT;
    
    if (!block)
    {
        
        return ERR_BLOCK_IS_NIL;
    }
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            block(RET_SERVER_SUCC, operation.responseString);
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SERVICE_FOR_SS_KEYCHAIN_TOKEN];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if ([(NSHTTPURLResponse *)operation.response statusCode] == ERR_SERVER_401) {
//            
//            block(ERR_SERVER_401,@"异地登录");
//            NOTIFY_IF_NEED_LOGIN(ERR_SERVER_401);
//        }
        block(RET_SERVER_FAIL, operation.responseString);
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//游客注册登录
- (NSInteger) visitorLoginCompletion:(NSString *)uid nickName:(NSString *)nickName headImg:(NSString *)headImg gender:(NSString *)gender type:(NSString *)type deviceToken:(NSString *)deviceToken block:(FreeBlock)block
{
    NSString* strUrl = URL_REGISTER;
    
    //validate params
    if (!nickName || nickName.length == 0) {
        return ERR_NICK_NAME_IS_NIL;
    }
    
    if (!uid) {
        return ERR_INVALID_SMS_CODE;
    }
    
    if (!gender || gender.length == 0) {
        return ERR_SEX_IS_NIL;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:uid, @"phoneNo", nickName, @"nickName", gender,@"gender", headImg, @"headImg", type, @"type", nil];
    
    if (deviceToken) {
        [dict setObject:deviceToken forKey:@"deviceToken"];
    }
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            if (block) {
                id data = [self strToJson:operation.responseString];
                
                _token = data[@"accessToken"];
                //存储到 keychain
                [[NSUserDefaults standardUserDefaults] setObject:_token forKey:SERVICE_FOR_SS_KEYCHAIN_TOKEN];
                
                if (![data[@"imToken"] isKindOfClass:[NSNull class]] && data[@"imToken"] != nil) {
                    _rongyunToken = data[@"imToken"];
                    //存储融云token
                    [[NSUserDefaults standardUserDefaults] setObject:_rongyunToken forKey:SERVICE_FOR_RONGYUN_TOKEN];
                }
                _phoneNo = uid;
                [self setAFHTTPSessionManagerToken:_token];
                block(RET_SERVER_SUCC, data[@"account"]);
            }
        }
        else
        {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//绑定手机号
- (NSInteger)bindVisitorPhoneNoOnCompletion:(NSString *)phoneNo sms:(NSString *)sms password:(NSString *)password block:(FreeBlock)block
{
    if (![self isSMSCode:sms]) {
        return ERR_INVALID_SMS_CODE;
    }
    
    if (password.length < 6) {
        return ERR_PASSWORD_TOO_SHORT;
    }
    
    if (password.length > 20) {
        return ERR_PASSWORD_TOO_LONG;
    }
    
    if (!phoneNo || ![self isMobileNo:phoneNo]) {
        return ERR_INVALID_MOBILE_NO;
    }
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    NSString *strUrl = URL_BIND_PHONENO;
    
    //MD5 handle pwd
    NSString* md5Pwd = [self md5:password];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:phoneNo, @"phoneNo", md5Pwd, @"password", sms, @"validateCode", nil];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            if (block) {
                _phoneNo = phoneNo;
                [[NSUserDefaults standardUserDefaults] setObject:phoneNo forKey:KEY_PHONE_NO];
                block(RET_SERVER_SUCC, operation.responseString);
            }
        }
        else
        {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark -通讯录相关

- (NSInteger) getAddressListOnCompletion:(FreeBlock)block
{
    NSString *strUrl = URL_ADDRESS_QUERY;
    
    [manager GET:strUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
         if (block)
         {
             block(RET_SERVER_SUCC,responseObject);
         }
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         if (block)
         {
             block(RET_SERVER_FAIL, error.description);
             NSLog(@"错误信息%@",error.description);
         }
         
     }];
    
    return RET_OK;
}

//传通讯录给服务器
- (NSInteger) sendAddressListOnCompletion:(NSString *)phoneList block:(FreeBlock)block {
    NSString *strUrl = URL_ADDRESS_LIST;
    
    if (!phoneList || [phoneList length] == 0) {
        return ERR_ADDRESS_LIST_IS_NIL;
    }
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    NSData* sendData = [phoneList dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:sendData strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            NSArray *data = [self strToJson:operation.responseString];
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark -日程表
//获取日程表
- (NSInteger) getCalendarOnCompletion:(FreeBlock)block
{
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    NSString *strUrl = URL_CALENDAR_LIST;
    
    [manager GET:strUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
         if (block)
         {
             block(RET_SERVER_SUCC,responseObject);
         }
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         if (block)
         {
             if ([(NSHTTPURLResponse *)task.response statusCode] == ERR_SERVER_401) {
                 block(ERR_SERVER_401,@"异地登录");
             }
             else
             {
                 block(RET_SERVER_FAIL,error.description);
                 NSLog(@"错误信息%@",error.description);
             }
         }
         
     }];
    
    return RET_OK;
}

//修改日程表－添加
- (NSInteger) addCalendarOnCompletion:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart  City:(NSString *)city remark:(NSString *)remark position:(NSString *)position block:(FreeBlock)block
{
    if (!freeDate) {
        return ERR_FREEDATE_IS_NIL;
    }
    
    NSString *strUrl = URL_CALENDAR_ADD;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:freeDate, @"freeDate", city, @"city", nil];
    
    if (remark != nil) {
//        dict = [[NSDictionary alloc] initWithObjectsAndKeys:freeDate, @"freeDate", remark, @"remark", city, @"city", nil];
        [dict setObject:remark forKey:@"remark"];
    }
    
    if (position) {
        [dict setObject:position forKey:@"position"];
    }
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            if (block) {
                block(RET_SERVER_SUCC, operation.responseString);
            }
        }
        else
        {
            NSLog(@"addCalendar error code is :%ld", (long)operation.response.statusCode);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            if ([(NSHTTPURLResponse *)operation.response statusCode] == ERR_SERVER_401) {
                block(ERR_SERVER_401,@"异地登录");
                NOTIFY_IF_NEED_LOGIN(ERR_SERVER_401);
            }
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//修改日程表－取消
- (NSInteger) cancelCalendarOnCompletion:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart block:(FreeBlock)block
{
    if (!freeDate) {
        return ERR_FREEDATE_IS_NIL;
    }
    
//    if (!freeTimeStart) {
//        return ERR_FREEDATE_START_IS_NIL;
//    }
    
    NSString *strUrl = URL_CALENDAR_CANCEL;
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:freeDate, @"freeDate", nil];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            if (block) {
                block(RET_SERVER_SUCC, operation.responseString);
            }
        }
        else
        {
            NSLog(@"addCalendar error code is :%ld", (long)operation.response.statusCode);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            if ([(NSHTTPURLResponse *)operation.response statusCode] == ERR_SERVER_401) {
                block(ERR_SERVER_401,@"异地登录");
                NOTIFY_IF_NEED_LOGIN(ERR_SERVER_401);
            }
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//获取匹配的好友列表
- (NSInteger) getCoupleArray:(FreeBlock)block
{
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    NSString *strUrl = URL_QUERY_FREE_MATCH;
    
    [manager GET:strUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
         if (block)
         {
             block(RET_SERVER_SUCC,responseObject);
         }
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         if (block)
         {
//             if ([(NSHTTPURLResponse *)task.response statusCode] == ERR_SERVER_401) {
//                 block(ERR_SERVER_401,@"异地登录");
//                 NOTIFY_IF_NEED_LOGIN(ERR_SERVER_401);
//             }
             
             block(RET_SERVER_FAIL,error.description);
             NSLog(@"错误信息%@",error.description);
         }
         
     }];
    
    return RET_OK;
}
//获取群员人数
-(NSInteger)getcrowdInfoOncompetion:(NSString *)crowdId block:(FreeBlock)block
{
     NSString *crowdUrl = [URL_QUERY_GROUP_BY_ID stringByAppendingString:crowdId];
    
    [manager GET:crowdUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
        block(RET_SERVER_SUCC, responseObject);
  
    } failure:^(NSURLSessionDataTask *task, NSError* err)
    {
        block(RET_SERVER_FAIL, err.description);
    }];
    
    return RET_OK;
}
#pragma mark -获取标签
- (NSInteger) postobtainLaleOncompletion:(NSString *)obtainName block:(FreeBlock )block
{

    if (!block)
    {
        return ERR_BLOCK_IS_NIL;
    }
    
     NSString *strUrl = URL_OBTAIN_SET;

     NSData* sendData = [obtainName dataUsingEncoding:NSUTF8StringEncoding];
    
     AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:sendData strUrl:strUrl]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, operation.responseString);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

- (NSInteger) getobtainLableOncompletion:(FreeBlock)block
{
    NSString *obtainPath = URL_OBTAIN;
    
    [manager GET:obtainPath parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
    {
        if (block)
        {
            block(RET_SERVER_SUCC,responseObject);
        }
    }
         failure:^(NSURLSessionDataTask *task, NSError *error)
    {
        if (block)
        {
            block(RET_SERVER_FAIL,error.description);
            NSLog(@"错误信息%@",error.description);
        }

    }];
    
    return RET_OK;
}

#pragma mark -上传城市

- (NSInteger) postCityOnCompletion:(NSString *)city block:(FreeBlock)block
{
    NSString *passUrl = URL_UPLOAD_CITY;
    
    if (!block)
    {
        return ERR_BLOCK_IS_NIL;
    }
    
    if (!city) {
        return 0;
    }
    
    NSData* sendData = [city dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:sendData strUrl:passUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (operation.response.statusCode == RET_SERVER_SUCC)
         {
             if (block)
             {
                 block(RET_SERVER_SUCC,operation.responseString);
             }
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@",operation.responseString);
         if (block)
         {
             block(RET_SERVER_FAIL,operation.responseString);
         }
     }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark -别的用户信息
//获取别的用户的信息
- (NSInteger) getOtherUserInfoCompletion:(NSString *)otherUserId block:(ZcBlock)block
{
    if (!otherUserId) {
        return ERR_USER_ID_IS_NIL;
    }
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    NSString *strUrl  = [URL_GET_OTHER_USER_INFO stringByAppendingString:otherUserId];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:GET_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            id data = [self strToJson:operation.responseString];
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//获取别的用户的推荐
- (NSInteger) queryOtherPostList:(NSString *)pageNo pageSize:(NSString *)pageSize postId:(NSString *)postId accountId:(NSString *)otherId block:(FreeBlock)block
{
    NSString* strUrl = [NSString stringWithFormat:@"%@/%@/%@", URL_QUERY_OTHER_POSTLIST, pageNo, pageSize];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:otherId, @"accountId", postId, @"postId", nil];
    
    [manager GET:strUrl parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
            block(RET_SERVER_FAIL, err.description);
        }
    }];
    
    return RET_OK;
}

//获取别的用户的想去
- (NSInteger) queryOtherLikeList:(NSString *)pageNo pageSize:(NSString *)pageSize postId:(NSString *)postId accountId:(NSString *)otherId block:(FreeBlock)block
{
    NSString* strUrl = [NSString stringWithFormat:@"%@/%@/%@", URL_QUERY_OTHER_LIKELIST, pageNo, pageSize];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:otherId, @"accountId", postId, @"postId", nil];
    
    [manager GET:strUrl parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
            block(RET_SERVER_FAIL, err.description);
        }
    }];
    return RET_OK;
}

#pragma  mark-找回密码
- (NSInteger) userGetPassWordOnCompletion:(NSString *)phone_num block:(FreeBlock)block
{
    NSString *passUrl = URL_GET_SMS_TO_FIND_PWD;
    
    if (!phone_num || ![self isMobileNo:phone_num])
    {
        return ERR_INVALID_MOBILE_NO;
    }
    
    if (!block)
    {
        return ERR_BLOCK_IS_NIL;
    }
    
    NSData *phoneDate = [phone_num dataUsingEncoding:NSUTF8StringEncoding];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:phoneDate strUrl:passUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (operation.response.statusCode == RET_SERVER_SUCC)
        {
            if (block)
            {
                block(RET_SERVER_SUCC,operation.responseString);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"%@",operation.responseString);
        if (block)
        {
            block(RET_SERVER_FAIL,operation.responseString);
        }
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark -更新密码
- (NSInteger) UserFinishGetPassWordOnCompletion:(NSString *)phone_num pwd:(NSString *)pwd_num pwd_confirm:(NSString *)pwd_confirm sms:(NSString *)sms block:(FreeBlock)block
{
    NSString *finishUrl = URL_FIND_PWD;
    
    if(![self isSMSCode:sms])
    {
        return ERR_INVALID_SMS_CODE;
    }
    if (![pwd_num isEqualToString:pwd_confirm]) {
        return ERR_PWD_NOT_SAME;
    }
    if (pwd_num.length<6) {
        return ERR_PASSWORD_TOO_SHORT;
    }
    if (pwd_confirm.length<6) {
        
        return ERR_PASSWORD_TOO_SHORT;

    }
    if (pwd_num.length>16) {
        
        return ERR_PASSWORD_TOO_LONG;
    }
    //MD5
     NSString *md5pwd = [self md5:pwd_num];
    
     NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:phone_num, @"phoneNo", md5pwd, @"password", sms, @"validateCode",nil];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:finishUrl]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (operation.response.statusCode == RET_SERVER_SUCC)
        {
            if (block)
            {
                block(RET_SERVER_SUCC, operation.responseString);
                self.token = operation.responseString;
                
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
        
        NSLog(@"%@",operation.responseString);
        if (block)
        {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperation:operation];
    
    return RET_OK;
}
//发送关注不关注请求
- (NSInteger) sendIfConcern:(NSString *)accountId status:(NSString *)status block:(FreeBlock)block
{
    if (!accountId || [accountId length] == 0) {
        return ERR_ACCOUNTID_IS_NIL;
    }
    
    NSString *strUrl = URL_SEND_STATUS;
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:accountId, @"id", status, @"status", nil];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            block(RET_SERVER_SUCC, operation.responseString);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}
#pragma mark -意见反馈
- (NSInteger)sendIdeaCompletion:(NSString *)content block:(FreeBlock)block
{
    NSString *path = URL_SUGGESTION_POST;
    
    if (!content || content.length == 0)
    {
        return ERR_IDEASEND_IS_NIL;
    }
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys: content,@"content", nil];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:path]];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC)
        {
            
            block(RET_SERVER_SUCC, operation.responseString);

        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     
    {
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        if (block) {
            if ([(NSHTTPURLResponse *)operation.response statusCode] == ERR_SERVER_401) {
                block(ERR_SERVER_401,@"异地登录");
                NOTIFY_IF_NEED_LOGIN(ERR_SERVER_401);
            }
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark - 二度人脉相关

- (NSInteger)editErDu:(BOOL)isOn block:(FreeBlock)block
{
    NSString *strUrl = URL_EDIT_ERDU_STATUS;
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            block(RET_SERVER_SUCC, operation.responseString);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark - 两人位置推荐
- (NSInteger)bothNearBy:(NSString *)accountId block:(FreeBlock)block
{
    if (!accountId) {
        return ERR_ACCOUNTID_IS_NIL;
    }
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", URL_BOTH_NEARBY, accountId];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:GET_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            id data = [self strToJson:operation.responseString];
            
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark - 登录图片
- (NSInteger) getAppLaunchUrl:(FreeBlock)block
{
    NSString *strUrl = URL_APP_LUANCH;
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:GET_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, operation.responseString);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark -活动
//活动新端口
- (NSInteger) postAcitiveInfoOnCompletion:(NSString *)title activityDate:(NSString *)activityDate activityTime:(NSString *)activityTime activityContent:(NSString *)activityContent position:(PositionModel *)positionModel imgUrl:(NSString *)imgUrl FriendsList:(NSArray *)friendsList postId:(NSString *)postId block:(FreeBlock)block
{
    NSString *strUrl = URL_SEND_ACTIVE;
    
    if (!title || [title length] == 0) {
        return ERR_ACTIVE_TITLE_IS_NIL;
    }
    
    if (!activityTime || [activityTime length] == 0) {
        return ERR_FREEDATE_START_IS_NIL;
    }
    
    if (!activityDate || [activityDate length] == 0) {
        return ERR_FREEDATE_START_IS_NIL;
    }
    
    if (!activityContent || [activityContent length] == 0) {
        return ERR_ACTIVE_CONTENT_IS_NIL;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:title forKey:@"title"];
    [dict setObject:activityTime forKey:@"activityTime"];
    [dict setObject:activityDate forKey:@"activityDate"];
    [dict setObject:activityContent forKey:@"activityContent"];
    [dict setObject:positionModel.position_name forKey:@"address"];
    if (positionModel.latitude) {
        NSString *positionStr = [NSString stringWithFormat:@"%f-%f", positionModel.latitude, positionModel.longitude];
        [dict setObject:positionStr forKey:@"position"];
    }
    if (imgUrl) {
        [dict setObject:imgUrl forKey:@"imgUrl"];
    }
    
    if ([friendsList count]) {
        [dict setObject:friendsList forKey:@"attendList"];
    }
    
    if (postId) {
        [dict setObject:postId forKey:@"postId"];
    }
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            id data = [self strToJson:operation.responseString];
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            block(operation.response.statusCode, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
    
}



- (NSInteger) postAcitiveInfoOnCompletion:(NSString *)freeDate freeStartTime:(NSString *)freeStartTime activeContent:(NSString *)activeContent block:(FreeBlock)block
{
    NSString *strUrl = URL_SEND_ACTIVE;
    NSInteger timeTag = [freeStartTime integerValue] + 6;
    
    if([self isPostTime:[self changeString2Date:freeDate] freeStartTime:timeTag])
    {
        return ERR_DATE_IS_POST;
    }
    
    if (!freeDate || [freeDate length] == 0) {
        return ERR_FREEDATE_IS_NIL;
    }
    
    if (!freeStartTime || [freeStartTime length] == 0) {
        return ERR_FREEDATE_START_IS_NIL;
    }
    
    if (!activeContent || [activeContent length] == 0) {
        return ERR_ACTIVE_CONTENT_IS_NIL;
    }
    
    if ([activeContent length] > 30) {
        return ERR_ACTIVE_CONTENT_TOO_LONG;
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:freeDate, @"activityDate", freeStartTime, @"activityTimeStart", activeContent, @"activityContent", nil];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            id data = [self strToJson:operation.responseString];
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            block(operation.response.statusCode, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//获取活动信息
- (NSInteger)getActiveInfoOnCompletion:(FreeBlock)block
{
    NSString *strUrl = URL_SEND_QUERY;
    
    [manager GET:strUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
         if (block)
         {
             block(RET_SERVER_SUCC,responseObject);
         }
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         if (block)
         {
             block(RET_SERVER_FAIL,error.description);
             NSLog(@"错误信息%@",error.description);
         }
         
     }];
    
    return RET_OK;
}

//获取某一时间段活动信息
- (NSInteger)getActiveInfoByTimeOnCompletion:(NSString *)freeDate freeStartTime:(NSString *)freeStartTime block:(FreeBlock)block
{
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@", URL_QUERYACTIVITY_BY_TIME, freeDate, freeStartTime];
    
    [manager GET:strUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
     {
         if (block)
         {
             block(RET_SERVER_SUCC,responseObject);
         }
     }
         failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         if (block)
         {
             block(RET_SERVER_FAIL,error.description);
             NSLog(@"错误信息%@",error.description);
         }
         
     }];
    
    return RET_OK;
}

//查询活动信息
- (NSInteger)activeDetailOnCompletion:(NSString *)activityId block:(FreeBlock)block
{
    if (!activityId) {
        return ERR_ACTIVE_ID_IS_NIL;
    }
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    NSString *activeIdStr = [NSString stringWithFormat:@"%@", activityId];
    
    NSString *strUrl  = [URL_ACTIVE_DETAIL stringByAppendingString:activeIdStr];
    
    [manager GET:strUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        block(RET_SERVER_SUCC, responseObject);
        //NSLog(@"responseObj is %@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        block(RET_SERVER_FAIL, err.description);
        NSLog(@"err is %@", err.description);
    }];
    
    return RET_OK;
}

//解散活动
- (NSInteger)cancelActiveOnCompletion:(NSString *)activityId block:(FreeBlock)block
{
    NSString *activeIdStr = [NSString stringWithFormat:@"%@", activityId];
    
    NSString *strUrl  = [URL_CANCEL_ACTIVE stringByAppendingString:activeIdStr];
    
    if (!activityId) {
        return ERR_ACTIVE_ID_IS_NIL;
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:activityId, @"activityId", nil];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, responseObject);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
    
}

//退出活动
- (NSInteger) exitActiveOnCompletion:(NSString *)activityId block:(FreeBlock)block
{
    if (!activityId) {
        return ERR_ACTIVE_ID_IS_NIL;
    }
    
    NSString *activeIdStr = [NSString stringWithFormat:@"%@", activityId];
    
    NSString *strUrl  = [URL_EXIT_ACTIVE stringByAppendingString:activeIdStr];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, responseObject);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//参加活动
- (NSInteger) attendActiveOnCompletion:(NSString *)activityId block:(FreeBlock)block
{
    if (!activityId) {
        return ERR_ACTIVE_ID_IS_NIL;
    }
    
    NSString *activeIdStr = [NSString stringWithFormat:@"%@", activityId];
    
    NSString *strUrl  = [URL_ATTEND_ACTIVE stringByAppendingString:activeIdStr];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, responseObject);
        }
        else
        {
            block(operation.response.statusCode, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//编辑活动
- (NSInteger) editAcitiveInfoOnCompletion:(NSString *)freeDate freeStartTime:(NSString *)freeStartTime activeContent:(NSString *)activeContent activityId:(NSString *)activityId block:(FreeBlock)block
{
    NSString *strUrl = URL_EDIT_ACTIVE;
    
    if (!freeDate || [freeDate length] == 0) {
        return ERR_FREEDATE_IS_NIL;
    }
    
    if (!freeStartTime || [freeStartTime length] == 0) {
        return ERR_FREEDATE_START_IS_NIL;
    }
    
    if (!activeContent || [activeContent length] == 0) {
        return ERR_ACTIVE_CONTENT_IS_NIL;
    }
    
    if ([activeContent length] > 30) {
        return ERR_ACTIVE_CONTENT_TOO_LONG;
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:freeDate, @"activityDate", freeStartTime, @"activityTimeStart", activeContent, @"activityContent", activityId, @"activityId", nil];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, operation.responseString);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//邀请好友
- (NSInteger) inviteAcitiveInfoOnCompletion:(NSString *)activityId friendsList:(NSArray *)friendsList block:(FreeBlock)block
{
    NSString *strUrl = URL_INVITE_ACTIVE;
    
    if (!activityId || [activityId length] == 0) {
        return ERR_ACTIVE_ID_IS_NIL;
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:activityId, @"activityId", friendsList, @"attendList", nil];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, operation.responseString);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//加入群聊
- (NSInteger)joinGroupOnCompletion:(NSString *)groupId block:(FreeBlock)block
{
    if (!groupId) {
        return ERR_ACTIVE_ID_IS_NIL;
    }
    
    NSString *activeIdStr = [NSString stringWithFormat:@"%@", groupId];
    
    NSString *strUrl  = [URL_JOIN_GROUP stringByAppendingString:activeIdStr];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, responseObject);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//退出群聊
- (NSInteger)quitGroupOnCompletion:(NSString *)groupId block:(FreeBlock)block
{
    if (!groupId) {
        return ERR_ACTIVE_ID_IS_NIL;
    }
    
    NSString *activeIdStr = [NSString stringWithFormat:@"%@", groupId];
    
    NSString *strUrl  = [URL_QUIT_GROUP stringByAppendingString:activeIdStr];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, responseObject);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//解散群聊
- (NSInteger)dismissGroupOnCompletion:(NSString *)groupId block:(FreeBlock)block
{
    if (!groupId) {
        return ERR_ACTIVE_ID_IS_NIL;
    }
    
    NSString *activeIdStr = [NSString stringWithFormat:@"%@", groupId];
    
    NSString *strUrl  = [URL_DISMISS_GROUP stringByAppendingString:activeIdStr];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, responseObject);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark - 发现
- (NSInteger)sendPostInfoOnCompletion:(PostModel *)model block:(FreeBlock)block
{
    if (![model.content length]) {
        return ERR_CONTENT_IS_NIL;
    }
    
    if (![model.tags length]) {
        return ERR_TAGS_IS_NIL;
    }
    
    if (![model.address length]) {
        return ERR_POSITION_IS_NIL;
    }
    
    NSString *strUrl = URL_POST_ADD;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:model.content forKey:@"content"];
    [dic setObject:model.url forKey:@"url"];
    
    if ([model.city length]) {
        [dic setObject:model.city forKey:@"city"];
    }
    
    [dic setObject:model.address forKey:@"address"];
    
//    if ([model.address length]) {
//
//    }
    if ([model.position length]) {
        [dic setObject:model.position forKey:@"position"];
    }
    if ([model.tags length]) {
        [dic setObject:model.tags forKey:@"tag"];
    }
    
    if ([model.postImg length]) {
        [dic setObject:model.postImg forKey:@"postImg"];
    }
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dic] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            NSString *result = [[ NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            block(RET_SERVER_SUCC, result);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//查询帖子
- (NSInteger)getPostInfoOnCompletion:(NSString *)pageNo pageSize:(NSString *)pageSize postStatus:(NSString *)postStatus postId:(NSString *)postId upOrDown:(NSString *)upOrDown city:(NSString *)city block:(FreeBlock)block
{
    NSString* strUrl = [NSString stringWithFormat:@"%@/%@/%@", URL_QUERY_POST, pageNo, pageSize];
    NSMutableDictionary *dict;
    
    if ([postStatus isEqualToString:CHOSEN_TYPE]) {
        if ([postId length]) {
            dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:postStatus, @"type", postId, @"recommendTime", upOrDown, @"action", nil];
        }
        else
        {
            dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:postStatus, @"type", upOrDown, @"action",nil];
        }
    }
    else
    {
        dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:postStatus, @"type", postId, @"postId", upOrDown, @"action", nil];
    }
    
    if (![city isEqualToString:@"北京市"] && ![city isEqualToString:@"上海市"] && ![city isEqualToString:@"广州市"]) {
        city = @"成都市";
    }
    [dict setObject:city forKey:@"city"];
    
    [manager GET:strUrl parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
            if ([(NSHTTPURLResponse *)task.response statusCode] == ERR_SERVER_401) {
                block(ERR_SERVER_401,@"异地登录");
                NOTIFY_IF_NEED_LOGIN(ERR_SERVER_401);
            } else {
                block(RET_SERVER_FAIL, err.description);
            }
            
        }
    }];
    
    return RET_OK;
}

//获取banner
- (NSInteger)getBannerOnCompletion:(FreeBlock)block
{
    NSString* strUrl = URL_GET_BANNER;
    
    [manager GET:strUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
                block(RET_SERVER_FAIL, err.description);
            }
    }];
    
    return RET_OK;
}

//点想去
- (NSInteger)upPostInfoOnCompletion:(NSString *)postId type:(NSString *)type block:(FreeBlock)block
{    
    NSString *strUrl = URL_UP_POST;
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:postId, @"contentId", type, @"type", nil];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
//    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            NSString *result  =[[ NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            block(RET_SERVER_SUCC, result);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//取消想去
- (NSInteger)cancelPostInfoOnCompletion:(NSString *)postId block:(FreeBlock)block
{
    NSString *strUrl = [NSString stringWithFormat:@"%@/%@", URL_CANCEL_POST, postId];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, responseObject);
        }
        else
        {
            block(operation.response.statusCode, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//帖子详情
- (NSInteger)postDetailOnCompletion:(NSString *)postId block:(FreeBlock)block
{
    if (![postId length]) {
        return ERR_POSTID_IS_NIL;
    }
    
    NSString *postStrId = [NSString stringWithFormat:@"%@", postId];
    NSString *strUrl  = [URL_POST_DETAIL stringByAppendingString:postStrId];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:GET_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            id data = [self strToJson:operation.responseString];
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//评论
- (NSInteger)sendRepostOnCompletion:(NSString *)postId repostId:(NSString *)repostId content:(NSString *)content block:(FreeBlock)block
{
    if (![content length]) {
        return ERR_REPOST_CONTENT_IS_NIL;
    }
    
    NSString *strUrl = URL_REPOST_ADD;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:postId forKey:@"postId"];
    [dict setObject:content forKey:@"content"];
    if (repostId) {
        [dict setObject:repostId forKey:@"replyAccountId"];
    }
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[dict JSONData] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            NSString *result  =[[ NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            block(RET_SERVER_SUCC, result);
        }
        else
        {
            block(operation.response.statusCode, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//查看所有评论
- (NSInteger)queryRepostOnCompletion:(NSString *)postId pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize repostId:(NSString *)repostId block:(FreeBlock)block
{
    if(![postId length])
    {
        return ERR_POSTID_IS_NIL;
    }
    
    if (![repostId length]) {
        return ERR_REPOST_ID_IS_NIL;
    }
    
    NSString* strUrl = [NSString stringWithFormat:@"%@/%@/%@", URL_REPOST_QUERY, pageNo, pageSize];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:postId, @"postId", repostId, @"repostId", nil];
    
    [manager GET:strUrl parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
            if ([(NSHTTPURLResponse *)task.response statusCode] == ERR_SERVER_401) {
                block(ERR_SERVER_401,@"异地登录");
                NOTIFY_IF_NEED_LOGIN(ERR_SERVER_401);
            } else {
                block(RET_SERVER_FAIL, err.description);
            }
        }
    }];
    
    return RET_OK;
}

//分享成功加分
- (NSInteger)shareSuccessOnCompletion:(FreeBlock)block
{
    //[URL_SHARE_ADD_POINT stringByAppendingString:itemId]
    NSString *strUrl  = URL_SHARE_ADD_POINT;
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            NSString *result  =[[ NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            block(RET_SERVER_SUCC, result);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//查看我想去的帖子
- (NSInteger)queryMyLikeList:(NSString *)pageNo pageSize:(NSString *)pageSize postId:(NSString *)postId block:(FreeBlock)block
{
    NSString* strUrl = [NSString stringWithFormat:@"%@/%@/%@", URL_QUERY_MY_LIKELIST, pageNo, pageSize];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:postId, @"postId", nil];
    
    [manager GET:strUrl parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
            block(RET_SERVER_FAIL, err.description);
        }
    }];
    return RET_OK;
}
//查看我的帖子
- (NSInteger)queryMyPostList:(NSString *)pageNo pageSize:(NSString *)pageSize postId:(NSString *)postId block:(FreeBlock)block
{
    NSString* strUrl = [NSString stringWithFormat:@"%@/%@/%@", URL_QUERY_MY_POSTLIST, pageNo, pageSize];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:postId, @"postId", nil];
    
    [manager GET:strUrl parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
            block(RET_SERVER_FAIL, err.description);
        }
    }];
    
    return RET_OK;
}

//删除我的回复
- (NSInteger)deleteMyRepost:(NSString *)repostId block:(FreeBlock)block
{
    NSString* strUrl = [NSString stringWithFormat:@"%@%@", URL_DELETE_MY_REPOST, repostId];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            block(RET_SERVER_SUCC, responseObject);
        }
        else
        {
            block(operation.response.statusCode, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//删除我的帖子
- (NSInteger)deleteMyPost:(NSString *)postId block:(FreeBlock)block
{
    NSString* strUrl = [NSString stringWithFormat:@"%@%@", URL_DELETE_MY_POST, postId];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            block(RET_SERVER_SUCC, responseObject);
        }
        else
        {
            block(operation.response.statusCode, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark - 积分商城
- (NSInteger)queryProductsOnCompletion:(NSString *)pageNo pageSize:(NSString *)pageSize block:(FreeBlock)block
{
    NSString* strUrl = [NSString stringWithFormat:@"%@/%@/%@", URL_PRODUCT_QUERY, pageNo, pageSize];
    NSString *str = @"up";
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:str, @"action", nil];
    
    [manager GET:strUrl parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
            block(RET_SERVER_FAIL, err.description);
        }
    }];

    return RET_OK;
}

//购买商品
- (NSInteger)buyProductsOnCompletion:(NSString *)itemId block:(FreeBlock)block
{
    NSString *strUrl  = [URL_BUY_PRODUCT stringByAppendingString:itemId];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            id data = [self strToJson:operation.responseString];
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//查询记录
- (NSInteger)queryRecordOnCompletion:(NSString *)pageNo pageSize:(NSString *)pageSize block:(FreeBlock)block
{
    NSString* strUrl = [NSString stringWithFormat:@"%@/%@/%@", URL_RECORD_QUERY, pageNo, pageSize];
    NSString *str = @"up";
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:str, @"action", nil];
    
    [manager GET:strUrl parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
            block(RET_SERVER_FAIL, err.description);
        }
    }];
    
    return RET_OK;
}

//使用邀请码获取积分
- (NSInteger)useInviteCodeOnCompletion:(NSString *)inviteCode block:(FreeBlock)block
{
    if ([inviteCode length] < 5)
    {
        return ERR_INVITE_CODE_LENGTH_TOO_SHORT;
    }
    
    NSString *strUrl  = URL_USE_INVITECODE;
    
    NSData *data =[inviteCode dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:data strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, operation.responseString);
        }
        else
        {
            block(operation.response.statusCode, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//查询我的验证码
- (NSInteger)queryMyInviteCodeOnCompletion:(FreeBlock)block
{
    NSString* strUrl = URL_QUERY_INVITECODE;
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, operation.responseString);
        }
        else
        {
            block(operation.response.statusCode, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark - 好友列表
//查询活动信息
- (NSInteger)getCoupleFriendsAndActivityOnCompletion:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart position:(NSString *)position block:(FreeBlock)block
{
    if (!freeDate) {
        return ERR_FREEDATE_IS_NIL;
    }
    
//    if (!freeTimeStart) {
//        return ERR_FREEDATE_START_IS_NIL;
//    }
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    NSString *strUrl  = [NSString stringWithFormat:@"%@%@", URL_COUPLE_FRIENDS_AND_ACTIVITY_LIST, freeDate];
    
    if (position) {
        strUrl = [NSString stringWithFormat:@"%@?position=%@", strUrl, position];
    }
    
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:GET_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            id data = [self strToJson:operation.responseString];
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            if (operation.response.statusCode == ERR_SERVER_401) {
                block(ERR_SERVER_401,@"异地登录");
                NOTIFY_IF_NEED_LOGIN(ERR_SERVER_401);
            }
            else
            {
                block(operation.response.statusCode, responseObject);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark - 好友相关
- (NSInteger)getFriendsInfoByPhoneNoOnCompletion:(NSString *)phoneNo block:(FreeBlock)block
{
    if (!phoneNo || ![self isMobileNo:phoneNo]) {
        return ERR_INVALID_MOBILE_NO;
    }
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    NSString *strUrl  = [URL_SEARCH_FRIENDS_INFO_BY_NO stringByAppendingString:phoneNo];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:GET_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            id data = [self strToJson:operation.responseString];
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        NSString *str = operation.responseString;
        if (operation.responseString == nil) {
            str = @"网络超时";
        }
        if (block) {
            block(RET_SERVER_FAIL, str);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//修改好友备注
- (NSInteger)updateFriendNameOnCompletion:(NSString *)accountId friendName:(NSString *)friendName block:(FreeBlock)block
{
    if (![accountId length]) {
        return ERR_ACCOUNTID_IS_NIL;
    }
    
    NSString *strUrl  = URL_UPDATE_FRIENDNAME;
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:accountId, @"id", friendName, @"friendName", nil];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, responseObject);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//添加好友
- (NSInteger)addFriendOnCompletion:(NSString *)accountId friendName:(NSString *)friendName pinyin:(NSString *)pinyin phoneNo:(NSString *)phoneNo headImg:(NSString *)headImg block:(FreeBlock)block
{
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    if (![accountId length]) {
        return ERR_ACCOUNTID_IS_NIL;
    }
    
    if (![pinyin length]) {
        return ERR_PINYIN_IS_NIL;
    }
    
    if (![friendName length]) {
        return ERR_FRIENDNAME_IS_NIL;
    }
    
//    if ([phoneNo isKindOfClass:[NSNull class]] || ![phoneNo length]) {
//        return ERR_PHONE_NO_IS_NIL;
//    }
    
    NSString *strUrl  = URL_ADD_FRIENDS;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:accountId, @"friendAccountId", friendName, @"friendName",pinyin, @"pinyin", headImg, @"headImg", nil];
    
    if (![phoneNo isKindOfClass:[NSNull class]] && phoneNo) {
        [dict setObject:phoneNo forKey:@"phoneNo"];
    }
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            id data = [self strToJson:operation.responseString];
            
            [[FreeSQLite sharedInstance] deleteFreeSQLiteAddressList:data[@"friendAccountId"]];
            [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:data[@"friendAccountId"] friendName:data[@"friendName"] nickName:data[@"friendName"] headImg:data[@"headImg"] Id:data[@"id"] phoneNo:data[@"phoneNo"] pinyin:data[@"pinyin"] status:data[@"status"]];
            
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            block(operation.response.statusCode, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",operation.responseString);
        if (block) {
            block(RET_SERVER_FAIL, operation.responseString);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//删除好友
- (NSInteger)deleteFriendOnCompletion:(NSString *)accountId block:(FreeBlock)block
{
    
    if (!accountId || [accountId length] == 0) {
        return ERR_GROUP_NAME_IS_NIL;
    }
    
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    NSString *strUrl  = [URL_DELETE_FRIENDS stringByAppendingString:accountId];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, operation.responseString);
        }
        else
        {
            block(operation.response.statusCode, operation.responseString);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark - 关注未关注列表
//获取关注列表
- (NSInteger)getCareFriendsListOnCompletion:(FreeBlock)block
{
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    NSString *strUrl  = URL_MYCARED_LIST;
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:GET_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            id data = [self strToJson:operation.responseString];
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

//获取粉丝列表
- (NSInteger)getMyFansListOnCompletion:(FreeBlock)block
{
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    NSString *strUrl  = URL_MYFANS_LIST;
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:GET_METHOD body:nil strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            id data = [self strToJson:operation.responseString];
            block(RET_SERVER_SUCC, data);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark - 修改remark

- (NSInteger)updateRemarkOnCompletion:(NSString *)remark freeDate:(NSString *)freeDate block:(FreeBlock)block
{
    if (!block) {
        return ERR_BLOCK_IS_NIL;
    }
    
    NSString *strUrl  = URL_UPDATE_REMARK;
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:freeDate, @"freeDate",remark, @"remark", nil];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, responseObject);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

#pragma mark - 群聊天
- (NSInteger)createGroup:(NSString *)groupName block:(FreeBlock)block
{
    NSString *strUrl = URL_CREATE_GROUP;
    
    if (!groupName || [groupName length] == 0) {
        return ERR_GROUP_NAME_IS_NIL;
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:groupName, @"groupName", nil];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:[self getRequest:POST_METHOD body:[self dictToJsonData:dict] strUrl:strUrl]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode == RET_SERVER_SUCC) {
            
            block(RET_SERVER_SUCC, operation.responseString);
        }
        else
        {
            block(operation.response.statusCode, responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.description);
        if (block) {
            block(RET_SERVER_FAIL, error.description);
        }
        
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
    
    return RET_OK;
}

- (NSInteger)getGroupInfoById:(NSString *)groupId block:(FreeBlock)block
{
    
    NSString *strUrl  = [URL_QUERY_GROUP_BY_ID stringByAppendingString:groupId];
    
    [manager GET:strUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (block) {
            block(RET_SERVER_SUCC, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError* err){
        if (block) {
            
            if ([(NSHTTPURLResponse *)task.response statusCode] == ERR_SERVER_401) {
                block(ERR_SERVER_401,@"异地登录");
                NOTIFY_IF_NEED_LOGIN(ERR_SERVER_401);
            }
            else
            {
                block(RET_SERVER_FAIL, err.description);
                NSLog(@"err is %@", err.description);
            }
        }
    }];
    
    return RET_OK;
}

#pragma mark -获取属性
//获取accountId
- (NSString *)getAccountId
{
    if (!self.accountId) {
        self.accountId = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_ACCOUNT_ID];
    }
    
    return self.accountId;
}

//获取融云token
- (NSString *)getRongyunToken
{
    if ([self.rongyunToken isKindOfClass:[NSNull class]] || !self.rongyunToken.length) {
        self.rongyunToken = [DEFAULTS stringForKey:SERVICE_FOR_RONGYUN_TOKEN];
    }
    
    return self.rongyunToken;
}

- (NSString *)getUserDeviceID
{
    if(!self.deviceID || [self.deviceID length] == 0)
    {
        self.deviceID = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_DEVICE_ID];
    }
    return self.deviceID;
}

- (NSString *)getPhoneNo
{
    if(!self.phoneNo || [self.phoneNo length] == 0)
    {
        self.phoneNo = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_PHONE_NO];
    }
    
    return self.phoneNo;
}

- (NSString *)getCity
{
    if(!self.city || [self.city length] == 0)
    {
        self.city = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_CITY_NAME];
    }
    
    return self.city;
}

//获取性别
- (NSString *)getUserGender
{
    if(!self.gender || [self.gender length] == 0)
    {
        self.gender = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_GENDER];
    }
    
    return self.gender;
}
//获取昵称
- (NSString *) getNickName
{
    if(!self.nickName || [self.nickName length] == 0)
    {
        self.nickName = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_NICK_NAME];
    }
    
    return self.nickName;
}
//获取头像
- (NSString *) getHeadImage
{
    if(!self.head_img || [self.head_img length] == 0)
    {
        self.head_img = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_HEAD_IMG_URL];
    }
    
    return self.head_img;
}

//获取等级
- (NSString *)getLevel
{
    if (!_level || [_level length] == 0) {
        _level = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_LEVEL];
    }
    
    return _level;
}

//获取积分
- (NSString *)getPoint
{
    if (!_point || [_point length] == 0) {
        _point = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_POINT];
    }
    
    return _point;
}

//获取标签
- (NSMutableArray *) getLalbeTitle
{
    if(!self.lableArray || [self.lableArray count] == 0)
    {
        _lableArray = [NSMutableArray array];
        
        _lableArray = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:KEY_LABLE_NUM];
    }
    
    return _lableArray;
}

//获取关注人数
- (NSString *)getMyFollowedNum
{
    if (!_my_Followed_Num || ![_my_Followed_Num length]) {
        _my_Followed_Num = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_FOLLOWED_NUM];
    }
    
    return _my_Followed_Num;
}

//获取关注者人数
- (NSString *)getMyFollowerNum
{
    if (!_my_Follower_Num || ![_my_Follower_Num length]) {
        _my_Follower_Num = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_FOLLOWER_NUM];
    }
    
    return _my_Follower_Num;
}

//获取我的邀请码
- (NSString *)getInviteCode
{
    if (!_inviteCode || ![_inviteCode length]) {
        _inviteCode = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_INVITE_CODE];
    }
    
    return _inviteCode;
}

//获取二度人脉开启标示
- (NSInteger)getErDu
{
    if (!_erdu || ![_erdu length]) {
        _erdu = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_ERDU_TAG];
    }
    
    return [_erdu integerValue];
}

//获取登陆类型
- (NSString *)getType
{
    if (!_type || ![_type length]) {
        _type = [[NSUserDefaults standardUserDefaults] stringForKey:KEY_LOGIN_TYPE];
    }
    
    return _type;
}


@end
