//
//  Message.h
//  Free
//
//  Created by 勇拓 李 on 15/5/7.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef enum {
//
//    MessageTypeMe = 0, // 自己发的
//    MessageTypeOther = 1 //别人发得
//
//} MessageType;

@interface Message : NSObject

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSNumber *type;

@property (nonatomic, copy) NSDictionary *dict;

@end
