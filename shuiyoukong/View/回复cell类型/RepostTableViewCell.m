//
//  RepostTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/21.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "RepostTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoViewController.h"
//#import "FreeSQLite.h"
#import "NSDate+TimeAgo.h"

@implementation RepostTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _head_Img.layer.cornerRadius = 3.f;
    _head_Img.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [super setSelected:selected animated:animated];
}

- (void)setModel:(RepostModel *)model
{
    _model = model;
    _label_name.text = model.nickName;
    if (_model.originalRepostName) {
        _text_content.text = [NSString stringWithFormat:@"@%@ %@", model.originalRepostName, model.content];
    }
    else
    {
        _text_content.text = model.content;
    }
    
    [self showHeadImage];
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageTap:)];
    _head_Img.userInteractionEnabled = YES;
    [_head_Img addGestureRecognizer:tapImage];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[_model.repostTime doubleValue]/1000.0];
    _label_time.text = [date timeAgo];
}

-(void)ImageTap:(UITapGestureRecognizer *)tap
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    
    vc.friend_id = _model.accountId;
//    vc.friend_name = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:_model.accountId];
//    if (![vc.friend_name length]) {
        vc.friend_name = _model.nickName;
//    }
    vc.hidesBottomBarWhenPushed = YES;
    
    [_vc.navigationController pushViewController:vc animated:YES];
}

- (void)showHeadImage
{
    //[FreeSingleton handleImageUrlWithSuffix:_model.head_Img sizeSuffix:SIZE_SUFFIX_100X100]
    //set tag
    
    [_head_Img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.headImg sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

@end
