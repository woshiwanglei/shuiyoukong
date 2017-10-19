//
//  RegistersViewController.m
//  Free
//
//  Created by yangcong on 15/5/4.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "RegistersViewController.h"
#import "FreeSingleton.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "Error.h"
#import "FreeSQLite.h"
#import "VPImageCropperViewController.h"
#import "UIChangeIncident.h"
#import "FreeMap.h"
#import "AMapSearchAPI.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface RegistersViewController ()<UINavigationControllerDelegate,UIActionSheetDelegate, VPImageCropperDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, AMapSearchDelegate>

@property (nonatomic,copy) NSString *headUrl;
@property (nonatomic, copy) NSString *genderModel;
@property (nonatomic,assign) int timeNumber;
@property (nonatomic,strong) MBProgressHUD *hud;
@property BOOL lockOfRegister;
@property (nonatomic, strong) NSString *boyOrgirl;
@property (nonatomic, strong) UIActionSheet *sheet;
@property AMapSearchAPI *search;

@end

@implementation RegistersViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    _search.delegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:_YourName];
}

/**
 *  确定
 *
 *  @param sender
 */
- (IBAction)certain:(UIButton *)sender
{
  [self submitInfo];
// [self performSegueWithIdentifier:@"newsgude" sender:self];
}
/**
 *  再次发送
 *
 *  @param sender
 */
- (IBAction)againCertain:(UIButton *)sender {
    
    _timeNumber = 60; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(_timeNumber<=0)
        {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{

                [_againCertain setTitle:@"重新获取" forState:UIControlStateNormal];
                _againCertain.userInteractionEnabled = YES;
               
            });
        }
        else
        {
            int seconds = _timeNumber % 60;
            
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_againCertain setTitle:[NSString stringWithFormat:@"重新获取(%@)",strTime] forState:UIControlStateNormal];
                
                _againCertain.userInteractionEnabled = NO;
                
                                                      });
            _timeNumber--;
            
        }
     });
    dispatch_resume(_timer);
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _hud.detailsLabelText=@"正在获取验证码中.....";
    
    __weak RegistersViewController *weakself = self;
    
    NSInteger ret=[[FreeSingleton sharedInstance] userGetSmsOnCompletion:_phone_num block:^(NSUInteger retcode, id data)
                   {
                       [_hud hide:YES];
                       
                       if (retcode == RET_SERVER_SUCC)
                       {
                           [Utils warningUser:weakself msg:@"请求验证码成功"];
                           _hud.mode = MBProgressHUDModeText;
                           _hud.detailsLabelText=data;
                           [_hud hide:YES afterDelay:1.5];
                       }
                       else
                       {
                           [Utils warningUser:weakself msg:@"请求验证码失败"];
                           _hud.mode = MBProgressHUDModeText;
                           _hud.detailsLabelText=data;
                           [_hud hide:YES afterDelay:1.5];
                           
                       }
                   }];
    
    if (ret != RET_OK) {
        [_hud hide:YES];
        [Utils warningUser:weakself msg:zcErrMsg(ret)];
    }

}
/**
 *  点击空白隐藏键盘
 *
 *  @param sender
 */
- (IBAction)hideKeyboard:(id)sender
{
    [_YourName resignFirstResponder];
    [_NumberSend resignFirstResponder];
    [_passWord resignFirstResponder];
    [_text_inviteCode resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}



-(void)initView
{
    //界面UI全体修改
    _YourName.borderStyle = UITextBorderStyleNone;
    _NumberSend.borderStyle = UITextBorderStyleNone;
    _passWord.borderStyle = UITextBorderStyleNone;
    _gender.borderStyle = UITextBorderStyleNone;
    _text_inviteCode.borderStyle = UITextBorderStyleNone;
    //self.navigationItem.hidesBackButton = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_YourName];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    _certain.layer.borderColor = [[UIColor clearColor] CGColor];
    _certain.layer.masksToBounds = YES;
    _certain.layer.cornerRadius = 5;
    _certain.backgroundColor  = FREE_BACKGOURND_COLOR;
    
    _againCertain.backgroundColor = FREE_BACKGOURND_COLOR;
    _againCertain.layer.borderColor = [[UIColor clearColor] CGColor];
    
    _againCertain.layer.masksToBounds = YES;
    
    _againCertain.layer.cornerRadius = 5;
    
    _HeadImage.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editPortrait)];
  
    [_HeadImage addGestureRecognizer:tapGes];
    
     _NumberSend.delegate = self;
     _YourName.delegate = self;
     _passWord.delegate = self;
    _text_inviteCode.delegate = self;
     _NumberSend.returnKeyType = UIReturnKeyDone;
//     _NumberSend.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
     _YourName.returnKeyType = UIReturnKeyDone;
//     _YourName.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
     _passWord.returnKeyType = UIReturnKeyDone;
//     _passWord.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
     _gender.returnKeyType = UIReturnKeyDone;
//     _gender.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    _text_inviteCode.returnKeyType = UIReturnKeyDone;
//    _text_inviteCode.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    
    [_gender addTarget:self action:@selector(chooseGender) forControlEvents:UIControlEventTouchDown];
    [self timeout];
    
     self.view.backgroundColor =[UIColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1];
 
    
    [self setBackgroudView:_NumberBG];
    [self setBackgroudView:_NameBG];
    [self setBackgroudView:_passWordBG];
    [self setBackgroudView:_genderBG];
    [self setBackgroudView:_inviteCodeBG];
    
    UIApplication *app = [UIApplication sharedApplication];
    
    [[NSNotificationCenter defaultCenter]
     
     addObserver:self
     
     selector:@selector(applicationWillResignActive:)
     
     name:UIApplicationWillResignActiveNotification
     
     object:app];
}
//程序进入后台时触发事件
- (void)applicationWillResignActive:(NSNotification *)notification
{
    [_NumberSend resignFirstResponder];
    [_YourName resignFirstResponder];
    [_passWord resignFirstResponder];
    [_text_inviteCode resignFirstResponder];
}
-(void) chooseGender
{
    _sheet  = [[UIActionSheet alloc] initWithTitle:@"选择性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女",nil];
    [_sheet showInView:self.view];
    [_NumberSend resignFirstResponder];
    [_YourName resignFirstResponder];
    [_passWord resignFirstResponder];
    [_text_inviteCode resignFirstResponder];
}


-(void)setBackgroudView:(UIView *)views
{
    views.backgroundColor = [UIColor whiteColor];
    views.layer.borderWidth = 1;
    views.layer.borderColor =[[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0] CGColor];;
}

-(void)timeout{
    
    _timeNumber=60; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(_timeNumber<=0)
        {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_againCertain setTitle:@"重新获取" forState:UIControlStateNormal];
                _againCertain.userInteractionEnabled = YES;
                
            });
        }
        else
        {
            int seconds = _timeNumber % 60;
            
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_againCertain setTitle:[NSString stringWithFormat:@"重新获取(%@)",strTime] forState:UIControlStateNormal];
                
                _againCertain.userInteractionEnabled = NO;
                
            });
            _timeNumber--;
            
        }
    });
    dispatch_resume(_timer);

}
/**
 *  点击头像
 */
#pragma  mark -头像触发事件
- (void)editPortrait {
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];
}

- (void) submitImage:(UIImage *)headImg {
    MBProgressHUD *hud = [Utils waiting:self msg:@"图片上传中.."];
    __weak RegistersViewController *weakSelf = self;
    NSInteger ret = RET_OK;
    ret = [[FreeSingleton sharedInstance] userSubmitImgOnCompletion:headImg ratio:0.3 block:^(NSUInteger retcode, id data){
        [Utils hideHUD:hud];
        if (retcode == RET_SERVER_SUCC) {
            _headUrl = data;
            [Utils warningUser:weakSelf msg:@"头像上传成功"];
            [weakSelf.HeadImage setImage:headImg];
            //设置头像为圆角
            weakSelf.HeadImage.layer.cornerRadius = weakSelf.HeadImage.frame.size.height/2;
            weakSelf.HeadImage.layer.masksToBounds = YES;
            [weakSelf.HeadImage setContentMode:UIViewContentModeScaleAspectFill];
            [weakSelf.HeadImage setClipsToBounds:YES];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:KEY_HEAD_IMG_URL];
            
        } else {
            
            [Utils warningUser:weakSelf msg:zcErrMsg(ret)];
        }
        _lockOfRegister = YES;
    }];
    
    
    if (ret != RET_OK) {
        [Utils warningUser:self msg:zcErrMsg(ret)];
        [Utils hideHUD:hud];
    }
}

#pragma mark -提交信息
- (void) submitInfo{
    __weak RegistersViewController *weakSelf = self;
    [weakSelf.view endEditing:YES];
    
    MBProgressHUD *hud = [Utils waiting:weakSelf msg:@"正在处理中.."];

    NSInteger ret = [[FreeSingleton sharedInstance] userRegisterOnCompletion:self.NumberSend.text nickname:self.YourName.text pwd:self.passWord.text gender:_boyOrgirl phone:_phone_num headUrl:_headUrl inviteCode:_text_inviteCode.text deviceToken:[[FreeSingleton sharedInstance] getUserDeviceID] block:^(NSUInteger retcode, id data){
        [Utils hideHUD:hud];
        if (retcode == RET_SERVER_SUCC) {
            
            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NOTICE_TABLE tableName:NOTICE_TABLE_NAME];
            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:REMARK_TABLE tableName:REMARK_TABLE_NAME];
            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:NEW_FRIENDS_TABLE tableName:NEW_FRIENDS_TABLE_NAME];
            [weakSelf setLocation];
            [weakSelf getUserInfo:data];
            [[FreeSingleton sharedInstance] rongyunLogin];
            //开启socket
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DID_LOGIN object:nil];
            //[Utils warningUserAfterJump:weakSelf msg:@"注册成功" time:1.5];
            [weakSelf performSegueWithIdentifier:@"newsgude" sender:self];
        } else {
            NSLog(@"%@",data);
            [Utils warningUser:weakSelf msg:data];
        }
    }];
    
    
    if (ret != RET_OK) {
        [Utils warningUser:self msg:zcErrMsg(ret)];
        [Utils hideHUD:hud];
    }
    
}

#pragma mark -地图定位
- (void)setLocation
{
    __weak RegistersViewController *weakSelf = self;
    //进行定位
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [FreeMap getPosition:weakSelf block:^(NSUInteger ret, id data) {
        if(data)
        {
            //初始化检索对象
            _search = [[AMapSearchAPI alloc] init];
            _search.delegate = self;
            
            //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
            AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
//            regeoRequest.searchType = AMapSearchType_ReGeocode;
            
            NSArray *array = [data componentsSeparatedByString:@"-"];
            
            NSString *longitude = array[0];
            NSString *latitude = array[1];
            
            regeoRequest.location = [AMapGeoPoint locationWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
            regeoRequest.radius = 10000;
            regeoRequest.requireExtension = YES;
            
            //发起逆地理编码
            [_search AMapReGoecodeSearch: regeoRequest];
        }
    }];
    //    });
}

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil)
    {
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        NSString *strCity = response.regeocode.addressComponent.city;
        if (!strCity || [strCity length] == 0) {
            strCity = response.regeocode.addressComponent.province;
        }
        
        if (strCity != [[FreeSingleton sharedInstance] getCity]) {
            [[FreeSingleton sharedInstance] postCityOnCompletion:strCity block:^(NSUInteger ret, id data) {
                if (ret == RET_SERVER_SUCC) {
                    [FreeSingleton sharedInstance].city = strCity;
                    [[NSUserDefaults standardUserDefaults] setObject:strCity forKey:KEY_CITY_NAME];
                }
            }];
        }
    }
}

- (void)getUserInfo:(id)data
{
    if (data) {
        if (![data[@"id"] isKindOfClass:[NSNull class]]) {
            [FreeSingleton sharedInstance].accountId = [NSString stringWithFormat:@"%@", data[@"id"]];
            [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].accountId forKey:KEY_ACCOUNT_ID];
        } else {
            NSLog(@"ID为空");
        }
        if (![[data mutableCopy][@"phoneNo"] isKindOfClass:[NSNull class]]) {
            [FreeSingleton sharedInstance].phoneNo = data[@"phoneNo"];
            [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"phoneNo"] forKey:KEY_PHONE_NO];
        } else {
            NSLog(@"PhoneNo为空");
        }
        if (![[data mutableCopy][@"nickName"] isKindOfClass:[NSNull class]]) {
            [FreeSingleton sharedInstance].nickName = data[@"nickName"];
            [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"nickName"] forKey:KEY_NICK_NAME];
        } else {
            NSLog(@"昵称为空");
        }
        
        if (![[data mutableCopy][@"status"] isKindOfClass:[NSNull class]]) {
            [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"status"] forKey:KEY_USER_STATUS];
            [FreeSingleton sharedInstance].status = data[@"status"];
        } else {
            NSLog(@"状态为空");
        }
        
        if (![[data mutableCopy][@"headImg"] isKindOfClass:[NSNull class]]) {
            [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"headImg"] forKey:KEY_HEAD_IMG_URL];
            [FreeSingleton sharedInstance].head_img = data[@"headImg"];
            
        }//未加判空告警
        
        if (![[data mutableCopy][@"gender"] isKindOfClass:[NSNull class]]) {
            [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"gender"] forKey:KEY_GENDER];
            [FreeSingleton sharedInstance].gender = data[@"gender"];
        }
        else
        {
            NSLog(@"性别为空");
        }
        
        if (![[data mutableCopy][@"tagList"] isKindOfClass:[NSNull class]]) {
            [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"tagList"] forKey:KEY_LABLE_NUM];
            [FreeSingleton sharedInstance].lableArray = data[@"tagList"];
        }
        
        if (![data[@"level"] isKindOfClass:[NSNull class]]) {
            [FreeSingleton sharedInstance].level = data[@"level"];
            [[NSUserDefaults standardUserDefaults] setObject:data[@"level"] forKey:KEY_LEVEL];
        } else {
            NSLog(@"Lv为空");
        }
        
        if (![data[@"point"] isKindOfClass:[NSNull class]]) {
            [FreeSingleton sharedInstance].point = [NSString stringWithFormat:@"%@", data[@"point"]];
            [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].point forKey:KEY_POINT];
        } else {
            NSLog(@"point为空");
        }
        
        if (![data[@"followNum"] isKindOfClass:[NSNull class]]) {
            [FreeSingleton sharedInstance].my_Followed_Num = [NSString stringWithFormat:@"%@", data[@"followNum"]];
            [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].my_Followed_Num forKey:KEY_FOLLOWED_NUM];
        }
        else
        {
            NSLog(@"关注为空");
        }
        
        if (![data[@"followerNum"] isKindOfClass:[NSNull class]]) {
            [FreeSingleton sharedInstance].my_Follower_Num = [NSString stringWithFormat:@"%@", data[@"followerNum"]];
            [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].my_Follower_Num forKey:KEY_FOLLOWER_NUM];
        }
        else
        {
            NSLog(@"关注者为空");
        }
        
        if (![data[@"erdu"] isKindOfClass:[NSNull class]]) {
            NSString *erdu_tag = [NSString stringWithFormat:@"%@",data[@"erdu"]];
            [FreeSingleton sharedInstance].erdu = erdu_tag;
            [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].erdu forKey:KEY_INVITE_CODE];
        }
        
        if(![data[@"type"] isKindOfClass:[NSNull class]]){
            NSString *type = [NSString stringWithFormat:@"%@", data[@"type"]];
            [FreeSingleton sharedInstance].type = type;
            [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].type forKey:KEY_LOGIN_TYPE];
        }
    }
    
}

#pragma mark 键盘即将退出

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField != _text_inviteCode && textField != _passWord && textField != _NumberSend) {
        return YES;
    }
    
    NSUInteger lengthOfText = 0;
    if (textField == _text_inviteCode) {
        lengthOfText = 5;
    }
    else if (textField == _NumberSend)
    {
        lengthOfText = 6;
    }
    else
    {
        lengthOfText = 12;
    }
    
    // Check for non-numeric characters
    NSUInteger proposedNewLength = textField.text.length - range.length + string.length;
    if (proposedNewLength > lengthOfText)
        return NO;
    return YES;
}


-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    
    // NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > 8) {
                textField.text = [toBeString substringToIndex:8];
            }
        }
        else{
            
        }
    }
    else{
        if (toBeString.length > 8) {
            textField.text = [toBeString substringToIndex:8];
        }
    }
}

- (void)keyBoardWillShow:(NSNotification *)note{
    
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, -110);
    }];
    
}

- (void)keyBoardWillHide:(NSNotification *)note{
    
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_NumberSend resignFirstResponder];
    [_YourName resignFirstResponder];
    [_passWord resignFirstResponder];
    [_text_inviteCode resignFirstResponder];
    return YES;
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    //    UIImage *scaleImage = [self scaleImage:editedImage toScale:0.5];
    [self submitImage:editedImage];
    _lockOfRegister = NO;
    self.HeadImage.contentMode = UIViewContentModeScaleAspectFill;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
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

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet == _sheet)
    {
        if (buttonIndex == 0)
        {
            _boyOrgirl = @"male";
            _gender.placeholder = @"男";
        }
        else if(buttonIndex == 1)
        {
           _boyOrgirl = @"female";
            _gender.placeholder = @"女";
        }
        else
        {
            
        }
         NSLog(@"%ld",(long)buttonIndex);
       
    }
    else
    {
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
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
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
