//
//  SubCalendarView.m
//  Free
//
//  Created by 勇拓 李 on 15/5/9.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SubCalendarViewModel.h"

@implementation SubCalendarViewModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        _friendsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
