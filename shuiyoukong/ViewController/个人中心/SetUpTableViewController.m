//
//  SetUpTableViewController.m
//  Free
//
//  Created by yangcong on 15/5/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SetUpTableViewController.h"
#import "TimeRemindTableViewCell.h"
#import "LookForMeTableViewCell.h"
#import "LeaveButtonTableViewCell.h"
#import "FreeSingleton.h"
#import "Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SecretSettingTableViewController.h"
#import "FristAccountManuTableViewController.h"

@interface SetUpTableViewController ()
@property (nonatomic, copy) NSString *identfiterOne;
@property (nonatomic, copy) NSString *identfiterThree;
@property (nonatomic, copy) NSString *identfiterFour;
@property (nonatomic, copy) NSString *tag;
@end

@implementation SetUpTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _identfiterOne = @"TimeRemindTableViewCell";
    _identfiterThree = @"LookForMeTableViewCell";
    _identfiterFour = @"LeaveButtonTableViewCell";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    self.tabBarController.tabBar.hidden = YES;
    [self.tableView registerNib:[UINib nibWithNibName:_identfiterOne bundle:nil] forCellReuseIdentifier:_identfiterOne];
    [self.tableView registerNib:[UINib nibWithNibName:_identfiterThree bundle:nil] forCellReuseIdentifier:_identfiterThree];
    [self.tableView registerNib:[UINib nibWithNibName:_identfiterFour bundle:nil] forCellReuseIdentifier:_identfiterFour];
     self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
    
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}
//设置Section的Header
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
        case 1:
            return @"";
            break;
        default:
            return @"";
            break;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 4;
        case 1:
            return 1;
        break;
            
        default:
             return 0;
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0.f;
    } 
    else if (section == 1)
    {
        return 30.f;
    }
    else {
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {    
   
    switch (indexPath.section) {
        case 0:
        case 1:
            return 50;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
         case 0:
        {
            if (indexPath.row == 0) {
                LookForMeTableViewCell *cell =(LookForMeTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:_identfiterThree];
                if (!cell) {
                    cell = [[LookForMeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identfiterThree];
                }
                cell.label_num.hidden = YES;
                cell.label_name.text = @"账号管理";
                return cell;
            }
            else if (indexPath.row == 1) {
                LookForMeTableViewCell *cell =(LookForMeTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:_identfiterThree];
                if (!cell) {
                    cell = [[LookForMeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identfiterThree];
                }
                cell.label_num.hidden = YES;
                cell.label_name.text = @"隐私设置";
                return cell;
            }
            else if (indexPath.row == 2) {
                LookForMeTableViewCell *cell3 =(LookForMeTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:_identfiterThree];
                if (!cell3) {
                    cell3 = [[LookForMeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identfiterThree];
                }
                cell3.label_num.hidden = YES;
                cell3.label_name.text = @"联系我们";
                return cell3;
            }
            else
            {
                LookForMeTableViewCell *cell3 =(LookForMeTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:_identfiterThree];
                if (!cell3) {
                    cell3 = [[LookForMeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identfiterThree];
                }
                float totalSize = [[SDImageCache sharedImageCache] getSize];
                totalSize = totalSize/1024.0/1024.0;
                
                NSString *clearCacheName = totalSize >= 1 ? [NSString stringWithFormat:@"已用缓存(%.2fM)",totalSize] : [NSString stringWithFormat:@"已用缓存(%.2fK)",totalSize * 1024];
                cell3.label_num.text = clearCacheName;
                cell3.label_name.text = @"清除缓存";
                cell3.label_num.hidden = NO;
                return cell3;
            }
        }
            break;
        default:
        {
            LeaveButtonTableViewCell *cell4 = (LeaveButtonTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:_identfiterFour];
            if (!cell4)
            {
                cell4 = [[LeaveButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identfiterFour];
            }
             [cell4.escButton addTarget:self action:@selector(escprogram) forControlEvents:UIControlEventTouchUpInside];
            
            return cell4;
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        //        [cell setSeparatorInset:UIEdgeInsetsZero];
        if(indexPath.section == 1)
        {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0)];
        }
        else
        {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
        }
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        if(indexPath.section == 1)
        {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0)];
        }
        else
        {
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 0)];
        }
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(void)escprogram
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"退出后下次需要重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.tag = 2;
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0)
    {
        if (alertView.tag == 2) {
            [self userLogout];
        }
        else
        {
            [self clearTmpPics];
        }
    }
}
- (void)userLogout
{
    __weak SetUpTableViewController *weakSelf = self;
    
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



- (void)delayMethodFailed
{
     dispatch_async(dispatch_get_main_queue(), ^{
    [KVNProgress showErrorWithStatus:@"登出失败" onView:[UIApplication sharedApplication].keyWindow];
                     });
}

- (void)delayMethodSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [KVNProgress showSuccessWithStatus:@"登出成功" onView:[UIApplication sharedApplication].keyWindow];
    });
}

- (void) jumpBack {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_NEED_LOGIN object:self userInfo:nil];
    
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

#pragma mark 清理缓存图片

//清除缓存图片
- (void)clearTmpPics
{
    
    [[SDImageCache sharedImageCache] clearDisk];
    
    [[SDImageCache sharedImageCache] clearMemory];//可有可无
    
    //    [[ZcSQLite sharedInstance] clearAllTable:db];//清除数据库表中的数据
    [self.tableView reloadData];
    NSLog(@"clear disk");
    [Utils warningUser:self msg:@"缓存清除成功"];
}

#pragma mark - 每行触发的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            FristAccountManuTableViewController *vc = [[FristAccountManuTableViewController alloc] initWithNibName:@"FristAccountManuTableViewController" bundle:nil];
            
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(indexPath.row == 1)
        {
            SecretSettingTableViewController *vc = [[SecretSettingTableViewController alloc] initWithNibName:@"SecretSettingTableViewController" bundle:nil];
            
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (indexPath.row == 2) {
            [self performSegueWithIdentifier:@"pushlookforme" sender:self];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清除缓存" message:@"确认要清除缓存吗?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            alert.tag = 1;
            [alert show];
        }

    }
    
}


@end
