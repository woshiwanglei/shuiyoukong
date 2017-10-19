//
//  CoupleSuccTableViewCell.m
//  Free
//
//  Created by 勇拓 李 on 15/5/14.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "CoupleSuccTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSDate+TimeAgo.h"
#import "UserInfoViewController.h"

@implementation CoupleSuccTableViewCell

- (void)awakeFromNib
{
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
    _label_erdu.layer.cornerRadius = 3.f;
    _label_erdu.layer.masksToBounds = YES;
    
//    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
//    self.selectedBackgroundView.backgroundColor = FREE_BACKGOURND_COLOR;
    
//    [FontSizemodle setfontSizeLableSize:_label_name];
}

-(void)setModel:(CoupleSuccCellModel *)model
{
    _model = model;
    _label_name.text = model.friend_name;
    
    if ([model.type integerValue] == 0) {
        _label_erdu.hidden = YES;
        _label_left_length.constant = 8.f;
    }
    else
    {
        _label_erdu.hidden = NO;
        _label_left_length.constant = 75.f;
    }
    
    NSString *label = [model.friend_tag stringByReplacingOccurrencesOfString:@"-" withString:@", "];
    
    if ([label length] > 15) {
        label = [NSString stringWithFormat:@"%@...", [label substringToIndex:14]];
    }
    
    if (label == nil || [label length] == 0 || [label isEqualToString:@"(null)"]) {
        label = @"";
    }
    
    _label_content.text = label;
    //设置头像
    [self showImage:model.headImg_url];
    
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageTap:)];
    _head_img.userInteractionEnabled = YES;
    [_head_img addGestureRecognizer:tapImage];
    
    if (_model.str_time) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[_model.str_time doubleValue]/1000.0];
        _label_time.text = [date timeAgo];
        _label_time.hidden = NO;
    }
    else
    {
        _label_time.hidden = YES;
    }
}

-(void)ImageTap:(UITapGestureRecognizer *)tap
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    
    vc.friend_id = _model.friend_accountId;
    vc.friend_name = _model.friend_name;

    vc.hidesBottomBarWhenPushed = YES;
    
    [_vc.navigationController pushViewController:vc animated:YES];
}

- (void)showImage:(NSString *)img_url
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}


//            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
//                                                         bundle:nil];
//            UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
//            CoupleSuccCellModel *model = _friendModelArray[indexPath.row];
//            vc.friend_id = model.friend_accountId;
//            //                vc.friend_name = name;
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
//    _view_isNew.hidden = YES;
    
}

@end