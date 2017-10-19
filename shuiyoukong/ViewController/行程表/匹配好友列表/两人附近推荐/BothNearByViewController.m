//
//  BothNearByViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/9/15.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "BothNearByViewController.h"
#import "RCDChatViewController.h"
#import "SquareTableViewCell.h"
#import "FreeSingleton.h"
#import "FreeSQLite.h"

@interface BothNearByViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *btn_sendMessage;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (strong, nonatomic)NSMutableArray *modelArray;
@property (strong, nonatomic)NSMutableArray *dataSource;

@property (strong, nonatomic)UIImageView *notice_view;

@property (weak, nonatomic)NSString *identifier;

@end

@implementation BothNearByViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _identifier = @"SquareTableViewCell";
    [_mTableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    [self initView];
    [self initData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCOUNTName:) name:ZC_NOTIFICATION_UPDATE_UPDATE_COUNT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDianZanNum:) name:ZC_NOTIFICATION_UPDATE_DIANZAN object:nil];
    }
    return self;
}

- (void)updateDianZanNum:(NSNotification *)notification {
    DiscoverModel *model = notification.object;
    
    for (int i = 0; i < [_dataSource count]; i++) {
        NSString *str = [NSString stringWithFormat:@"%@", _dataSource[i][@"postId"]];
        if ([str isEqualToString:model.postId]) {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:_dataSource[i]];
            if (model.isUp) {
                dic[@"upOrDown"] = @"1";
            }
            else
            {
                dic[@"upOrDown"] = @"0";
            }
            dic[@"upCount"] = model.num;
            [_dataSource replaceObjectAtIndex:i withObject:dic];
            NSMutableArray *arrayObj = _modelArray[i/2];
            DiscoverModel *modelObj = arrayObj[i%2];
            modelObj.num = model.num;
            modelObj.isUp = model.isUp;
            [arrayObj replaceObjectAtIndex:i%2 withObject:modelObj];
            [_modelArray replaceObjectAtIndex:i/2 withObject:arrayObj];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i/2 inSection:0];
            [_mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            
            break;
        }
    }
}

- (void)updateCOUNTName:(NSNotification *)notification {
    NSArray *array = notification.object;
    NSString* postId = array[1];
    BOOL isUp = [array[2] boolValue];//是否点赞
    NSString *num = array[3];//点赞数量
    
    for (int i = 0; i < [_modelArray count]; i++) {
        NSMutableArray *arrayObj = _modelArray[i];
        for (int j = 0; j < [arrayObj count]; j++) {
            DiscoverModel *modelObj = arrayObj[j];
            if ([modelObj.postId isEqualToString:postId]) {
                
                modelObj.isUp = isUp;
                modelObj.num = num;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [_mTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                
                NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithDictionary:_dataSource[i]];
                dic[@"upOrDown"] = [NSString stringWithFormat:@"%d", modelObj.isUp];
                dic[@"upCount"] = modelObj.num;
                [_dataSource replaceObjectAtIndex:i withObject:dic];
                break;
            }
        }
    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.navigationItem.title = @"我和TA附近的推荐";
    _notice_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_both_nearby"]];
    
    _notice_view.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 90)/2, ([[UIScreen mainScreen] bounds].size.height - 239)/2 - 40, 90, 119);
    [self.view addSubview:_notice_view];
    _notice_view.hidden = YES;
    
    [_btn_sendMessage addTarget:self action:@selector(sendMessageToFriends:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initData
{
    [KVNProgress showWithStatus:@"Loading"];
    __weak BothNearByViewController *weakSelf = self;
    NSInteger retcode = [[FreeSingleton sharedInstance] bothNearBy:_accountId block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            if ([data count]) {
                _dataSource = [NSMutableArray arrayWithArray:data];
                _modelArray = [NSMutableArray array];
                [weakSelf addSquareModel:_dataSource modelArray:_modelArray];
                [_mTableView reloadData];
            }
            else
            {
                _notice_view.hidden = NO;
            }
        }
    }];
    
    if (retcode != RET_OK) {
        [KVNProgress showWithStatus:zcErrMsg(retcode)];
    }
}

#pragma mark - addModel
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

#pragma mark - sendMessage
- (void)sendMessageToFriends:(id)sender
{
    //创建会话
    RCDChatViewController *chatViewController = [[RCDChatViewController alloc] init];
    chatViewController.conversationType = ConversationType_PRIVATE;
    chatViewController.targetId = _accountId;
    chatViewController.title = _friendName;
    chatViewController.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = self.navigationController;
    [navigationController popToRootViewControllerAnimated:NO];
    [navigationController pushViewController:chatViewController animated:YES];
}

#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_modelArray count]) {
        return [_modelArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SquareTableViewCell *cell = [_mTableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[SquareTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    cell.discover_vc = self;
    cell.modelArray = _modelArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [UIScreen mainScreen].bounds.size.width/2 + 66 - 12 + 6;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
