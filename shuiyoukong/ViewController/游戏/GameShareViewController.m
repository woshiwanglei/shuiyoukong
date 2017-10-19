//
//  GameShareViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/8.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "GameShareViewController.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocial.h"
#import "ShareInterfaceView.h"
#import "AppDelegate.h"

@interface GameShareViewController()<UMSocialUIDelegate>

@property (nonatomic, strong)ShareInterfaceView *shareview;
@property (nonatomic, assign)BOOL changeNameshare;

@property (nonatomic, strong)UIView *backgroudView;

@end

@implementation GameShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    _btn_playAgain.layer.cornerRadius = 5.f;
    _btn_share.layer.cornerRadius = 5.f;
    _btn_free.hidden = YES;
    _label_dishu.hidden = YES;
    
    if ([UIScreen mainScreen].bounds.size.height < 500) {
        _view_hegiht.constant = 360;
        _labeltoLabel1.constant = 15;
        _labelConstant1.constant = 5;
        _labelConstant2.constant = 5;
        _label_name.font = [UIFont systemFontOfSize:11];
        _label_name2.font = [UIFont systemFontOfSize:11];
        _label_name3.font = [UIFont systemFontOfSize:11];
    }
    else if ([UIScreen mainScreen].bounds.size.height < 600)
    {
        _view_hegiht.constant = 420;
        _labelConstant1.constant = 10;
        _labelConstant2.constant = 10;
        _top_to_top.constant = 15;
        _btn_to_bottom.constant = 53;
    }
    else if ([UIScreen mainScreen].bounds.size.height < 700)
    {
        _view_hegiht.constant = 480;
        _labelConstant1.constant = 15;
        _labelConstant2.constant = 15;
        _label_name.font = [UIFont systemFontOfSize:15];
        _label_name2.font = [UIFont systemFontOfSize:15];
        _label_name3.font = [UIFont systemFontOfSize:15];
        _top_to_top.constant = 35;
        _btn_to_bottom.constant = 63;
    }
    else
    {
        _view_hegiht.constant = 480;
        _labelConstant1.constant = 15;
        _labelConstant2.constant = 15;
        _label_name.font = [UIFont systemFontOfSize:15];
        _label_name2.font = [UIFont systemFontOfSize:15];
        _label_name3.font = [UIFont systemFontOfSize:15];
        _top_to_top.constant = 45;
        _btn_to_bottom.constant = 63;
    }
    
    [_btn_playAgain addTarget:self action:@selector(btn_Tapped_playAgain) forControlEvents:UIControlEventTouchDown];
    [_btn_share addTarget:self action:@selector(btn_Tapped_Share) forControlEvents:UIControlEventTouchDown];
}

- (void)initData
{
    if (_name1 != nil) {
        _label_name.text = [NSString stringWithFormat:@"%@,你是猪吗？我打你你不会躲啊!", _name1];
        
        if ([UIScreen mainScreen].bounds.size.height < 500)
        {
            [self fuwenbenLabel:_label_name FontNumber:[UIFont boldSystemFontOfSize:13] AndRange:NSMakeRange(0, [_name1 length])];
        }
        else
        {
            [self fuwenbenLabel:_label_name FontNumber:[UIFont boldSystemFontOfSize:15] AndRange:NSMakeRange(0, [_name1 length])];
        }
    }
    
    if (_name2 != nil) {
        _label_name2.text = [NSString stringWithFormat:@"%@,放学给我等着，看我不打死你!", _name2];
        if ([UIScreen mainScreen].bounds.size.height < 500)
        {
            [self fuwenbenLabel:_label_name2 FontNumber:[UIFont boldSystemFontOfSize:13] AndRange:NSMakeRange(0, [_name2 length])];
        }
        else
        {
            [self fuwenbenLabel:_label_name2 FontNumber:[UIFont boldSystemFontOfSize:15] AndRange:NSMakeRange(0, [_name2 length])];
        }
    }
    else
    {
        _label_name2.hidden = YES;
    }
    
    if (_name3 != nil) {
        _label_name3.text = [NSString stringWithFormat:@"%@,你有本事开门让我再打一次啊!", _name3];
        
        if ([UIScreen mainScreen].bounds.size.height < 500)
        {
            [self fuwenbenLabel:_label_name3 FontNumber:[UIFont boldSystemFontOfSize:13] AndRange:NSMakeRange(0, [_name3 length])];
        }
        else
        {
            [self fuwenbenLabel:_label_name3 FontNumber:[UIFont boldSystemFontOfSize:15] AndRange:NSMakeRange(0, [_name3 length])];
        }
    }
    else
    {
        _label_name3.hidden = YES;
    }
}

#pragma mark -功能函数
//设置不同字体颜色
-(void)fuwenbenLabel:(UILabel *)labell FontNumber:(id)font AndRange:(NSRange)range
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:labell.text];
    
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    
    labell.attributedText = str;
}

#pragma mark -分享UI操作

- (void)btn_Tapped_playAgain
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btn_Tapped_Share
{
    if (!_backgroudView) {
        _backgroudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UITapGestureRecognizer *tapView=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
        [_backgroudView addGestureRecognizer:tapView];
    }
    
    if (!_shareview) {
        _shareview = [[[NSBundle mainBundle] loadNibNamed:@"ShareInterfaceView"
                                                    owner:self
                                                  options:nil] objectAtIndex:0];
        _shareview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    [[AppDelegate getMainWindow] addSubview:_backgroudView];
    [_backgroudView addSubview:_shareview];
    NSDictionary *metrics = @{
                              @"widthe" : @0,
                              @"heightd" : @0
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(_shareview);
    [_backgroudView addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:[_shareview(190)]-0-|"
      options:0
      metrics:metrics
      views:views]];
    
    [_backgroudView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:
                                    @"H:|-widthe-[_shareview]-widthe-|"
                                    options:0
                                    metrics:metrics
                                    views:views]];
    [self fadeIn];
    [_shareview.QQButton addTarget:self action:@selector(QQshare) forControlEvents:UIControlEventTouchDown];//qq分享
    [_shareview.QQqone addTarget:self action:@selector(QoneShare) forControlEvents:UIControlEventTouchDown];//空间分享
    [_shareview.weixinButton addTarget:self action:@selector(weixinShare) forControlEvents:UIControlEventTouchDown];//微信分享
    [_shareview.FriendButton addTarget:self action:@selector(friendShare) forControlEvents:UIControlEventTouchDown];//朋友圈分享
    [_shareview.sinaButton addTarget:self action:@selector(SinaList) forControlEvents:UIControlEventTouchDown];//新浪分享
}

#pragma mark -分享

/**
 *  动画划出
 */
- (void)fadeIn
{
    _shareview.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _shareview.frame.size.width, _shareview.frame.size.height);
    
    [UIView animateWithDuration:.2 animations:^{
        _shareview.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height- _shareview.frame.size.height, _shareview.frame.size.width, _shareview.frame.size.height);
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
        _shareview.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _shareview.frame.size.width, _shareview.frame.size.height);
    } completion:^(BOOL finished) {
        [_shareview removeFromSuperview];
        [_backgroudView removeFromSuperview];
    }];
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
/**
 *  新浪分享
 */
-(void)SinaList
{
    [_shareview removeFromSuperview];
    
    self.navigationController.navigationBar.hidden = YES;
    self.btn_share.hidden = YES;
    self.btn_playAgain.hidden = YES;
    
    UIImage *pic = [self screenView:self.view];
    
    self.btn_share.hidden = NO;
    self.btn_playAgain.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    [[UMSocialControllerService defaultControllerService] setShareText:@"#谁有空##不约而同#来呀来呀～不服来战！我在爆裂地鼠等你！。http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free"shareImage:pic socialUIDelegate:self];
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
        alerView.delegate=self;
        _changeNameshare = NO;
        [alerView show];
    }
    else
    {
        UIAlertView *alerViews=[[UIAlertView alloc] initWithTitle:@"分享失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alerViews.delegate=self;
        _changeNameshare = NO;
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
    [UMSocialData defaultData].extConfig.qqData.title = UM_ZC_TITLE;//QQ分享title
    [UMSocialData defaultData].extConfig.qzoneData.title = UM_ZC_TITLE;//QQ空间title
    //微信好友title
    [UMSocialData defaultData].extConfig.wechatSessionData.title = UM_ZC_TITLE;
    //微信朋友圈title
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = UM_ZC_TITLE;
    
    [_shareview removeFromSuperview];
    [_backgroudView removeFromSuperview];
    
    self.navigationController.navigationBar.hidden = YES;
    _btn_share.hidden = YES;
    _btn_playAgain.hidden = YES;
    _btn_free.hidden = NO;
    _label_dishu.hidden = NO;
    
    //    UIImage *pic = [self shotScreen];
    UIImage *pic = [self screenView:self.view];
    
    self.navigationController.navigationBar.hidden = NO;
    _btn_free.hidden = YES;
    _label_dishu.hidden = YES;
    _btn_share.hidden = NO;
    _btn_playAgain.hidden = NO;
    
    //QQ分享
    [UMSocialQQHandler setQQWithAppId:@"1104634036" appKey:@"Qy4htxEyREjy5RQm" url:@"http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free"];
    //微信分享
    [UMSocialWechatHandler setWXAppId:@"wx978df91e43d81d2f" appSecret:@"eb69505c0114cf45c0079943609922ef" url:@"http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free"];
    
    //    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:
    //                                        @"http://www.baidu.com/img/bdlogo.gif"];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[shareName] content:@"并不是每个当下我们都会相遇，还好有空。快来谁有空开启不约而同的旅行吧" image:pic location:nil urlResource:nil
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

#pragma mark -测试截屏
- (UIImage*)screenView:(UIView *)view{
    
    CGSize imageSize = view.bounds.size;//你要的截图的位置
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 4.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
            CGContextSaveGState(context);
            
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            
            CGContextConcatCTM(context, [window transform]);
            
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            [[window layer] renderInContext:context];
            
            CGContextRestoreGState(context);
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


@end
