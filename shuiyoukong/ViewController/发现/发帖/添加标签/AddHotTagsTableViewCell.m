//
//  AddHotTagsTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/17.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "AddHotTagsTableViewCell.h"

@implementation AddHotTagsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}

@end
