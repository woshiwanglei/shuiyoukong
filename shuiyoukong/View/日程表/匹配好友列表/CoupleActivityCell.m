//
//  CoupleActivityCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/17.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "CoupleActivityCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation CoupleActivityCell

- (void)awakeFromNib {
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = FREE_BACKGOURND_COLOR;
    [FontSizemodle setfontSizeLableSize:_label_name];
    if (SCREEN_HEIGHT == 480)
    {
        _label_activityName.font = [UIFont systemFontOfSize:15.0];
    }
    else if(SCREEN_HEIGHT == 568)
    {
        _label_activityName.font = [UIFont systemFontOfSize:15.0];
    }
    else if(SCREEN_HEIGHT == 667)
    {
        _label_activityName.font = [UIFont systemFontOfSize:17.0];
    }
    else if(SCREEN_HEIGHT == 736)
    {
        _label_activityName.font = [UIFont systemFontOfSize:18.0];
    }
    else
    {
        _label_activityName.font = [UIFont systemFontOfSize:15.0];
    }

}


- (void)setModel:(CoupleSuccActivityModel *)model
{
    _model = model;
    _label_name.text = model.friendName;
    _label_peopleNum.text = [NSString stringWithFormat:@"%@人报名", model.peopleNum];
    _label_activityName.text = model.activityTitle;
    
//    if (model.isMyActivity == YES) {
//        [_btn_rightTag setImage:[UIImage imageNamed:@"icon_activity_me"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        [_btn_rightTag setImage:[UIImage imageNamed:@"icon_activity_other"] forState:UIControlStateNormal];
//    }
    
    [self showImage:model.img_url];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)showImage:(NSString *)img_url
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

@end
