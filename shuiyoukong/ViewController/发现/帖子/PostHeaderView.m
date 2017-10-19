//
//  PostHeaderView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/21.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "PostHeaderView.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FreeMapViewController.h"
#import "KCView.h"
#import "AllUserWantoTableViewController.h"
#import "UserInfoViewController.h"
#import "FreeImageView.h"

@interface PostHeaderView()<UIScrollViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>
@property UIPageControl *pageControl;
//@property (nonatomic,strong) UIScrollView *scrollviewed;
//@property (nonatomic, strong) UIImageView *holder;

@property (nonatomic, strong)NSMutableArray *viewArray;
@property (nonatomic, strong)NSMutableArray *boolArray;//该数组判断是否是第一次点击图片,1代表第一次，2代表不是第一次
@end

@implementation PostHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    _head_img.layer.cornerRadius = 3.f;
    _head_img.layer.masksToBounds = YES;
    [_btn_delete_Mypost addTarget:self action:@selector(deleteMyPost:) forControlEvents:UIControlEventTouchDown];
}

- (void)setModel:(DiscoverModel *)model
{
    _model = model;
    
    _viewArray = [NSMutableArray array];
    for (int i = 0; i < [model.img_array count]; i++)
    {
        NSMutableArray *array = [NSMutableArray array];
        [_viewArray addObject:array];
    }
    //如果不是我的帖子，隐藏
    if (![model.accountId isEqual:[[FreeSingleton sharedInstance] getAccountId]]) {
        _btn_delete_Mypost.hidden = YES;
    }
    _label_name.text = model.name;
    _label_num_bottom.text = model.num;
    _label_position.text = model.address;
//    _label_tags.text = model.editor_comment;
    [self setTagArray:model.editor_comment];
    
    _text_content.text = model.content;
    [self showHeadImage:_head_img url:_model.head_Img];
    [self initPics];
    _btn_location.userInteractionEnabled = NO;
    UITapGestureRecognizer *tapLocation = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btn_location_Tapped:)];
    [_view_position addGestureRecognizer:tapLocation];
//    [_btn_location addTarget:self action:@selector(btn_location_Tapped:) forControlEvents:UIControlEventTouchDown];
    UITapGestureRecognizer *tapAccoutList = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btn_accountList_Tapped:)];
    [_view_imgs addGestureRecognizer:tapAccoutList];
}

- (void)setTagArray:(NSString *)tagStr
{
    NSArray *array = [tagStr componentsSeparatedByString:@" "];
    float width = 0;
    int row = 0;
    for (int i = 0; i < [array count]; i++) {
        
        if (![array[i] length]) {
            continue;
        }
        
        UILabel *label = [[UILabel alloc] init];
        [label setFont:[UIFont systemFontOfSize:14.f]];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = FREE_179_GRAY_COLOR;
        label.layer.cornerRadius = 3.f;
        label.layer.masksToBounds = YES;
        label.textAlignment = NSTextAlignmentCenter;
        
        label.text = array[i];
        
        CGSize s_label = [label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 38 , FLT_MAX)];
        
        if (width + 10 + s_label.width > [UIScreen mainScreen].bounds.size.width - 38) {
            row ++;
            label.frame = CGRectMake(0, row * 24, s_label.width + 10, 20);
            width = s_label.width + 10 + 5;
        }
        else
        {
            label.frame = CGRectMake(width + 0, row * 24, s_label.width + 10, 20);
            width += (s_label.width + 10 + 5);
        }
        
        [_view_tags addSubview:label];
    }
    _view_tags_height.constant = (row + 1) * 24;
    _tagsView_height = (row + 1)* 24;
}

- (void)setImgArray:(NSMutableArray *)imgArray
{
    _imgArray = imgArray;
    [self initHeadImgs:imgArray];
}

- (void)setAccountList:(NSMutableArray *)accountList
{
    _accountList = [NSMutableArray array];
    for (int i = 0; i < [accountList count]; i++) {
        id data = accountList[i];
        SelectFriendsModel *model = [[SelectFriendsModel alloc] init];
        model.name = data[@"nickName"];
        model.accountId = [NSString stringWithFormat:@"%@", data[@"id"]];
        model.img_url = data[@"headImg"];
        model.fromInfo = 0;
        [_accountList addObject:model];
    }
}

- (void)initHeadImgs:(NSMutableArray *)imgArray
{
    NSArray *array = _view_imgs.subviews;
    for (id object in array) {
        if ([object isKindOfClass:[UIImageView class]]) {
            UIImageView *imgView = (UIImageView *)object;
            [imgView removeFromSuperview];
        }
    }
    
    for (int i = 0; i < [imgArray count]; i++) {
        FreeImageView *imageView = [[FreeImageView alloc] init];
        imageView.layer.cornerRadius = 3.f;
        imageView.layer.masksToBounds = YES;
        if ([UIScreen mainScreen].bounds.size.height < 600)
        {
            if (i > 4) {
                return;
            }
            imageView.frame = CGRectMake(10 + 45*(i%5), 5, 35, 35);
        }
        else if([UIScreen mainScreen].bounds.size.height < 700)
        {
            if (i > 5) {
                return;
            }
            imageView.frame = CGRectMake(10 + 45*(i%6), 5, 35, 35);
        }
        else
        {
            if (i > 6) {
                return;
            }
            imageView.frame = CGRectMake(10 + 45*(i%7), 5, 35, 35);
        }
        [self showHeadImage:imageView url:imgArray[i]];
        SelectFriendsModel *model = _accountList[i];
        imageView.accountId = model.accountId;
        imageView.name = model.name;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapHeadImg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btn_HeadImg_Tapped:)];
        [imageView addGestureRecognizer:tapHeadImg];
        
        [_view_imgs addSubview:imageView];
    }
}

- (void)initPics
{
    if ([_model.img_array count]) {
        
        _boolArray = [NSMutableArray array];
        
        for (int i = 0; i < [_model.img_array count]; i++) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, ([UIScreen mainScreen].bounds.size.width - 10) * i, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20)];
            
            //不超出图片
            imgView.clipsToBounds = YES;
            
            imgView.tag = i;
            imgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageTap:)];
            [imgView addGestureRecognizer:tapImage];
            NSString *imageStr = _model.img_array[i];
            [self showBigImage:imgView url:imageStr];
            [self addKCView:imgView url:imageStr];
            [_boolArray addObject:@"1"];
            [_big_img_view addSubview:imgView];
            
        }
        
        _big_img_height.constant = ([UIScreen mainScreen].bounds.size.width - 10) * [_model.img_array count];
    }
}

#pragma mark -警告
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self removeMyPost];
    }
}

//删除帖子
- (void)deleteMyPost:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要删除你的推荐吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)removeMyPost
{
    [KVNProgress showWithStatus:@"Loading"];
    
    [[FreeSingleton sharedInstance] deleteMyPost:_model.postId block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress showSuccessWithStatus:@"删除成功"];
            });
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_RELOAD_MYPOST object:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_vc.navigationController popViewControllerAnimated:YES];
            });
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"删除失败"];
        }
    }];
}

- (void)btn_location_Tapped:(UITapGestureRecognizer *)gesture
{
    FreeMapViewController *vc = [[FreeMapViewController alloc] initWithNibName:@"FreeMapViewController" bundle:nil];
    CLLocationCoordinate2D location;
    location.latitude = _model.latitude;
    location.longitude = _model.longitude;
    
    vc.location = location;
    vc.locationName = _model.address;
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:vc];
    
    [_vc presentViewController:nav animated:YES completion:nil];
}

- (void)btn_HeadImg_Tapped:(UITapGestureRecognizer *)gesture
{
    FreeImageView *imageView = (FreeImageView *)gesture.view;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    
    vc.friend_id = imageView.accountId;

    vc.friend_name = imageView.name;

    vc.hidesBottomBarWhenPushed = YES;
    
    [_vc.navigationController pushViewController:vc animated:YES];
}

- (void)btn_accountList_Tapped:(UITapGestureRecognizer *)gesture
{
    if (![_accountList count]) {
        return;
    }
    
    AllUserWantoTableViewController *vc = [[AllUserWantoTableViewController alloc] initWithNibName:@"AllUserWantoTableViewController" bundle:nil];
    
    vc.accountList = _accountList;
    vc.hidesBottomBarWhenPushed = YES;
    [_vc.navigationController pushViewController:vc animated:YES];
}

- (void)addKCView:(UIImageView *)imgView url:(NSString *)url
{
    for (int i = 0; i < [_model.imgTagsArray count]; i++) {
        PicTagsModel *model = _model.imgTagsArray[i];
        if ([url isEqualToString:model.imgUrl]) {
            NSMutableArray *imgViewArray = [NSMutableArray array];
            for (int j = 0; j < [model.imgTagList count]; j++) {
                addTagsModel *tagsModel = model.imgTagList[j];
                KCView *view = [[[NSBundle mainBundle] loadNibNamed:@"KCView"
                                                              owner:self
                                                            options:nil] objectAtIndex:0];
                view.cannottBeMove = YES;
                view.model = tagsModel;
                view.bounds = (CGRect){CGPointZero, CGSizeMake(20, 20)};
                view.center = tagsModel.point;
                [imgViewArray addObject:view];
                [imgView addSubview:view];
                [self performSelector:@selector(delayHidden:) withObject:imgView afterDelay:3.0f];
            }
            
            [_viewArray replaceObjectAtIndex:imgView.tag withObject:imgViewArray];
        }
    }
}

- (void)delayHidden:(UIImageView *)imageView
{
    NSMutableArray *array = _viewArray[imageView.tag];
    
    if ([_boolArray[imageView.tag] isEqualToString:@"2"]) {
        return;
    }
    
    if([array count])
    {
        for (KCView *view in array) {
            [view removeFromSuperview];
        }
        
        [array removeAllObjects];
        [_viewArray replaceObjectAtIndex:imageView.tag withObject:array];
    }
}


- (void)showHeadImage:(UIImageView *)imgView url:(NSString *)url
{
    //[FreeSingleton handleImageUrlWithSuffix:_model.head_Img sizeSuffix:SIZE_SUFFIX_100X100]
    //set tag
    [imgView sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

- (void)showBigImage:(UIImageView *)imgView url:(NSString *)url
{
    //set tag
    //[NSURL URLWithString:imageUrl]
    [imgView sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:url sizeSuffix:SIZE_SUFFIX_600X600] placeholderImage:[UIImage imageNamed:@"tupian"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

#pragma mark - 显示大图
//显示大图
- (void)ImageTap:(UITapGestureRecognizer *)gesture {
    
//    CGPoint touchPoint = [gesture locationInView:self.view];
//    if()
    if(![_viewArray count])
        return;
    
    UIImageView *imageView = (UIImageView *)gesture.view;
    
    if([_boolArray[imageView.tag] isEqualToString:@"1"])
    {
//        NSMutableArray *array = _viewArray[imageView.tag];
//        for (KCView *view in array) {
//            view.not_needToHidden = YES;
//            view.userInteractionEnabled = YES;
//        }
        [_boolArray replaceObjectAtIndex:imageView.tag withObject:@"2"];
//        return;
    }
    
//    CGPoint touchPoint = [gesture locationInView:imageView];
    NSMutableArray *array = _viewArray[imageView.tag];
    if([array count])
    {
        for (KCView *view in array) {
            [view removeFromSuperview];
        }
        
        [array removeAllObjects];
        [_viewArray replaceObjectAtIndex:imageView.tag withObject:array];
    }
    else
    {
        for (int i = 0; i < [_model.imgTagsArray count]; i++) {
            PicTagsModel *model = _model.imgTagsArray[i];
            NSString *imageStr = _model.img_array[imageView.tag];
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
                    [array addObject:view];
                    [imageView addSubview:view];
                }
            }
        }
    }
    
    
    
//    UIImageView *imgView = (UIImageView *)gesture.view;
//    _vc.navigationController.interactivePopGestureRecognizer.enabled = NO;//防止看大图时手势滑动引起的bug
//    _scrollviewed = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _vc.navigationController.view.frame.size.height)];
//
//    self.scrollviewed.backgroundColor = [UIColor blackColor];
//    [_vc.navigationController.view addSubview:self.scrollviewed];
//    self.scrollviewed.userInteractionEnabled = YES;
//    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapped:)];
//    _scrollviewed.tag = imgView.tag;
//    [self.scrollviewed addGestureRecognizer:tapGes];
//
//    NSString* url = _model.img_array[imgView.tag];
//    
//    NSInteger height = 300;
//    NSInteger width = 300;
//    //直接附图片  holder是图片的大小
//    if (width > self.scrollviewed.frame.size.width) {
//        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width-width)/2, (self.scrollviewed.frame.size.height - height)/2, self.scrollviewed.bounds.size.width,height*(self.scrollviewed.bounds.size.width/width))];
//        self.scrollviewed.contentSize=CGSizeMake(self.scrollviewed.bounds.size.width,height*(self.scrollviewed.bounds.size.width/width));
//    }
//    else if(height > self.scrollviewed.bounds.size.height)
//    {
//        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width - width)/2, (self.scrollviewed.frame.size.height - height)/2, width*(self.scrollviewed.bounds.size.height/height),height)];
//        self.scrollviewed.contentSize=CGSizeMake(width*(self.scrollviewed.bounds.size.height/height),height);
//    }
//    else
//    {
//        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width - width)/2, (self.scrollviewed.frame.size.height - height)/2, width, height)];
//        
//        self.scrollviewed.contentSize = CGSizeMake(width, height);
//    }
//    
//    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.scrollviewed animated:YES];
//    [self.holder sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
//     {
//         if (iamgeUrl == nil) {
//             [_holder setImage:[UIImage imageNamed:@"tupian"]];
//         }
//         [Utils hideHUD:hud];
//     }];
//    
//    // 等比例缩放
//    self.holder.center = _vc.view.center;
//    float scalex= _vc.view.frame.size.width/self.holder.frame.size.width;
//    float scaley= _vc.view.frame.size.height/self.holder.frame.size.height;
//    //最小的范围
//    float scale = MIN(scalex, scaley);
//    self.holder.transform=CGAffineTransformMakeScale(scale, scale);
//    self.holder.contentMode = UIViewContentModeScaleAspectFit;
//    self.scrollviewed.delegate=self;
//    self.scrollviewed.maximumZoomScale=3.0;
//    self.scrollviewed.minimumZoomScale=1.0;
//    [self.scrollviewed addSubview:self.holder];
//    
//    //实例化长按手势监听
//    UILongPressGestureRecognizer *longPress =
//    [[UILongPressGestureRecognizer alloc] initWithTarget:self
//                                                  action:@selector(handleImgLongPressed:)];
//    //代理
//    longPress.delegate = self;
//    longPress.minimumPressDuration = 1.0;
//    //将长按手势添加到需要实现长按操作的视图里
//    [self.scrollviewed addGestureRecognizer:longPress];
}

//- (void) bgTapped:(UITapGestureRecognizer *)gesture{
//    UIView *view = gesture.view;
//    _vc.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    [view removeFromSuperview];
//}
//
//-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return self.holder;
//}
////缩小时图片居中显示
//- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
//{
//    CGFloat offsetX = (self.scrollviewed.bounds.size.width > self.scrollviewed.contentSize.width)?
//    (self.scrollviewed.bounds.size.width - self.scrollviewed.contentSize.width) * 0.5 : 0.0;
//    CGFloat offsetY = (self.scrollviewed.bounds.size.height > self.scrollviewed.contentSize.height)?
//    (self.scrollviewed.bounds.size.height - self.scrollviewed.contentSize.height) * 0.5 : 0.0;
//    self.holder.center = CGPointMake(self.scrollviewed.contentSize.width * 0.5 + offsetX,
//                                     self.scrollviewed.contentSize.height * 0.5 + offsetY);
//}

//长按事件
//- (void)handleImgLongPressed:(UILongPressGestureRecognizer *)gesture
//{
//    UIScrollView *scroll_View = (UIScrollView *)gesture.view;
//    if (_model.img_array[scroll_View.tag] && gesture.state == UIGestureRecognizerStateBegan) {
//        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机相册", nil];
//        sheet.tag = scroll_View.tag;
//        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
//        [sheet showInView:[UIApplication sharedApplication].keyWindow];
//    }
//}

// 功能：保存图片到手机
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (actionSheet.numberOfButtons - 1 == buttonIndex) {
//        return;
//    }
//    NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
//    if ([title isEqualToString:@"保存到手机相册"]) {
//        
//        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_model.img_array[actionSheet.tag]]];
//        UIImage* image = [UIImage imageWithData:data];
//        
//        //UIImageWriteToSavedPhotosAlbum(image, nil, nil,nil);
//        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//    }
//}
//
//// 功能：显示对话框
//-(void)showAlert:(NSString *)msg {
//    UIAlertView *alert = [[UIAlertView alloc]
//                          initWithTitle:@""
//                          message:msg
//                          delegate:self
//                          cancelButtonTitle:@"确定"
//                          otherButtonTitles: nil];
//    [alert show];
//}
//
//// 功能：显示图片保存结果
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
//{
//    if (error){
//        [self showAlert:@"保存失败..."];
//    }else {
//        [self showAlert:@"图片保存成功！"];
//    }
//}


@end
