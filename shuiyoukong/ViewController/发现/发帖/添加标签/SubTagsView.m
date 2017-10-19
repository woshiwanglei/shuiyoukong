//
//  SubTagsView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/17.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SubTagsView.h"

@implementation SubTagsView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 3.f;
    self.layer.masksToBounds = YES;
}

@end
