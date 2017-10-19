//
//  inviteCodeDetailViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/9/9.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "inviteCodeDetailViewController.h"

@interface inviteCodeDetailViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progress_length;
@property (weak, nonatomic) IBOutlet UIButton *btn_1;
@property (weak, nonatomic) IBOutlet UIButton *btn_5;
@property (weak, nonatomic) IBOutlet UIButton *btn_50;
@property (weak, nonatomic) IBOutlet UILabel *label_notice;
@property (weak, nonatomic) IBOutlet UIView *progress_view;
@property (weak, nonatomic) IBOutlet UIView *track_view;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn_5_location;

@end

@implementation inviteCodeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.navigationItem.title = @"奖励详情";
    
    NSString *str = nil;
    
    if (_inviteNum < 1) {
        [_btn_1 setImage:[UIImage imageNamed:@"invite_code_1_off"] forState:UIControlStateNormal];
        [_btn_5 setImage:[UIImage imageNamed:@"invite_code_5_off"] forState:UIControlStateNormal];
        [_btn_50 setImage:[UIImage imageNamed:@"invite_code_50_off"] forState:UIControlStateNormal];
        
        str = @"已成功邀请 0 位好友 丨 获得 0 积分";
    }
    else if (_inviteNum >= 1 && _inviteNum < 5)
    {
        [_btn_1 setImage:[UIImage imageNamed:@"invite_code_1_on"] forState:UIControlStateNormal];
        [_btn_5 setImage:[UIImage imageNamed:@"invite_code_5_off"] forState:UIControlStateNormal];
        [_btn_50 setImage:[UIImage imageNamed:@"invite_code_50_off"] forState:UIControlStateNormal];
        
        str = [NSString stringWithFormat:@"已成功邀请 %ld 位好友 丨 获得 %ld 积分", (long)_inviteNum, _inviteNum * 50];
    }
    else if (_inviteNum >= 5 && _inviteNum < 50)
    {
        [_btn_1 setImage:[UIImage imageNamed:@"invite_code_1_on"] forState:UIControlStateNormal];
        [_btn_5 setImage:[UIImage imageNamed:@"invite_code_5_on"] forState:UIControlStateNormal];
        [_btn_50 setImage:[UIImage imageNamed:@"invite_code_50_off"] forState:UIControlStateNormal];
        str = [NSString stringWithFormat:@"已成功邀请 %ld 位好友 丨 获得 %ld 积分", (long)_inviteNum, _inviteNum * 50 + 1000];
    }
    else
    {
        [_btn_1 setImage:[UIImage imageNamed:@"invite_code_1_on"] forState:UIControlStateNormal];
        [_btn_5 setImage:[UIImage imageNamed:@"invite_code_5_on"] forState:UIControlStateNormal];
        [_btn_50 setImage:[UIImage imageNamed:@"invite_code_50_on"] forState:UIControlStateNormal];
        
        str = [NSString stringWithFormat:@"已成功邀请 %ld 位好友 丨 获得 13500 积分", (long)_inviteNum];
    }
    
    _label_notice.text = str;
    _track_view.layer.cornerRadius = 10.f;
    _track_view.layer.masksToBounds = YES;
    
    _progress_length.constant = ([UIScreen mainScreen].bounds.size.width - 20)/50 * _inviteNum;
    _btn_5_location.constant = ([UIScreen mainScreen].bounds.size.width - 20)/50 * 5;
}

@end
