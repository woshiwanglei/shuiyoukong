//
//  SubBottomCalendarModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/22.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubBottomCalendarModel : NSObject

@property(nonatomic, strong)NSString *week;
@property(nonatomic, strong)NSString *date_time;

@property(nonatomic, strong)NSString *date;

@property(assign) BOOL isToday;
@property(assign) BOOL isSelected;

@end
