//
//  DiscoverModel.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/15.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "DiscoverModel.h"

@implementation DiscoverModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _img_array = [NSMutableArray array];
        if (!_imgTagsArray) {
            _imgTagsArray = [NSMutableArray array];
        }
    }
    return self;
}

@end
