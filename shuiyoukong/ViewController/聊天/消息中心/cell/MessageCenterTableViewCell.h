//
//  MessageCenterTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageCenterModel.h"

@interface MessageCenterTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_content;
@property (weak, nonatomic) IBOutlet UILabel *label_time;
@property (weak, nonatomic) IBOutlet UIView *view_new;

@property (strong, nonatomic)MessageCenterModel *model;

@end
