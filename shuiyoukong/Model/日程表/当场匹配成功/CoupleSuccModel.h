//
//  CoupleSuccModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoupleSuccModel : NSObject

@property (nonatomic, strong)NSString *friend_name;
@property (nonatomic, strong)NSString *friend_img;
@property (nonatomic, strong)NSString *friend_tags;
@property (nonatomic, strong)NSString *friend_accountId;
@property (nonatomic, weak)UIViewController *view_Controller;

@end
