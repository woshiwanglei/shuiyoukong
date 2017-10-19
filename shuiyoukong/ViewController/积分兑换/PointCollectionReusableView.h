//
//  PointCollectionReusableView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointModel.h"

@interface PointCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *label_points;
@property (weak, nonatomic) IBOutlet UILabel *label_high_points;
@property (weak, nonatomic) IBOutlet UILabel *label_Lv;
@property (weak, nonatomic) IBOutlet UIButton *btn_left;
@property (weak, nonatomic) IBOutlet UIButton *btn_right;
@property (weak, nonatomic) IBOutlet UIButton *btn_lv;

@property (strong, nonatomic)PointModel *model;
@end
