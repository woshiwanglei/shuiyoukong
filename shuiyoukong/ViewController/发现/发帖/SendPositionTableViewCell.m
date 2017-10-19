//
//  SendPositionTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SendPositionTableViewCell.h"

@implementation SendPositionTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _btn_chosen.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(PositionModel *)model
{
    _model = model;
    _label_name.text = model.name;
    _label_position.text = model.address;
    if (model.isChosen) {
        _btn_chosen.hidden = NO;
    }
    else
    {
        _btn_chosen.hidden = YES;
    }
}

@end
