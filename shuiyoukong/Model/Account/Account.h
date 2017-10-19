//
//  Account.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

@property (nonatomic, strong)NSString *city;

@property (nonatomic, strong)NSString *gender;

@property (nonatomic, strong)NSString *headImg;

@property (nonatomic, strong)NSString *accountId;

@property (nonatomic, strong)NSString *nickName;

@property (nonatomic, strong)NSString *phoneNo;

@property (nonatomic, strong)NSString *status;

@property (nonatomic, strong)NSString *friendName;

@property (nonatomic, strong)NSString *pinyin;

@property (nonatomic, strong)NSString *inviteCode;//邀请码

@property (nonatomic, strong)NSMutableArray *tagList;

@property (nonatomic, strong)NSString *lv;
@property (nonatomic, strong)NSString *followed_num;
@property (nonatomic, strong)NSString *follower_num;

@property (nonatomic, strong)NSString *relationId;

@end
