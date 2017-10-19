//
//  Account.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "Account.h"

@implementation Account

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tagList = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
