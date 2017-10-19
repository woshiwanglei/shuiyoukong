//
//  CreateActivityViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "CreateActivityViewController.h"
#import "FreeSingleton.h"
#import "EditTitleViewController.h"
#import "ActionSheetDatePicker.h"
#import "SendPositionViewController.h"
#import "EditShareViewController.h"
#import "VPImageCropperViewController.h"
#import "FreeImageScale.h"
#import "SelectFriendsModel.h"
#import "ActivityInviteFriendsTableViewController.h"
#import "ActiveFriendsView.h"
#import "ActivityModel.h"
#import "ActivityInfoViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define DELETE_IMG_FLAG 123

#define VIEW_BASE_HEIGHT 480

@interface CreateActivityViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIView *fristView;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UIView *thirdView;
@property (weak, nonatomic) IBOutlet UIView *forthView;
@property (weak, nonatomic) IBOutlet UIImageView *img_add_pic;
@property (weak, nonatomic) IBOutlet UIView *view_friends;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view_height;
@property (weak, nonatomic) IBOutlet UIView *bottom_view;
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet UILabel *label_position;
@property (weak, nonatomic) IBOutlet UILabel *label_time;
@property (weak, nonatomic) IBOutlet UITextView *text_view_content;
@property (weak, nonatomic) IBOutlet UIButton *btn_invite;

@property (strong, nonatomic)NSString *freeDate;
@property (strong, nonatomic)NSString *activity_time;
@property (strong, nonatomic)NSMutableArray *modelArray;

@property (strong, nonatomic)ActivityModel *activity_model;
@end

@implementation CreateActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![_activity_title length]) {
        _label_title.text = @"请填写活动标题";
        _label_title.textColor = FREE_179_GRAY_COLOR;
    }
    else
    {
        _label_title.text = _activity_title;
        _label_title.textColor = FREE_BLACK_COLOR;
    }
    
    if (_positionModel) {
        _label_position.text = _positionModel.position_name;
        _label_position.textColor = FREE_BLACK_COLOR;
        //        [_label_position setFont:[UIFont systemFontOfSize:14]];
    }
    
    if ([_activity_content length]) {
        _text_view_content.text = _activity_content;
        _text_view_content.textColor = FREE_BLACK_COLOR;
        [_text_view_content setFont:[UIFont systemFontOfSize:15.f]];
    }
    else
    {
        _text_view_content.text = @"填写活动详情";
        _text_view_content.textColor = FREE_179_GRAY_COLOR;
        [_text_view_content setFont:[UIFont systemFontOfSize:15.f]];
    }
    
    if (_friendsArray) {
        [self setFriendsListLayout];
    }
    
    if (_cover_img_url) {
        [self showImage];
        _cover_img_url = nil;
    }
}

- (void)showImage
{
    [_img_add_pic sd_setImageWithURL:[NSURL URLWithString:_cover_img_url] placeholderImage:[UIImage imageNamed:@"tupian"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
}

#pragma mark - initData
- (void)initData
{
    [KVNProgress showWithStatus:@"Loading"];
    __weak CreateActivityViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] getMyFansListOnCompletion:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            if ([data count]) {
                [weakSelf add2Model:data];
            }
        }
    }];
}

- (void)add2Model:(id)dataSource
{
    _modelArray = [NSMutableArray array];
    
    for (int i = 0; i < [dataSource count]; i++) {
        SelectFriendsModel *model = [[SelectFriendsModel alloc] init];
        model.img_url = dataSource[i][@"headImg"];
        model.name = dataSource[i][@"friendName"];
        model.accountId = [NSString stringWithFormat:@"%@", dataSource[i][@"friendAccountId"]];
        model.status = [dataSource[i][@"status"] integerValue];
        model.isSelected = NO;
        
        if (![dataSource[i][@"pinyin"] isKindOfClass:[NSNull class]]) {
            model.pinyin = dataSource[i][@"pinyin"];
        }
        else
        {
            NSString *pinyin = [model.name mutableCopy];
            CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformMandarinLatin,NO);
            //再转换为不带声调的拼音
            CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformStripDiacritics,NO);
            model.pinyin = pinyin;
        }
        
        [_modelArray addObject:model];
    }
}

#pragma mark - initView
- (void)initView
{
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    UIBarButtonItem *backIteme = [[UIBarButtonItem alloc]init];
    backIteme.title = @" ";
    self.navigationItem.backBarButtonItem= backIteme;
    
    self.navigationItem.title = @"发起活动";
    
    //初始化右边上角
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"发起" style:UIBarButtonItemStylePlain target:self action:@selector(upLoadImg)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //初始化标题view
    [self initFristView];
    [self initSecondView];
    [self initThridView];
    [self initForthView];
    [self initFivthView];
    [self initBottomView];
}

//标题
- (void)initFristView
{
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setActivityTitle:)];
    [_fristView addGestureRecognizer:tapGes];
    _fristView.userInteractionEnabled = YES;
}

//时间
- (void)initSecondView
{
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setActivityTime:)];
    [_secondView addGestureRecognizer:tapGes];
    _secondView.userInteractionEnabled = YES;
}

//地点
- (void)initThridView
{
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setActivityPostion:)];
    [_thirdView addGestureRecognizer:tapGes];
    _thirdView.userInteractionEnabled = YES;
}

//内容
- (void)initForthView
{
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendShare:)];
    [_forthView addGestureRecognizer:tapGes];
    _forthView.userInteractionEnabled = YES;
}

//图片
- (void)initFivthView
{
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPic:)];
    [_img_add_pic addGestureRecognizer:tapGes];
    _img_add_pic.userInteractionEnabled = YES;
}

//设置底部view
- (void)initBottomView
{
    _bottom_view.layer.borderWidth = 0.5;
    _bottom_view.layer.borderColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:0.3].CGColor;
    
    [_btn_invite addTarget:self action:@selector(inviteFriends:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setFriendsListLayout
{
    float height = VIEW_BASE_HEIGHT;
    
    NSArray *views = [_view_friends subviews];
    for(UIView *friendsview in views)
    {
        if ([friendsview isKindOfClass:[ActiveFriendsView class]]) {
            [friendsview removeFromSuperview];
        }
    }
    
    if (![_friendsArray count]) {
        _view_height.constant = height;
        return;
    }
    height += 30;
    NSInteger listNum = [_friendsArray count];
    
    //4,5
    if ([UIScreen mainScreen].bounds.size.height < 700) {
        int row = (int)(listNum + 3)/4;
        if (row > 0) {
            height += row * 90.f;
        }
    }
    else
    {
        int row = (int)(listNum + 4)/5;
        if (row > 0) {
            height += row * 90.f;
        }
    }
    
    _view_height.constant = height;
    
    for (int i = 0; i < listNum; i ++) {
        ActiveFriendsView *view = [[[NSBundle mainBundle] loadNibNamed:@"ActiveFriendsView"
                                                                 owner:self
                                                               options:nil] objectAtIndex:0];
        if ([UIScreen mainScreen].bounds.size.height < 600)
        {
            view.frame = CGRectMake(0 + 80*(i%4),40 + 80*(i/4), 80, 20);
        }
        else if([UIScreen mainScreen].bounds.size.height < 700)
        {
            view.frame = CGRectMake(30 + 80*(i%4), 40 + 80*(i/4), 80, 20);
        }
        else
        {
            view.frame = CGRectMake(10 + 80*(i%5), 40 + 80*(i/5), 80, 20);
        }
        SelectFriendsModel *model = _friendsArray[i];
        
        view.model = model;
        view.label_fromInfo.hidden = YES;
        [_view_friends addSubview:view];
    }
}

#pragma mark - 对应功能
//跳到设置标题
- (void)setActivityTitle:(UITapGestureRecognizer *)gesture
{
    [_fristView setBackgroundColor:FREE_179_GRAY_COLOR];
    [self performSelector:@selector(delaySetColor:) withObject:_fristView afterDelay:0.5f];
    
    EditTitleViewController *vc = [[EditTitleViewController alloc] initWithNibName:@"EditTitleViewController" bundle:nil];
    vc.activity_title = _activity_title;
    [self.navigationController pushViewController:vc animated:YES];
}

//设置时间
- (void)setActivityTime:(UITapGestureRecognizer *)gesture
{
    NSMutableArray *part = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 5; i++) {
        [part addObject:@"1"];
    }
    
    NSDate *date = [NSDate date];
    [ActionSheetDatePicker showPickerWithTitle:@"选择时间" datePickerMode:UIDatePickerModeDateAndTime selectedDate:date doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        NSString *time = [[FreeSingleton sharedInstance] changeDate2String:selectedDate];
        NSArray *dateArray = [time componentsSeparatedByString:@" "];
        _freeDate = dateArray[0];
        _activity_time = dateArray[1];
        _label_time.text = time;
        _label_time.textColor = FREE_BLACK_COLOR;
    } cancelBlock:^(ActionSheetDatePicker *picker) {
    } origin:self.view];
}

//设置地点
- (void)setActivityPostion:(UITapGestureRecognizer *)gesture
{
    [_thirdView setBackgroundColor:FREE_179_GRAY_COLOR];
    [self performSelector:@selector(delaySetColor:) withObject:_thirdView afterDelay:0.5f];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    SendPositionViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SendPositionViewController"];
    
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

//跳到写内容
- (void)sendShare:(UITapGestureRecognizer *)gesture
{
    [_forthView setBackgroundColor:FREE_179_GRAY_COLOR];
    [self performSelector:@selector(delaySetColor:) withObject:_forthView afterDelay:0.5f];
    
    EditShareViewController *vc = [[EditShareViewController alloc] initWithNibName:@"EditShareViewController" bundle:nil];
    vc.text_content = _activity_content;
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

//上传或者更换图片
- (void)loadPic:(UITapGestureRecognizer *)gesture
{
    UIImageView *view = (UIImageView *)gesture.view;
    UIActionSheet *choiceSheet;
    if ([view.image isEqual:[UIImage imageNamed:@"icon_add_pic"]]) {
        choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"拍照", @"从相册中选取", nil];
    }
    else
    {
        choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:@"拍照", @"从相册中选取", @"移除图片", nil];
        choiceSheet.tag = DELETE_IMG_FLAG;
    }
    [choiceSheet showInView:self.view];
}

//邀请好友
- (void)inviteFriends:(id)sender
{
    ActivityInviteFriendsTableViewController *vc = [[ActivityInviteFriendsTableViewController alloc] initWithNibName:@"ActivityInviteFriendsTableViewController" bundle:nil];
    vc.modelArray = _modelArray;
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

//上传图片
- (void)upLoadImg
{
    if (!_activity_title) {
        [KVNProgress showErrorWithStatus:@"标题不能为空"];
        return;
    }
    
    if (!_activity_time || !_freeDate) {
        [KVNProgress showErrorWithStatus:@"活动时间不能为空"];
        return;
    }
    
    if (!_positionModel) {
        [KVNProgress showErrorWithStatus:@"活动地点不能为空"];
        return;
    }
    
    if (!_activity_content) {
        [KVNProgress showErrorWithStatus:@"活动内容不能为空"];
        return;
    }
    
    if ([_img_add_pic.image isEqual:[UIImage imageNamed:@"icon_add_pic"]]) {
        [KVNProgress showWithStatus:@"Loading"];
        [self createActivity:nil];
        return;
    }
    
    [KVNProgress showWithStatus:@"Loading"];
    __weak CreateActivityViewController *weakSelf = self;
    NSInteger retcode = [[FreeSingleton sharedInstance] userSubmitImgOnCompletion:_img_add_pic.image ratio:1.0 block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            [weakSelf createActivity:data];
        }
        else
        {
            [KVNProgress dismiss];
            [KVNProgress showErrorWithStatus:data];
        }
        
    }];
    
    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
    }
}


//发布活动
- (void)createActivity:(NSString *)imgUrl
{
    NSMutableArray *friendsArray = [NSMutableArray array];
    for (NSObject *obj in _friendsArray) {
        SelectFriendsModel *model = (SelectFriendsModel *)obj;
        if (model.isSelected == YES) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:model.accountId forKey:@"attendUserId"];
            [dic setObject:[NSNumber numberWithInt:0] forKey:@"fromInfo"];
            [friendsArray addObject:dic];
        }
    }
    
    __weak CreateActivityViewController *weakSelf = self;
    NSInteger retcode = [[FreeSingleton sharedInstance] postAcitiveInfoOnCompletion:_activity_title activityDate:_freeDate activityTime:_activity_time activityContent:_activity_content position:_positionModel imgUrl:imgUrl FriendsList:friendsArray postId:_post_Id block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {

            NSString *groupId = [NSString stringWithFormat:@"%@", data[@"groupId"]];
            
            [weakSelf addActivityModel:data];
            
            [[FreeSingleton sharedInstance] joinGroupOnCompletion:groupId block:^(NSUInteger ret, id data) {
                if (ret == RET_SERVER_SUCC) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [KVNProgress dismiss];
                    });
                    NSLog(@"加入群组成功");
                    [[FreeSingleton sharedInstance] syncGroups:^(NSUInteger ret, id data) {
                    }];
                    
                    //加入活动通知
                    [weakSelf addLocalNotice:_activity_model];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ActivityInfoViewController *vc = [[ActivityInfoViewController alloc] initWithNibName:@"ActivityInfoViewController" bundle:nil];
                        vc.activity_model = _activity_model;
                        UINavigationController *navigationController = weakSelf.navigationController;
                        [navigationController popToRootViewControllerAnimated:NO];
                        vc.hidesBottomBarWhenPushed = YES;
                        [navigationController pushViewController:vc animated:YES];
                    });
                }
                else
                {
                    NSLog(@"加入群组失败");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [KVNProgress dismiss];
                        [KVNProgress showErrorWithStatus:@"创建活动失败" onView:weakSelf.view];
                    });
                }
            }];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress dismiss];
                [KVNProgress showErrorWithStatus:@"创建活动失败"];
            });
        }
        
        
    }];
    
    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
    }
}

#pragma mark - 添加本地通知
- (void)addLocalNotice:(ActivityModel *)model
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        NSDate *date = [NSDate date];
        NSString *dateString1 = [NSString stringWithFormat:@"%@ %@", model.activityDate, model.activityTime];
        NSDate *date1 = [dateFormatter dateFromString:dateString1];
        NSTimeInterval time = [date1 timeIntervalSinceDate:date];
        
        notification.fireDate = [date dateByAddingTimeInterval:time - 30 * 60];
        
        // 设置重复间隔
        notification.repeatInterval = kCFCalendarUnitDay;
        
        // 设置提醒的文字内容
        if ([model.promoteAccount.accountId isEqualToString:[[FreeSingleton sharedInstance] getAccountId]]) {
            notification.alertBody = [NSString stringWithFormat:@"您的活动%@还有半个小时就要开始了喔",  model.title];
        }
        
        notification.alertAction = NSLocalizedString(@"活动要开始了", nil);
        
        // 通知提示音 使用默认的
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        // 设置应用程序右上角的提醒个数
        notification.applicationIconBadgeNumber++;
        
        // 设定通知的userInfo，用来标识该通知
        NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
        aUserInfo[@"activityId"] = model.activityId;
        notification.userInfo = aUserInfo;
        
        // 将通知添加到系统中
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

#pragma mark - 其他功能
- (void)addActivityModel:(id)data
{
    _activity_model = [[ActivityModel alloc] init];
    _activity_model.activityContent = data[@"activityContent"];
    _activity_model.activityDate = data[@"activityDate"];
    _activity_model.activityId = [NSString stringWithFormat:@"%@", data[@"activityId"]];
    _activity_model.activityTime = data[@"activityTime"];
    _activity_model.address = data[@"address"];
    _activity_model.title = data[@"title"];
    _activity_model.groupId = [NSString stringWithFormat:@"%@", data[@"groupId"]];
    
    if (![data[@"position"] isKindOfClass:[NSNull class]]) {
        _activity_model.position = data[@"position"];
    }
    
    _activity_model.postId = _post_Id;
    if ([data[@"type"] isKindOfClass:[NSNull class]]) {
        _activity_model.type = [data[@"type"] integerValue];
    }
    
    Account *accountModel = [[Account alloc] init];
    accountModel.headImg = [[FreeSingleton sharedInstance] getHeadImage];
    accountModel.nickName = [[FreeSingleton sharedInstance] getNickName];
    accountModel.accountId = [[FreeSingleton sharedInstance] getAccountId];
    _activity_model.promoteAccount = accountModel;
    
    if (![data[@"imgUrl"] isKindOfClass:[NSNull class]]) {
        _activity_model.imgUrl = data[@"imgUrl"];
    }
    
}

- (void)delaySetColor:(UIView *)view
{
    view.backgroundColor = [UIColor whiteColor];
}


#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
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
        }
            break;
        case 1:
        {
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
            break;
        case 2:
        {
            if (actionSheet.tag == DELETE_IMG_FLAG) {
            _img_add_pic.image = [UIImage imageNamed:@"icon_add_pic"];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [FreeImageScale imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    //    UIImage *scaleImage = [self scaleImage:editedImage toScale:0.5];
    _img_add_pic.image = editedImage;
    [cropperViewController dismissViewControllerAnimated:NO completion:^{
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

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
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

@end
