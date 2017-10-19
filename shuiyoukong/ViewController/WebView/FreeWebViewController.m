//
//  FreeWebViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FreeWebViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "settings.h"
#import "ShareWebView.h"
#import "AppDelegate.h"


@interface FreeWebViewController ()<UIWebViewDelegate, NJKWebViewProgressDelegate,UMSocialUIDelegate>
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    UIButton *btn_cancel;
}
@property (weak, nonatomic) IBOutlet UIWebView *web_view;
@property (nonatomic,strong) ShareWebView *sharejoinView;
@property (nonatomic,strong) UIView *backgroundview;

@end

@implementation FreeWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [btn_cancel removeFromSuperview];
    [_progressView removeFromSuperview];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)initView
{
    [self comeFromPush];//如果是推送过来
    
    //自定义主题头部
    if (!_img) {
        _img = [UIImage imageNamed:@"class"];
    }
    
    btn_cancel = [[UIButton alloc] initWithFrame:CGRectMake(40, 4, 60, 35)];
    [btn_cancel setTitle:@"关闭" forState:UIControlStateNormal];
    [btn_cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn_cancel.titleLabel.font = [UIFont systemFontOfSize:17.f];
    [self.navigationController.navigationBar addSubview:btn_cancel];
    [btn_cancel addTarget:self action:@selector(btn_cancel) forControlEvents:UIControlEventTouchUpInside];
    btn_cancel.hidden = YES;
    
    _progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    _web_view.delegate = _progressProxy;
    
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"style:UIBarButtonItemStylePlain target:self action:@selector(btn_back)];
    
    UIButton* _btn_more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_btn_more addTarget:self action:@selector(rightItemShare:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_more setImage:[UIImage imageNamed:@"icon_more_normal"] forState:UIControlStateNormal];
    [_btn_more setImage:[UIImage imageNamed:@"icon_more_highlight"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:_btn_more];
    self.navigationItem.rightBarButtonItem = backItem;
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"●●●"style:UIBarButtonItemStylePlain target:self action:@selector(rightItemShare:)];
    
    NSString *title = _url_title;
    if ([title length] > 5) {
        title = [title substringToIndex:5];
        title = [NSString stringWithFormat:@"%@...", title];
    }
    
    self.navigationItem.title = title;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
    [_web_view loadRequest:request];
    
}

- (void)comeFromPush
{
    if (!_img && _imgUrl) {
        NSURL *url = [FreeSingleton handleImageUrlWithSuffix:_imgUrl sizeSuffix:SIZE_SUFFIX_100X100];
        dispatch_queue_t queue = dispatch_queue_create("loadImage",NULL);
        dispatch_async(queue, ^{
            NSData *resultData = [NSData dataWithContentsOfURL:url];
            if (resultData) {
                _img = [UIImage imageWithData:resultData];
            }
            else
            {
                _img = [UIImage imageNamed:@"glass"];
            }
        });
    }
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    
    if (webView.canGoBack) {
        btn_cancel.hidden = NO;
    }
    else
    {
        btn_cancel.hidden = YES;
    }
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (void)btn_back
{
    if (_fromTag == COME_FROM_PUSH) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if (_web_view.canGoBack)
    {
        [_web_view goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)btn_cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}


/**
 *  实现分享界面
 *
 *  @param buttonItem buttonItem description
 */
-(void)rightItemShare:(UIBarButtonItem *)buttonItem
{
    if (!_backgroundview) {
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
        [_sharejoinView.btn_refresh addTarget:self action:@selector(surpassWebView) forControlEvents:UIControlEventTouchDown];//刷新
        [_sharejoinView.CopyButton addTarget:self action:@selector(copyShare) forControlEvents:UIControlEventTouchDown];//复制链接
        [_sharejoinView.SurpassButton addTarget:self action:@selector(btn_report_Tapped) forControlEvents:UIControlEventTouchDown];//刷新
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
      constraintsWithVisualFormat:@"V:[_sharejoinView(190)]-0-|"
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
    
    NSString *SinaTitle = _url_title;
//    NSString *SinaTail = @"http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free";
    NSString *SinaContent = [NSString stringWithFormat:@"%@%@", SinaTitle, _url];
    [[UMSocialControllerService defaultControllerService] setShareText:SinaContent shareImage:_img socialUIDelegate:self];
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
    [UMSocialData defaultData].extConfig.qqData.title = _url_title;//QQ分享title
    [UMSocialData defaultData].extConfig.qzoneData.title = _url_title;//QQ空间title
    //微信好友title
    [UMSocialData defaultData].extConfig.wechatSessionData.title = _url_title;
    //微信朋友圈title
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = _url_title;
    
    //QQ分享
    [UMSocialQQHandler setQQWithAppId:@"1104634036" appKey:@"Qy4htxEyREjy5RQm" url:_url];
    //微信分享
    [UMSocialWechatHandler setWXAppId:@"wx978df91e43d81d2f" appSecret:@"eb69505c0114cf45c0079943609922ef" url:_url];
    
    //    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:
    //                                        @"http://www.baidu.com/img/bdlogo.gif"];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[shareName] content:_content image:_img location:nil urlResource:nil
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
 *  刷新界面
 *
 *  @return
 */
-(void)surpassWebView
{
    [_backgroundview removeFromSuperview];
    [_sharejoinView removeFromSuperview];
    [_web_view reload];
}

/**
 *  复制链接
 *
 *  @return
 */
-(void)copyShare
{
//    [_backgroundview removeFromSuperview];
//    [_sharejoinView removeFromSuperview];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:_url];
    UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"复制成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    alerView.delegate = self;
    [alerView show];
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
