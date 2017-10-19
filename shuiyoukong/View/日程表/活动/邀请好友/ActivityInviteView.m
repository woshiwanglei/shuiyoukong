//
//  ActivityInviteView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/9.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ActivityInviteView.h"

@implementation ActivityInviteView

-(void)awakeFromNib
{
    [super awakeFromNib];
    [FontSizemodle setfontSizeLableSize:_weiLable];
    [FontSizemodle setfontSizeLableSize:_friendLable];
    [FontSizemodle setfontSizeLableSize:_lawLable];
    [FontSizemodle setfontSizeLableSize:_qqLable];
    [FontSizemodle setfontSizeLableSize:_qoneLable];
    
    [self changBtn:_qqBtn];
    [self changBtn:_qoneBtn];
    [self changBtn:_weixinBtn];
    [self changBtn:_weixinFriend];
    
}
-(void)changBtn:(UIButton *)btn
{
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = 1.0;
    btn.layer.cornerRadius = 6.0;
    btn.layer.borderColor = [[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1] CGColor];
    btn.backgroundColor = [UIColor whiteColor];
}
@end
