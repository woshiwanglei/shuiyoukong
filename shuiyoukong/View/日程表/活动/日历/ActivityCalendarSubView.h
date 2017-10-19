//
//  ActivityCalendarSubView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/2.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityCalendarSubModel.h"

@interface ActivityCalendarSubView : UIView

@property (weak, nonatomic) IBOutlet UILabel *label_weekDay;
@property (weak, nonatomic) IBOutlet UILabel *label_day;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic)ActivityCalendarSubModel *model;

@end
