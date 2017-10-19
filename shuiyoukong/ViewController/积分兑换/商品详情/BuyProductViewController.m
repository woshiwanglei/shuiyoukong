//
//  BuyProductViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "BuyProductViewController.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ShareWebView.h"
#import "AppDelegate.h"

@interface BuyProductViewController ()<UIScrollViewDelegate>
@property UIPageControl *pageControl;
//@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation BuyProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initView
- (void)initView
{
    _label_name.text = _model.itemName;
    _label_point.text = [NSString stringWithFormat:@"%@积分", _model.needPoints];
    [_btn_buy addTarget:self action:@selector(buyProduct:) forControlEvents:UIControlEventTouchUpInside];
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    _btn_buy.layer.cornerRadius = 5.f;
    _btn_buy.layer.masksToBounds = YES;
    
    [self initHeaderView];
    [self initViewHeight];
}

- (void)initHeaderView
{
//    _scroll_img_view.contentSize = CGSizeMake(self.view.frame.size.width * 1, 0);
//    _scroll_img_view.delegate = self;
//    _scroll_img_view.pagingEnabled = YES;
//    _scroll_img_view.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    _scroll_img_view.layer.borderWidth = 0.5f;
    
    self.navigationItem.title = _model.itemName;
    
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    
    //[_model.imgArray count]
//    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 0, 0, [UIScreen mainScreen].bounds.size.width, (float)(([UIScreen mainScreen].bounds.size.width *2)/3))];
    NSString *imageStr = nil;
    if ([_model.imgArray count] > 1) {
        imageStr = _model.imgArray[1];
    }
    else
    {
        imageStr = _model.imgArray[0];
    }
    //    NSString *imageStr = _model.model.imgArray[i];
    [self showBigImage:_imageView url:imageStr];
//    [_scroll_img_view addSubview:_imageView];
    
//    if ([_model.imgArray count] > 1) {
//        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 60, (float)((self.view.frame.size.width *2)/3) - 60, self.view.frame.size.width, 40)];
//        [_pageControl setCurrentPage:0];
//        _pageControl.numberOfPages = [_model.imgArray count];//指定页面个数
//        [_pageControl setBackgroundColor:[UIColor clearColor]];
//        
//        [self.view addSubview:_pageControl];
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat y = scrollView.contentOffset.y;
    NSLog(@"%f", y);
    NSLog(@"%f", _img_aspect.constant);
    if (y < 0) {
        _imgView_top.constant = y;
        _img_aspect.constant = -(50.f) * ( - y)/64;
    }
}

- (void)initViewHeight
{
    _text_view.text = _model.Description;
    CGSize s = [_text_view sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 8 , FLT_MAX)];
    _view_height.constant = 142 + s.height + (float)(([UIScreen mainScreen].bounds.size.width *2)/3);
    _text_height.constant = s.height;
}


- (void)buyProduct:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"兑换商品" message:@"确认要兑换该商品吗?" delegate:self cancelButtonTitle:@"兑换" otherButtonTitles:@"取消", nil];

    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0)
    {
        [KVNProgress showWithStatus:@"Loading" onView:self.view];
        __weak BuyProductViewController *weakSelf = self;
        [[FreeSingleton sharedInstance] buyProductsOnCompletion:_model.itemId block:^(NSUInteger ret, id data) {
            [KVNProgress dismiss];
            if (ret == RET_SERVER_SUCC) {
                [Utils warningUserAfterJump:weakSelf msg:@"购买成功!" time:1.0];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_REFRESH_POINT object:nil];//触发刷新通知
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                [Utils warningUser:weakSelf msg:data];
            }
        }];
    }
}


- (void)showBigImage:(UIImageView *)imgView url:(NSString *)url
{
    [imgView sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:url sizeSuffix:SIZE_SUFFIX_600X600] placeholderImage:[UIImage imageNamed:@"tupian"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

@end
