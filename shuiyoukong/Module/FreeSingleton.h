//
//  FreeSingleton.h
//  Free
//
//  Created by 勇拓 李 on 15/4/29.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "settings.h"
#import "Error.h"
#import "Utils.h"
#import <KVNProgress/KVNProgress.h>
#import <RongIMKit/RongIMKit.h>
#import "PostModel.h"
#import "PositionModel.h"

typedef void (^ZcBlock) (NSUInteger ret, id data);

#pragma mark -用户信息
#define KEY_ACCOUNT_ID                      @"KEY_ACCOUNT_ID"
#define KEY_NICK_NAME                       @"KEY_NICK_NAME"
#define KEY_GENDER                          @"KEY_GENDER"
#define KEY_HEAD_IMG_URL                    @"KEY_HEAD_IMG_URL"
#define KEY_USER_STATUS                     @"KEY_USER_STATUS"
#define KEY_DEVICE_ID                       @"KEY_DEVICE_ID"
#define KEY_CITY_NAME                       @"KEY_CITY_NAME"
#define KEY_PHONE_NO                        @"KEY_PHONE_NO"
#define KEY_LEVEL                           @"KEY_LEVEL"
#define KEY_POINT                           @"KEY_POINT"

#define KEY_FOLLOWED_NUM                    @"KEY_FOLLOWED_NUM"
#define KEY_FOLLOWER_NUM                    @"KEY_FOLLOWER_NUM"

#define KEY_INVITE_CODE                     @"KEY_INVITE_CODE"

#define KEY_LOGIN_TYPE                      @"KEY_LOGIN_TYPE"

#define KEY_ERDU_TAG                        @"KEY_ERDU_TAG"

#define KEY_ACTIVITY_ID                     @"KEY_ACTIVITY_ID"
#define KEY_FREE_DATE_PUSH                  @"KEY_FREE_DATE_PUSH"
#define KEY_FREE_START_TIME_PUSH            @"KEY_FREE_START_TIME_PUSH"

#define KEY_BANNER_URL                      @"KEY_BANNER_URL"
#define KEY_BANNER_IMGURL                   @"KEY_BANNER_IMGURL"
#define KEY_BANNER_TITLE                    @"KEY_BANNER_TITLE"
#define KEY_BANNER_CONTENT                  @"KEY_BANNER_CONTENT"

#define KEY_APP_LUANCH                  @"KEY_APP_LUANCH"

#define KEY_LABLE_NUM                       @"KEY_LABLE_NUM"

#define ZC_NOTIFICATION_NEED_LOGIN                      @"ZC_NOTIFICATION_NEED_LOGIN"
#define ZC_NOTIFICATION_DID_DELETE                      @"ZC_NOTIFICATION_DID_DELETE "
#define ZC_NOTIFICATION_DID_INDIVIDUALDELETE            @"ZC_NOTIFICATION_DID_INDIVIDUALDELETE"
#define ZC_NOTIFICATION_DID_IMG_CLICK                   @"ZC_NOTIFICATION_DID_IMG_CLICK"

#define ZC_NOTIFICATION_DID_IMG_CHANGED                 @"ZC_NOTIFICATION_DID_IMG_CHANGED"

#define CHOSEN_TYPE @"1"
#define SQUARE_TYPE @"0"
#define BANNER_TYPE @"2"

typedef void (^FreeBlock) (NSUInteger ret, id data);

@interface FreeSingleton : NSObject <RCIMUserInfoDataSource, RCIMGroupInfoDataSource>

@property (nonatomic) NSString* accountId;
@property (nonatomic) NSString* token;
@property (nonatomic) NSString* rongyunToken;
@property (nonatomic) NSString* deviceID;
@property (nonatomic) NSString* head_img;
@property (nonatomic) NSString* nickName;
@property (nonatomic) NSString* gender;
@property (nonatomic) NSString* city;
@property (nonatomic) NSString* phoneNo;
@property (nonatomic) NSString* status;
@property (nonatomic) NSString* level;
@property (nonatomic) NSString* point;
@property (nonatomic) NSString* inviteCode;
@property (nonatomic) NSString* erdu;//二度人脉显示标记
@property (nonatomic) NSString* type;//登录方式

@property (nonatomic) NSString* my_Followed_Num;
@property (nonatomic) NSString* my_Follower_Num;

@property (nonatomic,strong) NSMutableArray *lableArray;

+ (FreeSingleton *)sharedInstance;

#pragma mark -注册登录
//注册
- (NSInteger) userRegisterOnCompletion:(NSString *)sms nickname:(NSString *)nickname pwd:(NSString *)pwd gender:(NSString *)gender phone:(NSString *)phone_num headUrl:(NSString *)headUrl inviteCode:(NSString *)inviteCode deviceToken:(NSString *)deviceToken block:(FreeBlock)block;
//用于申请验证码
- (NSInteger) userGetSmsOnCompletion:(NSString *)phone_num block:(FreeBlock)block;
//登录
- (NSInteger) userLoginOnCompletion:(NSString *)phone_num pwd:(NSString *)pwd deviceToken:(NSString *)deviceToken block:(FreeBlock)block;
//我的信息
- (NSInteger) getUserInfoOnCompletion:(FreeBlock)block;
//更换头像
- (NSInteger) userEditHeadImgOnCompletion:(NSString *)img_url block:(FreeBlock)block;
//更换昵称
- (NSInteger) userEditNickNameOnCompletion:(NSString *)nickName block:(FreeBlock)block;
//找回密码
- (NSInteger) userGetPassWordOnCompletion:(NSString *)phone_num block:(FreeBlock)block;
//更新密码
- (NSInteger) UserFinishGetPassWordOnCompletion:(NSString *)phone_num pwd:(NSString *)pwd_num pwd_confirm:(NSString *)pwd_confirm sms:(NSString *)sms block:(FreeBlock)block;
//退出登录
- (NSInteger) userLoginOutCompletion:(FreeBlock)block;

//游客注册登录
- (NSInteger) visitorLoginCompletion:(NSString *)uid nickName:(NSString *)nickName headImg:(NSString *)headImg gender:(NSString *)gender type:(NSString *)type deviceToken:(NSString *)deviceToken block:(FreeBlock)block;

//绑定手机号
- (NSInteger)bindVisitorPhoneNoOnCompletion:(NSString *)phoneNo sms:(NSString *)sms password:(NSString *)password block:(FreeBlock)block;

#pragma mark -图片相关
- (NSInteger) userSubmitImgOnCompletion:(UIImage *)photo ratio:(float)ratio block:(FreeBlock)block;
//上传多张图片
- (NSInteger) userSubmitImgArrayOnCompletion:(NSMutableArray *)photoArray block:(FreeBlock)block;

#pragma mark -通讯录相关
//获取服务器的通讯录
- (NSInteger) getAddressListOnCompletion:(FreeBlock)block;

- (NSInteger) sendAddressListOnCompletion:(NSString *)phoneList block:(FreeBlock)block;
//发送关注不关注请求
- (NSInteger) sendIfConcern:(NSString *)accountId status:(NSString *)status block:(FreeBlock)block;

#pragma mark -日程表
//获取日程表
- (NSInteger) getCalendarOnCompletion:(FreeBlock)block;
//修改日程表－添加
- (NSInteger) addCalendarOnCompletion:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart  City:(NSString *)city remark:(NSString *)remark position:(NSString *)position block:(FreeBlock)block;
//修改日程表－取消
- (NSInteger) cancelCalendarOnCompletion:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart block:(FreeBlock)block;

//获取匹配的好友列表
- (NSInteger) getCoupleArray:(FreeBlock)block;

#pragma mark -标签
- (NSInteger) getobtainLableOncompletion:(FreeBlock)block;
- (NSInteger) postobtainLaleOncompletion:(NSString *)obtainName block:(FreeBlock )block;

#pragma mark -上传城市

- (NSInteger) postCityOnCompletion:(NSString *)city block:(FreeBlock)block;

#pragma mark -活动
- (NSInteger) postAcitiveInfoOnCompletion:(NSString *)freeDate freeStartTime:(NSString *)freeStartTime activeContent:(NSString *)activeContent block:(FreeBlock)block;
//获取活动信息
- (NSInteger) getActiveInfoOnCompletion:(FreeBlock)block;

//获取某一时间段活动信息
- (NSInteger)getActiveInfoByTimeOnCompletion:(NSString *)freeDate freeStartTime:(NSString *)freeStartTime block:(FreeBlock)block;

//查询活动信息
- (NSInteger) activeDetailOnCompletion:(NSString *)activityId block:(FreeBlock)block;

//解散活动
- (NSInteger) cancelActiveOnCompletion:(NSString *)activityId block:(FreeBlock)block;

//退出活动
- (NSInteger) exitActiveOnCompletion:(NSString *)activityId block:(FreeBlock)block;

//参加活动
- (NSInteger) attendActiveOnCompletion:(NSString *)activityId block:(FreeBlock)block;

//编辑活动
- (NSInteger) editAcitiveInfoOnCompletion:(NSString *)freeDate freeStartTime:(NSString *)freeStartTime activeContent:(NSString *)activeContent activityId:(NSString *)activityId block:(FreeBlock)block;
//获取群员人数
-(NSInteger)getcrowdInfoOncompetion:(NSString *)crowdId block:(FreeBlock)block;

//邀请好友
- (NSInteger) inviteAcitiveInfoOnCompletion:(NSString *)activityId friendsList:(NSArray *)friendsList block:(FreeBlock)block;

//活动新端口
- (NSInteger) postAcitiveInfoOnCompletion:(NSString *)title activityDate:(NSString *)activityDate activityTime:(NSString *)activityTime activityContent:(NSString *)activityContent position:(PositionModel *)positionModel imgUrl:(NSString *)imgUrl FriendsList:(NSArray *)friendsList postId:(NSString *)postId block:(FreeBlock)block;

#pragma mark - 匹配好友和活动列表
//查询活动信息
- (NSInteger)getCoupleFriendsAndActivityOnCompletion:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart position:(NSString *)position block:(FreeBlock)block;

#pragma mark - 发现
//发帖
- (NSInteger)sendPostInfoOnCompletion:(PostModel *)model block:(FreeBlock)block;

//查询帖子
- (NSInteger)getPostInfoOnCompletion:(NSString *)pageNo pageSize:(NSString *)pageSize postStatus:(NSString *)postStatus postId:(NSString *)postId upOrDown:(NSString *)upOrDown  city:(NSString *)city block:(FreeBlock)block;

//点想去
- (NSInteger)upPostInfoOnCompletion:(NSString *)postId type:(NSString *)type block:(FreeBlock)block;

//取消想去
- (NSInteger)cancelPostInfoOnCompletion:(NSString *)postId block:(FreeBlock)block;

//帖子详情
- (NSInteger)postDetailOnCompletion:(NSString *)postId block:(FreeBlock)block;

//评论
- (NSInteger)sendRepostOnCompletion:(NSString *)postId repostId:(NSString *)repostId content:(NSString *)content block:(FreeBlock)block;

//查看所有评论
- (NSInteger)queryRepostOnCompletion:(NSString *)postId pageNo:(NSString *)pageNo pageSize:(NSString *)pageSize repostId:(NSString *)repostId block:(FreeBlock)block;

//获取banner
- (NSInteger)getBannerOnCompletion:(FreeBlock)block;

//查看我想去的帖子
- (NSInteger)queryMyLikeList:(NSString *)pageNo pageSize:(NSString *)pageSize postId:(NSString *)postId block:(FreeBlock)block;
//查看我的帖子
- (NSInteger)queryMyPostList:(NSString *)pageNo pageSize:(NSString *)pageSize postId:(NSString *)postId block:(FreeBlock)block;

//删除我的回复
- (NSInteger)deleteMyRepost:(NSString *)repostId block:(FreeBlock)block;

//删除我的帖子
- (NSInteger)deleteMyPost:(NSString *)postId block:(FreeBlock)block;

#pragma mark - 积分商城
- (NSInteger)queryProductsOnCompletion:(NSString *)pageNo pageSize:(NSString *)pageSize block:(FreeBlock)block;
//购买商品
- (NSInteger)buyProductsOnCompletion:(NSString *)itemId block:(FreeBlock)block;

//查询记录
- (NSInteger)queryRecordOnCompletion:(NSString *)pageNo pageSize:(NSString *)pageSize block:(FreeBlock)block;

//分享成功加分
- (NSInteger)shareSuccessOnCompletion:(FreeBlock)block;

//使用邀请码获取积分
- (NSInteger)useInviteCodeOnCompletion:(NSString *)inviteCode block:(FreeBlock)block;

//查询我的验证码
- (NSInteger)queryMyInviteCodeOnCompletion:(FreeBlock)block;

#pragma mark - 好友相关
//根据电话号码搜索好友
- (NSInteger)getFriendsInfoByPhoneNoOnCompletion:(NSString *)phoneNo block:(FreeBlock)block;

//修改好友备注
- (NSInteger)updateFriendNameOnCompletion:(NSString *)accountId friendName:(NSString *)friendName block:(FreeBlock)block;
//添加好友
- (NSInteger)addFriendOnCompletion:(NSString *)accountId friendName:(NSString *)friendName pinyin:(NSString *)pinyin phoneNo:(NSString *)phoneNo headImg:(NSString *)headImg block:(FreeBlock)block;
//删除好友
- (NSInteger)deleteFriendOnCompletion:(NSString *)accountId block:(FreeBlock)block;

#pragma mark - 关注未关注列表
//获取关注列表
- (NSInteger)getCareFriendsListOnCompletion:(FreeBlock)block;

//获取粉丝列表
- (NSInteger)getMyFansListOnCompletion:(FreeBlock)block;

#pragma mark - 修改remark

- (NSInteger)updateRemarkOnCompletion:(NSString *)remark freeDate:(NSString *)freeDate block:(FreeBlock)block;

#pragma mark - 群聊天
- (NSInteger) createGroup:(NSString *)groupName block:(FreeBlock)block;

//与服务器同步群信息
- (void)syncGroupsInfo:(FreeBlock)block;

-(void)syncGroups:(FreeBlock)block;
//根据groupId获取消息
- (NSInteger)getGroupInfoById:(NSString *)groupId block:(FreeBlock)block;

//加入群聊
- (NSInteger)joinGroupOnCompletion:(NSString *)groupId block:(FreeBlock)block;

//退出群聊
- (NSInteger)quitGroupOnCompletion:(NSString *)groupId block:(FreeBlock)block;

//解散群聊
- (NSInteger)dismissGroupOnCompletion:(NSString *)groupId block:(FreeBlock)block;

#pragma mark -别的用户信息
//获取别的用户的信息
- (NSInteger) getOtherUserInfoCompletion:(NSString *)otherUserId block:(FreeBlock)block;

//获取别的用户的推荐
- (NSInteger) queryOtherPostList:(NSString *)pageNo pageSize:(NSString *)pageSize postId:(NSString *)postId accountId:(NSString *)otherId block:(FreeBlock)block;

//获取别的用户的想去
- (NSInteger) queryOtherLikeList:(NSString *)pageNo pageSize:(NSString *)pageSize postId:(NSString *)postId accountId:(NSString *)otherId block:(FreeBlock)block;

#pragma mark - 登录图片
- (NSInteger) getAppLaunchUrl:(FreeBlock)block;

#pragma mark -工具类
//请求压缩图
+ (NSURL *) handleImageUrlWithSuffix:(NSString *)imageUrl sizeSuffix:(NSString *)size;
+ (UIImage *) zipImg:(UIImage *)photo;
//str to json
- (NSArray *) strToJson:(NSString *)stringData;

//字典转jsonStr
- (NSString*)dictionaryToJson:(NSDictionary *)dic;

//转换string到date
- (NSDate *)changeString2Date:(NSString *)str;
//转换date到string
- (NSString *)changeDate2String:(NSDate *)date;

//转换date到string HH-dd
- (NSString *)changeDate2StringDD:(NSDate *)date;

- (NSData *) dictToJsonData:(NSDictionary *)dict;

//把标签转换成string
- (NSString *) changeTagsToString:(id)data;

//判断是否是今天
- (BOOL)isCurrentDay:(NSDate *)aDate;

//验证是否是合法手机号
- (BOOL) isMobileNo: (NSString*)text;
#pragma mark -意见反馈

- (NSInteger)sendIdeaCompletion:(NSString *)content block:(FreeBlock)block;

#pragma mark - 二度人脉相关

- (NSInteger)editErDu:(BOOL)isOn block:(FreeBlock)block;

#pragma mark - 两人位置推荐
- (NSInteger)bothNearBy:(NSString *)accountId block:(FreeBlock)block;

#pragma mark -融云token
- (void)rongyunLogin;

#pragma mark -获取单例属性
- (NSString *)getUserDeviceID;
- (NSString *)getPhoneNo;
- (NSString *)getCity;
- (NSString *)getAccountId;
//获取性别
- (NSString *) getUserGender;
//获取昵称
- (NSString *) getNickName;
//获取头像
- (NSString *) getHeadImage;
//获取等级
- (NSString *) getLevel;
//获取积分
- (NSString *)getPoint;
//获取标签
- (NSMutableArray *) getLalbeTitle;
//获取融云token
- (NSString *)getRongyunToken;
//获取关注人数
- (NSString *)getMyFollowedNum;
//获取关注者人数
- (NSString *)getMyFollowerNum;
//获取我的邀请码
- (NSString *)getInviteCode;
//获取二度人脉开启标示
- (NSInteger)getErDu;
//获取登陆类型
- (NSString *)getType;

@end