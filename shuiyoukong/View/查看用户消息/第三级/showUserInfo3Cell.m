//
//  showUserInfo3Cell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "showUserInfo3Cell.h"
#import "settings.h"

@implementation showUserInfo3Cell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _btn_send.tintColor = [UIColor whiteColor];
    _btn_send.backgroundColor = FREE_BACKGOURND_COLOR;
    _btn_send.layer.cornerRadius = 5.f;
    _btn_send.layer.masksToBounds = YES;
    _btn_send.layer.shadowColor = [UIColor blackColor].CGColor;
    _btn_send.layer.shadowOpacity = 0.33;
    _btn_send.layer.shadowOffset = CGSizeMake(0, 1.5);
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end