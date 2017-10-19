//
//  CoupleSuccTableViewCell.h
//  Free
//
//  Created by 勇拓 李 on 15/5/14.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoupleSuccCellModel.h"
#import "FontSizemodle.h"

@interface CoupleSuccTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_content;
@property (weak, nonatomic) IBOutlet UILabel *label_time;
@property (weak, nonatomic) IBOutlet UILabel *label_erdu;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label_left_length;

@property (nonatomic,strong)CoupleSuccCellModel *model;
@property (weak, nonatomic) IBOutlet UIView *bottom_line;

@property (nonatomic, weak)UIViewController *vc;

@end

