//
//  MessageCenterModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/18.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FRIENDS_COUPLE  2
#define FRIENDS_INVITE  3
#define FRIENDS_ACITIVTY 4
#define POST_NOTICE 6
#define PRIZE_NOTICE 7
#define DELETE_NOTICE 8
#define POINT_PRIZE  9
#define CHOSEN_NOTICE 10

@interface MessageCenterModel : NSObject

@property(nonatomic, strong)NSString *headImg_url;
@property(nonatomic, strong)NSString *freeDate;
@property(nonatomic, strong)NSString *freeStartTime;
@property(nonatomic, strong)NSString *time;
@property(nonatomic, strong)NSString *content;
@property(nonatomic, strong)NSString *activityId;
@property(nonatomic, strong)NSString *sessionId;
@property(nonatomic, assign)NSInteger type;
@property(assign) BOOL isNew;

@end
