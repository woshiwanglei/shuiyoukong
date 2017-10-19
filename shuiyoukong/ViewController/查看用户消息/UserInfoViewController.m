//
//  UserInfoViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "UserInfoViewController.h"
#import "SquareTableViewCell.h"
#import "UserInfoHeaderView.h"
#import "UserInfoTableHeader.h"
#import "FreeSingleton.h"
#import "AddressListCellModel.h"
#import "RCDChatViewController.h"
#import "MJRefresh.h"
#import "EditUserInfoTableViewController.h"
#import "FreeSQLite.h"

#define MY_CARE 1
#define CARE_ME 2

@interface UserInfoViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIButton *btn_care;
@property (weak, nonatomic) IBOutlet UIButton *btn_send;
@property (weak, nonatomic) IBOutlet UIView *bottom_view;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btn_view_height;

@property (weak, nonatomic)NSString *identifier;
@property (strong, nonatomic)NSMutableArray *modelArray_post;
@property (strong, nonatomic)NSMutableArray *modelArray_like;
@property (strong, nonatomic)Account *userInfoModel;
@property (strong, nonatomic)NSMutableArray *dataSource_post;
@property (strong, nonatomic)NSMutableArray *dataSource_like;
@property (strong, nonatomic)UserInfoTableHeader *userTableHeader;

@property (assign, nonatomic)BOOL isRight;


@property (strong, nonatomic)UIButton *btn_more;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _identifier = @"SquareTableViewCell";
    [_mTableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDianZanNum:) name:ZC_NOTIFICATION_UPDATE_DIANZAN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPost:) name:FREE_NOTIFICATION_RELOAD_MYPOST object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCOUNTName:) name:ZC_NOTIFICATION_UPDATE_UPDATE_COUNT object:nil];
    }
    return self;
}

- (void)updateCOUNTName:(NSNotification *)notification {
    NSArray *array = notification.object;
    NSString* postId = array[1];
    BOOL isUp = [array[2] boolValue];//是否点赞
    NSString *num = array[3];//点赞数量
    
    for (int i = 0; i < [_modelArray_post count]; i++) {
        NSMutableArray *arrayObj = _modelArray_post[i];
        for (int j = 0; j < [arrayObj count]; j++) {
            DiscoverModel *modelObj = arrayObj[j];
            if ([modelObj.postId isEqualToString:postId]) {
                
                modelObj.isUp = isUp;
                modelObj.num = num;
                if (!_isRight) {
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
                    [_mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                }
                
                NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:_dataSource_post[i]];
                dic[@"upOrDown"] = [NSString stringWithFormat:@"%d", modelObj.isUp];
                dic[@"upCount"] = modelObj.num;
                [_dataSource_post replaceObjectAtIndex:i withObject:dic];
                break;
            }
        }
    }
    
    for (int i = 0; i < [_modelArray_like count]; i++) {
        NSMutableArray *arrayObj = _modelArray_like[i];
        for (int j = 0; j < [arrayObj count]; j++) {
            DiscoverModel *modelObj = arrayObj[j];
            if ([modelObj.postId isEqualToString:postId]) {
                
                modelObj.isUp = isUp;
                modelObj.num = num;
                
                if (_isRight) {
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
                    [_mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                }
                
                NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:_dataSource_like[i]];
                dic[@"upOrDown"] = [NSString stringWithFormat:@"%d", modelObj.isUp];
                dic[@"upCount"] = modelObj.num;
                [_dataSource_like replaceObjectAtIndex:i withObject:dic];
                break;
            }
        }
    }
    
}

- (void)reloadPost:(NSNotification *)notification
{
    [self initData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateDianZanNum:(NSNotification *)notification {
    DiscoverModel *model = notification.object;
    
    for (int i = 0; i < [_dataSource_like count]; i++) {
        NSString *str = [NSString stringWithFormat:@"%@", _dataSource_like[i][@"postId"]];
        if ([str isEqualToString:model.postId]) {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:_dataSource_like[i]];
            if (model.isUp) {
                dic[@"upOrDown"] = @"1";
            }
            else
            {
                dic[@"upOrDown"] = @"0";
            }
            dic[@"upCount"] = model.num;
            [_dataSource_like replaceObjectAtIndex:i withObject:dic];
            NSMutableArray *arrayObj = _modelArray_like[i/2];
            DiscoverModel *modelObj = arrayObj[i%2];
            modelObj.num = model.num;
            modelObj.isUp = model.isUp;
            [arrayObj replaceObjectAtIndex:i%2 withObject:modelObj];
            [_modelArray_like replaceObjectAtIndex:i/2 withObject:arrayObj];
            
            if (_isRight) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i/2 inSection:0];
                [_mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            break;
        }
    }
    
    for (int i = 0; i < [_dataSource_post count]; i++) {
        NSString *str = [NSString stringWithFormat:@"%@", _dataSource_post[i][@"postId"]];
        if ([str isEqualToString:model.postId]) {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:_dataSource_post[i]];
            if (model.isUp) {
                dic[@"upOrDown"] = @"1";
            }
            else
            {
                dic[@"upOrDown"] = @"0";
            }
            dic[@"upCount"] = model.num;
            [_dataSource_post replaceObjectAtIndex:i withObject:dic];
            NSMutableArray *arrayObj = _modelArray_post[i/2];
            DiscoverModel *modelObj = arrayObj[i%2];
            modelObj.num = model.num;
            modelObj.isUp = model.isUp;
            [arrayObj replaceObjectAtIndex:i%2 withObject:modelObj];
            [_modelArray_post replaceObjectAtIndex:i/2 withObject:arrayObj];
            
            if (!_isRight) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i/2 inSection:0];
                [_mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            break;
        }
    }
}

#pragma mark - initView
- (void)initView
{
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    
    self.navigationItem.title = @"TA的信息";
    
    _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的
    _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mTableView.backgroundColor = FREE_LIGHT_COLOR;
    
    if ([[[FreeSingleton sharedInstance] getAccountId] isEqual:_friend_id]) {
        _bottom_view.hidden = YES;
        _btn_view_height.constant = 0;
    }
    
    [self setupRefresh];
}

- (void)initHeaderView
{
    UserInfoHeaderView *userInfoView = [[[NSBundle mainBundle] loadNibNamed:@"UserInfoHeaderView"
                                                                      owner:self
                                                                    options:nil] objectAtIndex:0];
    userInfoView.vc = self;
    userInfoView.model = _userInfoModel;
    userInfoView.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 141)];
    self.mTableView.tableHeaderView = headerView;
    [headerView addSubview:userInfoView];
    
    NSDictionary *metrics = @{
                              @"height" : @(141),
                              @"width" : @(self.view.frame.size.width)
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(userInfoView);
    [headerView addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-0-[userInfoView(width)]-0-|"
      options:0
      metrics:metrics
      views:views]];
    [headerView addConstraints:[NSLayoutConstraint
                                constraintsWithVisualFormat:
                                @"V:|-0-[userInfoView(height)]-0-|"
                                options:0
                                metrics:metrics
                                views:views]];
}

#pragma mark - initData

- (void)initData
{
    __weak UserInfoViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"];
    NSInteger ret = [[FreeSingleton sharedInstance] getOtherUserInfoCompletion:_friend_id block:^(NSUInteger retcode, id data) {
        [KVNProgress dismiss];
        if (retcode == RET_SERVER_SUCC) {
            if (data) {
                [weakSelf add2Model:data];
                [weakSelf.mTableView reloadData];
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"用户信息异常"];
            _bottom_view.hidden = YES;
            _btn_view_height.constant = 0;
            NSLog(@"showUserInfo error is %@", data);
        }
    }];
    
    if (ret != RET_OK)
    {
        _bottom_view.hidden = YES;
        _btn_view_height.constant = 0;
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(ret)];
    }
    
    [self initPost];
    [self initLike];
}

- (void)initPost
{
    UIActivityIndicatorView* activityIndicatorView = [ [ UIActivityIndicatorView alloc ]
                                                      initWithFrame:CGRectMake(250.0,20.0,30.0,30.0)];
    [self.mTableView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    __weak UserInfoViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] queryOtherPostList:@"1" pageSize:@"10" postId:@"0" accountId:_friend_id block:^(NSUInteger ret, id data) {
        [activityIndicatorView stopAnimating];
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
                _dataSource_post = [NSMutableArray arrayWithArray:data[@"items"]];
                _modelArray_post = [NSMutableArray array];
                [weakSelf addSquareModel:_dataSource_post modelArray:_modelArray_post];
                [weakSelf.mTableView reloadData];
            }
        }
    }];
}

- (void)initLike
{
    UIActivityIndicatorView* activityIndicatorView = [ [ UIActivityIndicatorView alloc ]
                                                    initWithFrame:CGRectMake(250.0,20.0,30.0,30.0)];
    [self.mTableView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    __weak UserInfoViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] queryOtherLikeList:@"1" pageSize:@"10" postId:@"0" accountId:_friend_id block:^(NSUInteger ret, id data) {
        [activityIndicatorView stopAnimating];
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
                _dataSource_like = [NSMutableArray arrayWithArray:data[@"items"]];
                _modelArray_like = [NSMutableArray array];
                [weakSelf addSquareModel:_dataSource_like modelArray:_modelArray_like];
                [weakSelf.mTableView reloadData];
            }
        }
    }];
}

- (void)add2Model:(id)data
{
    _userInfoModel = [[Account alloc] init];
    
    NSString *friendName = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:_friend_id];
    
    if (friendName) {
        _userInfoModel.nickName = friendName;
    }
    else
    {
        _userInfoModel.nickName = data[@"nickName"];
    }
    
    NSString *pinyin = [_userInfoModel.nickName mutableCopy];
    CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformStripDiacritics,NO);
    _userInfoModel.pinyin = pinyin;
    
    if (![data[@"city"] isKindOfClass:[NSNull class]]) {
        _userInfoModel.city = data[@"city"];
    }
    _userInfoModel.gender = data[@"gender"];
    if (![data[@"headImg"] isKindOfClass:[NSNull class]]) {
        _userInfoModel.headImg = data[@"headImg"];
    }
    if (![data[@"followNum"] isKindOfClass:[NSNull class]]) {
        _userInfoModel.followed_num = [NSString stringWithFormat:@"%@", data[@"followNum"]];
    }
    if (![data[@"followerNum"] isKindOfClass:[NSNull class]]) {
        _userInfoModel.follower_num = [NSString stringWithFormat:@"%@",data[@"followerNum"]];
    }
    _userInfoModel.accountId = [NSString stringWithFormat:@"%@", data[@"id"]];
    _userInfoModel.status = [NSString stringWithFormat:@"%@", data[@"status"]];
    _userInfoModel.phoneNo = data[@"phoneNo"];
    if (![data[@"level"] isKindOfClass:[NSNull class]]) {
        _userInfoModel.lv = data[@"level"];
    }
    _userInfoModel.status = [NSString stringWithFormat:@"%@",data[@"status"]];
    
    _btn_more = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_btn_more addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
    [_btn_more setImage:[UIImage imageNamed:@"icon_more_normal"] forState:UIControlStateNormal];
    [_btn_more setImage:[UIImage imageNamed:@"icon_more_highlight"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:_btn_more];
    self.navigationItem.rightBarButtonItem = backItem;
    
    
    if (![_userInfoModel.accountId isEqualToString:[[FreeSingleton sharedInstance] getAccountId]] && [_userInfoModel.status integerValue] != 2) {
        _btn_more.hidden = NO;
    }
    else
    {
        _btn_more.hidden = YES;
    }
    
    if (![data[@"relationId"] isKindOfClass:[NSNull class]]) {
        _userInfoModel.relationId = [NSString stringWithFormat:@"%@",data[@"relationId"]];
    }
    
    switch ([_userInfoModel.status integerValue]) {
        case 1:
            _btn_care.titleLabel.text = @"取消关注";
            [_btn_care setTitle:@"取消关注" forState:UIControlStateNormal];
            break;
        case 2:
            _btn_care.titleLabel.text = @"添加关注";
            [_btn_care setTitle:@"添加关注" forState:UIControlStateNormal];
            break;
        default:
            _btn_care.titleLabel.text = @"互相关注";
            [_btn_care setTitle:@"互相关注" forState:UIControlStateNormal];
            break;
    }
    
    [_btn_care addTarget:self action:@selector(btn_care_Tapped:) forControlEvents:UIControlEventTouchDown];
    [_btn_send addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchDown];
    [self initHeaderView];
}

- (void)addSquareModel:(id)data modelArray:(NSMutableArray *)modelArray
{
    int num = [data count]%2;
    
    for (int i = 0; i < [data count] - num; i = i + 2) {
        NSMutableArray *array = [NSMutableArray array];
        for (int j = 0; j < 2; j++) {
            DiscoverModel *model = [[DiscoverModel alloc] init];
            NSDictionary *dict = data[i + j];
            model.type = SQUARE_TYPE;
            model.postId = [NSString stringWithFormat:@"%@",dict[@"postId"]];
            model.accountId = [NSString stringWithFormat:@"%@",dict[@"accountId"]];
            NSArray *arrayUrl = [dict[@"url"] componentsSeparatedByString:@"#%#"];
            model.big_Img = arrayUrl[0];
            for (int k = 0; k < [arrayUrl count]; k++)
            {
                if ([arrayUrl[k] isKindOfClass:[NSNull class]] || [arrayUrl[k] length] == 0) {
                    continue;
                }
                
                [model.img_array addObject:arrayUrl[k]];
            }
            model.head_Img = dict[@"headImg"];
            NSString *friendName = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:model.accountId];
            if (friendName) {
                model.name = friendName;
            }
            else
            {
                model.name = dict[@"nickName"];
            }
            
            if (![dict[@"title"] isKindOfClass:[NSNull class]] && [dict[@"title"] length]) {
                model.title = dict[@"title"];
            }
            else
            {
                model.title = @"";
            }
            if (![dict[@"address"] isKindOfClass:[NSNull class]] && [dict[@"address"] length]) {
                model.address = dict[@"address"];
            }
            else
            {
                model.title = @"";
            }
            
            model.content = dict[@"content"];
            
            if (![dict[@"tag"] isKindOfClass:[NSNull class]] && [dict[@"tag"] length]) {
                NSArray *arrayTags = [dict[@"tag"] componentsSeparatedByString:@"#%#"];
                model.editor_comment = arrayTags[0];
                for (int j = 1; j < [arrayTags count]; j++) {
                    if ([arrayTags[j] length]) {
                    model.editor_comment = [NSString stringWithFormat:@"%@ %@", model.editor_comment, arrayTags[j]];
                    }
                }
            }
            else
            {
                model.editor_comment = @"";
            }
            
            model.isUp = [dict[@"upOrDown"] integerValue];
            model.num = [NSString stringWithFormat:@"%@",dict[@"upCount"]];
            model.reCount = [NSString stringWithFormat:@"%@",dict[@"reCount"]];
            
            if (![dict[@"position"] isKindOfClass:[NSNull class]] && [dict[@"position"] length])
            {
                NSArray *arrayPosition = [dict[@"position"] componentsSeparatedByString:@"-"];
                model.latitude = [arrayPosition[0] floatValue];
                model.longitude = [arrayPosition[1] floatValue];
            }
            
            [array addObject:model];
        }
        [modelArray addObject:array];
    }
    
    if (num) {
        NSMutableArray *array = [NSMutableArray array];
        NSDictionary *dic = data[[data count] - 1];
        DiscoverModel *model = [[DiscoverModel alloc] init];
        model.type = SQUARE_TYPE;
        model.postId = [NSString stringWithFormat:@"%@",dic[@"postId"]];
        model.accountId = [NSString stringWithFormat:@"%@",dic[@"accountId"]];
        NSArray *arrayUrl = [dic[@"url"] componentsSeparatedByString:@"#%#"];
        model.big_Img = arrayUrl[0];
        for (int k = 0; k < [arrayUrl count]; k++)
        {
            if ([arrayUrl[k] isKindOfClass:[NSNull class]] || [arrayUrl[k] length] == 0) {
                continue;
            }
            
            [model.img_array addObject:arrayUrl[k]];
        }
        model.head_Img = dic[@"headImg"];
        
        NSString *friendName = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:model.accountId];
        if (friendName) {
            model.name = friendName;
        }
        else
        {
            model.name = dic[@"nickName"];
        }
        
        if (![dic[@"title"] isKindOfClass:[NSNull class]] && [dic[@"title"] length]) {
            model.title = dic[@"title"];
        }
        else
        {
            model.title = @"";
        }
        if (![dic[@"address"] isKindOfClass:[NSNull class]] && [dic[@"address"] length]) {
            model.address = dic[@"address"];
        }
        else
        {
            model.title = @"";
        }
        model.content = dic[@"content"];
        
        if (![dic[@"tag"] isKindOfClass:[NSNull class]] && [dic[@"tag"] length]) {
            NSArray *arrayTags = [dic[@"tag"] componentsSeparatedByString:@"#%#"];
            model.editor_comment = arrayTags[0];
            for (int j = 1; j < [arrayTags count]; j++) {
                if ([arrayTags[j] length]) {
                model.editor_comment = [NSString stringWithFormat:@"%@ %@", model.editor_comment, arrayTags[j]];
                }
            }
        }
        else
        {
            model.editor_comment = @"";
        }
        model.num = [NSString stringWithFormat:@"%@",dic[@"upCount"]];
        model.reCount = [NSString stringWithFormat:@"%@",dic[@"reCount"]];
        model.isUp = [dic[@"upOrDown"] integerValue];
        
        if (![dic[@"position"] isKindOfClass:[NSNull class]] && [dic[@"position"] length])
        {
            NSArray *arrayPosition = [dic[@"position"] componentsSeparatedByString:@"-"];
            model.latitude = [arrayPosition[0] floatValue];
            model.longitude = [arrayPosition[1] floatValue];
        }
        
        [array addObject:model];
        [modelArray addObject:array];
    }
}

#pragma mark - 下拉刷新

- (void)setupRefresh
{
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [_mTableView addFooterWithTarget:self action:@selector(footerRereshing_square)];
    
    _mTableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
    _mTableView.footerReleaseToRefreshText = @"松开马上加载更多数据了";
    _mTableView.footerRefreshingText = @"正在加载中";
}

- (void)footerRereshing_square
{
    if (_isRight) {
        [self refreshLike];
    }
    else
    {
        [self refreshPost];
    }
}

- (void)refreshLike
{
    __weak UserInfoViewController *weakSelf = self;
    NSArray *array = [_modelArray_like lastObject];
    DiscoverModel *model = [array lastObject];
    
    [[FreeSingleton sharedInstance] queryOtherLikeList:@"1" pageSize:@"10" postId:model.postId accountId:_friend_id block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
                NSArray *dataArray = [_dataSource_like arrayByAddingObjectsFromArray:data[@"items"]];
                _dataSource_like = [NSMutableArray arrayWithArray:dataArray];
                _modelArray_like = [NSMutableArray array];
                [weakSelf addSquareModel:_dataSource_like modelArray:_modelArray_like];
                [_mTableView reloadData];
            }
            else
            {
                [KVNProgress showErrorWithStatus:@"没有更多了"];
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:data];
        }
        [_mTableView footerEndRefreshing];
    }];
}

- (void)refreshPost
{
    __weak UserInfoViewController *weakSelf = self;
    NSArray *array = [_modelArray_post lastObject];
    DiscoverModel *model = [array lastObject];
    
    [[FreeSingleton sharedInstance] queryOtherPostList:@"1" pageSize:@"10" postId:model.postId accountId:_friend_id block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
                NSArray *dataArray = [_dataSource_post arrayByAddingObjectsFromArray:data[@"items"]];
                _dataSource_post = [NSMutableArray arrayWithArray:dataArray];
                _modelArray_post = [NSMutableArray array];
                [weakSelf addSquareModel:_dataSource_post modelArray:_modelArray_post];
                [_mTableView reloadData];
            }
            else
            {
                [KVNProgress showErrorWithStatus:@"没有更多了"];
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:data];
        }
        [_mTableView footerEndRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    _userTableHeader = [[[NSBundle mainBundle] loadNibNamed:@"UserInfoTableHeader"
                                                                      owner:self
                                                                    options:nil] objectAtIndex:0];
    [_userTableHeader.btn_suggest addTarget:self action:@selector(switch_to_left) forControlEvents:UIControlEventTouchDown];
    [_userTableHeader.btn_want addTarget:self action:@selector(switch_to_right) forControlEvents:UIControlEventTouchDown];
    if (_isRight) {
        [_userTableHeader.btn_suggest setTitleColor:FREE_LIGHT_GRAY_COLOR forState:UIControlStateNormal];
        [_userTableHeader.btn_want setTitleColor:FREE_LABEL_NAME_COLOR forState:UIControlStateNormal];
        _userTableHeader.btn_want.userInteractionEnabled = NO;
    }
    else
    {
        [_userTableHeader.btn_suggest setTitleColor:FREE_LABEL_NAME_COLOR forState:UIControlStateNormal];
        [_userTableHeader.btn_want setTitleColor:FREE_LIGHT_GRAY_COLOR forState:UIControlStateNormal];
        _userTableHeader.btn_suggest.userInteractionEnabled = NO;
    }
    
    _userTableHeader.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
    return _userTableHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isRight) {
        if ([_modelArray_like count]) {
            return [_modelArray_like count];
        }
        return 0;
    }
    else
    {
        if ([_modelArray_post count]) {
            return [_modelArray_post count];
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SquareTableViewCell *cell = [_mTableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[SquareTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    cell.discover_vc = self;
    if (_isRight) {
        cell.modelArray = _modelArray_like[indexPath.row];
    }
    else
    {
        cell.modelArray = _modelArray_post[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [UIScreen mainScreen].bounds.size.width/2 + 66 - 12 + 6;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 相关操作
- (void)switch_to_left
{
    if (_isRight) {
        _isRight = NO;
        [self.mTableView reloadData];
    }
}

- (void)switch_to_right
{
    if (!_isRight) {
        _isRight = YES;
        [self.mTableView reloadData];
    }
}

#pragma mark - 关注
- (void)btn_care_Tapped:(id)sender
{
    NSString *stauts = [NSString stringWithFormat:@"%d", CARE_ME];
    if ([_userInfoModel.status isEqual:stauts]) {
        [self addFollow];
    }
    else
    {
        [self cancelFollow];
    }
}

//取消关注
- (void)cancelFollow
{
    NSString *status = [NSString stringWithFormat:@"%d", CARE_ME];
    __weak UserInfoViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading"];
    NSInteger ret = [[FreeSingleton sharedInstance] sendIfConcern:_userInfoModel.relationId status:status block:^(NSUInteger retcode, id data) {
        [KVNProgress dismiss];
        if (retcode == RET_SERVER_SUCC) {
            _userInfoModel.status = [NSString stringWithFormat:@"%d", CARE_ME];
            _btn_care.titleLabel.text = @"添加关注";
            [_btn_care setTitle:@"添加关注" forState:UIControlStateNormal];
            _btn_more.hidden = YES;//隐藏右上角
            [weakSelf addAddressModel];
        }
        else
        {
            [KVNProgress showErrorWithStatus:data];
            NSLog(@"update status error is: %@", data);
        }
    }];
    
    if (ret != RET_OK) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:zcErrMsg(ret)];
        NSLog(@"update status error is: %@", zcErrMsg(ret));
    }
}

//添加关注
- (void)addFollow
{
    [KVNProgress showWithStatus:@"Loading"];
    
    NSInteger retcode = [[FreeSingleton sharedInstance] addFriendOnCompletion:_userInfoModel.accountId friendName:_userInfoModel.nickName pinyin:_userInfoModel.pinyin phoneNo:_userInfoModel.phoneNo headImg:_userInfoModel.headImg block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            _userInfoModel.status = [NSString stringWithFormat:@"%@", data[@"status"]];
            if ([_userInfoModel.status integerValue] == 1) {
                _btn_care.titleLabel.text = @"取消关注";
                [_btn_care setTitle:@"取消关注" forState:UIControlStateNormal];
            }
            else if ([_userInfoModel.status integerValue] == 3)
            {
                _btn_care.titleLabel.text = @"互相关注";
                [_btn_care setTitle:@"互相关注" forState:UIControlStateNormal];
            }
            _btn_more.hidden = NO;
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

//构建一个addressmodel进行修改
- (void)addAddressModel
{
    AddressListCellModel *model = [[AddressListCellModel alloc] init];
    model.img_url = _userInfoModel.headImg;
    model.user_name = _userInfoModel.nickName;
    model.friendId = _userInfoModel.accountId;
    model.Id = _userInfoModel.relationId;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    model.status = [numberFormatter numberFromString:_userInfoModel.status];
    model.phoneNo = _userInfoModel.phoneNo;
    model.pinyin = _userInfoModel.pinyin;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPDATE_MYCARE object:model];
}

#pragma mark - 右上角
- (void)moreInfo
{
    EditUserInfoTableViewController *vc = [[EditUserInfoTableViewController alloc] initWithNibName:@"EditUserInfoTableViewController" bundle:nil];
    
    vc.accountId = _userInfoModel.accountId;
    vc.friendName = _userInfoModel.nickName;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 发送消息
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
    chatViewController.title = _userInfoModel.nickName;
    chatViewController.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = self.navigationController;
    [navigationController popToRootViewControllerAnimated:NO];
    [navigationController pushViewController:chatViewController animated:YES];
    
    return;
}

@end
