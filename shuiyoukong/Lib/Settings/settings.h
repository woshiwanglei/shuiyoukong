//
//  settings.h
//  Free
//
//  Created by 勇拓 李 on 15/4/29.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#ifndef Free_settings_h
#define Free_settings_h

#pragma mark -KEY
//高德地图key
#define GAODE_MAP_KEY @"6e9bda83ce26935adac334983501a6fc"
//友盟key
#define UMENG_KEY @"55407ac6e0f55a7b3b003860"
//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#warning 修改融云KEY
//修改融云KEY
//pwe86ga5elab6测试
//4z3hlwrv3crvt正式
#define RONGCLOUD_IM_APPKEY @"4z3hlwrv3crvt" //online key

#define RONGYUN_DeviceToken @"HBT9LDcilZXmOAKWmUy1+joxdp4Lq17xOcH4nNIlagt8m1anKNUzA4S5krYddy5xFAlc3qfnEpIELXf21wCq1Q=="

#define DEFAULTS [NSUserDefaults standardUserDefaults]

#warning 客服ID
//8080 KEFU1439885113484
//9090 KEFU1440058245847
#define SERVICE_ID @"KEFU1439885113484"

#pragma mark - 屏幕判断

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

//定义颜色
#define FREE_BACKGOURND_COLOR [UIColor colorWithRed:86/255.0 green:183/255.0 blue:164/255.0 alpha:1.0]

#define FREE_LIGHT_COLOR [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]

#define FREE_BLACK_COLOR [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0]

#define FREE_LABEL_NAME_COLOR [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]

#define FREE_LIGHT_GRAY_COLOR [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0]

#define FREE_NAVI_BACKGOURND_COLOR [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0]

#define FREE_179_GRAY_COLOR [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1.0]

#pragma mark -token
//定义token相关
#define SERVICE_FOR_SS_KEYCHAIN_TOKEN @"token"

#define SERVICE_FOR_RONGYUN_TOKEN @"rongyuntoken"

#pragma mark -url相关

#define POST_METHOD @"POST"
#define GET_METHOD  @"GET"

//114.215.108.65
//192.168.0.116
#define URL_SOCKET @"ws://114.215.108.65:8080/free-websocket/websocket"

#define ROOT_URL  @"http://114.215.108.65:8080/free-rest/rest"//@"http://192.168.0.105:8080/tem-rest-frontend/rest"//@"http://114.215.108.65:8080/tem-rest-frontend/rest"//@"http://114.215.108.65:9090/tem-rest-frontend/rest"
#define IMG_ROOT_URL @"http://121.42.8.202"

#define KEY_LOGIN_STATUS        @"token"

#pragma mark - 消息类型

#define COUPLE_TYPE 2
#define INVITE_TYPE 3
#define MY_ACTIVITY_TYPE 4

#define COME_FROM_PUSH  1    //活动push

#pragma mark - 登陆类型

#define WEIXIN_TYPE @"1"
#define QQ_TYPE @"2"
#define SINA_TYPE @"3"

#pragma mark -注册登录接口

//注册
#define URL_REGISTER            ROOT_URL"/access/open/register"
//获取验证码
#define URL_GET_SMS             ROOT_URL"/access/open/getValidateCode"
//登录
#define URL_LOGIN               ROOT_URL"/access/open/login"
//我的信息
#define URL_GET_USERINFO        ROOT_URL"/access/userInfo"
//找回密码
#define URL_GET_SMS_TO_FIND_PWD ROOT_URL"/access/open/getPasswordVerCode"
#define URL_FIND_PWD            ROOT_URL"/access/open/findMyPassword"
//更换昵称
#define URL_EDIT_NICKNAME       ROOT_URL"/access/nickname/edit"

#define URL_LOGOUT              ROOT_URL"/access/logout"

#define URL_BIND_PHONENO        ROOT_URL"/access/bind"

#pragma mark -图片相关

#define URL_UPLOAD_IMG          IMG_ROOT_URL"/uploadfile"
#define URL_EDIT_HEADIMG        ROOT_URL"/access/headImg/edit"

#pragma mark -通讯录相关
#define URL_ADDRESS_QUERY       ROOT_URL"/relation/queryOnline"
#define URL_ADDRESS_LIST        ROOT_URL"/relation/add"
#define URL_SEND_STATUS         ROOT_URL"/relation/updateStatus"

#pragma mark - 二度人脉相关
#define URL_EDIT_ERDU_STATUS         ROOT_URL"/access/erdu/edit"

#pragma mark - 两人附近推荐
#define URL_BOTH_NEARBY         ROOT_URL"/free/bothNearby/"

#pragma mark - 登录图片
#define URL_APP_LUANCH        ROOT_URL"/access/open/appStart"

#pragma mark -UserDefault
#define ADDRESS_TABLD_EXIST   @"ADDRESS_TABLD_EXIST"
//标签地址
#define URL_OBTAIN           ROOT_URL"/tag/querySystemTag"
#define URL_OBTAIN_SET          ROOT_URL"/tag/setTags"

#define URL_UPLOAD_CITY      ROOT_URL"/access/city/edit"

#pragma mark -日程表
//查询日程表
#define URL_CALENDAR_LIST     ROOT_URL@"/free/query"
//获取匹配情况
#define URL_QUERY_FREE_MATCH  ROOT_URL@"/free/queryFreeMatch"
//添加日程表状态
#define URL_CALENDAR_ADD     ROOT_URL@"/free/save"
//取消日程表状态
#define URL_CALENDAR_CANCEL     ROOT_URL@"/free/cancel"
//意见
#define URL_SUGGESTION_POST         ROOT_URL@"/feedback/add"

//查看别的用户信息
#define URL_GET_OTHER_USER_INFO ROOT_URL"/access/otherUserInfo/"

#pragma mark -活动
//发起活动
#define URL_SEND_ACTIVE ROOT_URL"/userActivity/add"
//获取活动
#define URL_SEND_QUERY ROOT_URL"/userActivity/query"
//通过时间段获取活动信息
#define URL_QUERYACTIVITY_BY_TIME ROOT_URL"/userActivity/queryByDate/"

//活动详情
#define URL_ACTIVE_DETAIL ROOT_URL"/userActivity/detail/"
//取消活动
#define URL_CANCEL_ACTIVE ROOT_URL"/userActivity/cancel/"
//退出活动
#define URL_EXIT_ACTIVE ROOT_URL"/attendActivity/cancel/"
//参加活动
#define URL_ATTEND_ACTIVE ROOT_URL"/attendActivity/add/"
//编辑活动
#define URL_EDIT_ACTIVE ROOT_URL"/userActivity/edit"
//添加好友
#define URL_INVITE_ACTIVE ROOT_URL"/userActivity/invite"

#pragma mark - 匹配好友和活动列表
#define URL_COUPLE_FRIENDS_AND_ACTIVITY_LIST ROOT_URL"/free/detail/"

#pragma mark - 好友相关
#define URL_SEARCH_FRIENDS_INFO_BY_NO ROOT_URL"/access/search/"

#define URL_UPDATE_FRIENDNAME   ROOT_URL"/relation/mark"

#define URL_ADD_FRIENDS         ROOT_URL"/relation/addFriend"

#define URL_DELETE_FRIENDS      ROOT_URL"/relation/delete/"

#pragma mark - 关注未关注列表

#define URL_MYCARED_LIST    ROOT_URL"/relation/queryIFollowed"

#define URL_MYFANS_LIST    ROOT_URL"/relation/queryMyFollower"

#pragma mark - remark
#define URL_UPDATE_REMARK ROOT_URL"/free/update"

#pragma mark - 群聊

#define URL_CREATE_GROUP   ROOT_URL"/group/add"

#define URL_QUERY_GROUP    ROOT_URL"/group/query"

#define URL_QUERY_GROUP_BY_ID ROOT_URL"/group/detail/"

#define URL_JOIN_GROUP     ROOT_URL"/group/join/"

#define URL_QUIT_GROUP     ROOT_URL"/group/quit/"

#define URL_SYNC_GROUP     ROOT_URL"/group/sync"

#define URL_DISMISS_GROUP     ROOT_URL"/group/delete/"

#pragma mark - 发现

#define URL_POST_ADD      ROOT_URL"/post/add"

#define URL_QUERY_POST    ROOT_URL"/post/query"

#define URL_UP_POST       ROOT_URL"/statistic/add"

#define URL_CANCEL_POST       ROOT_URL"/statistic/delete"

#define URL_POST_DETAIL   ROOT_URL"/post/detail/"

#define URL_REPOST_ADD      ROOT_URL"/repost/add"

#define URL_REPOST_QUERY    ROOT_URL"/repost/query"

#define URL_GET_BANNER      ROOT_URL"/post/banner/query"

#define URL_QUERY_MY_LIKELIST      ROOT_URL"/post/queryMyLikePost"

#define URL_QUERY_MY_POSTLIST      ROOT_URL"/post/queryMyPost"

#define URL_QUERY_OTHER_LIKELIST   ROOT_URL"/post/queryOtherLikePost"

#define URL_QUERY_OTHER_POSTLIST   ROOT_URL"/post/queryOtherPost"

#define URL_DELETE_MY_REPOST   ROOT_URL"/repost/delete/"

#define URL_DELETE_MY_POST   ROOT_URL"/post/delete/"

#pragma mark - 积分商城

#define URL_PRODUCT_QUERY      ROOT_URL"/exchangeItem/query"

#define URL_BUY_PRODUCT     ROOT_URL"/exchangeItem/exchange/"

#define URL_RECORD_QUERY      ROOT_URL"/exchangeItem/query/record"

#define URL_SHARE_ADD_POINT     ROOT_URL"/post/share"

#define URL_USE_INVITECODE     ROOT_URL"/access/inviteCode/add"

#define URL_QUERY_INVITECODE   ROOT_URL"/access/inviteCode/query"

#pragma mark -工具类正则
//验证码
#define SMSCODE_REGEX @"^[0-9]{4}$"
//手机号
#define MOBILE_NUM_PREFIX @"^(13[0-9]|15[012356789]|17[0-9]|18[0-9]|14[57])"
#define MOBILE_NUM_REGEX MOBILE_NUM_PREFIX"[0-9]{8}$"

#pragma mark -状态类
#define STATUS_CONCERN @"1"
#define STATUS_NO_CONCERN @"2"

#pragma mark -图片压缩大小

#define SIZE_SUFFIX_100X100 @"_100x100"
#define SIZE_SUFFIX_300X300 @"_300x300"
#define SIZE_SUFFIX_600X600 @"_600x600"
#pragma mark -通知

//需要登录
#define ZC_NOTIFICATION_NEED_LOGIN                  @"ZC_NOTIFICATION_NEED_LOGIN"
//是否登录
#define ZC_NOTIFICATION_DID_LOGIN                   @"ZC_NOTIFICATION_HAS_LOGIN"
//通讯录变化
#define ZC_NOTIFICATION_UPLOAD_ADDRESSLIST  @"ZC_NOTIFICATION_UPLOAD_ADDRESSLIST"
//匹配空闲好友成功
#define ZC_NOTIFICATION_COUPLE_FRIEND  @"ZC_NOTIFICATION_COUPLE_FRIEND"
//跳到好友列表
#define ZC_NOTIFICATION_GOTO_COUPLE_LIST  @"ZC_NOTIFICATION_GOTO_COUPLE_LIST"

//第一次点击判断
#define ZC_NOTIFICATION_FRIST_CLICK  @"ZC_NOTIFICATION_FRIST_CLICK"

//有空没空状态转变
#define ZC_NOTIFICATION_DID_STATE_CHANGE  @"ZC_NOTIFICATION_DID_STATE_CHANGE"

//消除状态
#define ZC_NOTIFICATION_DID_NEW_CHANGE  @"ZC_NOTIFICATION_DID_NEW_CHANGE"

//推送跳转处理
#define ZC_NOTIFICATION_DID_PUSH_CHANGE   @"ZC_NOTIFICATION_DID_PUSH_CHANGE"

//右上角数据变化
#define ZC_NOTIFICATION_DATASOURCE_CHANGE @"ZC_NOTIFICATION_DATASOURCE_CHANGE"

//选择日期
#define ZC_NOTIFICATION_CHOOSE_DATE  @"ZC_NOTIFICATION_CHOOSE_DATE"

//发送消息
#define ZC_NOTIFICATION_SEND_MESSAGE                @"ZC_NOTIFICATION_SEND_MESSAGE"
//消息改变
#define ZC_NOTIFICATION_DID_MESSAGE_CHANGE          @"ZC_NOTIFICATION_DID_MESSAGE_CHANGE"
//刷新消息盒子
#define ZC_NOTIFICATION_MESSAGE_NEED_REFRESH        @"ZC_NOTIFICATION_MESSAGE_NEED_REFRESH"

//有新朋友
#define ZC_NOTIFICATION_NEW_FRIENDS        @"ZC_NOTIFICATION_NEW_FRIENDS"

//联系人loading标记,YES为消除显示，NO为显示
#define ZC_NOTIFICATION_LOADING  @"ZC_NOTIFICATION_LOADING"

#define ZC_NOTIFICATION_NEW_NOTICE @"ZC_NOTIFICATION_NEW_NOTICE"
//细分消息通知
#define FREE_NOTIFICATION_NEW_NOTICE @"FREE_NOTIFICATION_NEW_NOTICE"

#define ZC_NOTIFICATION_CHANGE_REMARK @"ZC_NOTIFICATION_CHANGE_REMARK"

#define ZC_NOTIFICATION_UPDATE_FRIENDNAME @"ZC_NOTIFICATION_UPDATE_FRIENDNAME"
//更新想去
#define ZC_NOTIFICATION_UPDATE_UPDATE_COUNT @"ZC_NOTIFICATION_UPDATE_UPDATE_COUNT"
//更新点赞
#define ZC_NOTIFICATION_UPDATE_DIANZAN @"ZC_NOTIFICATION_UPDATE_DIANZAN"

#define ZC_NOTIFICATION_NEW_NOTICE_UPDATE   @"ZC_NOTIFICATION_NEW_NOTICE_UPDATE"
//更新关注的人
#define ZC_NOTIFICATION_UPDATE_MYCARE  @"ZC_NOTIFICATION_UPDATE_MYCARE"

//切换有空没空状态
#define FREE_NOTIFICATION_UPDATE_FREE_STATUS  @"FREE_NOTIFICATION_UPDATE_FREE_STATUS"

//在img上添加标签
#define FREE_NOTIFICATION_ADD_TAG    @"FREE_NOTIFICATION_ADD_TAG"

//在img上编辑标签
#define FREE_NOTIFICATION_EDIT_TAG    @"FREE_NOTIFICATION_EDIT_TAG"

//选择图片过后，更新图片标签数组
#define FREE_NOTIFICATION_CHANGE_TAG    @"FREE_NOTIFICATION_CHANGE_TAG"

//刷新帖子回复
#define FREE_NOTIFICATION_REFRESH_REPOST    @"FREE_NOTIFICATION_REFRESH_REPOST"

//删除我的帖子刷新
#define FREE_NOTIFICATION_RELOAD_MYPOST    @"FREE_NOTIFICATION_RELOAD_MYPOST"

//引导图1
#define FREE_NOTIFICATION_GUIDE_1    @"FREE_NOTIFICATION_GUIDE_1"

#define FREE_NOTIFICATION_GUIDE_2    @"FREE_NOTIFICATION_GUIDE_2"

#pragma mark - 积分商城

//通讯录变化
#define ZC_NOTIFICATION_REFRESH_POINT  @"ZC_NOTIFICATION_REFRESH_POINT"

#define MY_CARE_NOTIFICATION_REFRESH   @"MY_CARE_NOTIFICATION_REFRESH"

#pragma mark - 第三方登录
//成功绑定手机
#define FREE_NOTIFICATION_BIND_PHONENO    @"FREE_NOTIFICATION_BIND_PHONENO"

#pragma mark -分享
//分享
#define UM_ZC_TITLE @"谁有空—不约而同"

#define UM_SHARE_DESCRIBE @"并不是每个当下我们都会相遇，还好有空。快来谁有空开启不约而同的旅行吧。"
#define UM_SHARE_URL @"http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free"

#define UM_SHARE_ME @"并不是每个当下我们都会相遇，还好有空。快来谁有空开启不约而同的旅行吧。"

#define UM_SHARE_PIC @"并不是每个当下我们都会相遇，还好有空。快来谁有空开启不约而同的旅行吧。"

#pragma mark -本地存储关键字

#define KEY_IF_HAS_NEW_FRIENDS      @"KEY_IF_HAS_NEW_FRIENDS"

#define KEY_IF_HAS_NEW_COUPLE       @"KEY_IF_HAS_NEW_COUPLE"

#define KEY_IF_HAS_NEW_NOTICE      @"KEY_IF_HAS_NEW_NOTICE"
//官方通知红点
#define KEY_IS_HAS_NEW_OFFICIAL    @"KEY_IS_HAS_NEW_OFFICIAL"
//评论通知红点
#define KEY_IS_HAS_NEW_COMMENT     @"KEY_IS_HAS_NEW_COMMENT"
//活动通知红点
#define KEY_IS_HAS_NEW_ACTIVITY    @"KEY_IS_HAS_NEW_ACTIVITY"
//判断是否需要引导
#define KEY_IF_NOT_NEED_GUIDED      @"KEY_IF_NOT_NEED_GUIDED"

//判断是否需要引导3
#define KEY_IF_NOT_NEED_GUIDED_RIGHT_UP      @"KEY_IF_NOT_NEED_GUIDED_RIGHT_UP"

//判断发现是否需要引导
#define KEY_IF_DISCOVER_NOT_NEED_GUIDED      @"KEY_IF_DISCOVER_NOT_NEED_GUIDED"

#endif
