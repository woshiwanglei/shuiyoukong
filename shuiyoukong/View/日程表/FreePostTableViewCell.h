//
//  FreePostTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/7.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverModel.h"

@interface FreePostTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_tags;
@property (weak, nonatomic) IBOutlet UILabel *label_num;

@property (strong, nonatomic)DiscoverModel *model;
@end
