//
//  followFriendsTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/14.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressListCellModel.h"

#define FOLLOW 1
#define FOLLOWED 2

@interface followFriendsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_Img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UIButton *btn_add;

@property(nonatomic,strong) AddressListCellModel *model;

@end
