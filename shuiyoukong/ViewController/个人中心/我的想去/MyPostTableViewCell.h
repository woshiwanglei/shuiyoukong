//
//  MyPostTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverModel.h"

@interface MyPostTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_content;
@property (weak, nonatomic) IBOutlet UIButton *btn_up;
@property (weak, nonatomic) IBOutlet UILabel *label_num;

@property (strong, nonatomic)DiscoverModel *model;

@end
