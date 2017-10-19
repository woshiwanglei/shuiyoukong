//
//  SubBottonCalendarView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/22.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubBottomCalendarModel.h"

@interface SubBottonCalendarView : UIView

@property (weak, nonatomic) IBOutlet UILabel *label_week;
@property (weak, nonatomic) IBOutlet UILabel *label_date;
@property (weak, nonatomic) IBOutlet UIView *select_view;

@property (strong, nonatomic)SubBottomCalendarModel *model;

@end
