//
//  ShareWebView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"

@interface ShareWebView : UIView
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet UIButton *QButton;
@property (weak, nonatomic) IBOutlet UIButton *QoButton;
@property (weak, nonatomic) IBOutlet UIButton *WXbutton;
@property (weak, nonatomic) IBOutlet UIButton *WXFbutton;
@property (weak, nonatomic) IBOutlet UIButton *SinButton;
@property (weak, nonatomic) IBOutlet UIButton *SurpassButton;
@property (weak, nonatomic) IBOutlet UILabel *Surpass_label;
@property (weak, nonatomic) IBOutlet UIButton *CopyButton;
@property (weak, nonatomic) IBOutlet UIButton *btn_refresh;
@property (weak, nonatomic) IBOutlet UIView *view_refresh;
@property (weak, nonatomic) IBOutlet UIView *report_view;
@property (weak, nonatomic) IBOutlet UIView *view_copy;
@property (weak, nonatomic) IBOutlet UILabel *Copy_label;
@property (weak, nonatomic) IBOutlet UILabel *label_bottom_title;
@property (weak, nonatomic) IBOutlet UILabel *label_refresh;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label_height;
@end
