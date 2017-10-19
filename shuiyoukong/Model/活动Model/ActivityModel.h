//
//  ActivityModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/12.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@interface ActivityModel : NSObject
@property (nonatomic,strong)NSString *activityId;//活动Id
@property (nonatomic,strong)NSString *promoterId;//发起人Id
@property (nonatomic,strong)NSString *title;//活动主题
@property (nonatomic,strong)NSString *promoteDate;//活动发起时间
@property (nonatomic,strong)NSString *activityDate;//活动日期
@property (nonatomic,strong)NSString *activityTime;//活动时间
@property (nonatomic,strong)NSString *activityTimeStart;//活动起始时间
@property (nonatomic,strong)NSString *activityContent;//活动内容
@property (nonatomic,strong)NSString *address;//活动地方
@property (nonatomic,strong)NSString *position;//经纬度以-分割
@property (nonatomic,strong)NSString *imgUrl;//活动图片
@property (nonatomic,strong)NSString *groupId;//活动群组Id
@property (nonatomic,assign)NSInteger attendCount;//参与人数
@property (nonatomic,assign)NSInteger status;
@property (nonatomic,strong)NSString *postId;

@property (nonatomic,assign)NSInteger type;

@property (nonatomic, strong)NSString *headImg;//活动发起人头像
@property (nonatomic,strong)NSMutableArray *attendList;//参加活动人list

@property (nonatomic,strong)Account *promoteAccount;// 发起人信息

@end
