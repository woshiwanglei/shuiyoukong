//
//  ShuiyoukongActivityTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/12.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityModel.h"

@interface ShuiyoukongActivityTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_time;
@property (weak, nonatomic) IBOutlet UILabel *label_address;
@property (weak, nonatomic) IBOutlet UILabel *label_num;

@property (strong, nonatomic)ActivityModel *model;
@end
