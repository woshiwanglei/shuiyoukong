//
//  AddressListInviteTableViewCell.h
//  Free
//
//  Created by 勇拓 李 on 15/5/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressListInviteCellModel.h"
#import "ShareInterfaceView.h"
#import "AppDelegate.h"
#import "InviteUIview.h"
#import "UMSocial.h"
#import <MessageUI/MessageUI.h>
#import "FontSizemodle.h"
@class AddressListInviteCellModel;

@interface AddressListInviteTableViewCell : UITableViewCell<UMSocialUIDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *img_head;
@property (weak, nonatomic) IBOutlet UIButton *btn_invite;
@property (weak, nonatomic) IBOutlet UILabel *label_name;

@property (nonatomic, copy) NSString *phoneNB;

@property (nonatomic,strong) UIView *background;
@property (nonatomic, strong) InviteUIview *shareview;

@property(nonatomic,strong) AddressListInviteCellModel *model;

@end
