//
//  GuideView1.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/9/14.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "GuideView1.h"
#import "settings.h"
#import "UpdateRemarkViewController.h"

@implementation GuideView1

- (void)awakeFromNib
{
    [super awakeFromNib];
    _btn_2.hidden = YES;
    _btn_4.hidden = YES;
    
    [_btn_3 addTarget:self action:@selector(btn1_tapped:) forControlEvents:UIControlEventTouchDown];
    [_btn_4 addTarget:self action:@selector(btn2_tapped:) forControlEvents:UIControlEventTouchDown];
}

- (void)btn1_tapped:(UIButton *)btn
{
    GuideView1 *view = (GuideView1 *)btn.superview;
    view.btn_1.hidden = YES;
    view.btn_3.hidden = YES;
    view.btn_2.hidden = NO;
    view.btn_4.hidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_GUIDE_1 object:nil];
}

- (void)btn2_tapped:(UIButton *)btn
{
    _btn_2.hidden = YES;
    _btn_4.hidden = YES;
    
    UIView *view = self.superview;
    [view removeFromSuperview];
    [self removeFromSuperview];
    
    UpdateRemarkViewController *vc = [[UpdateRemarkViewController alloc] initWithNibName:@"UpdateRemarkViewController" bundle:nil];
    vc.remark = nil;
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:vc];
    [_vc presentViewController:nav animated:YES completion:nil];
}


@end
