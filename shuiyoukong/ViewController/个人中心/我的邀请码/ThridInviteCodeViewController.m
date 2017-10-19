//
//  ThridInviteCodeViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/9/21.
//  Copyright © 2015年 知春. All rights reserved.
//

#import "ThridInviteCodeViewController.h"
#import "AccountManageViewController.h"

@interface ThridInviteCodeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn_bind;

@end

@implementation ThridInviteCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initView
- (void)initView
{
    self.navigationItem.title = @"邀请码";
    _btn_bind.layer.cornerRadius = 3.f;
    _btn_bind.layer.masksToBounds = YES;
    [_btn_bind addTarget:self action:@selector(btn_bind_Tapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btn_bind_Tapped:(UIButton *)btn
{
    AccountManageViewController *vc = [[AccountManageViewController alloc] initWithNibName:@"AccountManageViewController" bundle:nil];
    
    vc.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = self.navigationController;
    [navigationController popToRootViewControllerAnimated:NO];
    [navigationController pushViewController:vc animated:YES];
}

@end
