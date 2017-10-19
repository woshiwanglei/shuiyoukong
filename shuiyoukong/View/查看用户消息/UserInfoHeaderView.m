//
//  UserInfoHeaderView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "UserInfoHeaderView.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface UserInfoHeaderView()<UIScrollViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>
@property (nonatomic,strong) UIScrollView *scrollviewed;
@property (nonatomic, strong) UIImageView *holder;

@end

@implementation UserInfoHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reNameFriendName:) name:ZC_NOTIFICATION_UPDATE_FRIENDNAME object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:ZC_NOTIFICATION_UPDATE_FRIENDNAME];
}

- (void)reNameFriendName:(NSNotification *) notification
{
    _model.nickName = notification.object;
    _label_name.text = _model.nickName;
}

- (void)setModel:(Account *)model
{
    _model = model;
    
    _label_name.text = model.nickName;
    [self showImage];
    
    _head_img.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageTap:)];
    [_head_img addGestureRecognizer:tapImage];
    
    if ([model.gender isEqualToString:@"male"]) {
        [_btn_gender setImage:[UIImage imageNamed:@"male"] forState:UIControlStateNormal];
    }
    else
    {
        [_btn_gender setImage:[UIImage imageNamed:@"female"] forState:UIControlStateNormal];
    }
    
    
    _label_city.text = _model.city;
    
    NSString *lv = _model.lv;
    if ([lv length]) {
        int lvNum = [[lv substringWithRange:NSMakeRange(2,1)] intValue];
        switch (lvNum) {
            case 0:
                break;
            default:
            {
                NSString *imgLv = [NSString stringWithFormat:@"icon_Lv%d", lvNum];
                [_btn_lv setImage:[UIImage imageNamed:imgLv] forState:UIControlStateNormal];
            }
                break;
        }
    }
    else
    {
        lv = @"Lv1盖碗茶";
        [_btn_lv setImage:[UIImage imageNamed:@"icon_Lv1"] forState:UIControlStateNormal];
    }
    
    _label_lv.text = lv;
    
    if (_model.followed_num) {
        _label_followed_num.text = _model.followed_num;
    }
    else
    {
        _label_followed_num.text = @"0";
    }
    
    if (_model.follower_num) {
        _label_follower_num.text = _model.follower_num;
    }
    else
    {
        _label_follower_num.text = @"0";
    }
}

- (void)showImage
{
    [_head_img sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:_model.headImg sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         
     }];
}

#pragma mark - 显示大图
//显示大图
- (void)ImageTap:(UITapGestureRecognizer *)gesture {
    
    UIImageView *imgView = (UIImageView *)gesture.view;
    _vc.navigationController.interactivePopGestureRecognizer.enabled = NO;//防止看大图时手势滑动引起的bug
    _scrollviewed = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _vc.navigationController.view.frame.size.height)];
    
    self.scrollviewed.backgroundColor = [UIColor blackColor];
    [_vc.navigationController.view addSubview:self.scrollviewed];
    self.scrollviewed.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapped:)];
    _scrollviewed.tag = imgView.tag;
    [self.scrollviewed addGestureRecognizer:tapGes];
    
    NSString* url = _model.headImg;
    
    NSInteger height = 300;
    NSInteger width = 300;
    //直接附图片  holder是图片的大小
    if (width > self.scrollviewed.frame.size.width) {
        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width-width)/2, (self.scrollviewed.frame.size.height - height)/2, self.scrollviewed.bounds.size.width,height*(self.scrollviewed.bounds.size.width/width))];
        self.scrollviewed.contentSize=CGSizeMake(self.scrollviewed.bounds.size.width,height*(self.scrollviewed.bounds.size.width/width));
    }
    else if(height > self.scrollviewed.bounds.size.height)
    {
        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width - width)/2, (self.scrollviewed.frame.size.height - height)/2, width*(self.scrollviewed.bounds.size.height/height),height)];
        self.scrollviewed.contentSize=CGSizeMake(width*(self.scrollviewed.bounds.size.height/height),height);
    }
    else
    {
        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width - width)/2, (self.scrollviewed.frame.size.height - height)/2, width, height)];
        
        self.scrollviewed.contentSize = CGSizeMake(width, height);
    }
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.scrollviewed animated:YES];
    [self.holder sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         if (iamgeUrl == nil) {
             [_holder setImage:[UIImage imageNamed:@"touxiang"]];
         }
         [Utils hideHUD:hud];
     }];
    
    // 等比例缩放
    self.holder.center = _vc.view.center;
    float scalex= _vc.view.frame.size.width/self.holder.frame.size.width;
    float scaley= _vc.view.frame.size.height/self.holder.frame.size.height;
    //最小的范围
    float scale = MIN(scalex, scaley);
    self.holder.transform=CGAffineTransformMakeScale(scale, scale);
    self.holder.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollviewed.delegate=self;
    self.scrollviewed.maximumZoomScale=3.0;
    self.scrollviewed.minimumZoomScale=1.0;
    [self.scrollviewed addSubview:self.holder];
    
    //实例化长按手势监听
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleImgLongPressed:)];
    //代理
    longPress.delegate = self;
    longPress.minimumPressDuration = 1.0;
    //将长按手势添加到需要实现长按操作的视图里
    [self.scrollviewed addGestureRecognizer:longPress];
}

- (void) bgTapped:(UITapGestureRecognizer *)gesture{
    UIView *view = gesture.view;
    _vc.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [view removeFromSuperview];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.holder;
}
//缩小时图片居中显示
- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
    CGFloat offsetX = (self.scrollviewed.bounds.size.width > self.scrollviewed.contentSize.width)?
    (self.scrollviewed.bounds.size.width - self.scrollviewed.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.scrollviewed.bounds.size.height > self.scrollviewed.contentSize.height)?
    (self.scrollviewed.bounds.size.height - self.scrollviewed.contentSize.height) * 0.5 : 0.0;
    self.holder.center = CGPointMake(self.scrollviewed.contentSize.width * 0.5 + offsetX,
                                     self.scrollviewed.contentSize.height * 0.5 + offsetY);
}

//长按事件
- (void)handleImgLongPressed:(UILongPressGestureRecognizer *)gesture
{
    UIScrollView *scroll_View = (UIScrollView *)gesture.view;
    if (_model.headImg && gesture.state == UIGestureRecognizerStateBegan) {
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机相册", nil];
        sheet.tag = scroll_View.tag;
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

// 功能：保存图片到手机
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.numberOfButtons - 1 == buttonIndex) {
        return;
    }
    NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"保存到手机相册"]) {
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_model.headImg]];
        UIImage* image = [UIImage imageWithData:data];
        
        //UIImageWriteToSavedPhotosAlbum(image, nil, nil,nil);
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

// 功能：显示对话框
-(void)showAlert:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@""
                          message:msg
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles: nil];
    [alert show];
}

// 功能：显示图片保存结果
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error){
        [self showAlert:@"保存失败..."];
    }else {
        [self showAlert:@"图片保存成功！"];
    }
}

@end
