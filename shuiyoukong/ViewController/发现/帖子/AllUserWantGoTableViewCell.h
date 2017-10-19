//
//  AllUserWantGoTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectFriendsModel.h"

@interface AllUserWantGoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;

@property (nonatomic ,strong)SelectFriendsModel *model;

@end
