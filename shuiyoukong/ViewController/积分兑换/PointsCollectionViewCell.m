//
//  PointsCollectionViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "PointsCollectionViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation PointsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
}

- (void)setModel:(ProductModel *)model
{
    for (UIView *view in _pic_Img.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    _model = model;
    _label_descriptopn.text = model.itemName;
    _label_point.text = [NSString stringWithFormat:@"%@积分", model.needPoints];
    [self showImage];
    
    if ([model.itemCount integerValue] == 0) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ([UIScreen mainScreen].bounds.size.width - 6)/2 - 8, ([UIScreen mainScreen].bounds.size.width - 6)/2 - 8)];
        imgView.image = [UIImage imageNamed:@"background_sellout"];
        [_pic_Img addSubview:imgView];
    }
}

- (void)showImage
{
//    _pic_Img.contentMode =  UIViewContentModeCenter;
//    _pic_Img.clipsToBounds = YES;
    //[FreeSingleton handleImageUrlWithSuffix:_model.head_Img sizeSuffix:SIZE_SUFFIX_100X100]
    //set tag
    [_pic_Img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.imgUrl sizeSuffix:SIZE_SUFFIX_300X300] placeholderImage:[UIImage imageNamed:@"tupian.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

@end
