//
//  CalendarCollectionViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/22.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubCalendarViewModel.h"

#define  DELETEMODEL @"DELETEMODEL"
#define  ADDMODEL    @"ADDMODEL"

#define NOTHING 0
#define NEWFRIEND 1
#define FRIENDSHERE 2

#define SETTINGVIEW 123

@interface CalendarCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) SubCalendarViewModel *model;
@property (weak, nonatomic) IBOutlet UIButton *btn_free;
@property (weak, nonatomic) IBOutlet UILabel *label_name;


@end
