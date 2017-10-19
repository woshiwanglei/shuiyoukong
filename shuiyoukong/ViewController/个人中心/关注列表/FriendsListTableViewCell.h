//
//  FriendsListTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/31.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *my_cared_num;
@property (weak, nonatomic) IBOutlet UILabel *care_me_num;
@property (weak, nonatomic) IBOutlet UIView *left_red_point;
@property (weak, nonatomic) IBOutlet UIView *right_red_point;
@property (weak, nonatomic) IBOutlet UIView *left_view;
@property (weak, nonatomic) IBOutlet UIView *right_view;

@property (weak, nonatomic)UIViewController *vc;
@end
