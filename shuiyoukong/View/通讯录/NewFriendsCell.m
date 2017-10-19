//
//  NewFriendsCell.m
//  Free
//
//  Created by 勇拓 李 on 15/5/9.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "NewFriendsCell.h"
#import "settings.h"
#import "FreeTabBarViewController.h"

@implementation NewFriendsCell

- (void)awakeFromNib
{
    _btn_newFriends.layer.cornerRadius = 3.f;
    _btn_newFriends.layer.masksToBounds = YES;
    
    [super awakeFromNib];
//    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
//    self.selectedBackgroundView.backgroundColor = FREE_BACKGOURND_COLOR;
    [self registerNotificationForMessage];
    self.btn_newFriends.userInteractionEnabled = NO;
    [FontSizemodle setfontSizeLableSize:_label_name];
}

- (UIViewController *)viewController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)setIsNew:(BOOL)isNew
{
    if (isNew == YES)
    {
        [_btn_newFriends setImage:[UIImage imageNamed:@"addfriend_new"] forState:UIControlStateNormal];
    }
    else
    {
        [_btn_newFriends setImage:[UIImage imageNamed:@"addfriend"] forState:UIControlStateNormal];
    }

    
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -注册通知
//发送消息
- (void) registerNotificationForMessage {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFriendsCome:) name:ZC_NOTIFICATION_NEW_FRIENDS object:nil];
}

//聊天发生变化
- (void) newFriendsCome:(NSNotification *) notification{
    
    if (self.isFirst == YES) {
        [_btn_newFriends setImage:[UIImage imageNamed:@"addfriend_new"] forState:UIControlStateNormal];
    }
}


@end

