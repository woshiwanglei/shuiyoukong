//
//  FreeSQLite.h
//  Free
//
//  Created by 勇拓 李 on 15/5/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define ERROR @"ERROR"
#define INADDRESSLIST @"INADDRESSLIST"
#define NOTINADDRESSLIST @"NOTINADDRESSLIST"

#define MY_FRIENDS 0
#define INVITE_FRIENDS 1
#define CARED_FRIENDS 2

#define ADDRESS_TABLE_NAME @"t_address"
//#define COUPLE_TABLE_NAME  @"t_couple"
#define NOTICE_TABLE_NAME  @"t_notice"

#define REMARK_TABLE_NAME  @"t_remark"

#define NEW_FRIENDS_TABLE_NAME  @"t_new_friends"

#define ADDRESS_TABLE "(SessionId integer PRIMARY KEY AUTOINCREMENT, phoneNo text NOT NULL, friendName text NOT NULL, nickName text, pinyin text, id text, imgUrl text, gender text, status integer NOT NULL, friendAccountId text,type integer, realName text)"

//#define COUPLE_TABLE "(SessionId integer PRIMARY KEY AUTOINCREMENT, friendName text NOT NULL, phoneNo text NOT NULL, effect integer, id integer NOT NULL, status integer NOT NULL, imgUrl text, freeDate text NOT NULL, freeTimeStart text NOT NULL, sameTags text , newTag integer)"

#define NOTICE_TABLE "(SessionId integer PRIMARY KEY AUTOINCREMENT, imgUrl text, freeDate text, freeTimeStart text, sendTime text, activityId text, newTag integer ,type integer, content text)"

#define REMARK_TABLE "(SessionId integer PRIMARY KEY AUTOINCREMENT, freeDate text NOT NULL, freeTimeStart text NOT NULL, remark text)"

#define NEW_FRIENDS_TABLE "(SessionId integer PRIMARY KEY AUTOINCREMENT, friendAccountId text NOT NULL, friendName text NOT NULL, headImg text, phoneNo text, pinyin text, status integer NOT NULL)"

@interface FreeSQLite : NSObject

@property (nonatomic, assign) sqlite3* db;

@property (atomic, retain) NSRecursiveLock *lock;

+ (FreeSQLite *)sharedInstance;

#pragma mark - 新朋友关注通知
//添加好友关注通知
- (void)insertFreeSQLiteNewFriends:(NSString *)friendAccountId friendName:(NSString *)friendName headImg:(NSString *)headImg phoneNo:(NSString *)phoneNo pinyin:(NSString *)pinyin;

//查询所有好友关注通知
- (void)selectFreeSQLiteNewFriends:(NSMutableArray *)dataArray;

//删除好友通知
- (void)deleteFreeSQLiteNewFriends:(NSString *)sessionId;

//更新好友通知
- (void)updateFreeSQLiteNewFriends:(NSString *)friendAccountId status:(NSNumber *)status;

//更新状态
- (void)updateFreeSQLiteNewFriendsIfExist:(NSString *)friendAccountId friendName:(NSString *)friendName headImg:(NSString *)headImg pinyin:(NSString *)pinyin;

//查询关注通知是否存在
-(BOOL)selectFreeSQLiteNewFriendsIfExist:(NSString *)accountId;

#pragma mark - 判断是否是第一次显示remark
- (void)insertFreeSQLiteRemarkList:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart remark:(NSString *)remark;

- (NSString *)selectFreeSQLiteRemarkList:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart;

- (void)updateFreeSQLiteRemarkList:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart remark:(NSString *)remark;

#pragma mark - 通知
//插入通知
- (void)insertFreeSQLiteNoticeList:(NSString *)imgUrl freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart sendTime:(NSString *)sendTime activityId:(NSString *)activityId type:(NSNumber *)type content:(NSString *)content;

//查询所有数据
- (void)selectFreeSQLiteNoticeList:(NSMutableArray *)dataSource page:(NSInteger)page type:(NSInteger)type;

//清除某个红点
- (void)updateFreeSQLiteNoticeList:(NSString *)sessionId;
//删除记录
- (void)deleteFreeSQLiteNoticeList:(NSString *)sessionId;

#pragma mark -通讯录
//查询通讯录的数据 旧的好友
- (void) selectFreeSQLiteAddressList:(NSMutableArray *)dataSource tag:(NSInteger )tag;
////查询通讯录的数据 新的好友
//- (void) selectFreeSQLiteAddressListNew:(NSMutableArray *)dataSource;

//添加好友
- (void)insertFreeSQLiteAddressList:(NSString *)friendAccountId friendName:(NSString *)friendName nickName:(NSString *)nickName headImg:(NSString *)headImg Id:(NSString *)Id phoneNo:(NSString *)phoneNo pinyin:(NSString *)pinyin status:(NSNumber *)status;

//添加通讯录好友多个
- (void) insertFreeSQLiteAddressList:(NSMutableArray *)array;

////更新好友状态
//- (void) updateFreeSQLiteAddressList:(NSString *)Id status:(NSNumber *)status;

//更新好友备注名
- (void)updateFriendNameFreeSqLIteSQLiteAdressList:(NSString *)accountId friendName:(NSString *)friendName;

////把新的好友设为旧的好友
//- (void) updateFreeSQLiteAddressListNewFriends;

//查询通讯录备注
- (NSString *) selectFreeSQLiteFriendName:(NSString *)accountId;

//查询通讯录单个数据
- (NSString *) selectFreeSQLitePhoneNo:(NSString *)phoneNo;

//搜索全部数据
- (void)selectFreeSQLiteADdressListAll:(NSMutableArray *)dataSource;

//更新新的好友消息
- (void) updateFreeSQLiteFriendInfo:(NSString *)accountId Id:(NSString *)Id imgUrl:(NSString *)imgUrl state:(NSNumber *)state nickName:(NSString *)nickName gender:(NSString *)gender type:(NSNumber *)type;

//查询通讯录好友消息
- (NSMutableDictionary *) selectFreeSQLiteUserInfo:(NSString *)accountId;

//删除好友
- (void)deleteFreeSQLiteAddressList:(NSString *)accountId;

#pragma mark -日程表
////插入信息
//- (void) insertFreeSQLiteCoupleList:(NSString *)phoneNo friendName:(NSString *)friendName imgUrl:(NSString *)imgUrl status:(NSNumber *)status Id:(NSNumber *)Id freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart sameTags:(NSString *)sameTags;
////插入通知message数据,分线程
//- (void) insertFreeSQLiteCoupleListAsyn:(NSString *)phoneNo friendName:(NSString *)friendName imgUrl:(NSString *)imgUrl status:(NSNumber *)status Id:(NSNumber *)Id freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart sameTags:(NSString *)sameTags;
////选择
//- (void) selectFreeSQLiteCoupleList:(NSMutableArray *)dataSource freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart;
//
////消除小红点
//- (void) updateFreeSQLiteCoupleList:(NSString *)Id freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart;
//
////查询是否需要显示小红点
//- (void) searchNewInFreeSQLiteCoupleList:(NSMutableArray *)dataSource;
//
////判断朋友是否在列表中
//- (BOOL)selectFriendIfInFreeSQLiteCouple:(NSNumber *)Id freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart;
////更新用户消息
//- (void)updateFriendInfoFreeSQLiteCouple:(NSString *)Id freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart status:(NSNumber *)status imgUrl:(NSString *)imgUrl sameTags:(NSString *)sameTags;
//
////删除过期记录
//- (void)deleteFreeSQLiteCouple:(NSString *)freeDate;
//
////删除记录
//- (void)deleteFreeSQLiteCoupleFriend:(NSString *)his_accountId freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart;

#pragma mark -other
//创建表
- (void)openFreeSQLiteAddressList:(const char*)sql tableName:(NSString *)tableName;

//清除表
- (void)clearAllTable:(NSString *)tableName;

@end