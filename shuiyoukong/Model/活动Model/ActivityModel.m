//
//  ActivityModel.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/12.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ActivityModel.h"

@implementation ActivityModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!_attendList) {
            _attendList = [NSMutableArray array];
        }
        if (!_promoteAccount) {
            _promoteAccount = [[Account alloc] init];
        }
    }
    return self;
}

@end
