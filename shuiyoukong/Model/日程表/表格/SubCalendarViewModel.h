//
//  SubCalendarView.h
//  Free
//
//  Created by 勇拓 李 on 15/5/9.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubCalendarViewModel : NSObject

@property(nonatomic, strong) NSMutableArray *friendsArray;

@property (nonatomic, strong) NSString *weekDay;
@property (nonatomic, strong) NSString *freeTime;
@property (nonatomic, strong) NSString *timeTitle;

@property(assign)NSInteger timeTag;
@property(assign)BOOL isFristGrid;
@property(assign)BOOL isTurnOn;

@property(assign)BOOL isToday;
@property(assign)NSInteger typeNum;

@end
