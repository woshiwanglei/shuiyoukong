//
//  ActivityInfoViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/12.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityModel.h"

@interface ActivityInfoViewController : UIViewController

@property (nonatomic,strong)ActivityModel* activity_model;

@property (nonatomic,strong)NSString *activityId;

@property (nonatomic, assign)NSInteger fromTag;

@end
