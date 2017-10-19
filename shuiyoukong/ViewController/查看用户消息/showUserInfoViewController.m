//
//  showUserInfoViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "showUserInfoViewController.h"
#import "showUserInfo1Cell.h"
#import "showUserInfo2Cell.h"
#import "showUserInfo3Cell.h"
#import "FreeSQLite.h"
#import "FreeSingleton.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "RCDChatViewController.h"
#import "EditUserInfoTableViewController.h"

@interface showUserInfoViewController ()<UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong)NSMutableDictionary *dataDict;

@property (nonatomic, strong)showUserInfo1Model *model1;

@property (nonatomic, strong)NSMutableArray *model2Array;

@property (nonatomic, weak)NSString *identifier1;
@property (nonatomic, weak)NSString *identifier2;
@property (nonatomic, weak)NSString *identifier3;
@property (nonatomic, strong)UIButton *btn_more;

@property (nonatomic, copy)NSString *phoneNumber;
@property (nonatomic, strong)UIWebView *phoneCallWebView;

@property (nonatomic,strong) UIScrollView *scrollviewed;
@property (nonatomic, strong) UIImageView *holder;
@property (nonatomic, weak) NSString *head_url;
@property (nonatomic, assign)BOOL isStranger;

@end

@implementation showUserInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initView];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendName:) name:ZC_NOTIFICATION_UPDATE_FRIENDNAME object:nil];
    }
    
    return self;
}

- (void)updateFriendName:(NSNotification *) notification
{
    _model1.name = notification.object;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initView
{
    _identifier1 = @"showUserInfo1Cell";
    _identifier2 = @"showUserInfo2Cell";
    _identifier3 = @"showUserInfo3Cell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier1 bundle:nil] forCellReuseIdentifier:_identifier1];
    [self.tableView registerNib:[UINib nibWithNibName:_identifier2 bundle:nil] forCellReuseIdentifier:_identifier2];
    [self.tableView registerNib:[UINib nibWithNibName:_identifier3 bundle:nil] forCellReuseIdentifier:_identifier3];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];//隐藏分割线
    
    self.navigationItem.title = @"个人信息";
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
    
    NSString *accountId;
    if (_accountModel) {
        accountId = [NSString stringWithFormat:@"%@", _accountModel.accountId];
    }
    else
    {
        accountId = [NSString stringWithFormat:@"%@", _friend_id];
    }
    
    
    _btn_more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_btn_more addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
    [_btn_more setImage:[UIImage imageNamed:@"icon_more_normal"] forState:UIControlStateNormal];
    [_btn_more setImage:[UIImage imageNamed:@"icon_more_highlight"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:_btn_more];
    self.navigationItem.rightBarButtonItem = backItem;
    
    UIBarButtonItem *backIteme = [[UIBarButtonItem alloc]init];
    backIteme.title = @" ";
    self.navigationItem.backBarButtonItem= backIteme;
    if (![accountId isEqualToString:[[FreeSingleton sharedInstance] getAccountId]] && !_isStranger && _accountModel) {
        _btn_more.hidden = NO;
    }
    else
    {
        _btn_more.hidden = YES;
    }
}

- (void)initData
{
    if (_accountModel != nil) {
        [self add2AccountModel];
    }
    else
    {
        __weak showUserInfoViewController *weakSelf = self;
        NSInteger ret = [[FreeSingleton sharedInstance] getOtherUserInfoCompletion:_friend_id block:^(NSUInteger retcode, id data) {
            if (retcode == RET_SERVER_SUCC) {
                _dataDict = data;
                [weakSelf addAllModel];
                [weakSelf.tableView reloadData];
            }
            else
            {
                NSLog(@"showUserInfo error is %@", data);
            }
        }];
        
        if (ret != RET_OK)
        {
            [KVNProgress showErrorWithStatus:zcErrMsg(ret)];
        }
    }
    
    
}

#pragma mark -addModel

- (void)add2AccountModel
{
    NSString *tagStr = nil;
    
    for (int k = 0; k < [_accountModel.tagList count]; k++) {
        if (k == 0) {
            tagStr = [NSString stringWithFormat:@"%@", _accountModel.tagList[k][@"tagName"]];
        }
        else
        {
            tagStr = [NSString stringWithFormat:@"%@, %@", tagStr,_accountModel.tagList[k][@"tagName"]];
        }
    }
    
    if ([tagStr length] > 15) {
        tagStr = [NSString stringWithFormat:@"%@...", [tagStr substringToIndex:14]];
    }
    
    if (tagStr == nil || [tagStr length] == 0) {
        tagStr = @"";
    }
    
    NSString *friendId = [NSString stringWithFormat:@"%@", _accountModel.accountId];
    
    NSString *accountId = [NSString stringWithFormat:@"%@", [[FreeSingleton sharedInstance] getAccountId]];
    
    
    if (_accountModel.friendName == nil && ![friendId isEqualToString:accountId])
    {
        _isStranger = YES;
    }
    
    if (_accountModel.friendName == nil) {
        _accountModel.friendName = _accountModel.nickName;
    }
    
    [self add2Model1:_accountModel.headImg name:_accountModel.friendName gender:_accountModel.gender niksname:_accountModel.nickName];
    
    _model2Array = [NSMutableArray array];
    
    [self add2Model2:@"地区" content:_accountModel.city];
    
    [self add2Model2:@"标签" content:tagStr];
    
    _phoneNumber = _accountModel.phoneNo;
}

- (void)addAllModel
{
    NSString *tagStr = nil;
    
    for (int k = 0; k < [_dataDict[@"tagList"] count]; k++) {
        if (k == 0) {
            tagStr = [NSString stringWithFormat:@"%@", _dataDict[@"tagList"][k][@"tagName"]];
        }
        else
        {
            tagStr = [NSString stringWithFormat:@"%@, %@", tagStr,_dataDict[@"tagList"][k][@"tagName"]];
        }
    }
    
    if ([tagStr length] > 15) {
        tagStr = [NSString stringWithFormat:@"%@...", [tagStr substringToIndex:14]];
    }
    
    if (tagStr == nil || [tagStr length] == 0) {
        tagStr = @"";
    }
    
    NSString *name = _friend_name;
    if (name == nil) {
        name = _dataDict[@"nickName"];
    }
    NSString *friendId = [NSString stringWithFormat:@"%@", _friend_id];
    
    NSString *accountId = [NSString stringWithFormat:@"%@", [[FreeSingleton sharedInstance] getAccountId]];
    
    
    NSString *friendName = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:_friend_id];
    
    _btn_more.hidden = NO;
    if (friendName == nil && ![friendId isEqualToString:accountId])
    {
        _isStranger = YES;
        _btn_more.hidden = YES;
    }
    
    [self add2Model1:_dataDict[@"headImg"] name:name gender:_dataDict[@"gender"] niksname:_dataDict[@"nickName"]];
    
    _model2Array = [NSMutableArray array];
    
    [self add2Model2:@"地区" content:_dataDict[@"city"]];
    
    [self add2Model2:@"标签" content:tagStr];
    
    //[self add2Model2:@"电话" content:_dataDict[@"phoneNo"]];
    
    _phoneNumber = _dataDict[@"phoneNo"];
    
    [[FreeSQLite sharedInstance] updateFreeSQLiteFriendInfo:_friend_id Id:nil imgUrl:_dataDict[@"headImg"] state:nil nickName:_dataDict[@"nickName"] gender:_dataDict[@"gender"] type:nil];
    
    
    RCUserInfo *users = [[RCUserInfo alloc] init];
    users.userId = friendId;
    users.name = name;
    users.portraitUri = _dataDict[@"headImg"];
    
    [[RCIM sharedRCIM] refreshUserInfoCache:users withUserId:friendId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//刷新个人资料
    
}

- (void)add2Model1:(NSString *)img_url name:(NSString *)name gender:(NSString *)gender niksname:(NSString *)niksname
{
    _model1 = [showUserInfo1Model alloc];
    
    _model1.img_url = img_url;
    
    _model1.name = name;
    
   _model1.gender = gender;
    
    _model1.niksname = niksname;
    
    _head_url = img_url;
}

- (void)add2Model2:(NSString *)title content:(NSString *)content
{
    showUserInfo2Model *model = [showUserInfo2Model alloc];
    model.title = title;
    model.content = content;
    [_model2Array addObject:model];
}

#pragma mark -tableViewControll
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_dataDict || _accountModel) {
        return 3;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        default:
        {
            NSString *accountId;
            if (_accountModel) {
                accountId = [NSString stringWithFormat:@"%@", _accountModel.accountId];
            }
            else
            {
                accountId = [NSString stringWithFormat:@"%@", _friend_id];
            }
            
            if (![accountId isEqual:[[FreeSingleton sharedInstance] getAccountId]]) {
                return 1;
            }
            else
            {
                return 0;
            }
            
        }
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            showUserInfo1Cell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier1 forIndexPath:indexPath];
            
            if (cell == nil) {
                cell = [[showUserInfo1Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier1];
            }
            
            cell.model = _model1;
            
            cell.head_img.userInteractionEnabled = YES;
            
            UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigImage:)];
            
            [cell.head_img addGestureRecognizer:tapGes];
            
            return cell;
        }
            break;
        case 1:
        {
            showUserInfo2Cell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier2 forIndexPath:indexPath];
            
            if (cell == nil) {
                cell = [[showUserInfo2Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier2];
            }
            
            cell.model = _model2Array[indexPath.row];
                return cell;
        }
            break;
        default:
        {
            if(!_isStranger)
            {
                showUserInfo3Cell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier3 forIndexPath:indexPath];
                
                if (cell == nil)
                {
                    
                    cell = [[showUserInfo3Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier3];
                }
                [cell.btn_send setTitle:@"发消息" forState:UIControlStateNormal];
                cell.btn_send.backgroundColor = FREE_BACKGOURND_COLOR;
                [cell.btn_send removeTarget:self action:@selector(addFriends) forControlEvents:UIControlEventTouchDown];
                [cell.btn_send addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchDown];
                return cell;
                
            }
            else
            {
                showUserInfo3Cell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier3 forIndexPath:indexPath];
                if (cell == nil)
                {
                    
                    cell = [[showUserInfo3Cell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier3];
                }
                [cell.btn_send setTitle:@"添加好友" forState:UIControlStateNormal];
                cell.btn_send.backgroundColor = FREE_BACKGOURND_COLOR;
                [cell.btn_send removeTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchDown];
                [cell.btn_send addTarget:self action:@selector(addFriends) forControlEvents:UIControlEventTouchDown];
                return cell;
            }
        }
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
            break;
        case 1:
            return 10;
            break;
        case 2:
            return 20;
            break;
        default:
            return 0;
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
            return 80 + 1;
            break;
        case 1:
            return 40 + 1;
        case 2:
            return 60 + 1;
        default:
            break;
    }
    
    return 60.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 2)
    {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 160)];
    view.backgroundColor = [UIColor clearColor];
    return view;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
         [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    MessageCenterTableViewCell* cell = (MessageCenterTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//    
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
//                                                 bundle:nil];
//    MessageViewController *vc = [sb instantiateViewControllerWithIdentifier:@"privateLetterSID"];
//    
//    vc.his_accountId = cell.model.friend_accountId;
//    vc.his_img  = cell.model.headImg_url;
//    vc.his_name = cell.model.friend_name;
//    
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark -相关处理函数
//显示大图
- (void)showBigImage:(UITapGestureRecognizer *)gesture {
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;//防止看大图时手势滑动引起的bug
    self.scrollviewed=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height)];
    self.scrollviewed.backgroundColor = [UIColor blackColor];
    [self.navigationController.view addSubview:self.scrollviewed];
    self.scrollviewed.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapped:)];
    [self.scrollviewed addGestureRecognizer:tapGes];
    self.tabBarController.tabBar.hidden = YES;
    NSString* url = _head_url;
    
    NSInteger height = 200;
    NSInteger width = 200;
    //直接附图片  holder是图片的大小
    if (width > self.scrollviewed.frame.size.width) {
        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width-width)/2, (self.scrollviewed.frame.size.height - height)/2, self.scrollviewed.bounds.size.width,height*(self.scrollviewed.bounds.size.width/width))];
        self.scrollviewed.contentSize=CGSizeMake(self.scrollviewed.bounds.size.width,height*(self.scrollviewed.bounds.size.width/width));
    }
    else if(height > self.scrollviewed.bounds.size.height)
    {
        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width - width)/2, (self.scrollviewed.frame.size.height - height)/2, width*(self.scrollviewed.bounds.size.height/height),height)];
        self.scrollviewed.contentSize=CGSizeMake(width*(self.scrollviewed.bounds.size.height/height),height);
    }
    else
    {
        self.holder = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollviewed.frame.size.width - width)/2, (self.scrollviewed.frame.size.height - height)/2, width, height)];
        
        self.scrollviewed.contentSize = CGSizeMake(width, height);
    }
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.scrollviewed animated:YES];
    [self.holder sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage* image,NSError* error,SDImageCacheType cachType, NSURL* iamgeUrl)
     {
         if (iamgeUrl == nil) {
             [_holder setImage:[UIImage imageNamed:@"datouxiang"]];
         }
         [Utils hideHUD:hud];
     }];
    
    // 等比例缩放
    self.holder.center=self.view.center;
    float scalex=self.view.frame.size.width/self.holder.frame.size.width;
    float scaley=self.view.frame.size.height/self.holder.frame.size.height;
    //最小的范围
    float scale = MIN(scalex, scaley);
    self.holder.transform=CGAffineTransformMakeScale(scale, scale);
    self.holder.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollviewed.delegate=self;
    self.scrollviewed.maximumZoomScale=3.0;
    self.scrollviewed.minimumZoomScale=1.0;
    [self.scrollviewed addSubview:self.holder];
    
    //实例化长按手势监听
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleImgLongPressed:)];
    _head_url = url;
    //代理
    longPress.delegate = self;
    longPress.minimumPressDuration = 1.0;
    //将长按手势添加到需要实现长按操作的视图里
    [self.scrollviewed addGestureRecognizer:longPress];
}

- (void) bgTapped:(UITapGestureRecognizer *)gesture{
    UIView *view = gesture.view;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [view removeFromSuperview];
    self.tabBarController.tabBar.hidden = YES;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.holder;
}
//缩小时图片居中显示
- (void)scrollViewDidZoom:(UIScrollView *)aScrollView
{
    CGFloat offsetX = (self.scrollviewed.bounds.size.width > self.scrollviewed.contentSize.width)?
    (self.scrollviewed.bounds.size.width - self.scrollviewed.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.scrollviewed.bounds.size.height > self.scrollviewed.contentSize.height)?
    (self.scrollviewed.bounds.size.height - self.scrollviewed.contentSize.height) * 0.5 : 0.0;
    self.holder.center = CGPointMake(self.scrollviewed.contentSize.width * 0.5 + offsetX,
                                     self.scrollviewed.contentSize.height * 0.5 + offsetY);
}

//长按事件
- (void)handleImgLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (_head_url && gesture.state == UIGestureRecognizerStateBegan) {
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机相册", nil];
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

// 功能：保存图片到手机
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.numberOfButtons - 1 == buttonIndex) {
        return;
    }
    NSString* title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"保存到手机相册"]) {
        
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_head_url]];
        UIImage* image = [UIImage imageWithData:data];
        
        //UIImageWriteToSavedPhotosAlbum(image, nil, nil,nil);
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

// 功能：显示对话框
-(void)showAlert:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@""
                          message:msg
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles: nil];
    [alert show];
}

// 功能：显示图片保存结果
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error){
        [self showAlert:@"保存失败..."];
    }else {
        [self showAlert:@"图片保存成功！"];
    }
}

#pragma mark - 右上角
- (void)moreInfo
{
    EditUserInfoTableViewController *vc = [[EditUserInfoTableViewController alloc] initWithNibName:@"EditUserInfoTableViewController" bundle:nil];
    NSString *accountId;
    if (_friend_id) {
        accountId = [NSString stringWithFormat:@"%@", _friend_id];
    }
    else
    {
        accountId = [NSString stringWithFormat:@"%@", _accountModel.accountId];
    }
    
    vc.accountId = accountId;
    vc.friendName = _friend_name;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 添加好友
- (void)addFriends
{
    __weak showUserInfoViewController *weakSelf = self;
    
    [KVNProgress showWithStatus:@"Loading"];
    NSString *accountId;
    NSString *phoneNo;
    NSString *headImg;
    NSString *pinyin;
    NSString *friendName;
    
    if (_accountModel) {
        accountId = [NSString stringWithFormat:@"%@", _accountModel.accountId];
        phoneNo = _accountModel.phoneNo;
        pinyin = _accountModel.pinyin;
        headImg = _accountModel.headImg;
        friendName = _accountModel.friendName;
    }
    else
    {
        accountId = [NSString stringWithFormat:@"%@", _friend_id];
        friendName = _friend_name;
        phoneNo = _dataDict[@"phoneNo"];
        headImg = _dataDict[@"headImg"];
        NSString *pinyinTmp = [friendName mutableCopy];
        CFStringTransform((CFMutableStringRef)pinyinTmp,NULL, kCFStringTransformMandarinLatin,NO);
        //再转换为不带声调的拼音
        CFStringTransform((CFMutableStringRef)pinyinTmp,NULL, kCFStringTransformStripDiacritics,NO);
        pinyin = pinyinTmp;
    }
    
    NSInteger retcode = [[FreeSingleton sharedInstance] addFriendOnCompletion:accountId friendName:friendName pinyin:pinyin phoneNo:phoneNo headImg:headImg block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            [[FreeSQLite sharedInstance] updateFreeSQLiteNewFriends:data[@"friendAccountId"] status:data[@"status"]];
            [[FreeSQLite sharedInstance] deleteFreeSQLiteAddressList:data[@"friendAccountId"]];
            [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:data[@"friendAccountId"] friendName:data[@"friendName"] nickName:data[@"friendName"] headImg:data[@"headImg"] Id:data[@"id"] phoneNo:data[@"phoneNo"] pinyin:data[@"pinyin"] status:data[@"status"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:nil];//触发刷新通知
            _btn_more.hidden = NO;
//            _accountModel.friendName = data[@"friendName"];
//            [weakSelf initData];
            _isStranger = NO;
            [weakSelf.tableView reloadData];
//            [weakSelf.navigationController popViewControllerAnimated:YES];
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

#pragma mark -拨打电话
-(void)sendPhoneNumber
{
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",_phoneNumber]];
    if ( !_phoneCallWebView && ![_phoneNumber isEqualToString:@""]) {
        _phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [_phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    [self.view addSubview:_phoneCallWebView];
}
#pragma mark -发送消息
//发私信
- (void)sendMessage
{
    NSMutableArray *viewControlles = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    if ([viewControlles count] > 1) {
        if ([viewControlles[[viewControlles count] - 2] isKindOfClass:[RCDChatViewController class]])
        {
            RCDChatViewController *chatView = viewControlles[[viewControlles count] - 2];
            if (chatView.conversationType == ConversationType_PRIVATE) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        }
    }
    
    //创建会话
    RCDChatViewController *chatViewController = [[RCDChatViewController alloc] init];
    chatViewController.conversationType = ConversationType_PRIVATE;
    chatViewController.targetId = _friend_id;
    chatViewController.title = _model1.name;
    chatViewController.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = self.navigationController;
    [navigationController popToRootViewControllerAnimated:NO];
    [navigationController pushViewController:chatViewController animated:YES];
    
    return;
}

@end