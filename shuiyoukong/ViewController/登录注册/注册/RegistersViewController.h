//
//  RegistersViewController.h
//  Free
//
//  Created by yangcong on 15/5/4.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistersViewController : UIViewController<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *HeadImage;

@property (weak, nonatomic) IBOutlet UITextField *NumberSend;

@property (weak, nonatomic) IBOutlet UITextField *YourName;

@property (weak, nonatomic) IBOutlet UITextField *passWord;

@property (weak, nonatomic) IBOutlet UITextField *gender;

@property (weak, nonatomic) IBOutlet UITextField *text_inviteCode;

@property (nonatomic, copy) NSString *phone_num;

@property (weak, nonatomic) IBOutlet UIButton *certain;

@property (weak, nonatomic) IBOutlet UIButton *againCertain;

@property (weak, nonatomic) IBOutlet UIView *NumberBG;

@property (weak, nonatomic) IBOutlet UIView *NameBG;

@property (weak, nonatomic) IBOutlet UIView *passWordBG;

@property (weak, nonatomic) IBOutlet UIView *genderBG;
@property (weak, nonatomic) IBOutlet UIView *inviteCodeBG;

@end
