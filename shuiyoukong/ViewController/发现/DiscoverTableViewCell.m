//
//  DiscoverTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/15.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "DiscoverTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "KCView.h"

@implementation DiscoverTableViewCell

- (void)awakeFromNib {
    _base_view.layer.cornerRadius = 5.f;
    _base_view.layer.masksToBounds = YES;
    _head_Img.layer.cornerRadius = 3.f;
    _head_Img.layer.masksToBounds = YES;
    //不超出图片
    _big_Img.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setModel:(DiscoverModel *)model
{
    _model = model;
    [self showHeadImage];
    [self showBigImage];
    
    if ([_view_array count])
    {
        for (KCView *view in _view_array) {
            [view removeFromSuperview];
        }
        [_view_array removeAllObjects];
    }
    
//    UITapGestureRecognizer *tapLocation = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageTap:)];
//    [_big_Img addGestureRecognizer:tapLocation];
//    _big_Img.userInteractionEnabled = YES;
    
    _label_content.text = model.content;
    _label_name.text = model.name;
    _label_editor_comment.text = model.editor_comment;
    _num.text = model.num;
    [_btn_up addTarget:self action:@selector(btn_up_Tapped:) forControlEvents:UIControlEventTouchDown];
    
    if (model.isUp)
    {
//        _btn_up.userInteractionEnabled = NO;
        [_btn_up setImage:[UIImage imageNamed:@"icon_heart"] forState:UIControlStateNormal];
    }
    else
    {
//        _btn_up.userInteractionEnabled = YES;
        [_btn_up setImage:[UIImage imageNamed:@"icon_heart_off"] forState:UIControlStateNormal];
    }
    
    [self setKCView];
}

- (void)setKCView
{
    _view_array = [NSMutableArray array];
    for (int i = 0; i < [_model.imgTagsArray count]; i++) {
        PicTagsModel *model = _model.imgTagsArray[i];
        if ([_model.big_Img isEqualToString:model.imgUrl]) {
            for (int j = 0; j < [model.imgTagList count]; j++) {
                addTagsModel *tagsModel = model.imgTagList[j];
                KCView *view = [[[NSBundle mainBundle] loadNibNamed:@"KCView"
                                                              owner:self
                                                            options:nil] objectAtIndex:0];
                view.cannottBeMove = YES;
                view.model = tagsModel;
                [_view_array addObject:view];
                [_big_Img addSubview:view];
                view.bounds = (CGRect){CGPointZero, CGSizeMake(20, 20)};
                view.center = tagsModel.point;
                NSLog(@"big frame is %@", NSStringFromCGRect(_big_Img.frame));
                NSLog(@"center is %@", NSStringFromCGPoint(tagsModel.point));
                NSLog(@"view center is %@", NSStringFromCGRect(view.frame));
                
                [self performSelector:@selector(delayHidden) withObject:nil afterDelay:3.0f];
            }
        }
    }
}

- (void)delayHidden
{
    
    if (_isNeedToShow) {
        return;
    }
    
    if([_view_array count])
    {
        for (KCView *view in _view_array) {
            [view removeFromSuperview];
        }
        
        [_view_array removeAllObjects];
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
            }
        }];
    }
}

#pragma mark - 图片触摸
- (void)ImageTap:(UITapGestureRecognizer *)gesture {
    
    //    CGPoint touchPoint = [gesture locationInView:self.view];
    //    if()
//    if(![_view_array count])
//        return;
    
    if(!_isNeedToShow)
    {
        _isNeedToShow = YES;
    }
    
    //    CGPoint touchPoint = [gesture locationInView:imageView];
    if([_view_array count])
    {
        for (KCView *view in _view_array) {
            [view removeFromSuperview];
        }
        
        [_view_array removeAllObjects];
    }
    else
    {
        for (int i = 0; i < [_model.imgTagsArray count]; i++) {
            PicTagsModel *model = _model.imgTagsArray[i];
            NSString *imageStr = _model.big_Img;
            if ([imageStr isEqualToString:model.imgUrl]) {
                for (int j = 0; j < [model.imgTagList count]; j++) {
                    addTagsModel *tagsModel = model.imgTagList[j];
                    KCView *view = [[[NSBundle mainBundle] loadNibNamed:@"KCView"
                                                                  owner:self
                                                                options:nil] objectAtIndex:0];
                    view.cannottBeMove = YES;
                    view.model = tagsModel;
                    view.bounds = (CGRect){CGPointZero, CGSizeMake(20, 20)};
                    view.center = tagsModel.point;
                    [_view_array addObject:view];
                    [_big_Img addSubview:view];
                }
            }
        }
    }
}

- (void)showHeadImage
{
    //[FreeSingleton handleImageUrlWithSuffix:_model.head_Img sizeSuffix:SIZE_SUFFIX_100X100]
    //set tag
    [_head_Img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.head_Img sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

- (void)showBigImage
{
    //set tag
//    [_big_Img setContentMode:UIViewContentModeScaleAspectFill];
//    _big_Img.clipsToBounds  = YES;
    [_big_Img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.big_Img sizeSuffix:SIZE_SUFFIX_600X600] placeholderImage:[UIImage imageNamed:@"tupian"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

@end
