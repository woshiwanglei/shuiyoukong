//
//  showUserInfo1Cell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "showUserInfo1Cell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface showUserInfo1Cell()


@end

@implementation showUserInfo1Cell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _head_img.layer.masksToBounds = YES;
    _head_img.layer.cornerRadius = 5;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)setModel:(showUserInfo1Model *)model
{
    _model = model;
    
    [self showImage:model.img_url];
    
    _label_name.text = model.name;
    
    _termame.text = model.niksname;
    
    
    if ([model.gender isEqualToString:@"male"])
    {
        
        _genderImage.image = [UIImage imageNamed:@"man"];
    }
    else
    {
        _genderImage.image = [UIImage imageNamed:@"woman"];
    }
}

- (void)showImage:(NSString *)img_url
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         
     }];
}



@end
