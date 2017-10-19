//
//  ShuiyoukongActivityTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/12.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ShuiyoukongActivityTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ShuiyoukongActivityTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
}

- (void)setModel:(ActivityModel *)model
{
    _model = model;
    [self showImage];
    if (model.attendCount) {
        _label_num.text = [NSString stringWithFormat:@"%ld人报名", (long)model.attendCount];
    }
    else
    {
        _label_num.text = [NSString stringWithFormat:@"0人报名"];
    }
    _label_name.text = model.title;
    _label_address.text = model.address;
    NSArray *array = [model.activityDate componentsSeparatedByString:@"-"];
    if ([array count] > 2) {
        _label_time.text = [NSString stringWithFormat:@"%@-%@ %@", array[1], array[2], model.activityTime];
    }
    else
    {
        _label_time.text = [NSString stringWithFormat:@"%@%@", model.activityDate, model.activityTime];
    }
    
}

- (void)showImage
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.headImg sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         
     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
