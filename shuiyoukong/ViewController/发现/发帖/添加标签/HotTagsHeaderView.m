//
//  HotTagsHeaderView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/17.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "HotTagsHeaderView.h"

@implementation HotTagsHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    _btn_add.layer.cornerRadius = 3.f;
    _btn_add.layer.masksToBounds = YES;
}

@end
