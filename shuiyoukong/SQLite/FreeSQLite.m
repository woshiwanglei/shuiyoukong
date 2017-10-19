//
//  FreeSQLite.m
//  Free
//
//  Created by 勇拓 李 on 15/5/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FreeSQLite.h"
#import "FreeSingleton.h"
#import "AddressSQLiteModel.h"

@implementation FreeSQLite

+ (FreeSQLite *)sharedInstance
{
    static FreeSQLite *_freeSQLite = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _freeSQLite = [[FreeSQLite alloc] init];
    });
    
    return _freeSQLite;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

#pragma mark -创建与删除
//创建通知message表
- (void) openFreeSQLiteAddressList:(const char*)sql tableName:(NSString *)tableName
{
    [self.lock lock];
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    NSString *accountSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@_%@ %s", tableName, [[FreeSingleton sharedInstance] getPhoneNo], sql];
    
    const char *pConstChar = [accountSql UTF8String];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK) {
        
        NSLog(@"成功打开数据库");
        
        char *errmsg = NULL;
        result = sqlite3_exec(_db, pConstChar, NULL, NULL, &errmsg);
        if (result == SQLITE_OK) {
            //设置创表成功的标志
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:
             [NSString stringWithFormat:@"%@_%@",[[FreeSingleton sharedInstance] getPhoneNo],ADDRESS_TABLD_EXIST]];
            NSLog(@"创表成功");
        }else
        {
            NSLog(@"创表失败----%s",errmsg);
        }
        
    }
    else
    {
        NSLog(@"打开数据库失败");
    }
    [self.lock unlock];
}


//清除表
- (void)clearAllTable:(NSString *)tableName
{
    [self.lock lock];
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK) {
        
        NSString *accountSql = [NSString stringWithFormat:@"delete from %@_%@", tableName, [[FreeSingleton sharedInstance] getPhoneNo]];
        
        const char *pConstChar = [accountSql UTF8String];
        
        char *errmsg = NULL;
        result = sqlite3_exec(_db, pConstChar, NULL, NULL, &errmsg);
        if (result == SQLITE_OK) {
            NSLog(@"删除成功");
        }else
        {
            NSLog(@"删除失败----%s",errmsg);
        }
        
    }
    else
    {
        NSLog(@"打开数据库失败");
    }
    [self.lock unlock];
}


#pragma mark - 事务处理

//执行插入事务语句
-(void)execInsertTransactionSql:(NSMutableArray *)transactionSql
{
    //使用事务，提交插入sql语句
    @try{
        char *errorMsg;
        if (sqlite3_exec(_db, "BEGIN", NULL, NULL, &errorMsg)==SQLITE_OK)
        {
            NSLog(@"启动事务成功");
            sqlite3_free(errorMsg);
            sqlite3_stmt *statement;
            for (int i = 0; i < transactionSql.count; i++)
            {
                if (sqlite3_prepare_v2(_db,[[transactionSql objectAtIndex:i] UTF8String], -1, &statement,NULL) == SQLITE_OK)
                {
                    if (sqlite3_step(statement)!=SQLITE_DONE)
                    {
                        sqlite3_finalize(statement);
                        return;
                    }
                }
            }
            sqlite3_finalize(statement);
            if (sqlite3_exec(_db, "COMMIT", NULL, NULL, &errorMsg)==SQLITE_OK)   NSLog(@"提交事务成功");
            sqlite3_free(errorMsg);
        }
        else sqlite3_free(errorMsg);
    }
    @catch(NSException *e)
    {
        char *errorMsg;
        if (sqlite3_exec(_db, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
        sqlite3_free(errorMsg);
    }
    @finally{
        
    }
}

#pragma mark - 新朋友关注通知
//添加好友关注通知
- (void)insertFreeSQLiteNewFriends:(NSString *)friendAccountId friendName:(NSString *)friendName headImg:(NSString *)headImg phoneNo:(NSString *)phoneNo pinyin:(NSString *)pinyin
{
    [self.lock lock];
    NSString *url = headImg;
    if (url == nil) {
        url = @"";
    }
    
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO t_new_friends_%@ (friendAccountId, friendName, headImg, phoneNo, pinyin, status) VALUES('%@','%@','%@','%@','%@','%@')", [[FreeSingleton sharedInstance] getPhoneNo],friendAccountId,friendName, url, phoneNo, pinyin, [NSNumber numberWithInt:2]];//1代表new
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"已存到数据库");
        }
        else
        {
            NSLog(@"insertFreeSQLiteNewFriends保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}
//更新状态
- (void)updateFreeSQLiteNewFriendsIfExist:(NSString *)friendAccountId friendName:(NSString *)friendName headImg:(NSString *)headImg pinyin:(NSString *)pinyin
{
    [self.lock lock];
    
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        NSString *sql;
        
        sql = [NSString stringWithFormat:@"UPDATE t_new_friends_%@ SET friendName = '%@', headImg = '%@', pinyin = '%@' where friendAccountId =\"%@\" ", [[FreeSingleton sharedInstance] getPhoneNo], friendName, headImg, pinyin, friendAccountId];
        
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"已更新到数据库");
        }
        else
        {
            NSLog(@"updateFreeSQLiteNoticeList保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

//更新好友通知
- (void)updateFreeSQLiteNewFriends:(NSString *)friendAccountId status:(NSNumber *)status
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        NSString *sql;
        
        sql = [NSString stringWithFormat:@"UPDATE t_new_friends_%@ SET status = %@ where friendAccountId = \"%@\" ", [[FreeSingleton sharedInstance] getPhoneNo], status, friendAccountId];
        
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"已更新到数据库");
        }
        else
        {
            NSLog(@"updateFreeSQLiteNewFriends保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

//查询所有好友关注通知
- (void)selectFreeSQLiteNewFriends:(NSMutableArray *)dataArray
{
    [self.lock lock];
    //    NSMutableArray *insideArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_new_friends_%@ order by SessionId", [[FreeSingleton sharedInstance] getPhoneNo]];
    
    sqlite3_stmt *stmt = NULL;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK)
    {
        //进行查询前的准备工作
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
            NSLog(@"查询语句没有问题");
            
            //每调用一次sqlite3_step函数，stmt就会指向下一条记录
            while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                //取出数据
                NSString *sessionIdField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
                [dic setObject:sessionIdField forKey:@"SessionId"];
                
                NSString *phoneNoField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
                [dic setObject:phoneNoField forKey:@"friendAccountId"];
                
                NSString *friendNameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
                [dic setObject:friendNameField forKey:@"friendName"];
                
                NSString *pinyinField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
                [dic setObject:pinyinField forKey:@"headImg"];
                
                NSString *idField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
                [dic setObject:idField forKey:@"phoneNo"];
                
                NSString *imgUrlField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
                [dic setObject:imgUrlField forKey:@"pinyin"];
                
                NSNumber *statusField = [[NSNumber alloc] initWithInt:sqlite3_column_int(stmt, 6)];
                [dic setObject:statusField forKey:@"status"];
                
                [dataArray addObject:[dic mutableCopy]];
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        else
        {
            NSLog(@"selectFreeSQLiteNewFriends查询语句有问题");
        }
    }
    [self.lock unlock];
}

//查询关注通知是否存在
-(BOOL)selectFreeSQLiteNewFriendsIfExist:(NSString *)accountId
{
    [self.lock lock];
    
    BOOL ret = NO;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_new_friends_%@ where friendAccountId = '%@'", [[FreeSingleton sharedInstance] getPhoneNo], accountId];
    
    sqlite3_stmt *stmt = NULL;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK)
    {
        //进行查询前的准备工作
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
            NSLog(@"查询语句没有问题");
            
            //每调用一次sqlite3_step函数，stmt就会指向下一条记录
            while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                //取出数据
                ret = YES;
                break;
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        else
        {
            NSLog(@"selectFreeSQLiteNewFriends查询语句有问题");
        }
    }
    [self.lock unlock];
    return ret;
}

//删除好友通知
- (void)deleteFreeSQLiteNewFriends:(NSString *)sessionId
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db)==SQLITE_OK) {
        NSString *sql;
        sql = [NSString stringWithFormat:@"delete from t_new_friends_%@ where SessionId =\"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], sessionId];
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"deleteFreeSQLiteNoticeList已删除");
        }
        else
        {
            NSLog(@"deleteFreeSQLiteNoticeList删除失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

#pragma mark - 判断是否是第一次显示remark
- (void)insertFreeSQLiteRemarkList:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart remark:(NSString *)remark
{
    [self.lock lock];
    NSString *str = remark;
    if (remark == nil) {
        str = @"";
    }
    
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO t_remark_%@ (freeDate, freeTimeStart, remark) VALUES('%@','%@','%@')", [[FreeSingleton sharedInstance] getPhoneNo],freeDate,freeTimeStart, str];//1代表new
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"已存到数据库");
        }
        else
        {
            NSLog(@"insertFreeSQLiteRemarkList保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

- (NSString *)selectFreeSQLiteRemarkList:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart
{
    [self.lock lock];
    NSString *ret = nil;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_remark_%@ where freeDate = \"%@\" and freeTimeStart = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], freeDate, freeTimeStart];
    
    sqlite3_stmt *stmt = NULL;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK)
    {
        //进行查询前的准备工作
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
            NSLog(@"查询语句没有问题");
            //每调用一次sqlite3_step函数，stmt就会指向下一条记录
            while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                NSString *sessionIdField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
                ret = sessionIdField;
                break;
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        else
        {
            NSLog(@"查询语句selectFreeSQLiteRemarkList有问题");
        }
    }
    [self.lock unlock];
    return ret;
}

- (void)updateFreeSQLiteRemarkList:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart remark:(NSString *)remark
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        NSString *sql;
        
        sql = [NSString stringWithFormat:@"UPDATE t_remark_%@ SET remark = \"%@\" where freeDate = \"%@\" and freeTimeStart = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], remark, freeDate, freeTimeStart];
        
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"已更新到数据库");
        }
        else
        {
            NSLog(@"updateFreeSQLiteRemarkList保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}


#pragma mark - 通知

//插入通知
- (void)insertFreeSQLiteNoticeList:(NSString *)imgUrl freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart sendTime:(NSString *)sendTime activityId:(NSString *)activityId type:(NSNumber *)type content:(NSString *)content
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO t_notice_%@ (imgUrl, freeDate, freeTimeStart, sendTime, activityId, newTag, type, content) VALUES('%@','%@','%@','%@','%@','%@','%@','%@')", [[FreeSingleton sharedInstance] getPhoneNo],imgUrl,freeDate,freeTimeStart,sendTime, activityId,[NSNumber numberWithInt:1], type, content];//1代表new
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"已存到数据库");
        }
        else
        {
            NSLog(@"insertFreeSQLiteNoticeList保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

//查询所有数据
- (void)selectFreeSQLiteNoticeList:(NSMutableArray *)dataSource page:(NSInteger)page type:(NSInteger)type
{
    [self.lock lock];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *sql = nil;
    
    switch (type) {
        case 0:
            sql = [NSString stringWithFormat:@"SELECT * FROM t_notice_%@ where type <= 10 and type >= 7 order by sendTime desc, newTag desc limit %ld, 10", [[FreeSingleton sharedInstance] getPhoneNo], (long)(page - 1)*10];
            break;
        case 1:
            sql = [NSString stringWithFormat:@"SELECT * FROM t_notice_%@ where type = 6 order by sendTime desc, newTag desc limit %ld, 10", [[FreeSingleton sharedInstance] getPhoneNo], (long)(page - 1)*10];
            break;
        default:
            sql = [NSString stringWithFormat:@"SELECT * FROM t_notice_%@ where type <=4 and type >= 3 order by sendTime desc, newTag desc limit %ld, 10", [[FreeSingleton sharedInstance] getPhoneNo], (long)(page - 1)*10];
            break;
    }
    
//    sql = [NSString stringWithFormat:@"SELECT * FROM t_notice_%@ where order by sendTime desc, newTag desc limit %ld, 10", [[FreeSingleton sharedInstance] getPhoneNo], (long)(page - 1)*10];
    
    sqlite3_stmt *stmt = NULL;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK)
    {
        //进行查询前的准备工作
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
            NSLog(@"查询语句没有问题");
            
            //每调用一次sqlite3_step函数，stmt就会指向下一条记录
            while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                //取出数据
                NSString *sessionIdField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 0)];
                [dic setObject:sessionIdField forKey:@"sessionId"];
                
                NSString *phoneNoField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
                [dic setObject:phoneNoField forKey:@"imgUrl"];
                
                NSString *friendAccountIdField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
                [dic setObject:friendAccountIdField forKey:@"freeDate"];
                
                NSString *imgUrlField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 3)];
                [dic setObject:imgUrlField forKey:@"freeTimeStart"];
                
                NSString *freeDateField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
                [dic setObject:freeDateField forKey:@"sendTime"];
                
                NSString *freeTimeStartField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
                [dic setObject:freeTimeStartField forKey:@"activityId"];
                
                NSNumber *newTagField = [[NSNumber alloc] initWithInt:sqlite3_column_int(stmt, 6)];
                [dic setObject:newTagField forKey:@"newTag"];
                
                NSNumber *typeField = [[NSNumber alloc] initWithInt:sqlite3_column_int(stmt, 7)];
                [dic setObject:typeField forKey:@"type"];
                
                NSString *contentField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 8)];
                [dic setObject:contentField forKey:@"content"];
                
                [dataSource addObject:[dic mutableCopy]];
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        else
        {
            NSLog(@"查询语句有问题");
        }
    }
    [self.lock unlock];
}

//清除某个红点
- (void)updateFreeSQLiteNoticeList:(NSString *)sessionId
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        NSString *sql;
        
        sql = [NSString stringWithFormat:@"UPDATE t_notice_%@ SET newTag = 0 where SessionId =\"%@\" ", [[FreeSingleton sharedInstance] getPhoneNo], sessionId];
        
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"已更新到数据库");
        }
        else
        {
            NSLog(@"updateFreeSQLiteNoticeList保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

//删除记录
- (void)deleteFreeSQLiteNoticeList:(NSString *)sessionId
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db)==SQLITE_OK) {
        NSString *sql;
        sql = [NSString stringWithFormat:@"delete from t_notice_%@ where SessionId =\"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], sessionId];
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"deleteFreeSQLiteNoticeList已删除");
        }
        else
        {
            NSLog(@"deleteFreeSQLiteNoticeList删除失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

#pragma mark - 匹配
//创建索引
- (void)createIndex
{
    @synchronized(self)
    {
    [self.lock lock];
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    NSString *accountSql = [NSString stringWithFormat:@"create index idxT1 on t_couple_%@ (id, freeDate,freeTimeStart)", [[FreeSingleton sharedInstance] getPhoneNo]];
    
    const char *pConstChar = [accountSql UTF8String];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK) {
        
        NSLog(@"成功创建索引");
        
        char *errmsg = NULL;
        result = sqlite3_exec(_db, pConstChar, NULL, NULL, &errmsg);
        if (result == SQLITE_OK) {
            
            NSLog(@"创表成功");
        }else
        {
            NSLog(@"创建索引失败----%s",errmsg);
        }
        
    }
    else
    {
        NSLog(@"打开数据库失败");
    }
    [self.lock unlock];
    }
}

//插入通知message数据,主线程
- (void) insertFreeSQLiteCoupleList:(NSString *)phoneNo friendName:(NSString *)friendName imgUrl:(NSString *)imgUrl status:(NSNumber *)status Id:(NSNumber *)Id freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart sameTags:(NSString *)sameTags
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO t_couple_%@ (friendName,phoneNo,id,status,imgUrl, freeDate, freeTimeStart, sameTags, newTag) VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")", [[FreeSingleton sharedInstance] getPhoneNo],friendName,phoneNo,Id,status,imgUrl,freeDate,freeTimeStart,sameTags, [NSNumber numberWithInt:1]];//1代表new
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"已存到数据库");
        }
        else
        {
            NSLog(@"insertFreeSQLiteCoupleList保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

//插入通知message数据,分线程
- (void) insertFreeSQLiteCoupleListAsyn:(NSString *)phoneNo friendName:(NSString *)friendName imgUrl:(NSString *)imgUrl status:(NSNumber *)status Id:(NSNumber *)Id freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart sameTags:(NSString *)sameTags
{
    @synchronized(self)
    {
        [self.lock lock];
        sqlite3_stmt *statement;
        
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
        
        const char *cfileName = fileName.UTF8String;
        
        if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
            
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO t_couple_%@ (friendName,phoneNo,id,status,imgUrl, freeDate, freeTimeStart, sameTags, newTag) VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")", [[FreeSingleton sharedInstance] getPhoneNo],friendName,phoneNo,Id,status,imgUrl,freeDate,freeTimeStart,sameTags, [NSNumber numberWithInt:1]];//1代表new
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                NSLog(@"已存到数据库");
            }
            else
            {
                NSLog(@"insertFreeSQLiteCoupleList保存失败");
            }
            sqlite3_finalize(statement);
            sqlite3_close(_db);
        }
        [self.lock unlock];
    }
}


//如果tag为YES，则选择新的消息，否则选择全部
- (void) selectFreeSQLiteCoupleList:(NSMutableArray *)dataSource freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart
{
    [self.lock lock];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSString *sql = nil;
    
    if (freeDate == nil && freeTimeStart == nil) {
        sql = [NSString stringWithFormat:@"SELECT * FROM t_couple_%@ order by freeDate, freeTimeStart desc", [[FreeSingleton sharedInstance] getPhoneNo]];
    }
    else if (freeTimeStart == nil)
    {
        sql = [NSString stringWithFormat:@"SELECT * FROM t_couple_%@ where freeDate=\"%@\" and newTag = 1 order by SessionId desc", [[FreeSingleton sharedInstance] getPhoneNo], freeDate];
    }
    else
    {
        sql = [NSString stringWithFormat:@"SELECT * FROM t_couple_%@ where freeDate=\"%@\" and freeTimeStart = \"%@\" order by SessionId desc", [[FreeSingleton sharedInstance] getPhoneNo], freeDate, freeTimeStart];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSLog(@"%@", paths);
    sqlite3_stmt *stmt = NULL;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK)
    {
        //进行查询前的准备工作
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
            NSLog(@"查询语句没有问题");
            
            //每调用一次sqlite3_step函数，stmt就会指向下一条记录
            while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                //取出数据
                NSString *friendNameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
                [dic setObject:friendNameField forKey:@"friendName"];
                
                NSString *phoneNoField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
                [dic setObject:phoneNoField forKey:@"phoneNo"];
                
                NSString *friendAccountIdField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
                [dic setObject:friendAccountIdField forKey:@"id"];
                
                NSString *imgUrlField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
                [dic setObject:imgUrlField forKey:@"imgUrl"];
                
                NSString *freeDateField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)];
                [dic setObject:freeDateField forKey:@"freeDate"];
                
                NSString *freeTimeStartField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 8)];
                [dic setObject:freeTimeStartField forKey:@"freeTimeStart"];
                
                NSString *sameTagsField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 9)];
                [dic setObject:sameTagsField forKey:@"sameTags"];
                
                NSNumber *newTagField = [[NSNumber alloc] initWithInt:sqlite3_column_int(stmt, 10)];
                [dic setObject:newTagField forKey:@"newTag"];
                
                [dataSource addObject:[dic mutableCopy]];
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        else
        {
            NSLog(@"查询语句有问题");
        }
    }
    [self.lock unlock];
}

//消除小红点
- (void) updateFreeSQLiteCoupleList:(NSString *)Id freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        NSString *sql;
        
        if (Id == nil) {
            sql = [NSString stringWithFormat:@"UPDATE t_couple_%@ SET newTag = 0 where freeDate = \"%@\" and freeTimeStart = \"%@\" ", [[FreeSingleton sharedInstance] getPhoneNo], freeDate, freeTimeStart];
        }
        else
        {
            sql = [NSString stringWithFormat:@"UPDATE t_couple_%@ SET newTag = 0 where id=\"%@\" and freeDate = \"%@\" and freeTimeStart = \"%@\" ", [[FreeSingleton sharedInstance] getPhoneNo], Id, freeDate, freeTimeStart];
        }
        
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
          if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"已更新到数据库");
        }
        else
        {
            NSLog(@"updateFreeSQLiteCoupleList保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

//查询是否需要显示小红点
- (void) searchNewInFreeSQLiteCoupleList:(NSMutableArray *)dataSource
{
        [self.lock lock];
        NSString *sql = nil;
        
        sql = [NSString stringWithFormat:@"SELECT * FROM t_couple_%@ where newTag = 1 order by freeDate", [[FreeSingleton sharedInstance] getPhoneNo]];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSLog(@"%@", paths);
        sqlite3_stmt *stmt = NULL;
        
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
        
        const char *cfileName = fileName.UTF8String;
        
        int result = sqlite3_open(cfileName, &_db);
        
        if (result == SQLITE_OK)
        {
            //进行查询前的准备工作
            if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
                NSLog(@"查询语句没有问题");
                
                //每调用一次sqlite3_step函数，stmt就会指向下一条记录
                while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                    //取出数据
                    NSString *freeDateField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 7)];
                    
                    [dataSource addObject:[freeDateField mutableCopy]];
                }
                sqlite3_finalize(stmt);
                sqlite3_close(_db);
            }
            else
            {
                NSLog(@"searchNewInFreeSQLiteCoupleList查询语句有问题");
            }
        }
        [self.lock unlock];
}

//判断朋友是否在列表中
- (BOOL)selectFriendIfInFreeSQLiteCouple:(NSNumber *)Id freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart
{
    @synchronized(self)
    {
        [self.lock lock];
        
        BOOL ret = NO;
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_couple_%@ where id = \"%@\" and freeDate = \"%@\" and freeTimeStart = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo],Id,freeDate,freeTimeStart];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSLog(@"%@", paths);
        sqlite3_stmt *stmt = NULL;
        
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
        
        const char *cfileName = fileName.UTF8String;
        
        int result = sqlite3_open(cfileName, &_db);
        
        if (result == SQLITE_OK)
        {
            //进行查询前的准备工作
            if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
                NSLog(@"查询语句没有问题");
                
                //每调用一次sqlite3_step函数，stmt就会指向下一条记录
                while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                    //取出数据
                    ret = YES;
                }
                sqlite3_finalize(stmt);
                sqlite3_close(_db);
            }
            else
            {
                NSLog(@"selectFriendIfInFreeSQLiteCouple查询语句有问题");
            }
        }
        [self.lock unlock];
        
        return ret;
    }
}

//更新用户消息
- (void)updateFriendInfoFreeSQLiteCouple:(NSString *)Id freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart status:(NSNumber *)status imgUrl:(NSString *)imgUrl sameTags:(NSString *)sameTags
{
    @synchronized(self)
    {
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        NSString *sql;
        
        if (freeDate == nil && freeTimeStart == nil) {
            sql = [NSString stringWithFormat:@"UPDATE t_couple_%@ SET imgUrl = \"%@\" where id = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], imgUrl, Id];
        }
        else
        {
            sql = [NSString stringWithFormat:@"UPDATE t_couple_%@ SET status = \"%@\", imgUrl = \"%@\", sameTags = \"%@\" where freeDate = \"%@\" and freeTimeStart = \"%@\" and id = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], status, imgUrl, sameTags, freeDate, freeTimeStart, Id];
        }
        
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"updateFriendInfoFreeSQLiteCouple已更新到数据库");
        }
        else
        {
            NSLog(@"updateFriendInfoFreeSQLiteCouple保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
    }
}

//删除记录
- (void)deleteFreeSQLiteCouple:(NSString *)freeDate
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db)==SQLITE_OK) {
        NSString *sql;
        sql = [NSString stringWithFormat:@"delete from t_couple_%@ where freeDate < \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], freeDate];
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"已删除");
        }
        else
        {
            NSLog(@"删除失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

//删除记录
- (void)deleteFreeSQLiteCoupleFriend:(NSString *)his_accountId freeDate:(NSString *)freeDate freeTimeStart:(NSString *)freeTimeStart
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db)==SQLITE_OK) {
        NSString *sql;
        sql = [NSString stringWithFormat:@"delete from t_couple_%@ where id = \"%@\" and freeDate = \"%@\" and freeTimeStart = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], his_accountId, freeDate, freeTimeStart];
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"已删除");
        }
        else
        {
            NSLog(@"删除失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

#pragma mark -通讯录
//插入通知message数据
- (void) insertFreeSQLiteAddressList:(NSMutableArray *)array
{
    if ([array count] <= 0) {
        return;
    }
    
    [self.lock lock];

    NSMutableArray *strArray = [NSMutableArray array];
    for (int i = 0; i < [array count]; i++) {
        AddressSQLiteModel *model = array[i];
         NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO t_address_%@ (phoneNo,friendName,imgUrl,pinyin,status,id,friendAccountId,type) VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")", [[FreeSingleton sharedInstance] getPhoneNo],model.phoneNo,model.friendName,model.imgUrl,model.pinyin,model.status,model.Id,model.friendAccountId,model.type];//0代表老友
        [strArray addObject:insertSQL];
    }
        
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db)==SQLITE_OK) {
        [self execInsertTransactionSql:strArray];
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

//查询通讯录的数据 旧的好友
- (void) selectFreeSQLiteAddressList:(NSMutableArray *)dataSource tag:(NSInteger )tag
{
    [self.lock lock];
//    NSMutableArray *insideArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_address_%@ where type = 0 order by pinyin", [[FreeSingleton sharedInstance] getPhoneNo]];
    
    sqlite3_stmt *stmt = NULL;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK)
    {
        //进行查询前的准备工作
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
            NSLog(@"查询语句没有问题");
            
            //每调用一次sqlite3_step函数，stmt就会指向下一条记录
            while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                //取出数据
                NSString *phoneNoField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
                [dic setObject:phoneNoField forKey:@"phoneNo"];
                
                NSString *friendNameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
                [dic setObject:friendNameField forKey:@"friendName"];
                
                NSString *pinyinField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
                [dic setObject:pinyinField forKey:@"pinyin"];
                
                NSString *idField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
                [dic setObject:idField forKey:@"id"];
                
                NSString *imgUrlField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
                [dic setObject:imgUrlField forKey:@"imgUrl"];
                
                NSNumber *statusField = [[NSNumber alloc] initWithInt:sqlite3_column_int(stmt, 8)];
                [dic setObject:statusField forKey:@"status"];
                
                NSString *friendAccountIdField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 9)];
                [dic setObject:friendAccountIdField forKey:@"friendAccountId"];
                
                if ([statusField intValue] == 0) {
                    if (tag == INVITE_FRIENDS) {
                        [dataSource addObject:[dic mutableCopy]];
                    }
                }
                else
                {
                    if (tag == MY_FRIENDS) {
                        [dataSource addObject:[dic mutableCopy]];
                    }
                    else
                    {
                        if ([statusField intValue] == 1 && tag != INVITE_FRIENDS) {
                            [dataSource addObject:[dic mutableCopy]];
                        }
                    }
                }
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        else
        {
            NSLog(@"查询语句有问题");
        }
    }
    [self.lock unlock];
}

//查询通讯录的数据 新的好友
- (void) selectFreeSQLiteAddressListNew:(NSMutableArray *)dataSource
{
    [self.lock lock];
    //    NSMutableArray *insideArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_address_%@ where type = 1", [[FreeSingleton sharedInstance] getPhoneNo]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSLog(@"%@", paths);
    sqlite3_stmt *stmt = NULL;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK)
    {
        //进行查询前的准备工作
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
            NSLog(@"查询语句没有问题");
            
            //每调用一次sqlite3_step函数，stmt就会指向下一条记录
            while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                //取出数据
                NSString *phoneNoField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
                [dic setObject:phoneNoField forKey:@"phoneNo"];
                
                NSString *friendNameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
                [dic setObject:friendNameField forKey:@"friendName"];
                
                NSString *pinyinField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
                [dic setObject:pinyinField forKey:@"pinyin"];
                
                NSString *idField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
                [dic setObject:idField forKey:@"id"];
                
                NSString *imgUrlField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
                [dic setObject:imgUrlField forKey:@"imgUrl"];
                
                NSNumber *statusField = [[NSNumber alloc] initWithInt:sqlite3_column_int(stmt, 8)];
                [dic setObject:statusField forKey:@"status"];
                
                NSString *friendAccountIdField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 9)];
                [dic setObject:friendAccountIdField forKey:@"friendAccountId"];
                
                [dataSource addObject:[dic mutableCopy]];
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        else
        {
            NSLog(@"查询语句有问题");
        }
    }
    
    [self.lock unlock];
}

//添加好友
- (void) insertFreeSQLiteAddressList:(NSString *)friendAccountId friendName:(NSString *)friendName nickName:(NSString *)nickName headImg:(NSString *)headImg Id:(NSString *)Id phoneNo:(NSString *)phoneNo pinyin:(NSString *)pinyin status:(NSNumber *)status
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO t_address_%@ (phoneNo,friendName,nickName,imgUrl,pinyin,status,id,friendAccountId,type) VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")", [[FreeSingleton sharedInstance] getPhoneNo],phoneNo,friendName,nickName, headImg,pinyin,status,Id,friendAccountId,[NSNumber numberWithInt:0]];//0代表老友
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"已存到数据库");
        }
        else
        {
            NSLog(@"insertFreeSQLiteAddressList保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
}

//查询通讯录单个数据
- (NSString *) selectFreeSQLitePhoneNo:(NSString *)phoneNo
{
//    @synchronized(self)
//    {
    [self.lock lock];
    NSString *ret = ERROR;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_address_%@ where phoneNo = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], phoneNo];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSLog(@"%@", paths);
    sqlite3_stmt *stmt = NULL;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK)
    {
        //进行查询前的准备工作
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
            NSLog(@"查询语句没有问题");
            
            ret = NOTINADDRESSLIST;
            
            //每调用一次sqlite3_step函数，stmt就会指向下一条记录
            while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                ret = INADDRESSLIST;
                break;
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        else
        {
            NSLog(@"查询语句有问题");
        }
    }
    [self.lock unlock];
    return ret;
//    }
}

//搜索全部数据
- (void)selectFreeSQLiteADdressListAll:(NSMutableArray *)dataSource
{
    [self.lock lock];
    //    NSMutableArray *insideArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_address_%@", [[FreeSingleton sharedInstance] getPhoneNo]];
    
    sqlite3_stmt *stmt = NULL;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK)
    {
        //进行查询前的准备工作
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
            NSLog(@"查询语句没有问题");
            
            //每调用一次sqlite3_step函数，stmt就会指向下一条记录
            while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                //取出数据
                NSString *phoneNoField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
                [dic setObject:phoneNoField forKey:@"phoneNo"];
                
//                NSString *friendNameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
//                [dic setObject:friendNameField forKey:@"friendName"];
//                
//                NSString *pinyinField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 4)];
//                [dic setObject:pinyinField forKey:@"pinyin"];
//                
//                NSString *idField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
//                [dic setObject:idField forKey:@"id"];
//                
//                NSString *imgUrlField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
//                [dic setObject:imgUrlField forKey:@"imgUrl"];
//                
//                NSNumber *statusField = [[NSNumber alloc] initWithInt:sqlite3_column_int(stmt, 8)];
//                [dic setObject:statusField forKey:@"status"];
//                
//                NSString *friendAccountIdField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 9)];
//                [dic setObject:friendAccountIdField forKey:@"friendAccountId"];
                
                [dataSource addObject:[dic mutableCopy]];
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        else
        {
            NSLog(@"查询语句有问题");
        }
    }
    [self.lock unlock];
}


//查询通讯录名称
- (NSString *) selectFreeSQLiteFriendName:(NSString *)accountId
{
//    @synchronized(self)
//    {
        [self.lock lock];
        NSString *ret = nil;
        
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_address_%@ where friendAccountId = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], accountId];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSLog(@"%@", paths);
        sqlite3_stmt *stmt = NULL;
        
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
        
        const char *cfileName = fileName.UTF8String;
        
        int result = sqlite3_open(cfileName, &_db);
        
        if (result == SQLITE_OK)
        {
            //进行查询前的准备工作
            if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
                NSLog(@"查询语句没有问题");
                
                //每调用一次sqlite3_step函数，stmt就会指向下一条记录
                while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                    ret = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
                }
                sqlite3_finalize(stmt);
                sqlite3_close(_db);
            }
            else
            {
                NSLog(@"查询语句有问题");
            }
        }
        [self.lock unlock];
        return ret;
//    }
}


//查询通讯录好友消息
- (NSMutableDictionary *) selectFreeSQLiteUserInfo:(NSString *)accountId
{
//    @synchronized(self)
//    {
    [self.lock lock];
    NSMutableDictionary *dic;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_address_%@ where friendAccountId = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], accountId];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSLog(@"%@", paths);
    sqlite3_stmt *stmt = NULL;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    int result = sqlite3_open(cfileName, &_db);
    
    if (result == SQLITE_OK)
    {
        //进行查询前的准备工作
        if (sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL) == SQLITE_OK) {//SQL语句没有问题
            NSLog(@"查询语句没有问题");
            
            //每调用一次sqlite3_step函数，stmt就会指向下一条记录
            while (sqlite3_step(stmt) == SQLITE_ROW) {//找到一条记录
                dic = [[NSMutableDictionary alloc] init];
                //取出数据
                NSString *friendNameField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 2)];
                [dic setObject:friendNameField forKey:@"friendName"];
                
                NSString *idField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 5)];
                [dic setObject:idField forKey:@"id"];
                
                NSString *imgUrlField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 6)];
                [dic setObject:imgUrlField forKey:@"imgUrl"];
                
                NSString *friendAccountIdField = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 9)];
                [dic setObject:friendAccountIdField forKey:@"friendAccountId"];
                
                break;
            }
            sqlite3_finalize(stmt);
            sqlite3_close(_db);
        }
        else
        {
            NSLog(@"查询语句有问题");
        }
    }
    [self.lock unlock];
    return dic;
//    }
}

//删除好友
- (void)deleteFreeSQLiteAddressList:(NSString *)accountId
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db)==SQLITE_OK) {
        NSString *sql;
        sql = [NSString stringWithFormat:@"delete from t_address_%@ where friendAccountId =\"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], accountId];
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"deleteFreeSQLiteAddressList已删除");
        }
        else
        {
            NSLog(@"deleteFreeSQLiteAddressList删除失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

//更新通讯录的数据
- (void) updateFreeSQLiteAddressList:(NSString *)Id status:(NSNumber *)status
{
//    @synchronized(self)
//    {
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        NSString *sql;
        sql = [NSString stringWithFormat:@"UPDATE t_address_%@ SET status = %@ where friendAccountId =\"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], status, Id];
        
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"已更新到数据库");
        }
        else
        {
            NSLog(@"updateFreeSQLiteAddressList保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
//    }
}

//更新好友备注名
- (void)updateFriendNameFreeSqLIteSQLiteAdressList:(NSString *)accountId friendName:(NSString *)friendName
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        NSString *sql;
        sql = [NSString stringWithFormat:@"UPDATE t_address_%@ SET friendName = \"%@\" where friendAccountId = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], friendName, accountId];
        
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"已更新到数据库");
        }
        else
        {
            NSLog(@"updateFriendNameFreeSqLIteSQLiteAdressList保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}

//把新的好友设为旧的好友
- (void)updateFreeSQLiteAddressListNewFriends
{
//    @synchronized(self)
//    {
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        NSString *sql;
        sql = [NSString stringWithFormat:@"UPDATE t_address_%@ SET type = 0 where type = 1", [[FreeSingleton sharedInstance] getPhoneNo]];
        
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"已更新到数据库");
        }
        else
        {
            NSLog(@"updateFreeSQLiteAddressListNewFriends保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
//    }
}


//更新新的好友消息
- (void) updateFreeSQLiteFriendInfo:(NSString *)accountId Id:(NSString *)Id imgUrl:(NSString *)imgUrl state:(NSNumber *)state nickName:(NSString *)nickName gender:(NSString *)gender type:(NSNumber *)type
{
    [self.lock lock];
    sqlite3_stmt *statement;
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"Free.sqlite"];
    
    const char *cfileName = fileName.UTF8String;
    
    if (sqlite3_open(cfileName, &_db) == SQLITE_OK) {
        NSString *sql;
        
        if (Id == nil) {
            sql = [NSString stringWithFormat:@"UPDATE t_address_%@ SET imgUrl = \"%@\", nickName = \"%@\", gender = \"%@\" where friendAccountId = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], imgUrl, nickName, gender, accountId];
        }
        else
        {
            sql = [NSString stringWithFormat:@"UPDATE t_address_%@ SET friendAccountId = \"%@\", imgUrl = \"%@\", nickName = \"%@\", gender = \"%@\", type = \"%@\", status = \"%@\" where id = \"%@\"", [[FreeSingleton sharedInstance] getPhoneNo], accountId, imgUrl, nickName, gender, type, state, Id];
        }
        
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(_db, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement)==SQLITE_DONE) {
            NSLog(@"已更新到数据库");
        }
        else
        {
            NSLog(@"updateFreeSQLiteFriendInfo保存失败");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_db);
    }
    [self.lock unlock];
}



@end
