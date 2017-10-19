//
//  trendTableViewCell.m
//  Free
//
//  Created by yangcong on 15/5/15.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "trendTableViewCell.h"

@implementation trendTableViewCell

- (void)awakeFromNib {
    
    for (UIButton *btn in _cityNames) {
        
       // btn.layer.masksToBounds = YES;
//        btn.layer.borderColor = [[UIColor blackColor] CGColor];
//        btn.layer.borderWidth = 1;
//        btn.layer.cornerRadius = 8;
         btn.backgroundColor = [UIColor whiteColor];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
