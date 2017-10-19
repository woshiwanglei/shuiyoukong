//
//  CoupleRemarkTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/8.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "CoupleRemarkTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FontSizemodle.h"

@implementation CoupleRemarkTableViewCell

- (void)awakeFromNib {
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = FREE_BACKGOURND_COLOR;
//    [FontSizemodle setfontSizeLableSize:_label_remark];
}

- (void)setRemark:(NSString *)remark
{
    NSString *str = remark;
    if (str == nil || [str isEqualToString:@""]) {
        str = @"想做点什么呢？";
    }
    _label_remark.text = [NSString stringWithFormat:@"%@", str];
    [self showImage];
    _head_Img.layer.cornerRadius = 5.f;
    _head_Img.layer.masksToBounds = YES;
    [FontSizemodle setfontSizeLableSize:_label_name];
//    [FontSizemodle setfontSizeLableSize:_label_remark];
    _label_name.text = [[FreeSingleton sharedInstance] getNickName];
}

- (void)showImage
{
    [_head_Img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:[[FreeSingleton sharedInstance] getHeadImage] sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
