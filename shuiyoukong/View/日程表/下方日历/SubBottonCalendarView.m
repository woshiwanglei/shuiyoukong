//
//  SubBottonCalendarView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/22.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SubBottonCalendarView.h"
#import "settings.h"
#import "BottomCalendarView.h"

@implementation SubBottonCalendarView

- (void)awakeFromNib
{
    [super awakeFromNib];
    _select_view.hidden = YES;
    _select_view.layer.cornerRadius = 2.f;
    _select_view.layer.masksToBounds = YES;
    _label_date.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    _label_week.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    self.backgroundColor = [UIColor clearColor];
    _select_view.backgroundColor = FREE_BACKGOURND_COLOR;
}

- (void)setModel:(SubBottomCalendarModel *)model
{
    _model = model;
    _label_week.text = model.week;
    _label_date.text = model.date_time;
    
    if (model.isSelected == YES) {
        _select_view.hidden = NO;
    }
    else
    {
        _select_view.hidden = YES;
    }
    
    if (model.isToday) {
        _label_date.textColor = [UIColor redColor];
    }
    else
    {
        _label_date.textColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
    }
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGes2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseDate:)];
    [self addGestureRecognizer:tapGes2];
}

- (void)chooseDate:(UITapGestureRecognizer *)gesture
{
    
    NSArray *superViewArray = self.superview.superview.subviews;
    
    for (BottomCalendarView *superView in superViewArray) {
        NSArray *viewArray = superView.subviews;
        for (SubBottonCalendarView *subview in viewArray) {
            
            if(subview.select_view.hidden == NO)
                subview.select_view.hidden = YES;
        }
    }
    
    _select_view.hidden = NO;
    
    NSString *dateTime = _model.date;
    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_CHOOSE_DATE object:dateTime];//触发刷新通知
}

@end