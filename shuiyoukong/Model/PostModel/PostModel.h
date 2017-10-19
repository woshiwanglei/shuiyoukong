//
//  PostModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostModel : NSObject
//帖子ID
@property (nonatomic, strong)NSString *postId;
//发帖人账号
@property (nonatomic, strong)NSString *accountId;
//标题
@property (nonatomic, strong)NSString *title;

@property (nonatomic, strong)NSString *url;// 图片以#%#分割
//内容
@property (nonatomic, strong)NSString *content;
//人均
@property (nonatomic, strong)NSString *price;
//商圈
@property (nonatomic, strong)NSString *area;
// 具体地址
@property (nonatomic, strong)NSString *address;
// 经纬度以-分割
@property (nonatomic, strong)NSString *position;
//标签以###分割
@property (nonatomic, strong)NSString *tags;
// 城市
@property (nonatomic, strong)NSString *city;
// 0.普通 1.编辑精选2.专题
@property (nonatomic, strong)NSNumber *type;
//发帖时间
@property (nonatomic, strong)NSString *postTime;
//浏览次数
@property (nonatomic, strong)NSNumber *brCount;
//评论次数
@property (nonatomic, strong)NSNumber *reCount;
//赞数量
@property (nonatomic, strong)NSNumber *upCount;
// 状态 1-正常 2-锁定 3-匿名 0-逻辑删除(正负抵消后点踩仍然超过5次)
@property (nonatomic, strong)NSNumber *status;
//-1-踩过 0-没有操作 1-赞过
@property (nonatomic, strong)NSNumber *upOrDown;
//用户名称
@property (nonatomic, strong)NSString *nickName;
//用户头像
@property (nonatomic, strong)NSString *headImg;
//回复列表
@property (nonatomic, strong)NSMutableArray *repostList;

//图片标签
@property (nonatomic, strong)NSString *postImg;

@end
