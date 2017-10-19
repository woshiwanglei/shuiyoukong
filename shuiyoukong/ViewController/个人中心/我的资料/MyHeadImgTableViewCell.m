//
//  MyHeadImgTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MyHeadImgTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MyHeadImgTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _head_img.layer.cornerRadius = 5.f;
    _head_img.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUrl:(NSString *)url
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:url sizeSuffix:SIZE_SUFFIX_300X300] placeholderImage:[UIImage imageNamed:@"touxiang"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

@end
