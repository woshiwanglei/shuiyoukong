//
//  PointsCollectionViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductModel.h"

@interface PointsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *pic_Img;
@property (weak, nonatomic) IBOutlet UILabel *label_descriptopn;
@property (weak, nonatomic) IBOutlet UILabel *label_point;

@property (strong, nonatomic)ProductModel *model;
@end
