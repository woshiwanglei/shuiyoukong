//
//  FreeMapViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/26.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FreeMapViewController : UIViewController

@property (nonatomic, assign)CLLocationCoordinate2D location;
@property (nonatomic, copy)NSString *locationName;

@end
