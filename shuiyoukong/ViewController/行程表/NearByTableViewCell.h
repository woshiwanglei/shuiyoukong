//
//  NearByTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/31.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverModel.h"

@interface NearByTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_content;
@property (weak, nonatomic) IBOutlet UILabel *label_distance;

@property (strong, nonatomic)DiscoverModel *model;

@end
