//
//  RepostTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/21.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RepostModel.h"


@interface RepostTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_Img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UITextView *text_content;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height_content;
@property (weak, nonatomic)UIViewController *vc;
@property (strong, nonatomic)RepostModel *model;
@property (weak, nonatomic) IBOutlet UILabel *label_time;

@end
