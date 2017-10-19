//
//  FristAccountManuTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/9/21.
//  Copyright © 2015年 知春. All rights reserved.
//

#import "FristAccountManuTableViewController.h"
#import "LookForMeTableViewCell.h"
#import "FreeSingleton.h"
#import "AccountManageViewController.h"

@interface FristAccountManuTableViewController ()
@property (nonatomic, weak)NSString *identifier;

@end

@implementation FristAccountManuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _identifier = @"LookForMeTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindPhoneNo:) name:FREE_NOTIFICATION_BIND_PHONENO object:nil];
    }
    return self;
}

- (void)bindPhoneNo:(NSNotification*) notification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - initView
- (void)initView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
    self.navigationItem.title = @"账号管理";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LookForMeTableViewCell *cell3 = (LookForMeTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:_identifier];
    if (!cell3) {
        cell3 = [[LookForMeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    
    
    switch (indexPath.row) {
        case 0:
        {
            if ([[FreeSingleton sharedInstance] getPhoneNo] && [[FreeSingleton sharedInstance] isMobileNo:[[FreeSingleton sharedInstance] getPhoneNo]]) {
                cell3.label_num.text = [[FreeSingleton sharedInstance] getPhoneNo];
            }
            else
            {
                cell3.label_num.text = @"立即绑定";
            }
            
            cell3.label_name.text = @"绑定手机号";
        }
            break;
        default:
        {
            cell3.label_name.text = @"登陆方式";
            if ([[FreeSingleton sharedInstance] getType]) {
                NSInteger type = [[[FreeSingleton sharedInstance] getType] integerValue];
                switch (type) {
                    case 0:
                        cell3.label_num.text = @"谁有空";
                        break;
                    case 1:
                        cell3.label_num.text = @"微信登陆";
                        break;
                    case 2:
                        cell3.label_num.text = @"QQ登陆";
                        break;
                    default:
                        cell3.label_num.text = @"新浪微博登陆";
                        break;
                }
            }
        }
            break;
    }
    
    cell3.label_num.hidden = NO;
    return cell3;
}

#pragma mark - 每行触发的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            if ([[FreeSingleton sharedInstance] getPhoneNo] && [[FreeSingleton sharedInstance] isMobileNo:[[FreeSingleton sharedInstance] getPhoneNo]]) {
                
                [Utils warningUser:self msg:@"已经成功绑定了手机号"];
            }
            else
            {
                AccountManageViewController *vc = [[AccountManageViewController alloc] initWithNibName:@"AccountManageViewController" bundle:nil];
                
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        default:
        {
            NSInteger type = [[[FreeSingleton sharedInstance] getType] integerValue];
            if (type) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"解除绑定" message:@"确认要解除绑定吗?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                [alert show];
            }
        }
            break;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0)
    {
        [self userLogout];
    }
}

- (void)userLogout
{
    __weak FristAccountManuTableViewController *weakSelf = self;
    
    NSInteger ret = [[FreeSingleton sharedInstance] userLoginOutCompletion:^(NSUInteger retcode, id data) {
        
        if (retcode == RET_SERVER_SUCC)
        {
            [self performSelector:@selector(delayMethodSuccess) withObject:nil afterDelay:0.4];
            
        } else {
            [self performSelector:@selector(delayMethodFailed) withObject:nil afterDelay:0.4];
        }
        [weakSelf removeUserInfo];
        [[RCIMClient sharedRCIMClient] disconnect:NO];
        [[RCIMClient sharedRCIMClient] logout];
        [weakSelf jumpBack];
        
    }];
    
    if (ret != RET_OK) {
        [Utils warningUser:self msg:zcErrMsg(ret)];
    }
}

#pragma mark 删除用户消息
- (void)removeUserInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_ACCOUNT_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_NICK_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_USER_STATUS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_HEAD_IMG_URL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_GENDER];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_FOLLOWED_NUM];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_FOLLOWER_NUM];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_INVITE_CODE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_LEVEL];
    
    [FreeSingleton sharedInstance].head_img = nil;
}

- (void) jumpBack {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEED_LOGIN object:self userInfo:nil];
    
}

- (void)delayMethodFailed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress showSuccessWithStatus:@"解绑成功" onView:[UIApplication sharedApplication].keyWindow];
    });
}

- (void)delayMethodSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress showSuccessWithStatus:@"解绑成功" onView:[UIApplication sharedApplication].keyWindow];
    });
}

@end
