//
//  RepostModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepostModel : NSObject

@property (nonatomic, strong) NSString* repostId;// 帖子Id
@property (nonatomic, strong) NSString* postId;// 帖子Id
@property (nonatomic, strong) NSString* accountId;// 评论人账号
@property (nonatomic, strong) NSString* content;// 内容
@property (nonatomic, strong) NSString* repostTime;// 发帖时间
@property (nonatomic, strong) NSNumber* upCount;// 赞数量
@property (nonatomic, strong) NSNumber* status;// 状态
@property (nonatomic, strong) NSString* replyAccountId;// 原来评论者Id.默认为0，代表的为回复帖子.其他值代表回复评论
@property (nonatomic, strong) NSNumber* upOrDown;// -1-踩过 0-没有操作 1-赞过
@property (nonatomic, strong) NSString* nickName;// 昵称
@property (nonatomic, strong) NSString* headImg;// 用户头像
@property (nonatomic, strong) NSString* originalRepostName;// 原来评论的名字

@end
