//
//  ActivityInviteView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/9.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontSizemodle.h"
@interface ActivityInviteView : UIView

@property (weak, nonatomic) IBOutlet UIButton *qqBtn;
@property (weak, nonatomic) IBOutlet UIButton *qoneBtn;

@property (weak, nonatomic) IBOutlet UIButton *weixinBtn;
@property (weak, nonatomic) IBOutlet UIButton *weixinFriend;
@property (weak, nonatomic) IBOutlet UILabel *qqLable;
@property (weak, nonatomic) IBOutlet UILabel *qoneLable;

@property (weak, nonatomic) IBOutlet UILabel *weiLable;
@property (weak, nonatomic) IBOutlet UILabel *friendLable;

@property (weak, nonatomic) IBOutlet UILabel *lawLable;

@end
