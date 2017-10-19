//
//  SharePictureViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SharePictureViewController.h"
#import "AppDelegate.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocial.h"
#import "ShareInterfaceView.h"
#import "FreeSingleton.h"
#import "VPImageCropperViewController.h"


@interface SharePictureViewController()<UMSocialUIDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *label_content1;
@property (weak, nonatomic) IBOutlet UILabel *label_content2;
@property (weak, nonatomic) IBOutlet UILabel *label_month;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view_aspect;

//@property (weak, nonatomic) IBOutlet UILabel *label_day;

@property (nonatomic,strong) UIView *background;
@property (nonatomic, strong) ShareInterfaceView *shareview;

@property (nonatomic, assign)BOOL changeNameshare;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label1_to_top;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label2_to_top;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icon_to_btn;
@property (weak, nonatomic) IBOutlet UIImageView *backgroud_ImgView;

@end

@implementation SharePictureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:0.5];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1]];
    self.navigationController.navigationBar.alpha = 0.400;
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.alpha = 0.400;
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.alpha = 1;
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)initView
{
    //适配
    [self adjustIphone];
    
    //随机背景图片
//    [self randomBackGroundImage];
    
    //增加随机触摸换图片事件
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(randomBackGroundImage)];
    _backgroud_ImgView.userInteractionEnabled = YES;
    [_backgroud_ImgView addGestureRecognizer:tapGes];
    
//    NSArray * arrMonth = [NSArray arrayWithObjects:@"一月",@"二月",@"三月",@"四月",@"五月",@"六月",@"七月", @"八月", @"九月", @"十月", @"十一月", @"十二月", nil];
//    
//    NSArray * arrDay = [NSArray arrayWithObjects:@"一日",@"二日",@"三日",@"四日",@"五日",@"六日",@"七日", @"八日", @"九日", @"十日", @"十一日", @"十二日", @"十三日", @"十四日", @"十五日", @"十六日", @"十七日", @"十八日", @"十九日", @"二十日", @"二十一日", @"二十二日", @"二十三日", @"二十四日", @"二十五日", @"二十六日", @"二十七日", @"二十八日", @"二十九日", @"三十日", @"三十一日", nil];
    NSDate *date = [NSDate date];
    NSString *freeDate = [self changeDate2String:date];
    NSArray *array = [freeDate componentsSeparatedByString:@"-"];
//    [NSString stringWithFormat:@"%@%@", [arrMonth objectAtIndex:[array[1] integerValue] - 1],[arrDay objectAtIndex:[array[2] integerValue] - 1]];
//    _label_month.text = [NSString stringWithFormat:@"%@", [arrMonth objectAtIndex:[array[1] integerValue] - 1]];
//    _label_day.text = [NSString stringWithFormat:@"%@", [arrDay objectAtIndex:[array[2] integerValue] - 1]];
    
    
    if ([array count] < 3) {
        return;
    }
    
    _label_month.text = [NSString stringWithFormat:@"来自 %@ %@.%@", [[FreeSingleton sharedInstance] getNickName],array[1],array[2]];
//    _label_month.text = [NSString stringWithFormat:@"%@", [arrMonth objectAtIndex:[array[1] integerValue] - 1]];
//    _label_day.text = [NSString stringWithFormat:@"%@", [arrDay objectAtIndex:[array[2] integerValue] - 1]];
    
    if ([_content length] > 10) {
        _label_content1.text = [_content substringToIndex:10];
        _label_content2.text = [_content substringFromIndex:10];
    }
    else
    {
        _label_content1.text = _content;
        _label_content2.text = nil;
    }
    
//    [_btn_share addTarget:self action:@selector(btn_Tappedshare:) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *btnitem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(btn_Tappedshare:)];
//    [btnitem setImage:[UIImage imageNamed:@"icon_share"]];
    btnitem.tintColor = [UIColor whiteColor];
    [btnitem setTitleTextAttributes:[NSDictionary
                                     dictionaryWithObjectsAndKeys:[UIFont
                                                                   boldSystemFontOfSize:18], NSFontAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = btnitem;
    
}

- (void)adjustIphone
{
    if ([UIScreen mainScreen].bounds.size.height < 500) {
//        _label1_to_top.constant = 20.f;
//        _label2_to_top.constant = 20.f;
//        _icon_to_btn.constant = 10.f;
//        _label_content1.font = [UIFont fontWithName:@"yuweij" size:15];
//        _label_content2.font = [UIFont fontWithName:@"yuweij" size:15];
//        _label_month.font = [UIFont fontWithName:@"yuweij" size:15];
        _view_aspect.constant = 50.f;
    }
}

- (void)btn_Tappedshare:(id)sender
{
    if ([_background superview]) {
        return;
    }
    
    _changeNameshare = NO;
    
    _background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _background.backgroundColor=[UIColor colorWithRed:190/255.0 green:190/255.0  blue:190/255.0  alpha:.3];
    [[AppDelegate getMainWindow] addSubview:_background];
    
    UITapGestureRecognizer *tapView =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
    [_background addGestureRecognizer:tapView];
    _shareview = [[[NSBundle mainBundle] loadNibNamed:@"ShareInterfaceView"
                                                owner:self
                                              options:nil] objectAtIndex:0];
    _shareview.translatesAutoresizingMaskIntoConstraints = NO;
    [_background addSubview:_shareview];
    NSDictionary *metrics = @{
                              @"widthe" : @0,
                              @"heightd" : @0
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(_shareview);
    [_background addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:[_shareview(190)]-0-|"
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
    [_shareview.QQButton addTarget:self action:@selector(QQshare) forControlEvents:UIControlEventTouchDown];//qq分享
    [_shareview.QQqone addTarget:self action:@selector(QoneShare) forControlEvents:UIControlEventTouchDown];//空间分享
    [_shareview.weixinButton addTarget:self action:@selector(weixinShare) forControlEvents:UIControlEventTouchDown];//微信分享
    [_shareview.FriendButton addTarget:self action:@selector(friendShare) forControlEvents:UIControlEventTouchDown];//朋友圈分享
    [_shareview.sinaButton addTarget:self action:@selector(SinaList) forControlEvents:UIControlEventTouchDown];//新浪分享
}

//- (void)btn_Tappedcancel:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

#pragma mark -分享
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
        [_background removeFromSuperview];
        [_shareview removeFromSuperview];
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
    [_background removeFromSuperview];
    
    UIImage *pic = [self screenView:self.view];
    
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    [[UMSocialControllerService defaultControllerService] setShareText:@"并不是每个当下我们都会相遇，还好有空。快来谁有空开启不约而同的旅行吧。http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free"shareImage:pic socialUIDelegate:self];
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
    [_background removeFromSuperview];
    
    
    UIImage *pic = [self screenView:self.view];
    
    
    //QQ分享
    [UMSocialQQHandler setQQWithAppId:@"1104634036" appKey:@"Qy4htxEyREjy5RQm" url:@"http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free"];
    //微信分享
    [UMSocialWechatHandler setWXAppId:@"wx978df91e43d81d2f" appSecret:@"eb69505c0114cf45c0079943609922ef" url:@"http://a.app.qq.com/o/simple.jsp?pkgname=com.mobile.zhichun.free"];
    
    //    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:
    //                                        @"http://www.baidu.com/img/bdlogo.gif"];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[shareName] content:UM_SHARE_PIC image:pic location:nil urlResource:nil
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
    
    self.navigationController.navigationBar.hidden = YES;
    
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
    
    self.navigationController.navigationBar.hidden = NO;
    
    return image;
}

#pragma mark -随机背景图片
- (void)randomBackGroundImage
{
//    int value = arc4random()%11;//生成0到10的随机数
//    NSString *pic_name = [NSString stringWithFormat:@"share_pic%d", value];
//    _backgroud_ImgView.image = [UIImage imageNamed:pic_name];
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];

}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //设置tabbar消失时不能删除通知
    //    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZC_NOTIFICATION_NEED_DELETE_NOTIFICATION];
    if (buttonIndex == 0) {
        // 拍照
        if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([self isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
        
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([self isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 NSLog(@"Picker View Controller is presented");
                             }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
        
        }];
}

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    //    UIImage *scaleImage = [self scaleImage:editedImage toScale:0.5];
    [cropperViewController dismissViewControllerAnimated:NO completion:^{
        _backgroud_ImgView.image = editedImage;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // bug fixes: UIIMagePickerController使用中偷换StatusBar颜色的问题
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}


#pragma mark camera utility

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}


#pragma mark -辅助功能

- (NSString *)changeDate2String:(NSDate *)date
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date_str = [dateformatter stringFromDate:date];
    return date_str;
}

@end
