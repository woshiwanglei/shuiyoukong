//
//  ActiveDetailViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#define NORMAL  3
#define NOT_ATTEND 2
#define ALREADY_ATTEND 1
#define MY_HOST 0

#import <UIKit/UIKit.h>

@interface ActiveDetailViewController : UIViewController

@property (nonatomic, copy)NSString *activityId;

@property (nonatomic, assign)NSInteger fromTag;

@end
