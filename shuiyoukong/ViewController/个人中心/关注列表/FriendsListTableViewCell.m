//
//  FriendsListTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/31.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FriendsListTableViewCell.h"
#import "MyFansTableViewController.h"
#import "settings.h"

@implementation FriendsListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _left_red_point.layer.cornerRadius = 4.f;
    _left_red_point.layer.masksToBounds = YES;
    _right_red_point.layer.cornerRadius = 4.f;
    _right_red_point.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoLeft:)];
    _left_view.userInteractionEnabled = YES;
    [_left_view addGestureRecognizer:tapGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoRight:)];
    _right_view.userInteractionEnabled = YES;
    [_right_view addGestureRecognizer:tapGestureRecognizer2];
}

- (void)gotoLeft:(UITapGestureRecognizer *)gesture
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MyCaredTableViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    [_vc.navigationController pushViewController:vc animated:YES];
}

- (void)gotoRight:(UITapGestureRecognizer *)gesture
{
    MyFansTableViewController *vc = [[MyFansTableViewController alloc] initWithNibName:@"MyFansTableViewController" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    [_vc.navigationController pushViewController:vc animated:YES];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_IF_HAS_NEW_FRIENDS];
    self.right_red_point.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [super setSelected:selected animated:animated];
}

@end
