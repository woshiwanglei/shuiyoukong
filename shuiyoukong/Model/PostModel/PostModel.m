//
//  PostModel.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "PostModel.h"

@implementation PostModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.repostList = [NSMutableArray array];
    }
    return  self;
}

@end
