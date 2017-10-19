//
//  MessageCenterTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MessageCenterTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MessageCenterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _view_new.layer.cornerRadius = 5.f;
    _view_new.layer.masksToBounds = YES;
    _view_new.hidden = YES;
    
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
}

- (void)setModel:(MessageCenterModel *)model
{
    _model = model;
    [self showImage:_head_img img_url:model.headImg_url];
    
    _label_content.text = model.content;
    
    [self setRightDownTime];
    [self setRedPoint];
}

- (void)showImage:(UIImageView *)avatar img_url:(NSString *)img_url
{
    NSString *picName = @"notice.png";
    
    switch (_model.type) {
        case COUPLE_TYPE:
            picName = @"couple";
            break;
        case POST_NOTICE:
            picName = @"icon_reply";
            break;
        case PRIZE_NOTICE:
            picName = @"icon_prize";
            break;
        case DELETE_NOTICE:
            picName = @"icon_delete_post";
            break;
        case POINT_PRIZE:
            picName = @"icon_point_prize";
            break;
        default:
            break;
    }
    
    
    [avatar sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:picName] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

////朋友匹配
//- (void)friendsCouple
//{
//    _label_content.text = [NSString stringWithFormat:@"匹配到好友“%@”", _model.friendName];
//}
//
////有朋友参加我的活动
//- (void)friendsJoinActivity
//{
//    _label_content.text = [NSString stringWithFormat:@"%@参加了我的活动“%@”", _model.friendName, _model.activity_name];
//}
//
////有朋友邀请我参加活动
//- (void)friendsInviteActivity
//{
//    _label_content.text = [NSString stringWithFormat:@"%@邀请我参加活动“%@”", _model.friendName, _model.activity_name];
//}
- (void)setRedPoint
{
    if (_model.isNew) {
        _view_new.hidden = NO;
    }
    else
    {
        _view_new.hidden = YES;
    }
}

//设置时间
- (void)setRightDownTime
{
    if (!_model.time) {
        return;
    }
    
    NSDate *date = [self changeString2Date:_model.time];
    NSArray *timeArray = [_model.time componentsSeparatedByString:@" "];
    if ([[FreeSingleton sharedInstance] isCurrentDay:date]) {
        _label_time.text = timeArray[1];
        return;
    }
    NSArray *dateArray = [timeArray[0] componentsSeparatedByString:@"-"];
    _label_time.text = [NSString stringWithFormat:@"%@-%@", dateArray[1], dateArray[2]];
}

//转换string到date
- (NSDate *)changeString2Date:(NSString *)str
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSDate *inputDate = [dateformatter dateFromString:str];
    return inputDate;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
