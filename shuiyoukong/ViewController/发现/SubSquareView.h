//
//  SubSquareView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverModel.h"
//#import "DiscoverViewController.h"

@interface SubSquareView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *num;
@property (weak, nonatomic) IBOutlet UIButton *btn_up;
@property (weak, nonatomic) IBOutlet UIView *base_view;

@property (weak, nonatomic) UIViewController *discover_vc;
@property (strong, nonatomic)DiscoverModel *model;

@end
