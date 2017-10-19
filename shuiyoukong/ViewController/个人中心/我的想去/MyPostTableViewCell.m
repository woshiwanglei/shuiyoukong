//
//  MyPostTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MyPostTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MyPostTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
    
}

- (void)setModel:(DiscoverModel *)model
{
    _model = model;
    [self showBigImage];
    _label_content.text = model.content;
    _label_num.text = model.num;
    
    [_btn_up addTarget:self action:@selector(btn_up_Tapped:) forControlEvents:UIControlEventTouchDown];
    
    if (_model.isUp) {
        [_btn_up setImage:[UIImage imageNamed:@"icon_heart"] forState:UIControlStateNormal];
        _btn_up.userInteractionEnabled = NO;
    }
    else
    {
        [_btn_up setImage:[UIImage imageNamed:@"icon_heart_off"] forState:UIControlStateNormal];
        _btn_up.userInteractionEnabled = YES;
    }
}


- (void)showBigImage
{
    //set tag
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.big_Img sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"tupian"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

- (void)btn_up_Tapped:(UIButton *)btn
{
    if (_model.isUp) {
        return;
    }
    
    [[FreeSingleton sharedInstance] upPostInfoOnCompletion:_model.postId type:@"0" block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            _model.isUp = YES;
            NSInteger num = [_model.num integerValue];
            num++;
            _model.num = [NSString stringWithFormat:@"%ld", (long)num];
            _label_num.text = _model.num;
            [_btn_up setImage:[UIImage imageNamed:@"icon_heart"] forState:UIControlStateNormal];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPDATE_DIANZAN object:_model];
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
