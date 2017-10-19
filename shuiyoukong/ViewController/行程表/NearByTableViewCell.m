//
//  NearByTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/31.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "NearByTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation NearByTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
}

- (void)setModel:(DiscoverModel *)model
{
    _model = model;
    [self showImage];
    _label_content.text = model.content;
    _label_distance.text = model.distance;
}

- (void)showImage
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.big_Img sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"glass"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         
     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
