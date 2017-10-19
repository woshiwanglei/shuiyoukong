//
//  CoupleSuccCellModel.h
//  Free
//
//  Created by 勇拓 李 on 15/5/14.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoupleSuccCellModel : NSObject

@property(nonatomic, strong)NSString *headImg_url;
@property(nonatomic, strong)NSString *friend_name;
@property(nonatomic, strong)NSString *friend_accountId;
@property(nonatomic, strong)NSString *friend_tag;
@property(nonatomic, strong)NSString *str_time;
@property(nonatomic, assign)NSNumber *type;
@property(assign) BOOL isNew;

@end
