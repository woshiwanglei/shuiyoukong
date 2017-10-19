//
//  CarlendSquaresView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "CarlendSquaresView.h"

@implementation CarlendSquaresView

- (void)awakeFromNib
{
    [super awakeFromNib];
    _view_square.layer.cornerRadius = 5.f;
    _view_square.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    _view_square.layer.borderWidth = .8f;
}

- (void)setModel:(CarlendSquaresModel *)model
{
    _model = model;
    
    if (model.isSelected == YES) {
        _btn_choose.hidden = NO;
        _view_square.layer.borderColor =  [[UIColor colorWithRed:32/255.0 green:186/255.0 blue:148/255.0 alpha:.7] CGColor];
    }
    else
    {
        _btn_choose.hidden = YES;
        _view_square.layer.borderColor =  [[UIColor clearColor] CGColor];
    }
}

@end