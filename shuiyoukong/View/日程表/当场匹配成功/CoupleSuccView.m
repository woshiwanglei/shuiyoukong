//
//  CoupleSuccView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "CoupleSuccView.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDChatViewController.h"

@implementation CoupleSuccView

- (void)awakeFromNib
{
    [super awakeFromNib];
    _btn_cancel.tintColor = FREE_BACKGOURND_COLOR;
    _btn_commit.tintColor = FREE_BACKGOURND_COLOR;

    _view_high.backgroundColor = FREE_BACKGOURND_COLOR;
    _view_mid.backgroundColor = FREE_BACKGOURND_COLOR;
    
    self.layer.cornerRadius = 5.f;
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.layer.shadowRadius = 4.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.head_img.layer.cornerRadius = 3.f;
    self.head_img.layer.masksToBounds = YES;
}

- (void)setModel:(CoupleSuccModel *)model
{
    _model = model;
    
    [self showImage:model.friend_img];
    
    NSString *label = [model.friend_tags stringByReplacingOccurrencesOfString:@"," withString:@"-"];
    
    if ([label length] > 15) {
        label = [NSString stringWithFormat:@"%@...", [label substringToIndex:14]];
    }
    
    if (label == nil || [label length] == 0) {
        label = @"";
    }
    
    _friend_tags.text = label;
    _friend_name.text = model.friend_name;
    
    [_btn_commit addTarget:self action:@selector(btn_commitTapped:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_cancel addTarget:self action:@selector(btn_cancelTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showImage:(NSString *)img_url
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

- (void)btn_commitTapped:(id)sender
{
    UIViewController *viewController = _model.view_Controller;
    UIView *view = [[sender superview] superview];
    [self removeFromSuperview];
    [view removeFromSuperview];
    
    //创建会话
    RCDChatViewController *chatViewController = [[RCDChatViewController alloc] init];
    NSString *accountId = [NSString stringWithFormat:@"%@", _model.friend_accountId];
    chatViewController.conversationType = ConversationType_PRIVATE;
    chatViewController.targetId = accountId;
    chatViewController.title = _model.friend_name;
    chatViewController.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = viewController.navigationController;
    [navigationController pushViewController:chatViewController animated:YES];
}



- (void)btn_cancelTapped:(id)sender
{
    UIView *view = [[sender superview] superview];
    [self removeFromSuperview];
    [view removeFromSuperview];
}

@end