//
//  RightFriendsListCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/25.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightFriendsListView : UIView
@property (weak, nonatomic) IBOutlet UILabel *label_time;
@property (weak, nonatomic) IBOutlet UILabel *label_people_num;
@property (weak, nonatomic) IBOutlet UIButton *btn_arrow;
@property (strong, nonatomic) IBOutlet UIButton *btn_new;
@property (weak, nonatomic) IBOutlet UIView *bottom_view;
@property (weak, nonatomic) IBOutlet UILabel *label_content;
@property (weak, nonatomic) IBOutlet UIView *bottom_line;

@end
