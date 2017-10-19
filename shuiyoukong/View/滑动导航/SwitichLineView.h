//
//  SwitichLineView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitichLineView : UIView
@property (weak, nonatomic) IBOutlet UIView *left_view;
@property (weak, nonatomic) IBOutlet UIView *right_view;
@property (weak, nonatomic) IBOutlet UIView *bottom_view;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *left_constrain;
@property (weak, nonatomic) IBOutlet UILabel *label_right;
@property (weak, nonatomic) IBOutlet UILabel *label_left;

@end
