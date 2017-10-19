//
//  FreeKeyChain.h
//  Free
//
//  Created by 勇拓 李 on 15/4/29.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FreeKeyChainManager.h"

@interface FreeKeyChain : NSObject

/**
 *  @brief  存储密码
 *
 *  @param  password    密码内容
 */
+(void)savePassWord:(NSString *)password;

/**
 *  @brief  读取密码
 *
 *  @return 密码内容
 */
+(id)readPassWord;

/**
 *  @brief  删除密码数据
 */
+(void)deletePassWord;

@end
