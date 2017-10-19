//
//  FreeMap.h
//  Free
//
//  Created by 勇拓 李 on 15/5/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FreeSingleton.h"

@interface FreeMap : NSObject

// 获取经纬度
+ (void)getPosition:(UIViewController *)viewController block:(FreeBlock)block;

@end
