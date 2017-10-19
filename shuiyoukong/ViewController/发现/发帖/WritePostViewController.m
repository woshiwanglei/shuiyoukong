//
//  WritePostViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "WritePostViewController.h"
#import "SendPositionViewController.h"
#import "EditShareViewController.h"
#import "VPImageCropperViewController.h"
#import "FreeSingleton.h"
#import "FreeImageScale.h"
#import "HotTagsTableViewController.h"
#import "PostModel.h"
#import "DiscoverViewController.h"
#import "AddTagsToPIcViewController.h"
#import "addTagsModel.h"

#define CHANGE_COVER 2

#define PIC_NUM 5

#define PIC_INDEX (_pic_index - 1)

@interface WritePostViewController ()<UIActionSheetDelegate, VPImageCropperDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *cover_img;
@property (weak, nonatomic) IBOutlet UIView *position_view;
@property (weak, nonatomic) IBOutlet UIView *write_view;
@property (weak, nonatomic) IBOutlet UIView *tags_view;
@property (weak, nonatomic) IBOutlet UIImageView *add_img;
@property (weak, nonatomic) IBOutlet UILabel *label_position;
@property (weak, nonatomic) IBOutlet UITextView *text_view;
@property (weak, nonatomic) IBOutlet UIImageView *pic_add1;
@property (weak, nonatomic) IBOutlet UIImageView *pic_add2;
@property (weak, nonatomic) IBOutlet UIImageView *pic_add3;
@property (weak, nonatomic) IBOutlet UIImageView *pic_add4;
@property (weak, nonatomic) IBOutlet UILabel *label_tags;
@property (weak, nonatomic) IBOutlet UIView *frist_view;
@property (weak, nonatomic) IBOutlet UIView *last_view;

@property (weak, nonatomic) UIImageView *imgView_needChanged;

@property (strong, nonatomic)NSMutableArray *imgArray;

@property (strong, nonatomic)NSMutableArray *pic_TagsArray;//保存pic_tags_Array的大数组

@property (assign, nonatomic)BOOL isFirstLoading;//第一次载入

@end

@implementation WritePostViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self resignNotice];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//通知，改变图片标签
- (void)resignNotice
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePicTags:) name:FREE_NOTIFICATION_CHANGE_TAG object:nil];
}

//更改标签数组
- (void)changePicTags:(NSNotification *)notification
{
    _pic_tags_Array = notification.object;
    if ([_pic_tags_Array count]) {
        [_pic_TagsArray replaceObjectAtIndex:PIC_INDEX withObject:_pic_tags_Array];
        if (PIC_INDEX == 0) {
            [_tags_array removeAllObjects];
            _isFirstLoading = YES;
        }
    }
    else
    {
        NSMutableArray *array = [NSMutableArray array];
        [_pic_TagsArray replaceObjectAtIndex:PIC_INDEX withObject:array];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstLoading = YES;//设置为第一次载入
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (_positionModel) {
        _label_position.text = _positionModel.position_name;
        _label_position.textColor = FREE_BLACK_COLOR;
//        [_label_position setFont:[UIFont systemFontOfSize:14]];
    }
    if ([_share_Content length]) {
        _text_view.text = _share_Content;
        self.text_view.textColor = FREE_BLACK_COLOR;
        [_text_view setFont:[UIFont systemFontOfSize:15]];
    }
    else
    {
        _text_view.text = @"来分享一下您的发现心得吧！";
        _text_view.textColor = FREE_LIGHT_GRAY_COLOR;
        [_text_view setFont:[UIFont systemFontOfSize:15]];
    }
    
    [self setTagsArrays];
}

#pragma mark - 设置标签
- (void)setTagsArrays
{
    //把图片上的标签默认为选择标签
    if (_isFirstLoading) {
        for (int i = 0; i < [_pic_TagsArray count]; i++) {
            id array = _pic_TagsArray[i];
            if ([array isKindOfClass:[NSNull class]] || [array count] == 0) {
                continue;
            }
            else
            {
                _isFirstLoading = NO;
                if (!_tags_array) {
                    _tags_array = [NSMutableArray array];
                }
                
                int index = 0;
                
                for (addTagsModel *model in array) {
                    if ([model.fristLabel length]) {
                        if (index < 4 && [_tags_array count] < 7) {
                            [_tags_array addObject:model.fristLabel];
                            index ++;
                        }
                        else
                        {
                            break;
                        }
                    }
                    if ([model.secondLabel length]) {
                        if (index < 4 && [_tags_array count] < 7) {
                            [_tags_array addObject:model.secondLabel];
                            index ++;
                        }
                        else
                        {
                            break;
                        }
                    }
                    if ([model.thirdLabel length]) {
                        if (index < 4 && [_tags_array count] < 7) {
                            [_tags_array addObject:model.thirdLabel];
                            index ++;
                        }
                        else
                        {
                            break;
                        }
                    }
                    if ([model.forthLabel length]) {
                        if (index < 4 && [_tags_array count] < 7) {
                            [_tags_array addObject:model.forthLabel];
                            index ++;
                        }
                        else
                        {
                            break;
                        }
                    }
                }
                
                break;
            }
        }
    }
    
    
    if ([_tags_array count]) {
        _label_tags.text = _tags_array[0];
        _label_tags.textColor = [UIColor colorWithRed:219/255.0 green:64/255.0 blue:77/255.0 alpha:1.0];
        for (int i = 1; i < [_tags_array count]; i++) {
            _label_tags.text = [NSString stringWithFormat:@"%@ %@", _label_tags.text, _tags_array[i]];
        }
    }
    else
    {
        _label_tags.textColor = FREE_LIGHT_GRAY_COLOR;
        _label_tags.text = @"添加您喜爱的标签";
    }
}

//删除标签
- (void)deleteTagsArray
{
    _isFirstLoading = YES;//重新设置标记
    
    id array = _pic_TagsArray[PIC_INDEX];
    
    if ([array isKindOfClass:[NSNull class]] || [array count] == 0) {
        return;
    }
    
    NSMutableArray *deleteArray = [NSMutableArray array];
    for (int i = 0; i < [_tags_array count]; i++) {
        int index = 0;
        
        for (addTagsModel *model in array) {
            if ([model.fristLabel length]) {
                if (index < 4 && [_tags_array[i] isEqualToString:model.fristLabel]) {
                    [deleteArray addObject:model.fristLabel];
                    index ++;
                }
                else if (index >= 4)
                {
                    [_tags_array removeObjectsInArray:deleteArray];
                    return;
                }
            }
            if ([model.secondLabel length]) {
                if (index < 4 && [_tags_array[i] isEqualToString:model.secondLabel]) {
                    [deleteArray addObject:model.secondLabel];
                    index ++;
                }
                else if (index >= 4)
                {
                    [_tags_array removeObjectsInArray:deleteArray];
                    return;
                }
            }
            if ([model.thirdLabel length]) {
                if (index < 4 && [_tags_array[i] isEqualToString:model.thirdLabel]) {
                    [deleteArray addObject:model.thirdLabel];
                    index ++;
                }
                else if (index >= 4)
                {
                    [_tags_array removeObjectsInArray:deleteArray];
                    return;
                }
            }
            if ([model.forthLabel length]) {
                if (index < 4 && [_tags_array[i] isEqualToString:model.forthLabel]) {
                    [deleteArray addObject:model.forthLabel];
                    index ++;
                }
                else if (index >= 4)
                {
                    [_tags_array removeObjectsInArray:deleteArray];
                    return;
                }
            }
        }
    }
    
    [_tags_array removeObjectsInArray:deleteArray];
}

#pragma mark - initView
- (void)initView
{
//    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    UIBarButtonItem *backIteme = [[UIBarButtonItem alloc]init];
    backIteme.title = @" ";
    self.navigationItem.backBarButtonItem= backIteme;
    self.view.backgroundColor = FREE_LIGHT_COLOR;
    self.navigationItem.title = @"发现推荐";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendPost)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self initFristView];
    [self initSecondView];
    [self initThirdView];
    [self initForthView];
    [self initLastView];
}


- (void)initFristView
{
    if (!_pic_TagsArray) {
        _pic_TagsArray = [NSMutableArray array];
        for (int i = 0; i < PIC_NUM; i++) {
            [_pic_TagsArray addObject:[NSNull null]];
        }
    }
    
    if ([_pic_tags_Array count]) {
        [_pic_TagsArray replaceObjectAtIndex:0 withObject:_pic_tags_Array];
    }
    else
    {
        NSMutableArray *array = [NSMutableArray array];
        [_pic_TagsArray replaceObjectAtIndex:0 withObject:array];
    }
    
    _imgArray = [NSMutableArray array];
    [_imgArray addObject:_cover_url];
    for (int i = 1; i < PIC_NUM; i++) {
        [_imgArray addObject:[NSNull null]];
    }
    _cover_img.image = _cover_url;
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCover:)];
    [_cover_img addGestureRecognizer:tapGes];
    _cover_img.tag = 0;
    _cover_img.userInteractionEnabled = YES;
//    _frist_view.layer.borderWidth = 0.5f;
//    _frist_view.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)initSecondView
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendPosition:)];
    [_position_view addGestureRecognizer:tapGestureRecognizer];
//    _position_view.layer.borderWidth = 0.5f;
//    _position_view.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)initThirdView
{
    _text_view.backgroundColor = [UIColor clearColor];
    _text_view.userInteractionEnabled = NO;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendShare:)];
    [_write_view addGestureRecognizer:tapGestureRecognizer];
//    _write_view.layer.borderWidth = 0.5f;
//    _write_view.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)initForthView
{
//    _label_tags.hidden = YES;
    _tags_view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendTags:)];
    [_tags_view addGestureRecognizer:tapGestureRecognizer];
//    _tags_view.layer.borderWidth = 0.5f;
//    _tags_view.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)initLastView
{
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPic:)];
    [_pic_add1 addGestureRecognizer:tapGes];
    _pic_add1.userInteractionEnabled = YES;
    _pic_add1.tag = 1;
    UITapGestureRecognizer* tapGes2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPic:)];
    [_pic_add2 addGestureRecognizer:tapGes2];
    _pic_add2.userInteractionEnabled = YES;
    _pic_add2.tag = 2;
    UITapGestureRecognizer* tapGes3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPic:)];
    [_pic_add3 addGestureRecognizer:tapGes3];
    _pic_add3.userInteractionEnabled = YES;
    _pic_add3.tag = 3;
    UITapGestureRecognizer* tapGes4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadPic:)];
    [_pic_add4 addGestureRecognizer:tapGes4];
    _pic_add4.userInteractionEnabled = YES;
    _pic_add4.tag = 4;
    
//    _last_view.layer.borderWidth = 0.5f;
//    _last_view.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

#pragma mark - 各个view的功能

//发帖子-传图片
- (void)sendPost
{
    NSString* strContent = [_share_Content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (!strContent.length) {
        [KVNProgress showErrorWithStatus:@"分享内容不能为空"];
        return;
    }
    
    if (![_positionModel.position_name length]) {
        [KVNProgress showErrorWithStatus:@"地理位置不能为空"];
        return;
    }
    
    if (![_tags_array count]) {
        [KVNProgress showErrorWithStatus:@"标签不能为空"];
        return;
    }
    
    [KVNProgress showWithStatus:@"Loading" onView:self.view];
    __weak WritePostViewController *weakSelf = self;
    
    NSMutableArray *upLoadImgArray = [NSMutableArray array];
    for (int i = 0; i < [_imgArray count]; i++) {
        if (![_imgArray[i] isKindOfClass:[NSNull class]]) {
            [upLoadImgArray addObject:_imgArray[i]];
        }
    }
    
    NSInteger retcode = [[FreeSingleton sharedInstance] userSubmitImgArrayOnCompletion:upLoadImgArray block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            [weakSelf sendPostInfo:data];
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

//发送帖子内容
- (void)sendPostInfo:(id)data
{
    PostModel *model = [[PostModel alloc] init];
    NSString* strContent = [_share_Content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    model.content = strContent;
//    if ([[[FreeSingleton sharedInstance] getCity] length]) {
//        model.city = [[FreeSingleton sharedInstance] getCity];
//    }
//    else
//    {
        model.city = _city;
//    }
    model.url = data;
    if (_positionModel) {
        model.address = _positionModel.position_name;
        model.position = [NSString stringWithFormat:@"%f-%f", _positionModel.latitude, _positionModel.longitude];
    }
    
    if([_tags_array count])
    {
        model.tags = _tags_array[0];
        NSString *str = @"#%#";
        for (int i = 1; i < [_tags_array count]; i++) {
            model.tags = [NSString stringWithFormat:@"%@%@%@", model.tags, str, _tags_array[i]];
        }
    }
    
    model.postImg = [self changeToJson:model.url];
    
    __weak WritePostViewController *weakSelf = self;
    NSInteger retcode = [[FreeSingleton sharedInstance] sendPostInfoOnCompletion:model block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            if ([data length]) {
                [KVNProgress showSuccessWithStatus:data];
            }
            else
            {
                [KVNProgress showSuccessWithStatus:@"发表成功!"];
            }
            
            DiscoverViewController *setPrizeVC = [weakSelf.navigationController.viewControllers objectAtIndex:weakSelf.navigationController.viewControllers.count-2];
            setPrizeVC.isNeedReload = YES;
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [KVNProgress showErrorWithStatus:data];
        }
            
    }];
    
    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
    }
}

//跳到发送坐标
- (void)sendPosition:(UITapGestureRecognizer *)gesture
{
    [_position_view setBackgroundColor:[UIColor lightGrayColor]];
    [self performSelector:@selector(delaySetColor:) withObject:_position_view afterDelay:0.5f];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    SendPositionViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SendPositionViewController"];
    
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}
//跳到写内容
- (void)sendShare:(UITapGestureRecognizer *)gesture
{
    [_write_view setBackgroundColor:[UIColor lightGrayColor]];
    [self performSelector:@selector(delaySetColor:) withObject:_write_view afterDelay:0.5f];
    
    EditShareViewController *vc = [[EditShareViewController alloc] initWithNibName:@"EditShareViewController" bundle:nil];
    vc.text_content = _share_Content;
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

//添加标签
- (void)sendTags:(UITapGestureRecognizer *)gesture
{
    [_tags_view setBackgroundColor:[UIColor lightGrayColor]];
    [self performSelector:@selector(delaySetColor:) withObject:_tags_view afterDelay:0.5f];
//    [self performSegueWithIdentifier:@"HotTagsTableViewController" sender:self];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    HotTagsTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"HotTagsTableViewController"];
    
    vc.addArray = _tags_array;
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

//更换封面
- (void)changeCover:(UITapGestureRecognizer *)gesture
{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    _pic_index = 1;
    _imgView_needChanged = _cover_img;
    [choiceSheet showInView:self.view];
}

//上传或者更换图片
- (void)loadPic:(UITapGestureRecognizer *)gesture
{
    UIImageView *view = (UIImageView *)gesture.view;
    _imgView_needChanged = view;
    _pic_index = view.tag + 1;//选择图片的index
    UIActionSheet *choiceSheet;
    
    if ([self twoPicIsEqual:view.image image:[UIImage imageNamed:@"icon_add_pic"]]) {
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
                                         otherButtonTitles:@"拍照", @"从相册中选取", @"设为封面", @"移除图片", nil];
        choiceSheet.tag = CHANGE_COVER;
    }
    [choiceSheet showInView:self.view];
}

#pragma mark - 杂项功能

- (NSString *)changeToJson:(NSString *)imgUrl
{
    NSMutableArray *imgArray = [NSMutableArray array];
    
    NSArray *arrayUrl = [imgUrl componentsSeparatedByString:@"#%#"];
    for (int k = 0; k < [arrayUrl count]; k++)
    {
        if ([arrayUrl[k] isKindOfClass:[NSNull class]] || [arrayUrl[k] length] == 0) {
            continue;
        }
        [imgArray addObject:arrayUrl[k]];
    }
    
    //用来保存url顺序
    int urlIndex = 0;
    
    NSMutableArray *postImgsArray = [NSMutableArray array];
    for (int i = 0; i < [_pic_TagsArray count]; i++) {
        
        if ([_pic_TagsArray[i] isKindOfClass:[NSNull class]]) {
            continue;
        }
        
        if ([_pic_TagsArray[i] count] == 0) {
            urlIndex++;
            continue;
        }
        
        NSMutableArray *postTagsArray = [NSMutableArray array];
        NSMutableArray *tmpArray = _pic_TagsArray[i];
        for (int j = 0; j < [tmpArray count]; j++) {
            addTagsModel *tagsModel = tmpArray[j];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            if (tagsModel.fristLabel) {
                [dic setObject:tagsModel.fristLabel forKey:@"name"];
            }
            if (tagsModel.secondLabel) {
                [dic setObject:tagsModel.secondLabel forKey:@"address"];
            }
            if (tagsModel.thirdLabel) {
                [dic setObject:tagsModel.thirdLabel forKey:@"price"];
            }
            if (tagsModel.forthLabel) {
                [dic setObject:tagsModel.forthLabel forKey:@"item"];
            }
            CGFloat x = tagsModel.point.x/([UIScreen mainScreen].bounds.size.width);
            CGFloat y = tagsModel.point.y/([UIScreen mainScreen].bounds.size.width);
            [dic setObject:[NSString stringWithFormat:@"%f", x] forKey:@"x"];
            [dic setObject:[NSString stringWithFormat:@"%f", y] forKey:@"y"];
            
            [postTagsArray addObject:dic];
        }
        
        NSString *url = imgArray[urlIndex];
        urlIndex++;
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:url, @"imgUrl", postTagsArray, @"imgTagList", nil];
        NSString *jsonStr = [[FreeSingleton sharedInstance] dictionaryToJson:dict];
        
        [postImgsArray addObject:jsonStr];
    }
    
    if (![postImgsArray count]) {
        return nil;
    }
    
    
    NSString *result = [[NSString alloc] initWithData:[postImgsArray jsonString] encoding:NSUTF8StringEncoding];
    
//    result = [result stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    return result;
}

- (void)delaySetColor:(UIView *)view
{
    view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)twoPicIsEqual:(UIImage *)image1 image:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data = UIImagePNGRepresentation(image2);
    
    if ([data isEqual:data1]) {
        return YES;
    }
    return NO;
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
                if (actionSheet.tag == CHANGE_COVER) {
//                    [_imgArray removeObject:_cover_img.image];
//                    [_imgArray removeObject:_imgView_needChanged.image];
//                    [_imgArray insertObject:_imgView_needChanged.image atIndex:0];
//                    [_imgArray addObject:_cover_img.image];
                    [_imgArray replaceObjectAtIndex:0 withObject:_imgView_needChanged.image];
                    [_imgArray replaceObjectAtIndex:PIC_INDEX withObject:_cover_img.image];
                    
                    id array_0 = _pic_TagsArray[0];
                    id array_replace = _pic_TagsArray[PIC_INDEX];
                    
                    [_pic_TagsArray replaceObjectAtIndex:0 withObject:array_replace];
                    [_pic_TagsArray replaceObjectAtIndex:PIC_INDEX withObject:array_0];
                    
                    [self deleteTagsArray];
                    [self setTagsArrays];
                    
                    UIImage *img = _cover_img.image;
                    _cover_img.image = _imgView_needChanged.image;
                    _imgView_needChanged.image = img;
                }
            }
            break;
        case 3:
        {
            [self deleteTagsArray];
            [_imgArray replaceObjectAtIndex:PIC_INDEX withObject:[NSNull null]];
            [_pic_TagsArray replaceObjectAtIndex:PIC_INDEX withObject:[NSNull null]];
            _imgView_needChanged.image = [UIImage imageNamed:@"icon_add_pic"];
            
            _isFirstLoading = NO;
            if ([_tags_array count]) {
                _label_tags.text = _tags_array[0];
                _label_tags.textColor = [UIColor colorWithRed:219/255.0 green:64/255.0 blue:77/255.0 alpha:1.0];
                for (int i = 1; i < [_tags_array count]; i++) {
                    _label_tags.text = [NSString stringWithFormat:@"%@ %@", _label_tags.text, _tags_array[i]];
                }
            }
            else
            {
                _label_tags.textColor = FREE_LIGHT_GRAY_COLOR;
                _label_tags.text = @"添加您喜爱的标签";
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
    _imgView_needChanged.image = editedImage;
    [_imgArray replaceObjectAtIndex:PIC_INDEX withObject:editedImage];
    
    AddTagsToPIcViewController *vc = [[AddTagsToPIcViewController alloc] initWithNibName:@"AddTagsToPIcViewController" bundle:nil];
    vc.img = editedImage;
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    
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
