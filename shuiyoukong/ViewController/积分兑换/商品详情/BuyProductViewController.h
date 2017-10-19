//
//  BuyProductViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductModel.h"

@interface BuyProductViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btn_buy;
//@property (weak, nonatomic) IBOutlet UIScrollView *scroll_img_view;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_point;
@property (weak, nonatomic) IBOutlet UITextView *text_view;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *text_height;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *img_aspect;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgView_top;

@property (strong, nonatomic)ProductModel *model;
@end
