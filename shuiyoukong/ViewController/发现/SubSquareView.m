//
//  SubSquareView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SubSquareView.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PostViewController.h"

@implementation SubSquareView

- (void)awakeFromNib
{
    [super awakeFromNib];
//    self.layer.cornerRadius = 5.f;
//    self.layer.masksToBounds = YES;
    _base_view.layer.cornerRadius = 5.f;
    _base_view.layer.masksToBounds = YES;
//    _num.layer.cornerRadius = 5.f;
    _num.layer.masksToBounds = YES;
    _btn_up.layer.masksToBounds = YES;
}

- (void)setModel:(DiscoverModel *)model
{
    _model = model;
    if (model == nil) {
        self.hidden = YES;
        return;
    }
    
    self.hidden = NO;
    [self showBigImage];
    _content.text = model.content;
    _num.text = model.num;
    
    [_btn_up addTarget:self action:@selector(btn_up_Tapped:) forControlEvents:UIControlEventTouchDown];
    
    UITapGestureRecognizer* tapGes2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPostDetail:)];
    [self addGestureRecognizer:tapGes2];
    
    if (model.isUp)
    {
        [_btn_up setImage:[UIImage imageNamed:@"icon_heart"] forState:UIControlStateNormal];
    }
    else
    {
        [_btn_up setImage:[UIImage imageNamed:@"icon_heart_off"] forState:UIControlStateNormal];
    }
    
}

- (void)btn_up_Tapped:(UIButton *)btn
{
    if (_model.isUp) {
        [[FreeSingleton sharedInstance] cancelPostInfoOnCompletion:_model.postId block:^(NSUInteger ret, id data) {
            if (ret == RET_SERVER_SUCC) {
                _model.isUp = NO;
                NSInteger num = [_model.num integerValue];
                num--;
                _model.num = [NSString stringWithFormat:@"%ld", (long)num];
                _num.text = _model.num;
                [_btn_up setImage:[UIImage imageNamed:@"icon_heart_off"] forState:UIControlStateNormal];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPDATE_DIANZAN object:_model];
            }
        }];
    }
    else
    {
        [[FreeSingleton sharedInstance] upPostInfoOnCompletion:_model.postId type:@"0" block:^(NSUInteger ret, id data) {
            if (ret == RET_SERVER_SUCC) {
                _model.isUp = YES;
                NSInteger num = [_model.num integerValue];
                num++;
                _model.num = [NSString stringWithFormat:@"%ld", (long)num];
                _num.text = _model.num;
                [_btn_up setImage:[UIImage imageNamed:@"icon_heart"] forState:UIControlStateNormal];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPDATE_DIANZAN object:_model];
            }
        }];
    }
}

-(void)gotoPostDetail:(UITapGestureRecognizer *)tap
{
    [self setBackgroundColor:[UIColor lightGrayColor]];
    [self performSelector:@selector(delaySetColor) withObject:nil afterDelay:0.5f];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PostViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];
    viewController.model = _model;
    viewController.hidesBottomBarWhenPushed = YES;
    
    [_discover_vc.navigationController pushViewController:viewController animated:YES];
}

- (void)delaySetColor
{
    self.backgroundColor = [UIColor whiteColor];
}

//获取当前屏幕显示的viewcontroller
- (void)showBigImage
{
    //set tag
    [_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.big_Img sizeSuffix:SIZE_SUFFIX_600X600] placeholderImage:[UIImage imageNamed:@"tupian"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

@end
