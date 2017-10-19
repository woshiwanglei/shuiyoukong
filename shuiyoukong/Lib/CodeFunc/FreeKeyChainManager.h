//
//  FreeKeyChainManager.h
//  Free
//
//  Created by 勇拓 李 on 15/4/29.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface FreeKeyChainManager : NSObject

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteService:(NSString *)service;
@end
