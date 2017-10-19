//
//  LookForMeTableViewCell.m
//  Free
//
//  Created by yangcong on 15/5/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "LookForMeTableViewCell.h"

@implementation LookForMeTableViewCell

- (void)awakeFromNib {
    _label_num.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
