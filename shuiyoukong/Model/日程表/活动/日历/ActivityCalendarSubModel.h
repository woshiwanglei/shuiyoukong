//
//  ActivityCalendarSubModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/2.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityCalendarSubModel : NSObject

@property (nonatomic, assign)NSInteger month;
@property (nonatomic, strong)NSString *week;
@property (nonatomic, strong)NSString *day;

@property (nonatomic, strong)NSString *freeDate;

@property (nonatomic, assign)BOOL isSelected;

@end
