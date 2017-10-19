//
//  SelectFriendsCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/2.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectFriendsModel.h"
#import "FontSizemodle.h"

@interface SelectFriendsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *image_selected;

@property (strong, nonatomic)SelectFriendsModel *model;

@end
