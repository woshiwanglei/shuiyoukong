//
//  InviteUIview.h
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/5/19.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "FreeTabBarViewController.h"
#import "settings.h"

@interface InviteUIview : UIView<MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *QQbtn;

@property (weak, nonatomic) IBOutlet UIButton *WXbtn;

@property (weak, nonatomic) IBOutlet UIButton *Phonebtn;

@property (nonatomic,copy)  NSString * phonenumber;

@property (nonatomic, weak) UIView *backgroudView;

@property (nonatomic, weak) UIButton *btn;


@end
