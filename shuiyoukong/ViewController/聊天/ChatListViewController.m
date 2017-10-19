//
//  ChatListViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/15.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ChatListViewController.h"
#import <QuartzCore/QuartzCore.h>
#pragma GCC diagnostic ignored "-Wundeclared-selector"
#import "RCDChatViewController.h"
#import "FreeSQLite.h"
#import "FreeSingleton.h"
#import "MessageCenterFatherTableViewController.h"

@interface ChatListViewController ()
@property (nonatomic, strong)UIButton *btn_notice;
@property (nonatomic,strong) RCConversationModel *tempModel;

- (void)updateBadgeValueForTabBarItem;

@end

@implementation ChatListViewController

/**
 *  此处使用storyboard初始化，代码初始化当前类时*****必须要设置会话类型和聚合类型*****
 *
 *  @param aDecoder aDecoder description
 *
 *  @return return value description
 */
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP),@(ConversationType_SYSTEM)]];
        
        //聚合会话类型
//        [self setCollectionConversationType:@[@(ConversationType_GROUP),@(ConversationType_DISCUSSION)]];
        [self setCollectionConversationType:@[@(ConversationType_DISCUSSION)]];
        //设置为不用默认渲染方式
        self.tabBarItem.image = [[UIImage imageNamed:@"icon_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_chat_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [self registerNoticeNew];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
    self.navigationItem.title = @"消息中心";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dic;
    
    //设置tableView样式
    self.conversationListTableView.tableFooterView = [UIView new];
    self.conversationListTableView.userInteractionEnabled = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initMessageCenter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_IF_HAS_NEW_NOTICE];//消除中心红点
    [self updateBadgeValueForTabBarItem];
    
}

//设置消息中心
- (void)initMessageCenter
{
    //初始化右上角
    if(!_btn_notice)
    {
        _btn_notice = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_btn_notice addTarget:self action:@selector(checkNotice) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:_btn_notice];
        self.navigationItem.rightBarButtonItem = backItem;
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_IF_HAS_NEW_COUPLE]) {
        [_btn_notice setImage:[UIImage imageNamed:@"lingdang_new"] forState:UIControlStateNormal];
    }
    else
    {
        [_btn_notice setImage:[UIImage imageNamed:@"lingdang"] forState:UIControlStateNormal];
    }
    
    [_btn_notice setImage:[UIImage imageNamed:@"dianjilingdao"] forState:UIControlStateHighlighted];
}

- (void)checkNotice
{
    [_btn_notice setImage:[UIImage imageNamed:@"lingdang"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_IF_HAS_NEW_COUPLE];
    MessageCenterFatherTableViewController *vc = [[MessageCenterFatherTableViewController alloc] initWithNibName:@"MessageCenterFatherTableViewController" bundle:nil];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updateBadgeValueForTabBarItem
{
    __weak typeof(self) __weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        int count = [[RCIMClient sharedRCIMClient] getUnreadCount:__weakSelf.displayConversationTypeArray];
        if (count > 0) {
            [__weakSelf.tabBarController.tabBar.items[2] setImage:[[UIImage imageNamed:@"message_new.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }
        else
        {
            [__weakSelf.tabBarController.tabBar.items[2] setImage:[[UIImage imageNamed:@"message.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }
    });
}


/**
 *  点击进入会话界面
 *
 *  @param conversationModelType 会话类型
 *  @param model                 会话数据
 *  @param indexPath             indexPath description
 */
-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
        RCDChatViewController *_conversationVC = [[RCDChatViewController alloc]init];
        _conversationVC.conversationType = model.conversationType;
        _conversationVC.targetId = model.targetId;
        _conversationVC.userName = model.conversationTitle;
        _conversationVC.title = model.conversationTitle;
        _conversationVC.conversation = model;
        _conversationVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:_conversationVC animated:YES];
    }
    
    if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION)
    {
        ChatListViewController *temp = [[ChatListViewController alloc] init];
        NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInt:model.conversationType]];
        [temp setDisplayConversationTypes:array];
        [temp setCollectionConversationType:nil];
        temp.isEnteredToCollectionViewController = YES;
        [self.navigationController pushViewController:temp animated:YES];
    }
}

- (void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [super willDisplayConversationTableCell:cell atIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
}

//左滑删除
-(void)rcConversationListTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    //[_myDataSource removeObject:model];
    [self.conversationListDataSource removeObjectAtIndex:indexPath.row];
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//高度
-(CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67.0f;
}

#pragma mark - 收到消息监听
-(void)didReceiveMessageNotification:(NSNotification *)notification
{
    __weak typeof(&*self) blockSelf_ = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //调用父类刷新未读消息数
        [super didReceiveMessageNotification:notification];
        [blockSelf_ resetConversationListBackgroundViewIfNeeded];
        [blockSelf_ updateBadgeValueForTabBarItem];
    });
}

#pragma mark - 消息监听
//新消息
- (void) registerNoticeNew {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newNoticeCome:) name:ZC_NOTIFICATION_NEW_NOTICE object:nil];
}

//上传通讯录
- (void) newNoticeCome:(NSNotification *) notification{
    [_btn_notice setImage:[UIImage imageNamed:@"lingdang_new"] forState:UIControlStateNormal];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IF_HAS_NEW_COUPLE];
}


@end
