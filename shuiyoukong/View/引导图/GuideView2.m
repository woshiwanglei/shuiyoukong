//
//  GuideView2.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/9/14.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "GuideView2.h"

@implementation GuideView2

- (void)awakeFromNib
{
    [super awakeFromNib];
    _btn_2.hidden = YES;
    _btn_4.hidden = YES;
    [_btn_3 addTarget:self action:@selector(btn_1_Tapped) forControlEvents:UIControlEventTouchDown];
}

- (void)btn_1_Tapped
{
    _btn_1.hidden = YES;
    _btn_3.hidden = YES;
    _btn_2.hidden = NO;
    _btn_4.hidden = NO;
}


@end
