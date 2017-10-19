//
//  showUserInfo1Cell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "showUserInfo1Model.h"

@interface showUserInfo1Cell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;

@property (weak, nonatomic) IBOutlet UILabel *termame;

@property (weak, nonatomic) IBOutlet UIImageView *genderImage;

@property (strong, nonatomic)showUserInfo1Model *model;

@end
