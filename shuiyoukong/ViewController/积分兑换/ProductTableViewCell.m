//
//  ProductTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ProductTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ProductTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _head_img.layer.cornerRadius = 5.f;
    _head_img.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(RecordModel *)model
{
    _model = model;
    _label_name.text = model.model.itemName;
//    _label_name.text = @"兑换详情";
    [self setRightDownTime];
    [self showImage];
}

//设置时间
- (void)setRightDownTime
{
    double time;
    time = [[NSString stringWithFormat:@"%@",_model.model.expireDate] doubleValue];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time/1000.0];
    NSString* strDate = [[FreeSingleton sharedInstance] changeDate2String:date];
    NSArray *timeArray = [strDate componentsSeparatedByString:@" "];
    _label_time.text = [NSString stringWithFormat:@"到期时间: %@", timeArray[0]];
    
}

- (void)showImage
{
    //[FreeSingleton handleImageUrlWithSuffix:_model.head_Img sizeSuffix:SIZE_SUFFIX_100X100]
    //set tag
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.model.imgUrl sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"tupian.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

@end
