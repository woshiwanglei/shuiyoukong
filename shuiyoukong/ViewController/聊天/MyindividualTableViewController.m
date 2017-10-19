//
//  MyindividualTableViewController.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/25.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MyindividualTableViewController.h"
#import "ShutTableViewCell.h"
#import "FreeSingleton.h"

@interface MyindividualTableViewController ()

@property (nonatomic,copy)NSString *indterfile;
@property (nonatomic,assign)BOOL isSucceed;
@property (nonatomic,assign)NSInteger num;
@property (nonatomic,strong)RCConversation *conversation;


@end

@implementation MyindividualTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}
-(void)initView
{
    self.navigationItem.title = @"设置";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    _indterfile = @"ShutTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_indterfile bundle:nil] forCellReuseIdentifier:_indterfile];
    _isSucceed = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)initData
{
    _conversation = [[RCIMClient sharedRCIMClient] getConversation:_IndividualType targetId:_IndividualId];
    
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:_IndividualType targetId:_IndividualId success:^(RCConversationNotificationStatus nStatus)
     {
         _num = nStatus;
         
         if (_num == DO_NOT_DISTURB)
         {
             _isSucceed = NO;
         }
         else
         {
             _isSucceed = YES;
         }
         
     } error:^(RCErrorCode status)
     {
         NSLog(@"获取失败");
     }];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.row == 0)
        {
            ShutTableViewCell *cell1 = [self.tableView dequeueReusableCellWithIdentifier:_indterfile forIndexPath:indexPath];
            if (!cell1)
            {
                cell1 = [[ShutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_indterfile];
            }
            cell1.cellName.text = @"置顶聊天";
            
            [cell1.cellSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
            
            if (_conversation.isTop == YES)
            {
                cell1.cellSwitch.on = YES;
            }
            else
            {
                cell1.cellSwitch.on = NO;
            }
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell1;
        }
        else if(indexPath.row == 1)
        {
            ShutTableViewCell *cell2 = [self.tableView dequeueReusableCellWithIdentifier:_indterfile forIndexPath:indexPath];
            if (!cell2)
            {
                cell2 = [[ShutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_indterfile];
            }
            cell2.cellName.text = @"新消息通知";
            
            [cell2.cellSwitch addTarget:self action:@selector(newsSwitchChange:) forControlEvents:UIControlEventValueChanged];
            if (_isSucceed)
            {
                cell2.cellSwitch.on = YES;
            }
            else
            {
                cell2.cellSwitch.on = NO;
            }
            cell2.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell2;
        }
        else
        {
            ShutTableViewCell *cell3= [self.tableView dequeueReusableCellWithIdentifier:_indterfile forIndexPath:indexPath];
            if (!cell3)
            {
                cell3 = [[ShutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_indterfile];
            }
            cell3.cellName.text = @"清除聊天记录";
            cell3.cellSwitch.hidden = YES;
            
            return cell3;
        }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}

-(void)switchChange:(UISwitch *)witch
{
    _conversation.isTop = !_conversation.isTop;
    BOOL isconver = _conversation.isTop;
    
    [[RCIMClient sharedRCIMClient] setConversationToTop:_IndividualType targetId:_IndividualId isTop:isconver];
}
-(void)newsSwitchChange:(UISwitch *)witch
{
    [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:_IndividualType targetId:_IndividualId isBlocked:_isSucceed success:^(RCConversationNotificationStatus nStatus)
     {
         NSLog(@"%lu", (unsigned long)nStatus);
     } error:^(RCErrorCode status) {
         NSLog(@"失败");
     }];
}
#pragma mark - 每行触发的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 2)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"是否清除聊天记录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
    
}

#pragma mark-UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[RCIMClient sharedRCIMClient] clearMessages:_IndividualType targetId:_IndividualId];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DID_INDIVIDUALDELETE object:self userInfo:nil];
    }
}

@end
