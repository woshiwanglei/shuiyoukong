//
//  followFriendsTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/14.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "followFriendsTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation followFriendsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = FREE_BACKGOURND_COLOR;
    _btn_add.layer.cornerRadius = 3.f;
    _btn_add.layer.masksToBounds = YES;
    
    _head_Img.layer.cornerRadius = 3.f;
    _head_Img.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(AddressListCellModel *)model
{
    _model = model;
    _label_name.text = model.user_name;
    [self showImage];
    if([model.status integerValue] == FOLLOWED)//代表为关注
    {
        _btn_add.userInteractionEnabled = YES;
        [_btn_add setTitle:@"关注" forState:UIControlStateNormal];
        _btn_add.backgroundColor = FREE_BACKGOURND_COLOR;
        [_btn_add setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        _btn_add.userInteractionEnabled = NO;
        [_btn_add setTitle:@"已关注" forState:UIControlStateNormal];
        _btn_add.backgroundColor = [UIColor clearColor];
        [_btn_add setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)showImage
{
    [_head_Img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

@end
