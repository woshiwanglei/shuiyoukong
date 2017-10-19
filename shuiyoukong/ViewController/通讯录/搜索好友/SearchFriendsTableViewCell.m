//
//  SearchFriendsTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SearchFriendsTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation SearchFriendsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUrl:(NSString *)url
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         
     }];
}

@end
