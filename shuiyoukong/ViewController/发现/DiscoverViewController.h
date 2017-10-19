//
//  DiscoverViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscoverViewController : UIViewController

@property (nonatomic, assign)BOOL isNeedReload;

@property (nonatomic, strong)NSString *city;
@property (nonatomic, assign)NSInteger isCityChange;//城市是否变化

@end
