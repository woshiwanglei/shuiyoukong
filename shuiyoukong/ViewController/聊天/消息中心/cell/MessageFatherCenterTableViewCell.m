//
//  MessageFatherCenterTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/28.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MessageFatherCenterTableViewCell.h"

@implementation MessageFatherCenterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _red_point.layer.cornerRadius = 5.f;
    _red_point.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
