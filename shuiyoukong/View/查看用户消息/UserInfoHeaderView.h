//
//  UserInfoHeaderView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"

@interface UserInfoHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UIButton *btn_gender;
@property (weak, nonatomic) IBOutlet UILabel *label_city;
@property (weak, nonatomic) IBOutlet UIButton *btn_lv;
@property (weak, nonatomic) IBOutlet UILabel *label_lv;
@property (weak, nonatomic) IBOutlet UILabel *label_followed_num;
@property (weak, nonatomic) IBOutlet UILabel *label_follower_num;

@property (strong, nonatomic)Account *model;

@property (weak, nonatomic)UIViewController *vc;

@end
