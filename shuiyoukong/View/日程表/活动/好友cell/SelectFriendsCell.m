//
//  SelectFriendsCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/2.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SelectFriendsCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation SelectFriendsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [FontSizemodle setfontSizeLableSize:_name];
    _image_selected.userInteractionEnabled = NO;
    
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
}

- (void)setModel:(SelectFriendsModel *)model
{
    _model = model;
    [self showImage:_model.img_url];
    _name.text = model.name;
    if (_model.isSelected == YES) {
        [_image_selected setImage:[UIImage imageNamed:@"icon_selected"]];
    }
    else
    {
        [_image_selected setImage:[UIImage imageNamed:@"icon_unselect"]];
    }
}

- (void)showImage:(NSString *)img_url
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}


@end