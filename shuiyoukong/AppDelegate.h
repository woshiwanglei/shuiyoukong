//
//  AppDelegate.h
//  shuiyoukong
//
//  Created by 勇拓 李 on 15/4/28.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FreeSingleton.h"

#define PUSH_ACITITY 1
#define PUSH_FRIENDS 2

@interface AppDelegate : UIResponder <UIApplicationDelegate, RCIMConnectionStatusDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (UIWindow*)getMainWindow;

@property(atomic, assign) NSInteger isComeFromPush;

@end

