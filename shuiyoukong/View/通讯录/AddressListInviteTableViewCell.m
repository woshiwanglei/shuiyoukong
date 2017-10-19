//
//  AddressListInviteTableViewCell.m
//  Free
//
//  Created by 勇拓 李 on 15/5/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "AddressListInviteTableViewCell.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "FreeTabBarViewController.h"

#import "FreeSQLite.h"
@implementation AddressListInviteTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _btn_invite.layer.cornerRadius = 5.f;
    _btn_invite.layer.masksToBounds = YES;
    _img_head.layer.cornerRadius = 3.f;
    _img_head.layer.masksToBounds = YES;
    [FontSizemodle setfontSizeLableSize:_label_name];
    //    [FontSizemodle setfontSizeLableSize:_yaoLable];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setModel:(AddressListInviteCellModel *)model
{
    _model = model;
    
    _label_name.text = _model.user_name;
    
    _phoneNB = _model.phoneNo;
    
    //设置头像
    [self showImage:_img_head img_url:_model.img_url];
    
    [_btn_invite addTarget:self action:@selector(inviteUser) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)showImage:(UIImageView *)avatar img_url:(NSString *)img_url
{
    //set tag
    [avatar sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:img_url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

- (void)inviteUser
{
    _background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _background.backgroundColor=[UIColor colorWithRed:190/255.0 green:190/255.0  blue:190/255.0  alpha:.3];
    //加入点击手势remove分享界面
    UITapGestureRecognizer *tapView=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
    [_background addGestureRecognizer:tapView];
    _shareview = [[[NSBundle mainBundle] loadNibNamed:@"InviteUIview"
                                                owner:self
                                              options:nil] objectAtIndex:0];
    _shareview.translatesAutoresizingMaskIntoConstraints = NO;
    [[AppDelegate getMainWindow] addSubview:_background];
    [_background addSubview:_shareview];
    NSDictionary *metrics = @{
                              @"widthe" : @0,
                              @"heightd" : @0
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(_shareview);
    [_background addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:[_shareview(100)]-0-|"
      options:0
      metrics:metrics
      views:views]];
    
    [_background addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:
                                 @"H:|-widthe-[_shareview]-widthe-|"
                                 options:0
                                 metrics:metrics
                                 views:views]];
    [self fadeIn];
    
    [_shareview.QQbtn addTarget:self action:@selector(QQshare) forControlEvents:UIControlEventTouchDown];//qq分享
    [_shareview.WXbtn addTarget:self action:@selector(weixinShare) forControlEvents:UIControlEventTouchDown];//微信分享
      _shareview.phonenumber = _phoneNB;
    _shareview.backgroudView = _background;
    _shareview.btn = _btn_invite;
    _shareview.inviteController = (inviteFriendsViewController *)[self viewController];
   // [_shareview.Phonebtn addTarget:self action:@selector(PhonebtnList) forControlEvents:UIControlEventTouchDown];//短信分享
    
}


- (UIViewController *)viewController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

/**
 *  动画划出
 */
- (void)fadeIn
{
    _shareview.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _shareview.frame.size.width, _shareview.frame.size.height);
    
    [UIView animateWithDuration:.1 animations:^{
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
        [_background removeFromSuperview];
    }];
    
    
}

/**
 *  qq分享
 */
-(void)QQshare
{
    [self allSharePort:UMShareToQQ];
}
/**
 *  空间分享
 */
-(void)QoneShare
{
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
    
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    [[UMSocialControllerService defaultControllerService] setShareText:[NSString stringWithFormat:@"%@%@",UM_SHARE_DESCRIBE, UM_SHARE_URL] shareImage:[UIImage imageNamed:@"glass"] socialUIDelegate:self];
    
    UIViewController  *wakSelf  =  (FreeTabBarViewController *)self.window.rootViewController;
    
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(wakSelf,[UMSocialControllerService defaultControllerService],YES);
    
}

//-(void)PhonebtnList
//{
//    MFMessageComposeViewController *message;
//    
//    if ([MFMessageComposeViewController canSendText]) {
//        message = [[MFMessageComposeViewController alloc] init];
//        message.messageComposeDelegate = self;
//        message.recipients = @[_phoneNB];
//        [message setBody:[NSString stringWithFormat:@"%@%@",UM_SHARE_DESCRIBE, UM_SHARE_URL]];
//        UIViewController  *wakSelf  =  (FreeTabBarViewController *)self.window.rootViewController;
//        [wakSelf presentViewController:message animated:YES completion:nil ];
//    }
//    else
//    {
//        NSLog(@"设别不支持");
//    }
//
//}
//
//
//- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
//{
//    
//    if(result==MessageComposeResultSent)
//    {
//        NSLog(@"发短信成功");
//    }
//    else if(result==MessageComposeResultCancelled)
//    {
//        NSLog(@"发短信取消");
//    }
//    else if(result==MessageComposeResultFailed)
//    {
//        NSLog(@"发短信失败");
//    }
//    [controller dismissViewControllerAnimated:YES completion:nil];
//}

- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
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
     
        [alerView show];
    }
    else
    {
        UIAlertView *alerViews=[[UIAlertView alloc] initWithTitle:@"分享失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alerViews.delegate=self;

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
//    [_shareview removeFromSuperview];
    //QQ分享
    [UMSocialQQHandler setQQWithAppId:@"1104634036" appKey:@"Qy4htxEyREjy5RQm" url:UM_SHARE_URL];
    //微信分享
    [UMSocialWechatHandler setWXAppId:@"wx978df91e43d81d2f" appSecret:@"eb69505c0114cf45c0079943609922ef" url:UM_SHARE_URL];
    
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[shareName] content:UM_SHARE_DESCRIBE image:[UIImage imageNamed:@"glass"] location:nil urlResource:nil
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
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"确定"])
    {
        [_shareview removeFromSuperview];
        [_background removeFromSuperview];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end