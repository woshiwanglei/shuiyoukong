//
//  PointCollectionReusableView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "PointCollectionReusableView.h"

@implementation PointCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setModel:(PointModel *)model
{
    _model = model;
    
    if (![model.high_points length])
    {
        model.high_points = @"";
    }
    
    _label_high_points.text = [NSString stringWithFormat:@"历史最高积分%@", model.high_points];
    _label_points.text = model.points;
    _label_Lv.text = model.Lv;
    
    NSString *lv = model.Lv;
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
}

@end
