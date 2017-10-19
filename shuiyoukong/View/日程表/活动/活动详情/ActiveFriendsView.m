//
//  ActiveFriendsView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ActiveFriendsView.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoViewController.h"

@implementation ActiveFriendsView

- (void)awakeFromNib
{
    [super awakeFromNib];
  //  self.userInteractionEnabled = NO;
}

- (void)setModel:(SelectFriendsModel *)model
{
    _model = model;
    _label_name.text = model.name;
    _friendId = _model.accountId;
    _friendName = _model.name;
    
    switch (model.fromInfo) {
        case 0:
        {
            _label_fromInfo.text = @"谁有空";
            UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageTap:)];
            
            [self addGestureRecognizer:tapImage];
        }
            break;
        case 1:
            _label_fromInfo.text = @"微信";
            break;
        default:
            _label_fromInfo.text = @"QQ";
            break;
    }
    
    [self showImage:model.img_url];
 
  
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

-(void)ImageTap:(UITapGestureRecognizer *)tap
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    
    vc.friend_id = _friendId;
    vc.friend_name = _friendName;
    vc.hidesBottomBarWhenPushed = YES;
    UIViewController *viewCont =[self viewController];
    
    [viewCont.navigationController pushViewController:vc animated:YES];
}

- (void)showImage:(NSString *)img_url
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}
@end
