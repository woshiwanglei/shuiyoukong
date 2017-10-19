//
//  Utils.m
//  Free
//
//  Created by 勇拓 李 on 15/4/29.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "Utils.h"

//#import "INTULocationManager.h"

@implementation Utils


+ (void) warningUser:(UIViewController *) viewController msg:(NSString *) msg{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    hud.detailsLabelText = msg;
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:0.8];
    
    
}

+ (void) warningUser:(UIViewController *) viewController msg:(NSString *) msg time:(NSInteger)time{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    hud.detailsLabelText = msg;
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:time];
    
    
}

+ (void) warningUserAfterJump:(UIViewController *)viewController msg:(NSString *)msg time:(NSInteger)time {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewController.view.window animated:YES];
    hud.detailsLabelText = msg;
    hud.mode = MBProgressHUDModeText;
    [hud hide:YES afterDelay:time];
}


+ (MBProgressHUD *) waiting:(UIViewController *)viewController msg:(NSString *)msg {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    if (msg) {
        hud.labelText = msg;
    } else {
        hud.mode = MBProgressHUDModeIndeterminate;
    }
    return hud;
}

+ (void)hideHUD:(MBProgressHUD *)hud {
    [hud hide:YES];
}
+ (UIActivityIndicatorView *) showIndicator:(UIViewController *)viewController {
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    UIBarButtonItem* btn_indicator = [[UIBarButtonItem alloc] initWithCustomView:indicator];
    viewController.navigationItem.rightBarButtonItem = btn_indicator;
    [indicator startAnimating];
    
    return indicator;
}

+ (UIActivityIndicatorView *) showIndicatorWithUINavigtationItem:(UINavigationItem *)navigationItem {
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    UIBarButtonItem* btn_indicator = [[UIBarButtonItem alloc] initWithCustomView:indicator];
    navigationItem.rightBarButtonItem = btn_indicator;
    [indicator startAnimating];
    
    return indicator;
}

+ (void) hideIndicator:(UIViewController *)viewController indicator:(UIActivityIndicatorView *)indicator{
    
    if (indicator) {
        [indicator stopAnimating];
        
    }
}

+ (void) hideIndicator:(UIViewController *)viewController indicator:(UIActivityIndicatorView *)indicator insteadOf:(UIBarButtonItem *)btn{
    
    if (indicator) {
        [indicator stopAnimating];
        viewController.navigationItem.rightBarButtonItem = btn;
    }
}


+ (void) hideIndicatorWithUINavigationItem:(UINavigationItem *)navigationItem indicator:(UIActivityIndicatorView *)indicator {
    
    if (indicator) {
        [indicator stopAnimating];
        
    }
}

+ (void) hideIndicatorWithUINavigationItem:(UINavigationItem *)navigationItem indicator:(UIActivityIndicatorView *)indicator insteadOf:(UIBarButtonItem *)btn {
    
    if (indicator) {
        [indicator stopAnimating];
        navigationItem.rightBarButtonItem = btn;
    }
}

+ (void) showAlertView:(UIViewController *)viewController alertMsg:(NSString *)msg {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"ops" message:msg delegate:nil cancelButtonTitle:@"恩" otherButtonTitles:nil, nil];
    [viewController.view addSubview:alert];
    [alert show];
}

// 获取经纬度
//+ (void)getPosition:(UIViewController *)viewController block:(ZcBlock)block{
//    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
//    __block NSString* position;
//    
//    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock
//                                       timeout:2.0
//                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
//                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
//                                             if (status == INTULocationStatusSuccess) {
//                                                 position = [NSString stringWithFormat:@"%f-%f",currentLocation.coordinate.longitude, currentLocation.coordinate.latitude];
//                                                 NSLog(@"获取经纬度成功 %@",position);
//                                                 block(1, position);
//                                                 
//                                             }
//                                             else if (status == INTULocationStatusTimedOut) {
//                                                 position = [NSString stringWithFormat:@"%f-%f",currentLocation.coordinate.longitude, currentLocation.coordinate.latitude];
//                                                 NSLog(@"获取经纬度超时，使用上一次的数据 %@",position);
//                                                 block(0, position);
//                                             }
//                                             else {
//                                                 block(0, position);
//                                                 [self warningUser:viewController msg:@"获取经纬度失败"];
//                                                 
//                                             }
//                                             
//                                         }];
//    
//    
//}
@end
