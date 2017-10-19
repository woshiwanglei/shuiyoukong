//
//  DiscoverTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/15.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverModel.h"

@interface DiscoverTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_Img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *num;
@property (weak, nonatomic) IBOutlet UIImageView *big_Img;
@property (weak, nonatomic) IBOutlet UILabel *label_content;
@property (weak, nonatomic) IBOutlet UILabel *label_editor_comment;
@property (weak, nonatomic) IBOutlet UIButton *btn_up;
@property (weak, nonatomic) IBOutlet UIView *base_view;

@property (strong, nonatomic)NSMutableArray *view_array;
@property (assign, nonatomic)BOOL isNeedToShow;//是否需要显示

@property (strong, nonatomic)DiscoverModel *model;

@end
