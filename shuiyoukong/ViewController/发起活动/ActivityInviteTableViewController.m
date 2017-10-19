//
//  ActivityInviteTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/9.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ActivityInviteTableViewController.h"
#import "ActivityInviteView.h"
#import "SelectFriendsModel.h"
#import "SelectFriendsCell.h"
#import "FreeSingleton.h"
#import "FreeSQLite.h"
#import "PrintObject.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocial.h"
#import "AppDelegate.h"
#import "RCDChatViewController.h"

@interface ActivityInviteTableViewController ()<UMSocialUIDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (strong, nonatomic)NSMutableArray *modelArray;
@property (weak, nonatomic)NSString *identifier;
@property BOOL isallbtn;
@property (nonatomic,strong) UIButton *btn;
@property (nonatomic, strong)RCDiscussion *global_discussion;

@end

@implementation ActivityInviteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    self.navigationItem.title = @"邀请好友";
    _identifier = @"SelectFriendsCell";
    [self.mTableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    
    _modelArray = [NSMutableArray array];
    
//    [[FreeSQLite sharedInstance] selectFreeSQLiteAddressList:dataSource tag:CARED_FRIENDS];
    [KVNProgress showWithStatus:@"Loading"];
    __weak ActivityInviteTableViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] getMyFansListOnCompletion:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            if ([data count]) {
                [weakSelf add2Model:data];
                [weakSelf.mTableView reloadData];
            }
        }
    }];
}

- (void)add2Model:(id)dataSource
{
    for (int i = 0; i < [dataSource count]; i++) {
        SelectFriendsModel *model = [[SelectFriendsModel alloc] init];
        model.img_url = dataSource[i][@"headImg"];
        model.name = dataSource[i][@"friendName"];
        model.accountId = dataSource[i][@"friendAccountId"];
        model.isSelected = NO;
        [_modelArray addObject:model];
    }
}

- (void)initView
{
    _isallbtn = NO;
    
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    
    ActivityInviteView *activeView = [[[NSBundle mainBundle] loadNibNamed:@"ActivityInviteView"
                                                                       owner:self
                                                                     options:nil] objectAtIndex:0];
    
    [activeView.qqBtn addTarget:self action:@selector(QQshare) forControlEvents:UIControlEventTouchUpInside];
    [activeView.qoneBtn addTarget:self action:@selector(QoneShare) forControlEvents:UIControlEventTouchUpInside];
    [activeView.weixinBtn addTarget:self action:@selector(weixinShare) forControlEvents:UIControlEventTouchUpInside];
    [activeView.weixinFriend addTarget:self action:@selector(friendShare) forControlEvents:UIControlEventTouchUpInside];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 120)];
    activeView.backgroundColor = [UIColor colorWithRed:239/255.0 green:237/255.0 blue:239/255.0 alpha:1];
    activeView.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:activeView];
    self.mTableView.tableHeaderView = view;
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    
    UIBarButtonItem *btnitem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(btn_commitTapped:)];
    btnitem.tintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
    
    if (SCREEN_HEIGHT == 480)
    {
        [btnitem setTitleTextAttributes:[NSDictionary
                                         dictionaryWithObjectsAndKeys:[UIFont
                                                                       boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
    }
    else if(SCREEN_HEIGHT == 568)
    {
        [btnitem setTitleTextAttributes:[NSDictionary
                                         dictionaryWithObjectsAndKeys:[UIFont
                                                                       boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
    }
    else if(SCREEN_HEIGHT == 667)
    {
        [btnitem setTitleTextAttributes:[NSDictionary
                                         dictionaryWithObjectsAndKeys:[UIFont
                                                                       boldSystemFontOfSize:17], NSFontAttributeName,nil] forState:UIControlStateNormal];
    }
    else if(SCREEN_HEIGHT == 736)
    {
        [btnitem setTitleTextAttributes:[NSDictionary
                                         dictionaryWithObjectsAndKeys:[UIFont
                                                                       boldSystemFontOfSize:18], NSFontAttributeName,nil] forState:UIControlStateNormal];    }
    else
    {
        [btnitem setTitleTextAttributes:[NSDictionary
                                         dictionaryWithObjectsAndKeys:[UIFont
                                                                       boldSystemFontOfSize:15], NSFontAttributeName,nil] forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = btnitem;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_modelArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[SelectFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    
    cell.model = _modelArray[indexPath.row];
    
    return cell;
}
//获取分组标题并显示
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    headView.layer.borderWidth = 1;
    headView.layer.borderColor = [[UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1] CGColor];
    headView.backgroundColor = [UIColor colorWithRed:239/255.0 green:237/255.0 blue:239/255.0 alpha:1];
    UILabel *leftlable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
    leftlable.text = @"我的好友";
    leftlable.font = [UIFont systemFontOfSize:14.0];
    [headView addSubview:leftlable];
    
    _btn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-48, 0, 50, 30)];
    _btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_btn setTitle:@"全选" forState:UIControlStateNormal];
    if (_isallbtn)
    {
        [_btn setTitle:@"取消" forState:UIControlStateNormal];
    }
    else
    {
        [_btn setTitle:@"全选" forState:UIControlStateNormal];
    }
    [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(chooseAll:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:_btn];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.f + 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.mTableView.rowHeight = UITableViewAutomaticDimension;
    self.mTableView.estimatedRowHeight = 50.f + 1;
    return 50.f + 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SelectFriendsCell* cell = (SelectFriendsCell *)[self.mTableView cellForRowAtIndexPath:indexPath];
    
    SelectFriendsModel *model = _modelArray[indexPath.row];
    model.isSelected = !model.isSelected;
    
    cell.model = model;
}

#pragma mark - 功能
//全选
- (void)chooseAll:(UIButton *)sender
{
    _isallbtn = !(_isallbtn);
    
    if (_isallbtn)
    {
        for (int i = 0; i < [_modelArray count]; i++) {
            SelectFriendsModel *model = _modelArray[i];
            model.isSelected = YES;
            [_modelArray replaceObjectAtIndex:i withObject:model];
        }
        
        [_mTableView reloadData];
       
    }
    else
    {
        for (int i = 0; i < [_modelArray count]; i++) {
            SelectFriendsModel *model = _modelArray[i];
            model.isSelected = NO;
            [_modelArray replaceObjectAtIndex:i withObject:model];
        }
        [_mTableView reloadData];
    }

}

-(void)btn_commitTapped:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"活动发起完成，请在提醒界面中查看活动进程" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"进入群聊", nil];
    alertView.tag = 1;
    NSMutableArray *friendsArray = [NSMutableArray array];
    for (NSObject *obj in _modelArray) {
        SelectFriendsModel *model = (SelectFriendsModel *)obj;
        if (model.isSelected == YES) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:model.accountId forKey:@"attendUserId"];
            [dic setObject:[NSNumber numberWithInt:0] forKey:@"fromInfo"];
            [friendsArray addObject:dic];
        }
    }
    
    if ([friendsArray count] == 0) {
//        [KVNProgress showErrorWithStatus:@"请选择至少一个朋友"];
        [alertView show];
        return;
    }
    
    //选择多人则创建讨论组
    
    NSMutableString *discussionTitle = [NSMutableString string];
   // NSMutableArray *userIdList = [NSMutableArray new];
    
    [discussionTitle appendString:[NSString stringWithFormat:@"%@", [[FreeSingleton sharedInstance] getNickName]]];
   // [userIdList addObject:[[FreeSingleton sharedInstance] getAccountId]];
    
    __weak ActivityInviteTableViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"
                         onView:weakSelf.view];
    
    NSSet *set = [NSSet setWithArray:friendsArray];
    
    NSInteger retcode = [[FreeSingleton sharedInstance] inviteAcitiveInfoOnCompletion:_activeId friendsList:[set allObjects] block:^(NSUInteger ret, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress dismiss];
            });
                if (ret == RET_SERVER_SUCC) {
                    [alertView show];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [KVNProgress showErrorWithStatus:data onView:weakSelf.view];
                    });
                }
        }];

    if (retcode != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(retcode) onView:self.view];
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0 && alertView.tag == 1)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    else if(buttonIndex == 1)
    {
        //创建会话
        RCDChatViewController *_conversationVC = [[RCDChatViewController alloc]init];
        _conversationVC.conversationType = ConversationType_GROUP;
        _conversationVC.targetId = _groupId;
        _conversationVC.userName = _activiName;
        _conversationVC.title = _activiName;
        _conversationVC.hidesBottomBarWhenPushed = YES;
        UINavigationController *navigationController = self.navigationController;
        [navigationController popToRootViewControllerAnimated:NO];
        [navigationController pushViewController:_conversationVC animated:YES];
        
    }

}



#pragma mark -分享
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
    [UMSocialSinaSSOHandler openNewSinaSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    NSString *str1 = @"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxef49c97a732015c0&redirect_uri=http%3a%2f%2fwww.duanzigou.com%2ffreeweb%2fapp%2f%23%2fpostdetail%2f";
    NSString *str2 = @"&response_type=code&scope=snsapi_userinfo&state=1#wechat_redirect";
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@%@%@", _activiName, str1, _activeId, str2];
    
    [[UMSocialControllerService defaultControllerService] setShareText:strUrl shareImage:[UIImage imageNamed:@"glass"] socialUIDelegate:self];
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
    NSString *strTitle = [NSString stringWithFormat:@"周%@%@", _week, _noon];
    [UMSocialData defaultData].extConfig.qqData.title = strTitle;//QQ分享title
    [UMSocialData defaultData].extConfig.qzoneData.title = strTitle;//QQ空间title
    //微信好友title
    [UMSocialData defaultData].extConfig.wechatSessionData.title = strTitle;
    //微信朋友圈title
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = _activiName;
    
    NSString *str1 = @"https://open.weixin.qq.com/connect/oauth2/authorize?appid=wxef49c97a732015c0&redirect_uri=http%3a%2f%2fwww.duanzigou.com%2ffreeweb%2fapp%2f%23%2fpostdetail%2f";
    NSString *str2 = @"&response_type=code&scope=snsapi_userinfo&state=1#wechat_redirect";
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@%@", str1, _activeId,str2];
    
    NSString *qqStrUrl = @"http://www.duanzigou.com/GetToken.html?activityId=";
    NSString *qqAllStrUrl = [NSString stringWithFormat:@"%@%@",qqStrUrl,_activeId];
//    NSString *strUrl = [NSString stringWithFormat:@"http://114.215.108.65:9090/freeweb/app/#/postdetail/%@", _activeId];
    
    //QQ分享
    [UMSocialQQHandler setQQWithAppId:@"1104634036" appKey:@"Qy4htxEyREjy5RQm" url:qqAllStrUrl];
    //微信分享
    [UMSocialWechatHandler setWXAppId:@"wx978df91e43d81d2f" appSecret:@"eb69505c0114cf45c0079943609922ef" url:strUrl];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialWXMessageTypeNone;
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[shareName] content:_activiName image:[UIImage imageNamed:@"glass"] location:nil urlResource:nil
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

@end
