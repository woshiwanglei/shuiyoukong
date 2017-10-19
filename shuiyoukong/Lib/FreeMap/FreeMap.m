//
//  FreeMap.m
//  Free
//
//  Created by 勇拓 李 on 15/5/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FreeMap.h"
#import "INTULocationManager.h"

@interface FreeMap()


@end

@implementation FreeMap

// 获取经纬度
+ (void)getPosition:(UIViewController *)viewController block:(FreeBlock)block
{
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    __block NSString* position;
    
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                       timeout:2.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 position = [NSString stringWithFormat:@"%f-%f",currentLocation.coordinate.longitude, currentLocation.coordinate.latitude];
                                                 NSLog(@"获取经纬度成功 %@",position);
                                                 block(1, position);
                                                 
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 position = [NSString stringWithFormat:@"%f-%f",currentLocation.coordinate.longitude, currentLocation.coordinate.latitude];
                                                 NSLog(@"获取经纬度超时，使用上一次的数据 %@",position);
                                                 block(0, position);
                                             }
                                             else {
                                                 position = nil;
                                                 block(0, position);
                                                 NSLog(@"获取经纬度失败");
                                                 
                                             }
                                         }];
}




@end
