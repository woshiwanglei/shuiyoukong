//
//  PicTagsModel.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/20.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "PicTagsModel.h"

@implementation PicTagsModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!_imgTagList) {
            _imgTagList = [NSMutableArray array];
        }
    }
    
    return self;
}

@end
