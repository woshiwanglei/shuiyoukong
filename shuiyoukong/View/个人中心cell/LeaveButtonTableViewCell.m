//
//  LeaveButtonTableViewCell.m
//  Free
//
//  Created by yangcong on 15/5/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "LeaveButtonTableViewCell.h"
#import "settings.h"

@implementation LeaveButtonTableViewCell

- (void)awakeFromNib {
    
    _escButton.layer.borderColor = [[UIColor clearColor] CGColor];
    _escButton.layer.masksToBounds = YES;
    _escButton.layer.cornerRadius = 5;
    _escButton.backgroundColor  = FREE_BACKGOURND_COLOR;
    
     self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
