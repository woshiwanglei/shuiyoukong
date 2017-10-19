//
//  PositionModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface PositionModel : NSObject

@property (nonatomic, assign)CGFloat latitude;

@property (nonatomic, assign)CGFloat longitude;

@property (nonatomic, strong)NSString *position_name;

@property (nonatomic, strong)NSString *name;

@property (nonatomic, strong)NSString *address;

@property (nonatomic, strong)NSString *city;

@property (nonatomic, assign)BOOL isChosen;

@end
