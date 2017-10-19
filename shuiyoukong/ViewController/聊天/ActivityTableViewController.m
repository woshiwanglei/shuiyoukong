//
//  ActivityTableViewController.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ActivityTableViewController.h"
#import "ShutTableViewCell.h"
#import "FreeSingleton.h"
#import "RootTableViewCell.h"
#import "RCDChatViewController.h"
#import "UserAllTableViewCell.h"
#import "ChangeNameViewController.h"
#import "ActivityInfoViewController.h"
#import "personnelView.h"
#import "Crowdmodel.h"

@interface ActivityTableViewController ()

@property (nonatomic,copy)NSString *identerfile;
@property (nonatomic,copy)NSString *identerfileRoot;
@property (nonatomic,strong)NSString *identerfileallcrowd;
@property (nonatomic,strong)RCConversation *converstation;
@property (nonatomic,assign)NSInteger number;
@property (nonatomic,assign)BOOL isstatus;
@property (nonatomic,strong)NSMutableArray *crowdArry;
@property (nonatomic,strong)Crowdmodel *model;
@property (nonatomic,strong)NSString *promoteId;

@property (nonatomic,strong)UIActionSheet *sheet;
@property (nonatomic,copy)NSString *actiyId;
@end

@implementation ActivityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (void)initData
{
    _converstation = [[RCIMClient sharedRCIMClient] getConversation:_activityType targetId:_activityId];
    [KVNProgress showWithStatus:@"Loading"];
    [[FreeSingleton sharedInstance] getcrowdInfoOncompetion:_activityId block:^(NSUInteger ret, id data)
     {
         if (ret == RET_SERVER_SUCC)
         {
             _promoteId = [NSString stringWithFormat:@"%@", data[@"promoteId"]];
             _model = [[Crowdmodel alloc] init];
             [_model initWithDic:(NSDictionary*)data];
             _actiyId = [NSString stringWithFormat:@"%@",data[@"activityId"]];
             [self.tableView reloadData];
             
         }
         [KVNProgress dismiss];
     }];
    
    [[RCIMClient sharedRCIMClient] getConversationNotificationStatus:_activityType targetId:_activityId success:^(RCConversationNotificationStatus nStatus)
     {
         _number = nStatus;
         
         if (_number == DO_NOT_DISTURB)
         {
             _isstatus = NO;
         }
         else
         {
             _isstatus = YES;
         }
         
     } error:^(RCErrorCode status)
     {
         NSLog(@"获取失败");
     }];
}


-(void)initView
{
    self.navigationItem.title = @"设置";
    _identerfile = @"ShutTableViewCell";
    _identerfileRoot = @"RootTableViewCell";
    _identerfileallcrowd = @"UserAllTableViewCell";
    _isstatus = YES;
    
    _crowdArry = [NSMutableArray array];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    [self.tableView registerNib:[UINib nibWithNibName:_identerfile bundle:nil] forCellReuseIdentifier:_identerfile];
    [self.tableView registerNib:[UINib nibWithNibName:_identerfileRoot bundle:nil] forCellReuseIdentifier:_identerfileRoot];
    [self.tableView registerNib:[UINib nibWithNibName:_identerfileallcrowd bundle:nil] forCellReuseIdentifier:_identerfileallcrowd];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45)];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width - 50, 45)];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 6.0;
    [button setBackgroundColor:[UIColor redColor]];
    [button setTitle:@"退出群聊" forState:UIControlStateNormal];
    [button setCenter:CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2)];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    self.tableView.tableFooterView = view;
    self.tableView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0  blue:245.0/255.0  alpha:1.0];
}
-(void)buttonAction:(UIButton*)sender{
    _sheet = [[UIActionSheet alloc] initWithTitle:@"确定要退出群聊吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
    [_sheet showInView:self.view];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
          break;
        case 1:
            return 4;
          break;
         case 2:
            return 0;
            break;
        default:
             return 0;
            break;
    }
   
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1.0f;
    }
    else if (section == 2)
    {
        return 25.0f;
    }
    else
    {
        return 15.0f;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            if (_model)
            {
                return  [UserAllTableViewCell cellHeight:_model];
            }
            return 100;
            break;
        case 1:
            return 50.0;
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
            UserAllTableViewCell *cell1 = [self.tableView dequeueReusableCellWithIdentifier:_identerfileallcrowd forIndexPath:indexPath];
            if (!cell1) {
                cell1 = [[UserAllTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identerfileallcrowd];
            }
            
            if (_model)
            {
               cell1.model = _model;
            }
            return cell1;
        }
            break;
            
        default:
        {
//            if (indexPath.row == 0)
//            {
////                RootTableViewCell *cell2 = [self.tableView dequeueReusableCellWithIdentifier:_identerfileRoot forIndexPath:indexPath];
////                if (!cell2) {
////                    cell2 = [[RootTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identerfileRoot];
////                }
////                cell2.crowdName.text = @"群组名称";
////                cell2.selectionStyle = UITableViewCellSelectionStyleNone;
////                cell2.namecrow.text = _titileName;
////                return cell2;
            //}

            if(indexPath.row == 0)
            {
                RootTableViewCell *cellbtn = [self.tableView dequeueReusableCellWithIdentifier:_identerfileRoot forIndexPath:indexPath];
                if (!cellbtn) {
                    cellbtn = [[RootTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identerfileRoot];
                }
                cellbtn.crowdName.text = @"活动详情";
                cellbtn.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cellbtn.namecrow.hidden = YES;
                return cellbtn;
            }
           else if(indexPath.row == 1)
           {
               ShutTableViewCell *cell3 = [self.tableView dequeueReusableCellWithIdentifier:_identerfile forIndexPath:indexPath];
               
               if (!cell3)
               {
                   cell3 = [[ShutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identerfile];
               }
               cell3.cellName.text = @"置顶聊天";
               [cell3.cellSwitch addTarget:self action:@selector(switchincident:) forControlEvents:UIControlEventValueChanged];
               if (_converstation.isTop)
               {
                   cell3.cellSwitch.on = YES;
               }
               else
               {
                   cell3.cellSwitch.on = NO;
               }
               cell3.selectionStyle = UITableViewCellSelectionStyleNone;
               return cell3;
           }
           else if(indexPath.row == 2)
           {
               ShutTableViewCell *cell4 = [self.tableView dequeueReusableCellWithIdentifier:_identerfile forIndexPath:indexPath];
               cell4.cellName.text = @"新消息通知";
               
               if (!cell4)
               {
                   cell4 = [[ShutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identerfile];
               }
               if (_isstatus)
               {
                   cell4.cellSwitch.on = YES;
               }
               else
               {
                   cell4.cellSwitch.on = NO;
               }
               cell4.selectionStyle = UITableViewCellSelectionStyleNone;
               [cell4.cellSwitch addTarget:self action:@selector(newsincident:) forControlEvents:UIControlEventValueChanged];
               return cell4;
           }
           else
           {
               ShutTableViewCell *cell5 = [self.tableView dequeueReusableCellWithIdentifier:_identerfile forIndexPath:indexPath];
               if (!cell5)
               {
                   cell5 = [[ShutTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identerfile];
               }
               cell5.cellName.text = @"清除聊天记录";
               cell5.cellSwitch.hidden = YES;
               return cell5;
           }
           
        }
            break;
    }
}

-(void)switchincident:(UISwitch *)sender
{
    _converstation.isTop = !_converstation.isTop;
    BOOL isconver = _converstation.isTop;

    [[RCIMClient sharedRCIMClient] setConversationToTop:_activityType targetId:_activityId isTop:isconver];

}
-(void)newsincident:(UISwitch *)sender
{

        [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:_activityType targetId:_activityId isBlocked:_isstatus success:^(RCConversationNotificationStatus nStatus) {
            NSLog(@"%lu", (unsigned long)nStatus);
        } error:^(RCErrorCode status) {
             NSLog(@"失败");
        }];
   
}
#pragma mark - 每行触发的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1)
    {
        
//        if (indexPath.row == 0)
//        {
//            ChangeNameViewController *changeName = [[ChangeNameViewController alloc] initWithNibName:@"ChangeNameViewController" bundle:nil];
//            
//            [self.navigationController pushViewController:changeName animated:YES];
//        }
        
        if (indexPath.row == 0)
        {
            
            if (_actiyId != nil)
            {
                ActivityInfoViewController *vc = [[ActivityInfoViewController alloc] initWithNibName:@"ActivityInfoViewController" bundle:nil];
                vc.activityId = _actiyId ;
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }
        
        else if (indexPath.row == 3)
        {
          UIActionSheet   *actionsheet = [[UIActionSheet alloc] initWithTitle:@"是否清除聊天记录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
            [actionsheet showInView:self.view];
        }
      
    }
    
}

#pragma mark-UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet == _sheet)
    {
        if (0 == buttonIndex) {
            
            [self exitGroup];
        }
    }
    else
    {
        if(0 == buttonIndex)
        {
            [[RCIMClient sharedRCIMClient] clearMessages:_activityType targetId:_activityId];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DID_DELETE object:self userInfo:nil];
        }
    }
}

//退群
- (void)exitGroup
{
    __weak typeof(&*self)  weakSelf = self;
    
    [[FreeSingleton sharedInstance] quitGroupOnCompletion:_activityId block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            
            [[RCIMClient sharedRCIMClient] quitGroup:_activityId success:^{
                NSLog(@"退出群聊成功");
                [[FreeSingleton sharedInstance] syncGroups:^(NSUInteger ret, id data) {
                }];
                UIViewController *temp = nil;
                NSArray *viewControllers = weakSelf.navigationController.viewControllers;
                temp = viewControllers[viewControllers.count -1 -2];
                if (temp) {
                    //切换主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController popToViewController:temp animated:YES];
                    });
                }
            } error:^(RCErrorCode status) {
                [KVNProgress showErrorWithStatus:@"退出群聊失败"];
                NSLog(@"退出群聊失败");
            }];
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"退出群聊失败"];
            NSLog(@"退出群聊失败");
        }
    }];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
