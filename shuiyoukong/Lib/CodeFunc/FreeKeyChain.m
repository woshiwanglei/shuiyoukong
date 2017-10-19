//
//  FreeKeyChain.m
//  Free
//
//  Created by 勇拓 李 on 15/4/29.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FreeKeyChain.h"

@implementation FreeKeyChain

static NSString * const KEY_IN_KEYCHAIN = @"com.free.app.allinfo";
static NSString * const KEY_PASSWORD = @"com.free.app.password";

+(void)savePassWord:(NSString *)password
{
    NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
    [usernamepasswordKVPairs setObject:password forKey:KEY_PASSWORD];
    [FreeKeyChainManager save:KEY_IN_KEYCHAIN data:usernamepasswordKVPairs];
}

+(id)readPassWord
{
    NSMutableDictionary *usernamepasswordKVPair = (NSMutableDictionary *)[FreeKeyChainManager load:KEY_IN_KEYCHAIN];
    return [usernamepasswordKVPair objectForKey:KEY_PASSWORD];
}

+(void)deletePassWord
{
    [FreeKeyChainManager deleteService:KEY_IN_KEYCHAIN];
}
@end
