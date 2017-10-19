//
//  CoupleSuccView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoupleSuccModel.h"


@interface CoupleSuccView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *friend_name;
@property (weak, nonatomic) IBOutlet UILabel *friend_tags;

@property (weak, nonatomic) IBOutlet UIView *view_high;
@property (weak, nonatomic) IBOutlet UIView *view_mid;
@property (weak, nonatomic) IBOutlet UIButton *btn_commit;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;

@property (strong, nonatomic)CoupleSuccModel *model;

@end
