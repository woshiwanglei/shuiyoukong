//
//  CoupleActivityCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/17.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoupleSuccActivityModel.h"
#import "FontSizemodle.h"
@interface CoupleActivityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_activityName;
@property (weak, nonatomic) IBOutlet UILabel *label_peopleNum;

@property (nonatomic, strong)CoupleSuccActivityModel *model;
@end
