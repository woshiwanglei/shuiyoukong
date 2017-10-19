//
//  GameShareViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/8.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameShareViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_name2;
@property (weak, nonatomic) IBOutlet UILabel *label_name3;
@property (weak, nonatomic) IBOutlet UIButton *btn_playAgain;
@property (weak, nonatomic) IBOutlet UIButton *btn_share;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view_hegiht;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labeltoLabel1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelConstant1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelConstant2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn_to_bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top_to_top;
@property (weak, nonatomic) IBOutlet UILabel *label_dishu;
@property (weak, nonatomic) IBOutlet UIButton *btn_free;

@property (nonatomic, copy)NSString *name1;
@property (nonatomic, copy)NSString *name2;
@property (nonatomic, copy)NSString *name3;

@end
