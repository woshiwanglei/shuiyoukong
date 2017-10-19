//
//  Group.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/18.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

@property(nonatomic, assign)NSInteger groupId;// 群组id
@property(nonatomic, strong)NSString *groupName;//群组名称
@property(nonatomic, strong)NSString *groupUrl;//群组
@property(nonatomic, assign)NSInteger promoteId;// 发起者Id
//groupInfo
@property(nonatomic, strong)NSMutableArray *groupInfoList;//参与者信息

@end
