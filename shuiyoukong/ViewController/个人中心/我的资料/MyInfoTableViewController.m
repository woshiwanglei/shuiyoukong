//
//  MyInfoTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MyInfoTableViewController.h"
#import "MyHeadImgTableViewCell.h"
#import "MyInfoTableViewCell.h"
#import "FreeSingleton.h"
#import "VPImageCropperViewController.h"
#import "FreeImageScale.h"
#import "UpdateMyNameViewController.h"

@interface MyInfoTableViewController ()<VPImageCropperDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic)NSString *identifier_headImg;
@property (weak, nonatomic)NSString *identifier_info;
@end

@implementation MyInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self initData];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerHeadImgChanged];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isNeedRefresh) {
        NSIndexSet *indexSet=[[NSIndexSet alloc] initWithIndex:2];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)registerHeadImgChanged
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(img_changed:) name:ZC_NOTIFICATION_DID_IMG_CHANGED object:nil];
}

- (void)img_changed:(NSNotification *) notification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - init
- (void)initView
{
    _identifier_headImg = @"MyHeadImgTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_headImg bundle:nil] forCellReuseIdentifier:_identifier_headImg];
    _identifier_info = @"MyInfoTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_info bundle:nil] forCellReuseIdentifier:_identifier_info];
    self.navigationItem.title = @"个人信息";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.backgroundColor = FREE_LIGHT_COLOR;
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

- (void)initData
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return 0;
            break;
        case 1:
            return 2;
            break;
        default:
            return 3;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return nil;
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                MyHeadImgTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_headImg forIndexPath:indexPath];
                if (!cell)
                {
                    cell = [[MyHeadImgTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_headImg];
                }
                cell.url = [[FreeSingleton sharedInstance] getHeadImage];
                return cell;
            }
                break;
            default:
            {
                MyInfoTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_info forIndexPath:indexPath];
                if (!cell) {
                    cell = [[MyInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_info];
                }
                cell.label_name.text = @"昵称";
                cell.label_content.text = [[FreeSingleton sharedInstance] getNickName];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.label_right.constant = 0;
                return cell;
            }
                break;
        }
    }
    else
    {
        MyInfoTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_info forIndexPath:indexPath];
        if (!cell) {
            cell = [[MyInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_info];
        }
        switch (indexPath.row) {
            case 0:
                cell.label_name.text = @"性别";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.label_right.constant = 35;
                cell.label_content.text = [[[FreeSingleton sharedInstance] getUserGender] isEqualToString:@"male"] ? @"男":@"女";
                break;
            case 1:
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.label_right.constant = 0;
                cell.label_name.text = @"城市";
                cell.label_content.text = [[FreeSingleton sharedInstance] getCity];
            }
                break;
            default:
            {
                NSMutableArray *array = [[FreeSingleton sharedInstance] getLalbeTitle];
                if ([array count]) {
                    NSString *str = array[0][@"tagName"];
                    for (int i = 1; i < [array count]; i++) {
                        str = [NSString stringWithFormat:@"%@,%@", str, array[i][@"tagName"]];
                    }
                    cell.label_content.text = str;
                }
                else
                {
                    cell.label_content.text = @"";
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.label_right.constant = 0;
                cell.label_name.text = @"兴趣标签";
            }
                break;
        }
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            return;
            break;
        case 1:
            if (indexPath.row == 0) {
                UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                         delegate:self
                                                                cancelButtonTitle:@"取消"
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:@"拍照", @"从相册中选取", nil];
                [choiceSheet showInView:self.view];
            }
            else
            {
                UpdateMyNameViewController *vc = [[UpdateMyNameViewController alloc] initWithNibName:@"UpdateMyNameViewController" bundle:nil];
                vc.nickName = [[FreeSingleton sharedInstance] getNickName];
                UINavigationController *nav = [[UINavigationController alloc]
                                               initWithRootViewController:vc];
                [self presentViewController:nav animated:YES completion:nil];
            }
            break;
        default:
            switch (indexPath.row) {
                case 0:
                    return;
                    break;
                case 1:
                    [self performSegueWithIdentifier:@"getAllcitypush" sender:self];
                    break;
                default:
                    [self performSegueWithIdentifier:@"getinterestLable" sender:self];
                    break;
            }
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];

    if (section == 0) {
        view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 8);
    }
    else
    {
        view.frame = CGRectMake(0, 0, tableView.bounds.size.width, 15);
    }
    view.backgroundColor = FREE_LIGHT_COLOR;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 8.f;
            break;
        case 1:
            return 0.f;
            break;
        default:
            return 15.f;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 0;
        case 1:
            if (indexPath.row == 0) {
                return 70.0 + 1;
            }
            return 40.0;
            break;
        default:
            return 40.0 + 1;
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        //        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 8, 0, 0)];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        //        [cell setLayoutMargins:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 8, 0, 0)];
        
    }
    
    if(indexPath.section == 2 && indexPath.row == 2)
    {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            //        [cell setSeparatorInset:UIEdgeInsetsZero];
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            //        [cell setLayoutMargins:UIEdgeInsetsZero];
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
            
        }
    }
    
}

#pragma mark - 更换头像
#pragma mark - Delegate for FDTake
- (void)sumbitHeadImg:(UIImage *)photo
{
    [KVNProgress showWithStatus:@"头像更新中，请稍等"];
    __weak MyInfoTableViewController *weakSelf = self;
    
    NSInteger retcode = [[FreeSingleton sharedInstance] userSubmitImgOnCompletion:[FreeSingleton zipImg:photo] ratio:0.3 block:^(NSUInteger ret, id data){
        
        if (ret == RET_SERVER_SUCC) {
            [[FreeSingleton sharedInstance] userEditHeadImgOnCompletion:data block:^(NSUInteger retcode, id responseData){
                [KVNProgress dismiss];
                if (retcode == RET_SERVER_SUCC)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:KEY_HEAD_IMG_URL];
                    [FreeSingleton sharedInstance].head_img = data;
                    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DID_IMG_CHANGED object:nil];//触发刷新通知
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView reloadData];
                        [KVNProgress showSuccessWithStatus:@"头像更新成功"
                                                    onView:weakSelf.view];
                        
                        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:1];
                        [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                        
                        NSString *uId = [NSString stringWithFormat:@"%@",[[FreeSingleton sharedInstance] getAccountId]];
                        RCUserInfo *user = [[RCUserInfo alloc] init];
                        
                        user.userId = uId;
                        user.name  = [[FreeSingleton sharedInstance] getNickName];
                        user.portraitUri = data;
                        
                        [[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:uId];
                        
                    });
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [KVNProgress showErrorWithStatus:@"头像更新失败"
                                                  onView:weakSelf.view];
                    });
                }
            }];
            
        } else {
            [KVNProgress dismiss];
            [KVNProgress showErrorWithStatus:data
                                      onView:weakSelf.view];
        }
    }];
    
    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)
                                  onView:weakSelf.view];
    }
    
}
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    //    UIImage *scaleImage = [self scaleImage:editedImage toScale:0.5];
    [self sumbitHeadImg:editedImage];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
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
    //设置tabbar消失时不能删除通知
    //    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZC_NOTIFICATION_NEED_DELETE_NOTIFICATION];
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
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
