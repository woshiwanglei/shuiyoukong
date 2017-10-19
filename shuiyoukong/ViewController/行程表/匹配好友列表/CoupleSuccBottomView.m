//
//  CoupleSuccBottomView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/10.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "CoupleSuccBottomView.h"

@implementation CoupleSuccBottomView

- (void)awakeFromNib
{
    [super awakeFromNib];
    _btn_cancel.layer.cornerRadius = 5.f;
    //    _btn_cancel.layer.masksToBounds = YES;
    _btn_cancel.layer.shadowColor = [UIColor blackColor].CGColor;
    _btn_cancel.layer.shadowOpacity = 0.1;
    _btn_cancel.layer.shadowOffset = CGSizeMake(0, 1);
    
    _btn_share.layer.cornerRadius = 5.f;
    _btn_share.layer.shadowColor = [UIColor blackColor].CGColor;
    _btn_share.layer.shadowOpacity = 0.2;
    _btn_share.layer.shadowOffset = CGSizeMake(0, 1);
}

@end
