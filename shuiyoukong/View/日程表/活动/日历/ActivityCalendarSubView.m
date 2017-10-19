//
//  ActivityCalendarSubView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/2.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ActivityCalendarSubView.h"

@implementation ActivityCalendarSubView

- (void)awakeFromNib
{
    [super awakeFromNib];
//    _view_circle.layer.borderColor = [[UIColor clearColor] CGColor];
//    _view_circle.layer.borderWidth = 1.f;
//    _view_circle.layer.cornerRadius = 15.f;
//    _view_circle.backgroundColor = [UIColor clearColor];
//    _btn_little.hidden = YES;
    _bottomView.hidden = YES;
    _bottomView.layer.cornerRadius = 3.f;
     _label_day.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0  blue:128/255.0  alpha:1.0];
}

- (void)setModel:(ActivityCalendarSubModel *)model
{
    _model = model;
    _label_day.text = model.day;
   
//    NSArray * arrMonth = [NSArray arrayWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug", @"Sep", @"Oct", @"Nov", @"Dec",nil];
//    _label_month.text = [arrMonth objectAtIndex:model.month - 1];
    _label_weekDay.text = model.week;
    if (model.isSelected == YES) {
//        _view_circle.layer.borderColor = [[UIColor groupTableViewBackgroundColor] CGColor];
//        _btn_little.hidden = NO;
//        [_label_day setFont:[UIFont systemFontOfSize:19]];
        _label_day.textColor = [UIColor redColor];
        _bottomView.hidden = NO;
    }
    else
    {
//        _view_circle.layer.borderColor = [[UIColor clearColor] CGColor];
//        _btn_little.hidden = YES;
//        [_label_day setFont:[UIFont systemFontOfSize:15]];
        _label_day.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0  blue:128/255.0  alpha:1.0];
        _bottomView.hidden = YES;
    }
}



@end