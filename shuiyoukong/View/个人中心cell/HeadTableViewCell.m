//
//  HeadTableViewCell.m
//  Free
//
//  Created by yangcong on 15/5/12.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "HeadTableViewCell.h"
#import "FreeSingleton.h"

@implementation HeadTableViewCell

- (void)awakeFromNib {
    _headImage.layer.masksToBounds = YES;
    _headImage.layer.cornerRadius = 4;
}

//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//}

- (void)setHeadCell:(HeadCellModel *)headCell
{
    _headCell = headCell;
    _headUserName.text = _headCell.headName;
    
    NSString *lv = [[FreeSingleton sharedInstance] getLevel];
    if ([lv length]) {
        int lvNum = [[lv substringWithRange:NSMakeRange(2,1)] intValue];
        switch (lvNum) {
            case 0:
                break;
            default:
            {
                NSString *imgLv = [NSString stringWithFormat:@"icon_Lv%d", lvNum];
                [_btn_lv setImage:[UIImage imageNamed:imgLv] forState:UIControlStateNormal];
            }
                break;
        }
    }
    else
    {
        lv = @"Lv1盖碗茶";
        [_btn_lv setImage:[UIImage imageNamed:@"icon_Lv1"] forState:UIControlStateNormal];
    }
    
    _label_Lv.text = lv;
    
//    [NSString stringWithFormat:@"%@ (%@积分)", lv, [[FreeSingleton sharedInstance] getPoint]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
