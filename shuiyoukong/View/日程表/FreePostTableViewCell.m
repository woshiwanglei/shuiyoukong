//
//  FreePostTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/7.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FreePostTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation FreePostTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
}

- (void)setModel:(DiscoverModel *)model
{
    _model = model;
    [self showImage];
    if (model.num) {
        _label_num.text = [NSString stringWithFormat:@"%@人想去", model.num];
    }
    else
    {
        _label_num.text = [NSString stringWithFormat:@"0人想去"];
    }
    _label_name.text = model.content;
    _label_tags.text = model.editor_comment;
}

- (void)showImage
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.big_Img sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         
     }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
