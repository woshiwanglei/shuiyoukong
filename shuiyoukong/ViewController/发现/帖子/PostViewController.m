//
//  PostViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/21.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "PostViewController.h"
#import "PostHeaderView.h"
#import "FreeSingleton.h"
#import "CreateActivityViewController.h"
#import "RepostTableViewCell.h"
#import "AppDelegate.h"
#import "EditRepostView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfoViewController.h"
#import "FreeSQLite.h"
#import "LoadMoreTableViewCell.h"
#import "MorePostViewController.h"
#import "ShareWebView.h"

#define OTHER 123
#define MY_REPOST 321

#define SHARE_ALERT 111

@interface PostViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UMSocialUIDelegate, UIActionSheetDelegate>

@property (strong, nonatomic)PostHeaderView *postHeaderView;

@property (strong, nonatomic)NSMutableArray *modelArray;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIView *btn_view;
@property (weak, nonatomic) IBOutlet UITextField *input_textfiled;
@property (weak, nonatomic) IBOutlet UIButton *btn_enjoy;

@property (strong, nonatomic)EditRepostView *editRepostView;
@property (strong, nonatomic)ShareWebView *shareView;

@property (strong, nonatomic)UIImageView *share_img;

@property (strong, nonatomic)UIView *backView;
@property (weak, nonatomic) NSString *identifier;
@property (weak, nonatomic) NSString *identifier_loadMore;

@property (strong, nonatomic)RepostModel *selectedModel;

@property (assign ,nonatomic)BOOL ifHasModel;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_postId) {
        _ifHasModel = NO;
    }
    else
    {
        _ifHasModel = YES;
    }
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needToRefresh:) name:FREE_NOTIFICATION_REFRESH_REPOST object:nil];
    }
    return self;
}

- (void)needToRefresh:(NSNotification *)note
{
    [self initData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _input_textfiled.delegate = nil;
    _mTableView.delegate = nil;
}

#pragma mark - initView
- (void)initView
{
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    //设置tableview滑动速度
//    self.mTableView.decelerationRate = 0.5;
    _identifier = @"RepostTableViewCell";
    _identifier_loadMore = @"LoadMoreTableViewCell";
    [self.mTableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    [self.mTableView registerNib:[UINib nibWithNibName:_identifier_loadMore bundle:nil] forCellReuseIdentifier:_identifier_loadMore];
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    self.tabBarController.tabBar.hidden = YES;//解决初始化时回复框的跳动
    self.mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    
    _input_textfiled.delegate = self;
    self.navigationItem.title = @"内容";
    
    UIBarButtonItem *backIteme = [[UIBarButtonItem alloc]init];
    backIteme.title = @" ";
    self.navigationItem.backBarButtonItem = backIteme;
    
    _btn_view.layer.borderWidth = 0.5;
    _btn_view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _input_textfiled.placeholder = @"写评论";
    
    [_btn_enjoy addTarget:self action:@selector(btn_enjoy_Tapped:) forControlEvents:UIControlEventTouchDown];
    if (_model.isUp) {
        [_btn_enjoy setImage:[UIImage imageNamed:@"icon_enjoy_on"] forState:UIControlStateNormal];
    }
    else
    {
        [_btn_enjoy setImage:[UIImage imageNamed:@"icon_enjoy"] forState:UIControlStateNormal];
    }
    
    if (_ifHasModel) {
        [self initHeaderView];
        _share_img = [[UIImageView alloc] init];
        [self showShareImage:_share_img url:_model.big_Img];
    }
}

- (void)initHeaderView
{
    _postHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"PostHeaderView"
                                                     owner:self
                                                   options:nil] objectAtIndex:0];
    _postHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    _postHeaderView.vc = self;
    _postHeaderView.model = _model;
    CGSize s =  [_postHeaderView.text_content sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 10 , FLT_MAX)];
//    CGSize s_label = [_postHeaderView.label_tags sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 39 , FLT_MAX)];
    
    float img_height = [_model.img_array count] * ([UIScreen mainScreen].bounds.size.width - 10);
//    _postHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, 396 + s.height + s_label.height);
    _postHeaderView.text_height.constant = s.height;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 277 + s.height + _postHeaderView.tagsView_height + img_height)];

    self.mTableView.tableHeaderView = headerView;
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageTap:)];
    _postHeaderView.head_view.userInteractionEnabled = YES;
    [_postHeaderView.head_view addGestureRecognizer:tapImage];
    [_postHeaderView.btn_more addTarget:self action:@selector(rightItemShare) forControlEvents:UIControlEventTouchDown];
    [_postHeaderView.btn_qq addTarget:self action:@selector(QQshare) forControlEvents:UIControlEventTouchDown];//qq分享
    [_postHeaderView.btn_friends addTarget:self action:@selector(friendShare) forControlEvents:UIControlEventTouchDown];//朋友圈分享
    [_postHeaderView.btn_wx addTarget:self action:@selector(weixinShare) forControlEvents:UIControlEventTouchDown];//微信分享

    [headerView addSubview:_postHeaderView];
    NSDictionary *metrics = @{
                              @"height" : @(277 + s.height + _postHeaderView.tagsView_height + img_height),
                              @"width" : @(self.view.frame.size.width)
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(_postHeaderView);
    [headerView addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-0-[_postHeaderView(width)]-0-|"
      options:0
      metrics:metrics
      views:views]];
    [headerView addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:
                                @"V:|-0-[_postHeaderView(height)]-0-|"
                                options:0
                                metrics:metrics
                                views:views]];
}

#pragma mark - initData
- (void)initData
{
    __weak PostViewController *weakSelf = self;
    
    NSString *str;
    if (_ifHasModel) {
        str = _model.postId;
    }
    else
    {
        [KVNProgress showWithStatus:@"Loading"];
        str = _postId;
    }
    
    NSInteger retcode = [[FreeSingleton sharedInstance] postDetailOnCompletion:str block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if(ret == RET_SERVER_SUCC)
        {
            //初始化右边上角
            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"发起活动" style:UIBarButtonItemStylePlain target:weakSelf action:@selector(gotoActivity) ];
            [rightItem setTitleTextAttributes:[NSDictionary
                                               dictionaryWithObjectsAndKeys:[UIFont
                                                                             boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
            weakSelf.navigationItem.rightBarButtonItem = rightItem;
            
            [weakSelf setPostModel:data];
            [weakSelf.mTableView reloadData];
        }
        else
        {
            [KVNProgress showErrorWithStatus:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_RELOAD_MYPOST object:nil];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
    }
}

- (void)setPostModel:(id)data
{
    //区分两种情况
    if (!_ifHasModel) {
         _model = [[DiscoverModel alloc] init];
        _model.postId = [NSString stringWithFormat:@"%@",data[@"postId"]];
        _model.type = CHOSEN_TYPE;
        _model.accountId = [NSString stringWithFormat:@"%@",data[@"accountId"]];
        
        if ([data[@"recommendTime"] isKindOfClass:[NSNull class]]) {
            _model.recommendTime = nil;
        }
        else
        {
            //            NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[NSString stringWithFormat:@"%@",dict[@"recommendTime"]] doubleValue]/1000.0];
            //            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
            //            [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS"];
            //            NSString *date_str = [dateformatter stringFromDate:date];
            _model.recommendTime = [NSString stringWithFormat:@"%@", data[@"recommendTime"]];
        }
        
        NSArray *array = [data[@"url"] componentsSeparatedByString:@"#%#"];
        _model.big_Img = array[0];
        for (int k = 0; k < [array count]; k++)
        {
            if ([array[k] isKindOfClass:[NSNull class]] || [array[k] length] == 0) {
                continue;
            }
            [_model.img_array addObject:array[k]];
        }
        _model.head_Img = data[@"headImg"];
        _model.name = data[@"nickName"];
        
        if (![data[@"title"] isKindOfClass:[NSNull class]] && [data[@"title"] length]) {
            _model.title = data[@"title"];
        }
        else
        {
            _model.title = @"";
        }
        
        if (![data[@"address"] isKindOfClass:[NSNull class]] && [data[@"address"] length]) {
            _model.address = data[@"address"];
        }
        else
        {
            _model.title = @"";
        }
        
        _model.content = data[@"content"];
        
        if (![data[@"tag"] isKindOfClass:[NSNull class]] && [data[@"tag"] length]) {
            NSArray *arrayTags = [data[@"tag"] componentsSeparatedByString:@"#%#"];
            _model.editor_comment = arrayTags[0];
            for (int j = 1; j < [arrayTags count]; j++) {
                _model.editor_comment = [NSString stringWithFormat:@"%@ %@", _model.editor_comment, arrayTags[j]];
            }
        }
        else
        {
            _model.editor_comment = @"";
        }
        
        if (![data[@"position"] isKindOfClass:[NSNull class]] && [data[@"position"] length])
        {
            NSArray *arrayPosition = [data[@"position"] componentsSeparatedByString:@"-"];
            _model.latitude = [arrayPosition[0] floatValue];
            _model.longitude = [arrayPosition[1] floatValue];
        }
    }
    
    _model.isUp = [data[@"upOrDown"] boolValue];
    if (_model.isUp) {
        [_btn_enjoy setImage:[UIImage imageNamed:@"icon_enjoy_on"] forState:UIControlStateNormal];
    }
    else
    {
        [_btn_enjoy setImage:[UIImage imageNamed:@"icon_enjoy"] forState:UIControlStateNormal];
    }
    
    _model.num = [NSString stringWithFormat:@"%@", data[@"upCount"]];
    _model.reCount =  [NSString stringWithFormat:@"%@", data[@"reCount"]];
    
    if (!_ifHasModel) {
        [self initHeaderView];
        _ifHasModel = YES;
    }
    
    _postHeaderView.label_num_bottom.text = _model.num;
    
    _modelArray = [NSMutableArray array];
    
    NSArray *dataArray = [[NSArray alloc] initWithArray:data[@"repostList"]];
    for (int i = 0; i < [dataArray count]; i++) {
        RepostModel *model = [[RepostModel alloc] init];
        model.repostTime = [NSString stringWithFormat:@"%@",dataArray[i][@"repostTime"]];
        model.accountId = [NSString stringWithFormat:@"%@", dataArray[i][@"accountId"]];
        
        NSString *friendName = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:model.accountId];
        if (friendName) {
            model.nickName = friendName;
        }
        else
        {
            model.nickName = dataArray[i][@"nickName"];
        }
        
        model.content = dataArray[i][@"content"];
        model.headImg = dataArray[i][@"headImg"];
        model.repostId = [NSString stringWithFormat:@"%@", dataArray[i][@"repostId"]];
        
        if (![dataArray[i][@"originalRepostName"] isKindOfClass:[NSNull class]]) {
            model.originalRepostName = dataArray[i][@"originalRepostName"];
        }
        
        [_modelArray addObject:model];
    }
    
    if (![data[@"accountList"] isKindOfClass:[NSNull class]]) {
        _postHeaderView.accountList = data[@"accountList"];
    }
    
    _postHeaderView.imgArray = data[@"headImgList"];
    
    if (![_model.imgTagsArray count]) {
        [self addImgTags2Model:data model:_model];
    }
    
    NSMutableArray *objArray = [NSMutableArray array];
    [objArray addObject:_model.type];
    [objArray addObject:_model.postId];
    [objArray addObject:[NSString stringWithFormat:@"%d", _model.isUp]];
    [objArray addObject:_model.num];
    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPDATE_UPDATE_COUNT object:objArray];
    
}

//添加tag
- (void)addImgTags2Model:(id)dict model:(DiscoverModel *)model
{
    if (![dict[@"postImg"] isKindOfClass:[NSNull class]] && [dict[@"postImg"] length]) {
        NSError *jsonError;
        id data = [NSJSONSerialization JSONObjectWithData:[dict[@"postImg"] dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:NSJSONReadingMutableContainers
                                                    error:&jsonError];
        
        if (jsonError) {
            NSLog(@"%@",jsonError);
        }
        
        for (int j = 0; j < [data count]; j++) {
            
            id tmpdata;
            if ([data[j] isKindOfClass:[NSString class]]) {
                
                NSArray* array = [[FreeSingleton sharedInstance] strToJson:data[j]];
                tmpdata = array;
            }
            else
            {
                tmpdata = data[j];
            }
            
            if ([tmpdata count]) {
                PicTagsModel *picModel = [[PicTagsModel alloc] init];
                picModel.imgUrl = tmpdata[@"imgUrl"];
                for (int i = 0; i < [tmpdata[@"imgTagList"] count]; i++) {
                    addTagsModel *tagsModel = [[addTagsModel alloc] init];
                    NSDictionary *dic = tmpdata[@"imgTagList"][i];
                    if (![dic[@"name"] isKindOfClass:[NSNull class]] && [dic[@"name"] length]) {
                        tagsModel.fristLabel = dic[@"name"];
                    }
                    if (![dic[@"address"] isKindOfClass:[NSNull class]]  && [dic[@"address"] length]) {
                        tagsModel.secondLabel = dic[@"address"];
                    }
                    if (![dic[@"price"] isKindOfClass:[NSNull class]] && [dic[@"price"] length]) {
                        tagsModel.thirdLabel = dic[@"price"];
                    }
                    if (![dic[@"item"] isKindOfClass:[NSNull class]] && [dic[@"item"] length]) {
                        tagsModel.forthLabel = dic[@"item"];
                    }
                    if (![dic[@"x"] isKindOfClass:[NSNull class]] && ![dic[@"y"] isKindOfClass:[NSNull class]] && dic[@"x"] && dic[@"y"]) {
                        tagsModel.point = CGPointMake([dic[@"x"] floatValue] * ([UIScreen mainScreen].bounds.size.width - 20), [dic[@"y"] floatValue] * ([UIScreen mainScreen].bounds.size.width - 20));
                    }
                    
                    [picModel.imgTagList addObject:tagsModel];
                }
                
                [model.imgTagsArray addObject:picModel];
            }
        }
    }
}


- (void)showHeadImage:(UIImageView *)headImg url:(NSString *)url
{
    [headImg sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"touxiang.png"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
    [headImg setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)showShareImage:(UIImageView *)headImg url:(NSString *)url
{
    [headImg sd_setImageWithURL:[FreeSingleton handleImageUrlWithSuffix:url sizeSuffix:SIZE_SUFFIX_100X100] placeholderImage:[UIImage imageNamed:@"class"] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         //[[SDImageCache sharedImageCache] storeImage:image forKey:KEY_FOR_IMAGE_AVATAR_CACHE];
     }];
    [headImg setContentMode:UIViewContentModeScaleAspectFill];
}

#pragma mark - 其他功能
- (void)gotoActivity
{
    CreateActivityViewController *vc = [[CreateActivityViewController alloc] initWithNibName:@"CreateActivityViewController" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    PositionModel *positionModel = [[PositionModel alloc] init];
    positionModel.latitude = _model.latitude;
    positionModel.longitude = _model.longitude;
    positionModel.position_name = _model.address;
    vc.positionModel = positionModel;
    vc.cover_img_url = _model.big_Img;
    vc.post_Id = _model.postId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)send_add:(UIButton *)btn
{
    NSString *repostId = nil;
    if (_selectedModel) {
        repostId = _selectedModel.accountId;
    }
    
    NSString* strContent = [_editRepostView.text_content.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [_editRepostView.text_content resignFirstResponder];
    [_editRepostView removeFromSuperview];
    [_backView removeFromSuperview];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress showWithStatus:@"Loading"];
    });
    
    __weak PostViewController *weakSelf = self;
    
    NSInteger retcode = [[FreeSingleton sharedInstance] sendRepostOnCompletion:_model.postId repostId:repostId content:strContent block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
            if (ret == RET_SERVER_SUCC) {
                if ([data length]) {
                    [weakSelf performSelector:@selector(delayHidden:) withObject:data afterDelay:0.5f];
                }
                else
                {
                    [weakSelf performSelector:@selector(delayHidden:) withObject:@"评论成功" afterDelay:0.5f];
                }
                
                _editRepostView.text_content.text = nil;
                _input_textfiled.text = nil;
                [weakSelf initData];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [KVNProgress showErrorWithStatus:@"评论失败"];
                });
            }
    }];
    
    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode)];
    }
}

- (void)delayHidden:(id)sender
{
    [KVNProgress showSuccessWithStatus:sender];
}

- (void)send_cancel:(UIButton *)btn
{
    _input_textfiled.text = _editRepostView.text_content.text;
    [_editRepostView.text_content resignFirstResponder];
    [_editRepostView removeFromSuperview];
    [_backView removeFromSuperview];
}

//发帖人头像点击
-(void)ImageTap:(UITapGestureRecognizer *)tap
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    
    vc.friend_id = _model.accountId;
    vc.friend_name = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:_model.accountId];
    if (![vc.friend_name length]) {
        vc.friend_name = _model.name;
    }
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btn_enjoy_Tapped:(UIButton *)btn
{
    if (_model.isUp) {
        //取消点赞
        [[FreeSingleton sharedInstance] cancelPostInfoOnCompletion:_model.postId block:^(NSUInteger ret, id data) {
            if (ret == RET_SERVER_SUCC) {
                _model.isUp = NO;
                NSInteger num = [_model.num integerValue];
                num--;
                _model.num = [NSString stringWithFormat:@"%ld", (long)num];
                _postHeaderView.label_num_bottom.text = _model.num;
                [_btn_enjoy setImage:[UIImage imageNamed:@"icon_enjoy"] forState:UIControlStateNormal];
                
                for (SelectFriendsModel *model in _postHeaderView.accountList) {
                    if ([model.accountId isEqualToString:[[FreeSingleton sharedInstance] getAccountId]]) {
                        [_postHeaderView.accountList removeObject:model];
                        break;
                    }
                }
                
                NSMutableArray *array = [_postHeaderView.imgArray mutableCopy];
                NSString *str = [[FreeSingleton sharedInstance] getHeadImage];
                for (NSString *imgUrl in array) {
//                    if (![imgUrl isKindOfClass:[NSNull class]]) {
                        if ([imgUrl isEqualToString:str]) {
                            [array removeObject:imgUrl];
                            break;
                        }
                    else if (str == nil && ([imgUrl isKindOfClass:[NSNull class]] || [imgUrl isEqualToString:@""]))
                    {
                        [array removeObject:imgUrl];
                        break;
                    }
//                    }
                }
                _postHeaderView.imgArray = array;
                
                NSMutableArray *objArray = [NSMutableArray array];
                [objArray addObject:_model.type];
                [objArray addObject:_model.postId];
                [objArray addObject:[NSString stringWithFormat:@"%d", _model.isUp]];
                [objArray addObject:_model.num];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPDATE_UPDATE_COUNT object:objArray];
            }
        }];
    }
    else
    {
        //点赞
        [[FreeSingleton sharedInstance] upPostInfoOnCompletion:_model.postId type:@"0" block:^(NSUInteger ret, id data) {
            if (ret == RET_SERVER_SUCC) {
                
                if ([data length]) {
                    [KVNProgress showSuccessWithStatus:data];
                }
                
                _model.isUp = YES;
                NSInteger num = [_model.num integerValue];
                num++;
                _model.num = [NSString stringWithFormat:@"%ld", (long)num];
                _postHeaderView.label_num_bottom.text = _model.num;
                [_btn_enjoy setImage:[UIImage imageNamed:@"icon_enjoy_on"] forState:UIControlStateNormal];
                
                //添加自己到accoutList里面
                SelectFriendsModel *model = [[SelectFriendsModel alloc] init];
                model.accountId = [[FreeSingleton sharedInstance] getAccountId];
                model.img_url = [[FreeSingleton sharedInstance] getHeadImage];
                model.name = [[FreeSingleton sharedInstance] getNickName];
                [_postHeaderView.accountList insertObject:model atIndex:0];
                
                //添加自己头像到imgArray里面
                NSMutableArray *array = [_postHeaderView.imgArray mutableCopy];
                NSString *str = [[FreeSingleton sharedInstance] getHeadImage];
                if (![str length]) {
                    str = @"";
                }
                [array insertObject:str atIndex:0];
                _postHeaderView.imgArray = array;
                
                NSMutableArray *objArray = [NSMutableArray array];
                [objArray addObject:_model.type];
                [objArray addObject:_model.postId];
                [objArray addObject:[NSString stringWithFormat:@"%d", _model.isUp]];
                [objArray addObject:_model.num];
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPDATE_UPDATE_COUNT object:objArray];
            }
        }];
    }
}

#pragma mark - textfiled
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    _selectedModel = nil;
    [self inputViewWillAppear];
    return NO;
}

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    _editRepostView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _editRepostView.frame.size.width, 190);
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    
    _editRepostView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height - keyboardBounds.size.height - 190, _editRepostView.frame.size.width, _editRepostView.frame.size.height);
    
    // commit animations
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    _editRepostView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _editRepostView.frame.size.width, _editRepostView.frame.size.height);
    
    // commit animations
    [UIView commitAnimations];
//    [_editRepostView removeFromSuperview];
//    [_backView removeFromSuperview];
    _selectedModel = nil;
}

- (void)inputViewWillAppear
{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_backView setBackgroundColor:[UIColor colorWithRed:(0/255.0)
                                                      green:(0/255.0)  blue:(0/255.0) alpha:.4]];
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
        [_backView addGestureRecognizer:tapView];
    }
    
    if (![_backView superview]) {
        [[AppDelegate getMainWindow] addSubview:_backView];
        
        if (!_editRepostView) {
            _editRepostView = [[[NSBundle mainBundle] loadNibNamed:@"EditRepostView"
                                                             owner:self
                                                           options:nil] objectAtIndex:0];
            [_editRepostView.btn_cancel addTarget:self action:@selector(send_cancel:) forControlEvents:UIControlEventTouchDown];
            [_editRepostView.btn_send addTarget:self action:@selector(send_add:) forControlEvents:UIControlEventTouchDown];
        }
        _editRepostView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 190, [UIScreen mainScreen].bounds.size.width, 190);
        
        if (_selectedModel) {
            _editRepostView.repostName = _selectedModel.nickName;
        }
        
        [_backView addSubview:_editRepostView];
        [_editRepostView.text_content becomeFirstResponder];
    }
}

-(void)tapChange:(UITapGestureRecognizer *)gureView
{
    if ([_editRepostView.text_content isFirstResponder]) {
        _input_textfiled.text = _editRepostView.text_content.text;
        [_editRepostView.text_content resignFirstResponder];
        [_editRepostView removeFromSuperview];
        [_backView removeFromSuperview];
        return;
    }
    
    [UIView animateWithDuration:.2 animations:^{
        _shareView.frame = CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _shareView.frame.size.width, _shareView.frame.size.height);
    } completion:^(BOOL finished) {
        [_editRepostView removeFromSuperview];
        [_backView removeFromSuperview];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_modelArray count]) {
        if ([_modelArray count] < 4) {
            return [_modelArray count];
        }
        else
        {
            return 5;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 4) {
        LoadMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier_loadMore forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[LoadMoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_loadMore];
        }
        [cell.label_title setFont:[UIFont boldSystemFontOfSize:15]];
        cell.label_title.text = @"加载更多评论";
        return cell;
    }
    
    RepostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[RepostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    cell.vc = self;
    cell.model = _modelArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 4) {
        return 43.f;
    }
    
    if ([_modelArray count]) {
        RepostTableViewCell* cell = (RepostTableViewCell *)[self.mTableView dequeueReusableCellWithIdentifier:_identifier];
        RepostModel *model = _modelArray[indexPath.row];
        if (model.originalRepostName) {
            cell.text_content.text = [NSString stringWithFormat:@"@%@ %@", model.originalRepostName, model.content];
        }
        else
        {
            cell.text_content.text = model.content;
        }
        
        CGSize s = [cell.text_content sizeThatFits:CGSizeMake(self.view.frame.size.width - 56 , FLT_MAX)];
    
        return 36.f + 1 + s.height;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                     bundle:nil];
        MorePostViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MorePostViewController"];
        
        vc.postId = _model.postId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        
        _selectedModel = _modelArray[indexPath.row];
        UIActionSheet *choiceSheet;
        if ([_selectedModel.accountId isEqual:[[FreeSingleton sharedInstance] getAccountId]]) {
            choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"删除", @"复制", @"举报", nil];
            choiceSheet.tag = MY_REPOST;
        }
        else
        {
            choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"回复", @"复制", @"举报", nil];
            choiceSheet.tag = OTHER;
        }
        
        [choiceSheet showInView:self.view];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 30)];
    label.font = [UIFont boldSystemFontOfSize:14];
    label.textColor = FREE_LABEL_NAME_COLOR;
    label.text = [NSString stringWithFormat:@"全部评论 (共%@条)", _model.reCount];
    [view addSubview:label];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
}


#pragma mark - 点击cell事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            if (actionSheet.tag == MY_REPOST) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setString:_selectedModel.content];
                UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"确定要删除这条回复吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alerView.delegate = self;
                [alerView show];
            }
            else
            {
                [self inputViewWillAppear];
            }
        }
            break;
        case 1:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:_selectedModel.content];
            UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"复制成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            alerView.delegate = self;
            [alerView show];
        }
            break;
        case 2:
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
            UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"IdeaFeedbackViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress showWithStatus:@"Loading"];
        });
        
        __weak PostViewController *weakSelf = self;
        [[FreeSingleton sharedInstance] deleteMyRepost:_selectedModel.repostId block:^(NSUInteger ret, id data) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress dismiss];
            });
            if (ret == RET_SERVER_SUCC) {
                [weakSelf initData];
            }
            else
            {
                [KVNProgress showErrorWithStatus:data];
            }
        }];
    }
    else
    {
        if (alertView.tag == SHARE_ALERT) {
            [_backView removeFromSuperview];
            [_shareView removeFromSuperview];
        }
    }
}

#pragma mark 分享
/**
 *  实现分享界面
 *
 *  @param buttonItem buttonItem description
 */
-(void)rightItemShare
{
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_backView setBackgroundColor:[UIColor colorWithRed:(0/255.0)
                                                      green:(0/255.0)  blue:(0/255.0) alpha:.4]];
        UITapGestureRecognizer *tapView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapChange:)];
        [_backView addGestureRecognizer:tapView];
    }
    
    if (![_backView superview]) {
        [[AppDelegate getMainWindow] addSubview:_backView];
        if(!_shareView)
        {
            _shareView = [[[NSBundle mainBundle] loadNibNamed:@"ShareWebView" owner:self options:nil]objectAtIndex:0];
            
            _shareView.translatesAutoresizingMaskIntoConstraints = NO;
            [_shareView.QButton addTarget:self action:@selector(QQshare) forControlEvents:UIControlEventTouchDown];//qq分享
            [_shareView.QoButton addTarget:self action:@selector(QoneShare) forControlEvents:UIControlEventTouchDown];//空间分享
            [_shareView.WXbutton addTarget:self action:@selector(weixinShare) forControlEvents:UIControlEventTouchDown];//微信分享
            [_shareView.WXFbutton addTarget:self action:@selector(friendShare) forControlEvents:UIControlEventTouchDown];//朋友圈分享
            [_shareView.SinButton addTarget:self action:@selector(SinaList) forControlEvents:UIControlEventTouchDown];//新浪分享
            [_shareView.SurpassButton addTarget:self action:@selector(reportBtn) forControlEvents:UIControlEventTouchDown];//刷新
            _shareView.Copy_label.hidden = YES;
            _shareView.CopyButton.hidden = YES;
            _shareView.view_refresh.hidden = YES;
            _shareView.label_bottom_title.hidden = YES;
        }
        [_backView addSubview:_shareView];
        NSDictionary *metrics = @{
                                  @"widthe" : @0,
                                  @"heightd" : @0
                                  };
        NSDictionary *views = NSDictionaryOfVariableBindings(_shareView);
        [_backView addConstraints:
         [NSLayoutConstraint
          constraintsWithVisualFormat:@"V:[_shareView(190)]-0-|"
          options:0
          metrics:metrics
          views:views]];
        
        [_backView addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:
                                   @"H:|-widthe-[_shareView]-widthe-|"
                                   options:0
                                   metrics:metrics
                                   views:views]];
        [self fadeIn];
    }
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
    [_shareView removeFromSuperview];
    
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    NSString *url = @"http://rufree.cn/freeweb/app/#/share/";
    NSString *SinaTail = [NSString stringWithFormat:@"%@%@", url, _model.postId];
    
    NSString *SinaTitle = _model.content;
    NSString *SinaContent = [NSString stringWithFormat:@"%@%@", SinaTitle, SinaTail];
    [[UMSocialControllerService defaultControllerService] setShareText:SinaContent shareImage:_share_img.image socialUIDelegate:self];
    //设置分享内容和回调对象
    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
    
}
//实现回调方法（可选）：
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        __weak PostViewController *weakSelf = self;
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alerView.delegate = self;
        [[FreeSingleton sharedInstance] shareSuccessOnCompletion:^(NSUInteger ret, id data) {
            if (ret == RET_SERVER_SUCC) {
                UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:data message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                alerView.delegate = weakSelf;
                alerView.tag = SHARE_ALERT;
                [alerView show];
            }
            else
            {
                UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                alerView.delegate = weakSelf;
                alerView.tag = SHARE_ALERT;
                [alerView show];
            }
        }];
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
    [UMSocialData defaultData].extConfig.qqData.title = @"来自谁有空";//QQ分享title
    [UMSocialData defaultData].extConfig.qzoneData.title = @"来自谁有空";//QQ空间title
    //微信好友title
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"来自谁有空";
    //微信朋友圈title
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = _model.content;
    
    NSString *url = @"http://rufree.cn/freeweb/app/#/share/";
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", url, _model.postId];
    //QQ分享
    [UMSocialQQHandler setQQWithAppId:@"1104634036" appKey:@"Qy4htxEyREjy5RQm" url:urlStr];
    //微信分享
    [UMSocialWechatHandler setWXAppId:@"wx978df91e43d81d2f" appSecret:@"eb69505c0114cf45c0079943609922ef" url:urlStr];
    
    //    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:
    //                                        @"http://www.baidu.com/img/bdlogo.gif"];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[shareName] content:_model.content image:_share_img.image location:nil urlResource:nil
                                            presentedController:nil completion:^(UMSocialResponseEntity *response){
                                                
                                                if (response.responseCode == UMSResponseCodeSuccess)
                                                {
                                                    __weak PostViewController *weakSelf = self;
                                                    [[FreeSingleton sharedInstance] shareSuccessOnCompletion:^(NSUInteger ret, id data) {
                                                        
                                                        if (ret == RET_SERVER_SUCC) {
                                                            UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:data message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                                            alerView.delegate = weakSelf;
                                                            alerView.tag = SHARE_ALERT;
                                                            [alerView show];
                                                        }
                                                        else
                                                        {
                                                            UIAlertView *alerView=[[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                                            alerView.delegate = weakSelf;
                                                            alerView.tag = SHARE_ALERT;
                                                            [alerView show];
                                                        }
                                                        
                                                    }];
                                                }
                                                else
                                                {
                                                    UIAlertView *alerViews=[[UIAlertView alloc] initWithTitle:@"分享失败" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                                                    alerViews.delegate = self;
                                                    alerViews.tag = SHARE_ALERT;
                                                    [alerViews show];
                                                }
                                            }];
    
    
}


/**
 *  刷新界面
 *
 *  @return
 */
-(void)reportBtn
{
    [_backView removeFromSuperview];
    [_shareView removeFromSuperview];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"IdeaFeedbackViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  动画划出
 */
- (void)fadeIn
{
    _shareView.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height, _shareView.frame.size.width, _shareView.frame.size.height);
    
    [UIView animateWithDuration:.1 animations:^{
        _shareView.frame=CGRectMake([UIScreen mainScreen].bounds.origin.x, [UIScreen mainScreen].bounds.size.height- _shareView.frame.size.height, _shareView.frame.size.width, _shareView.frame.size.height);
    }];
}

@end
