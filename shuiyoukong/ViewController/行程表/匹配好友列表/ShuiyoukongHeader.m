//
//  ShuiyoukongHeader.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/7.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ShuiyoukongHeader.h"
#import "FreeSingleton.h"
#import "UpdateRemarkViewController.h"
#import "FreeMap.h"

@implementation ShuiyoukongHeader

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self registerHeadImgChanged];
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
    
    _btn_free.layer.cornerRadius = 3.f;
    _btn_free.layer.masksToBounds = YES;
    
    [self showImage];
    _label_name.text = [[FreeSingleton sharedInstance] getNickName];
    
    [_btn_free addTarget:self action:@selector(setFreeStatus) forControlEvents:UIControlEventTouchDown];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guideNotice:) name:FREE_NOTIFICATION_GUIDE_1 object:nil];
    
    UITapGestureRecognizer *tapLocation = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateRemark:)];
    [self addGestureRecognizer:tapLocation];
}

- (void) guideNotice:(NSNotification*) notification {
    [self setFreeStatus];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerHeadImgChanged
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(img_changed:) name:ZC_NOTIFICATION_DID_IMG_CHANGED object:nil];
}

- (void)img_changed:(NSNotification *) notification
{
    [self showImage];
    _label_name.text = [[FreeSingleton sharedInstance] getNickName];
}


- (void)setContent:(NSString *)content
{
    if (content == nil) {
        _label_content.text = @"你想玩点什么呢?";
    }
    else
    {
        _label_content.text = content;
    }
}

- (void)setIsFree:(BOOL)isFree
{
    _isFree = isFree;
    if (isFree) {
//        _btn_free.titleLabel.text = @"有空";
//        [_btn_free setTitle:@"有空" forState:UIControlStateNormal];
//        [_btn_free setBackgroundColor:FREE_BACKGOURND_COLOR];
        [_btn_free setImage:[UIImage imageNamed:@"btn_youkong"] forState:UIControlStateNormal];
    }
    else
    {
//        _btn_free.titleLabel.text = @"忙碌";
//        [_btn_free setTitle:@"忙碌" forState:UIControlStateNormal];
//        [_btn_free setBackgroundColor:FREE_LIGHT_GRAY_COLOR];
        [_btn_free setImage:[UIImage imageNamed:@"btn_meikong"] forState:UIControlStateNormal];
    }
}

- (void)showImage
{
    //set tag
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:[[FreeSingleton sharedInstance] getHeadImage] sizeSuffix:SIZE_SUFFIX_300X300] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

- (void)updateRemark:(UITapGestureRecognizer *)tap
{
    UpdateRemarkViewController *vc = [[UpdateRemarkViewController alloc] initWithNibName:@"UpdateRemarkViewController" bundle:nil];
    vc.remark = _content;
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:vc];
    [_vc presentViewController:nav animated:YES completion:nil];
}


//发送空闲时间
- (void)setFreeStatus
{
    _btn_free.userInteractionEnabled = NO;
    NSDate *date = [NSDate date];
    NSString *freeDate = [[FreeSingleton sharedInstance] changeDate2StringDD:date];
    
    UIActivityIndicatorView *testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    testActivityIndicator.center = _btn_free.center;//只能设置中心，不能设置大小
    [self addSubview:testActivityIndicator];
    testActivityIndicator.color = FREE_BACKGOURND_COLOR; // 改变圈圈的颜色为红色； iOS5引入
    [testActivityIndicator startAnimating]; // 开始旋转
    
    if (!_isFree) {
//        [KVNProgress showWithStatus:@"Loading" onView:self.window];
        
        [FreeMap getPosition:_vc block:^(NSUInteger ret_position, id data) {
            NSString *positionStr = nil;
            if(data)
            {
                NSArray *arrayPosition = [data componentsSeparatedByString:@"-"];
                if([arrayPosition count] > 1)
                {
                    positionStr = [NSString stringWithFormat:@"%@-%@", arrayPosition[1], arrayPosition[0]];
                }
            }
            
            NSInteger ret = [[FreeSingleton sharedInstance] addCalendarOnCompletion:freeDate freeTimeStart:nil City:[[FreeSingleton sharedInstance] getCity] remark:_content position:positionStr block:^(NSUInteger retcode, id Data) {
                [testActivityIndicator stopAnimating]; // 结束旋转
                [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
                if (retcode == RET_SERVER_SUCC) {
                    [_btn_free setImage:[UIImage imageNamed:@"btn_youkong"] forState:UIControlStateNormal];
                    _isFree = YES;
                    NSString *freeTag = [NSString stringWithFormat:@"%d", _isFree];
                    [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_UPDATE_FREE_STATUS object:freeTag];
                }
                _btn_free.userInteractionEnabled = YES;
            }];
            
            if (ret != RET_OK)
            {
//                [KVNProgress dismiss];
                [testActivityIndicator stopAnimating]; // 结束旋转
                [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
                _btn_free.userInteractionEnabled = YES;
                NSLog(@"sendFreeDate error is :%@", zcErrMsg(ret));
            }
        }];
    }
    else
    {
//        [KVNProgress showWithStatus:@"Loading" onView:self.window];
        NSInteger ret = [[FreeSingleton sharedInstance] cancelCalendarOnCompletion:freeDate freeTimeStart:nil block:^(NSUInteger retcode, id data) {
            _btn_free.userInteractionEnabled = YES;
            [testActivityIndicator stopAnimating]; // 结束旋转
            [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
            if (retcode == RET_SERVER_SUCC) {
                [_btn_free setImage:[UIImage imageNamed:@"btn_meikong"] forState:UIControlStateNormal];
                _isFree = NO;
                NSString *freeTag = [NSString stringWithFormat:@"%d", _isFree];
                [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_UPDATE_FREE_STATUS object:freeTag];
            }
            else
            {
                NSLog(@"sendFreeDate error is :%@", data);
            }
        }];
        
        if (ret != RET_OK)
        {
            [testActivityIndicator stopAnimating]; // 结束旋转
            [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
            _btn_free.userInteractionEnabled = YES;
            NSLog(@"sendFreeDate error is :%@", zcErrMsg(ret));
        }
    }
    
}

@end
