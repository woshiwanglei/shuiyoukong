//
//  AddressListTableViewCell.m
//  Free
//
//  Created by 勇拓 李 on 15/5/5.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "AddressListTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation AddressListTableViewCell

- (void)awakeFromNib
{
    _img_head.layer.cornerRadius = 3.f;
    _img_head.layer.masksToBounds = YES;
//    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
//    self.selectedBackgroundView.backgroundColor = FREE_BACKGOURND_COLOR;
//    self.switch_attention.onTintColor = FREE_BACKGOURND_COLOR;
    
    [FontSizemodle setfontSizeLableSize:_label_name];
//    [FontSizemodle setfontSizeLableSize:_label_attention];
}

- (void)setModel:(AddressListCellModel *) model
{
    
    _model = model;
    
    _label_name.text = model.user_name;
    
    //设置头像
    [self showImage:_img_head img_url:model.img_url];
    
    [self setStatus];
    
    [_btn_followed addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)showImage:(UIImageView *)avatar img_url:(NSString *)img_url
{
    //set tag
    [avatar sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

- (void)setStatus
{
    switch ([_model.status intValue]) {
        case MY_CARE:
            [_btn_followed setImage:[UIImage imageNamed:@"icon_no_cocern"] forState:UIControlStateNormal];
            break;
        case CARE_ME:
            [_btn_followed setImage:[UIImage imageNamed:@"icon_cocern"] forState:UIControlStateNormal];
            break;
        case CARE_EACH:
            [_btn_followed setImage:[UIImage imageNamed:@"icon_cocern_each"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

//切换状态
- (void)switchAction:(UISwitch *)sender
{
    _btn_followed.userInteractionEnabled = NO;
//    BOOL isButtonOn = [sender isOn];
    
    if ([_model.status intValue] != CARE_ME) {
        _model.status = [NSNumber numberWithInt:CARE_ME];
        [self setStatus];
        
        NSString *status = [NSString stringWithFormat:@"%d", CARE_ME];
        
        NSInteger ret = [[FreeSingleton sharedInstance] sendIfConcern:_model.Id status:status block:^(NSUInteger retcode, id data) {
            _btn_followed.userInteractionEnabled = YES;
            if (retcode == RET_SERVER_SUCC) {
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPDATE_MYCARE object:_model];
            }
            else
            {
                NSLog(@"update status error is: %@", data);
            }
        }];
        
        if (ret != RET_OK) {
            _btn_followed.userInteractionEnabled = YES;
            NSLog(@"update status error is: %@", zcErrMsg(ret));
        }
    }
    else
    {
        __weak AddressListTableViewCell *weakSelf = self;
        [KVNProgress showWithStatus:@"Loading"];
        NSInteger retcode = [[FreeSingleton sharedInstance] addFriendOnCompletion:_model.friendId friendName:_model.user_name pinyin:_model.pinyin phoneNo:_model.phoneNo headImg:_model.img_url block:^(NSUInteger ret, id data) {
            _btn_followed.userInteractionEnabled = YES;
            [KVNProgress dismiss];
            if (ret == RET_SERVER_SUCC) {
                _model.status = data[@"status"];
                [weakSelf setStatus];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPDATE_MYCARE object:_model];
            }
            else
            {
                [KVNProgress showErrorWithStatus:data];
            }
            
        }];
        
        if (retcode != RET_OK) {
            _btn_followed.userInteractionEnabled = YES;
            [KVNProgress dismiss];
            [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

@end
