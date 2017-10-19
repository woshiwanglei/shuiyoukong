//
//  showUserInfo2Cell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "showUserInfo2Cell.h"

@implementation showUserInfo2Cell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _label_title.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    _label_content.textColor = [UIColor lightGrayColor];
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)setModel:(showUserInfo2Model *)model
{
    _model = model;
    _label_title.text = model.title;
    _label_content.text = model.content;
}

@end