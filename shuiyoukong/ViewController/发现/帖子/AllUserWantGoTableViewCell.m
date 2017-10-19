//
//  AllUserWantGoTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "AllUserWantGoTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation AllUserWantGoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
}

- (void)setModel:(SelectFriendsModel *)model
{
    _model = model;
    [self showHeadImage];
    _label_name.text = model.name;
}

- (void)showHeadImage
{
    //[FreeSingleton handleImageUrlWithSuffix:_model.head_Img sizeSuffix:SIZE_SUFFIX_100X100]
    //set tag
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
