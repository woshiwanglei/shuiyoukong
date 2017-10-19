//
//  ShuiyoukongHeader.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/7.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShuiyoukongTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ShuiyoukongHeader : UIView
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_content;
@property (weak, nonatomic) IBOutlet UIButton *btn_free;
@property (weak, nonatomic) IBOutlet UIButton *btn_edit;

@property (assign, nonatomic)BOOL isFree;
@property (strong, nonatomic)NSString *content;

@property (weak, nonatomic)ShuiyoukongTableViewController *vc;

@end
