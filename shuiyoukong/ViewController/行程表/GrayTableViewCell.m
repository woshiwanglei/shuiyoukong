//
//  GrayTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/9/23.
//  Copyright © 2015年 知春. All rights reserved.
//

#import "GrayTableViewCell.h"

@implementation GrayTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
