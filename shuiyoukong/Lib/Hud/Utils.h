//
//  Utils.h
//  Free
//
//  Created by 勇拓 李 on 15/4/29.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface Utils : NSObject

//弹出提示
+ (void) warningUser:(UIViewController *) viewController msg:(NSString *) msg;
+ (void) warningUser:(UIViewController *) viewController msg:(NSString *) msg time:(NSInteger)time;
+ (void) warningUserAfterJump:(UIViewController *) viewController msg:(NSString *) msg time:(NSInteger)time;

//弹出带菊花的提示
+ (MBProgressHUD *) waiting:(UIViewController *) viewController msg:(NSString *)msg;
+ (void) hideHUD:(MBProgressHUD *)hud;
//获取位置
//+ (void) getPosition:(UIViewController *) viewController block:(ZcBlock)block;

//在导航栏右边显示、隐藏菊花
+ (UIActivityIndicatorView *) showIndicator:(UIViewController *) viewControllerindicator;
+ (void) hideIndicator:(UIViewController *) viewControllerindicator indicator:(UIActivityIndicatorView *)indicator;
+ (void) hideIndicator:(UIViewController *) viewControllerindicator indicator:(UIActivityIndicatorView *)indicator insteadOf:(UIBarButtonItem *)btn;

//在导航栏右边隐藏菊花 segue 为 modal 的形式
+ (void) hideIndicatorWithUINavigationItem:(UINavigationItem *)navigationItem indicator:(UIActivityIndicatorView *)indicator;
+ (void) hideIndicatorWithUINavigationItem:(UINavigationItem *)navigationItem indicator:(UIActivityIndicatorView *)indicator insteadOf:(UIBarButtonItem *)btn;
+ (UIActivityIndicatorView *) showIndicatorWithUINavigtationItem:(UINavigationItem *)navigationItem;
//显示 alertview
+ (void) showAlertView:(UIViewController *)viewController alertMsg:(NSString *)msg;

////在导航栏右边显示、隐藏菊花 tabbar --> navigationbar
//+ (UIActivityIndicatorView *) showIndicatorUINavigationItemInTabBarController:()

@end
