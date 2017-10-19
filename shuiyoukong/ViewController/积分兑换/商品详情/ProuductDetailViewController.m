//
//  ProuductDetailViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ProuductDetailViewController.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ShareWebView.h"
#import "AppDelegate.h"

@interface ProuductDetailViewController ()<UIScrollViewDelegate, UMSocialUIDelegate>
@property (nonatomic,strong) ShareWebView *sharejoinView;
@property (nonatomic,strong) UIView *backgroundview;

@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation ProuductDetailViewController

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
    _label_name.text = _model.model.itemName;
    _label_code.text = _model.barcode;
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    self.navigationItem.title = _model.model.itemName;
    
    UIButton* _btn_more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_btn_more addTarget:self action:@selector(rightItemShare:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_more setImage:[UIImage imageNamed:@"icon_more_normal"] forState:UIControlStateNormal];
    [_btn_more setImage:[UIImage imageNamed:@"icon_more_highlight"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:_btn_more];
    self.navigationItem.rightBarButtonItem = backItem;
    
    [self initHeaderView];
    [self initViewHeight];
}

- (void)initHeaderView
{
    _scroll_img_view.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 1, 0);
    _scroll_img_view.delegate = self;
    _scroll_img_view.pagingEnabled = YES;
    _scroll_img_view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _scroll_img_view.layer.borderWidth = 0.5f;
    
    //[_model.model.imgArray count]
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 0, 0, [UIScreen mainScreen].bounds.size.width, (float)(([UIScreen mainScreen].bounds.size.width *2)/3))];
    
//    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSString *imageStr = nil;
    if ([_model.model.imgArray count] > 1) {
        imageStr = _model.model.imgArray[1];
    }
    else
    {
        imageStr = _model.model.imgArray[0];
    }
//    NSString *imageStr = _model.model.imgArray[i];
    [self showBigImage:_imageView url:imageStr];
    [_scroll_img_view addSubview:_imageView];

}

- (void)initViewHeight
{
    _text_content.text = _model.model.Description;
    CGSize s = [_text_content sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 8 , FLT_MAX)];
    _view_height.constant = 114 + s.height + (float)(([UIScreen mainScreen].bounds.size.width *2)/3);
    _textView_height.constant = s.height;
}

- (void)showBigImage:(UIImageView *)imgView url:(NSString *)url
{
    //set tag
    //    [_big_Img setContentMode:UIViewContentModeScaleAspectFill];
    //    _big_Img.clipsToBounds  = YES;
    [imgView sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:url sizeSuffix:SIZE_SUFFIX_600X600] placeholderImage:[UIImage imageNamed:@"tupian"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat y = scrollView.contentOffset.y + 64;
//    if (y < (-2/3 * SCREEN_WIDTH)) {
//
//    }
//}

#pragma mark - 分享
/**
 *  实现分享界面
 *
 *  @param buttonItem buttonItem description
 */
-(void)rightItemShare:(UIBarButtonItem *)buttonItem
{
    if(!_backgroundview)
    {
        _backgroundview = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backgroundview.backgroundColor = [UIColor colorWithRed:190/255.0 green:190/255.0  blue:190/255.0  alpha:.3];
        //分享页面remove
        UITapGestureRecognizer *tapRemove = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
        [_backgroundview addGestureRecognizer:tapRemove];
    }
    
    if (!_sharejoinView) {
        _sharejoinView=[[[NSBundle mainBundle] loadNibNamed:@"ShareWebView" owner:self options:nil]objectAtIndex:0 ];
        
        _sharejoinView.translatesAutoresizingMaskIntoConstraints = NO;
        [_sharejoinView.QButton addTarget:self action:@selector(QQshare) forControlEvents:UIControlEventTouchDown];//qq分享
        [_sharejoinView.QoButton addTarget:self action:@selector(QoneShare) forControlEvents:UIControlEventTouchDown];//空间分享
        [_sharejoinView.WXbutton addTarget:self action:@selector(weixinShare) forControlEvents:UIControlEventTouchDown];//微信分享
        [_sharejoinView.WXFbutton addTarget:self action:@selector(friendShare) forControlEvents:UIControlEventTouchDown];//朋友圈分享
        [_sharejoinView.SinButton addTarget:self action:@selector(SinaList) forControlEvents:UIControlEventTouchDown];//新浪分享
        _sharejoinView.report_view.hidden = YES;
        _sharejoinView.view_refresh.hidden = YES;
        _sharejoinView.view_copy.hidden = YES;
        _sharejoinView.label_bottom_title.hidden = YES;
    }
    
    [[AppDelegate getMainWindow] addSubview:_backgroundview];
    
    [_backgroundview addSubview:_sharejoinView];
    
    
    NSDictionary *metrics = @{
                              @"widthe" : @0,
                              @"heightd" : @0
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(_sharejoinView);
    [_backgroundview addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:[_sharejoinView(140)]-0-|"
      options:0
      metrics:metrics
      views:views]];
    
    [_backgroundview addConstraints:[NSLayoutConstraint
                                     constraintsWithVisualFormat:
                                     @"H:|-widthe-[_sharejoinView]-widthe-|"
                                     options:0
                                     metrics:metrics
                                     views:views]];
    [self fadeIn];
}
/**
 *  qq分享
 */
-(void)QQshare
{
    if (![QQApiInterface isQQInstalled]) {
        [Utils warningUser:self msg:@"请先安装手机QQ"];
        return;
    }
    [self allSharePort:UMShareToQQ];
}
/**
 *  空间分享
 */
-(void)QoneShare
{
    if (![QQApiInterface isQQInstalled]) {
        [Utils warningUser:self msg:@"请先安装手机QQ"];
        return;
    }
    [self allSharePort:UMShareToQzone];
}
/**
 *  微信分享
 */
-(void)weixinShare
{
    [self allSharePort:UMShareToWechatSession];
}
/**
 *  朋友圈分享
 */
-(void)friendShare
{
    [self allSharePort:UMShareToWechatTimeline];
}

-(void)btn_report_Tapped
{
    [_backgroundview removeFromSuperview];
    [_sharejoinView removeFromSuperview];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"IdeaFeedbackViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  新浪分享
 */
-(void)SinaList
{
    [_backgroundview removeFromSuperview];
    [_sharejoinView removeFromSuperview];
    
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    NSString *SinaTitle = [NSString stringWithFormat:@"我已兑换%@一张，你还在等什么？快去玩什么频道火热开抢！", _model.model.itemName];
    //    NSString *SinaTail = @"http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free";
    NSString *SinaContent = [NSString stringWithFormat:@"%@%@", SinaTitle, @"http://mp.weixin.qq.com/s?__biz=MzA3Nzg3OTk4MQ==&mid=209254560&idx=1&sn=0573782a5fc98202a5c1ec28323994e5#rd"];
    [[UMSocialControllerService defaultControllerService] setShareText:SinaContent shareImage:[UIImage imageNamed:@"icon_hongbao"] socialUIDelegate:self];
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
    
}
//实现回调方法（可选）：
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alerView.delegate = self;
        [alerView show];
    }
    else
    {
        UIAlertView *alerViews=[[UIAlertView alloc] initWithTitle:@"分享失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alerViews.delegate = self;
        [alerViews show];
    }
    
}
/**
 *  总体分享接口事件
 *
 *  @return
 */
-(void)allSharePort:(NSString *)shareName
{
    NSString *content = [NSString stringWithFormat:@"我已兑换%@一张，你还在等什么？快去玩什么频道火热开抢！", _model.model.itemName];
    
    [UMSocialData defaultData].extConfig.qqData.title = content;//QQ分享title
    [UMSocialData defaultData].extConfig.qzoneData.title = content;//QQ空间title
    //微信好友title
    [UMSocialData defaultData].extConfig.wechatSessionData.title = content;
    //微信朋友圈title
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = content;
    
    //QQ分享
    [UMSocialQQHandler setQQWithAppId:@"1104634036" appKey:@"Qy4htxEyREjy5RQm" url:@"http://mp.weixin.qq.com/s?__biz=MzA3Nzg3OTk4MQ==&mid=209254560&idx=1&sn=0573782a5fc98202a5c1ec28323994e5#rd"];
    //微信分享
    [UMSocialWechatHandler setWXAppId:@"wx978df91e43d81d2f" appSecret:@"eb69505c0114cf45c0079943609922ef" url:@"http://mp.weixin.qq.com/s?__biz=MzA3Nzg3OTk4MQ==&mid=209254560&idx=1&sn=0573782a5fc98202a5c1ec28323994e5#rd"];
    
    //    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:
    //                                        @"http://www.baidu.com/img/bdlogo.gif"];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[shareName] content:@"想要呼朋唤友？我用谁有空，不约而同发现身边的吃喝玩乐" image:[UIImage imageNamed:@"icon_hongbao"] location:nil urlResource:nil
                                            presentedController:nil completion:^(UMSocialResponseEntity *response){
                                                if (response.responseCode == UMSResponseCodeSuccess)
                                                {
                                                    UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                                    alerView.delegate = self;
                                                    [alerView show];
                                                }
                                                else
                                                {
                                                    UIAlertView *alerViews=[[UIAlertView alloc] initWithTitle:@"分享失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                                    alerViews.delegate=self;
                                                    [alerViews show];
                                                }
                                            }];
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [_backgroundview removeFromSuperview];
        [_sharejoinView removeFromSuperview];
    }
}

/**
 *  动画划出
 */
- (void)fadeIn
{
    _sharejoinView.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _sharejoinView.frame.size.width, _sharejoinView.frame.size.height);
    
    [UIView animateWithDuration:.1 animations:^{
        _sharejoinView.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height- _sharejoinView.frame.size.height, _sharejoinView.frame.size.width, _sharejoinView.frame.size.height);
    }];
}
/**
 *  动画关闭
 *
 *  @param gureView
 */
-(void)tapChange:(UITapGestureRecognizer *)gureView
{
    
    [UIView animateWithDuration:.2 animations:^{
        _sharejoinView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _sharejoinView.frame.size.width, _sharejoinView.frame.size.height);
    } completion:^(BOOL finished) {
        [_sharejoinView removeFromSuperview];
        [_backgroundview removeFromSuperview];
    }];
    
    
}

@end
