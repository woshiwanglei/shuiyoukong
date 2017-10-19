//
//  RCDChatViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/15.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "RCDChatViewController.h"
#import "FreeSingleton.h"
#import "FreeSQLite.h"
#import "UserInfoViewController.h"
#import "MyindividualTableViewController.h"
#import "ActivityTableViewController.h"
#import "FreeImagePreviewController.h"
#import "FreeLocationPickerViewController.h"
#import "FreeMapViewController.h"

@interface RCDChatViewController ()

@end

@implementation RCDChatViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.pluginBoardView removeItemWithTag:1003];
    [self.pluginBoardView removeItemWithTag:1004];
    [self.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"place2x"]
                                        title:@"位置"
                                          tag:1999];
    [self registerNotificationFordelete];
    [self registerNotificationForIndividualdelete];
    
    self.enableSaveNewPhotoToLocalSystem = YES;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [btn addTarget:self action:@selector(rightBarButtonItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.conversationType == ConversationType_GROUP) {

//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
//                                                  initWithImage:[UIImage imageNamed:@"chat_group"]
//                                                  style:UIBarButtonItemStylePlain
//                                                  target:self
//                                                  action:@selector(rightBarButtonItemClicked:)];
        [btn setImage:[UIImage imageNamed:@"chat_group"] forState:UIControlStateNormal];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = backItem;
    }
    else if(self.conversationType == ConversationType_PRIVATE)
    {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
//                                                  initWithImage:[UIImage imageNamed:@"chat_private"]
//                                                  style:UIBarButtonItemStylePlain
//                                                  target:self
//                                                  action:@selector(rightBarButtonItemClicked:)];
        [btn setImage:[UIImage imageNamed:@"chat_private"] forState:UIControlStateNormal];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = backItem;
        [self.pluginBoardView removeItemAtIndex:3];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self notifyUpdateUnreadMessageCount];
    /***********如何自定义面板功能***********************
     自定义面板功能首先要继承RCConversationViewController，如现在所在的这个文件。
     然后在viewDidLoad函数的super函数之后去编辑按钮：
     插入到指定位置的方法如下：
     [self.pluginBoardView insertItemWithImage:imagePic
     title:title
     atIndex:0
     tag:101];
     或添加到最后的：
     [self.pluginBoardView insertItemWithImage:imagePic
     title:title
     tag:101];
     删除指定位置的方法：
     [self.pluginBoardView removeItemAtIndex:0];
     删除指定标签的方法：
     [self.pluginBoardView removeItemWithTag:101];
     删除所有：
     [self.pluginBoardView removeAllItems];
     更换现有扩展项的图标和标题:
     [self.pluginBoardView updateItemAtIndex:0 image:newImage title:newTitle];
     或者根据tag来更换
     [self.pluginBoardView updateItemWithTag:101 image:newImage title:newTitle];
     以上所有的接口都在RCPluginBoardView.h可以查到。
     
     当编辑完扩展功能后，下一步就是要实现对扩展功能事件的处理，放开被注掉的函数
     pluginBoardView:clickedItemWithTag:
     在super之后加上自己的处理。
     
     */
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
}

- (void)leftBarButtonItemPressed:(id)sender {
    
    //需要调用super的实现
    [super leftBarButtonItemPressed:sender];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *  此处使用自定义设置，开发者可以根据需求自己实现
 *  不添加rightBarButtonItemClicked事件，则使用默认实现。
 */

- (void)rightBarButtonItemClicked:(id)sender {
    
    if (self.conversationType == ConversationType_GROUP) {

        ActivityTableViewController *settingVC =
        [[ActivityTableViewController alloc] initWithNibName:@"ActivityTableViewController" bundle:nil];
        settingVC.activityType = self.conversationType;
        settingVC.activityId = self.targetId;
        settingVC.titileName = self.navigationItem.title;
        
        
//        settingVC.conversationTitle = self.userName;
        //设置讨论组标题时，改变当前聊天界面的标题
//        settingVC.setDiscussTitleCompletion = ^(NSString *discussTitle) {
//            self.title = discussTitle;
//            self.userName = discussTitle;
//        };
        
//     //   清除聊天记录之后reload data
//           __weak RCDChatViewController *weakSelf = self;
//        settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
//            if (isSuccess) {
//                [weakSelf.conversationDataRepository removeAllObjects];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf.conversationMessageCollectionView reloadData];
//                });
//            }
//      };
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    else if(self.conversationType == ConversationType_PRIVATE)
    {
        
        MyindividualTableViewController *myindivideual = [[MyindividualTableViewController alloc] initWithNibName:@"MyindividualTableViewController" bundle:nil];
        myindivideual.IndividualType = self.conversationType;
        myindivideual.IndividualId = self.targetId;
        
        [self.navigationController pushViewController:myindivideual animated:YES];
        
    }
    else
    {
        
    }
    
}

/**
 *  打开大图。开发者可以重写，自己下载并且展示图片。默认使用内置controller
 *
 *  @param imageMessageContent 图片消息内容
 */
- (void)presentImagePreviewController:(RCMessageModel *)model;
{
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZC_NOTIFICATION_NEED_DELETE_NOTIFICATION];
    
    FreeImagePreviewController *_imagePreviewVC =
    [[FreeImagePreviewController alloc] init];
    _imagePreviewVC.messageModel = model;
    _imagePreviewVC.title = @"图片预览";
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:_imagePreviewVC];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)presentLocationViewController:(RCLocationMessage *)locationMessageContent
{
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZC_NOTIFICATION_NEED_DELETE_NOTIFICATION];
    
    FreeMapViewController *vc = [[FreeMapViewController alloc] initWithNibName:@"FreeMapViewController" bundle:nil];
    
    vc.location = locationMessageContent.location;
    vc.locationName = locationMessageContent.locationName;
    
    UINavigationController *nav = [[UINavigationController alloc]
                                   initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didLongTouchMessageCell:(RCMessageModel *)model inView:(UIView *)view {
    [super didLongTouchMessageCell:model inView:view];
    NSLog(@"%s", __FUNCTION__);
}


/**
 *  更新左上角未读消息数
 */
- (void)notifyUpdateUnreadMessageCount {
    int count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                @(ConversationType_PRIVATE),
                                                                @(ConversationType_DISCUSSION),
                                                                @(ConversationType_APPSERVICE),
                                                                @(ConversationType_CUSTOMERSERVICE),
                                                                @(ConversationType_GROUP)
                                                                ]];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *backString = nil;
        if (count > 0 && count < 1000) {
            backString = [NSString stringWithFormat:@"返回(%d)", count];
        } else if (count >= 1000) {
            backString = @"返回(...)";
        } else {
            backString = @"返回";
        }
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        [backItem setTintColor:[UIColor whiteColor]];
        backItem.title = @" ";
        self.navigationItem.backBarButtonItem = backItem;
        
        NSDictionary *dic = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        self.navigationController.navigationBar.titleTextAttributes = dic;
        

    });
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage
{
    //保存图片
    UIImage *image = newImage;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // bug fixes: UIIMagePickerController使用中偷换StatusBar颜色的问题
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}


//- (void)locationPicker:(RCLocationPickerViewController *)locationPicker didSelectLocation:(CLLocationCoordinate2D)location locationName:(NSString *)locationName mapScreenShot:(UIImage *)mapScreenShot
//{
//    
//}

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag{
    [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
    switch (tag)
    {
        case 1999:
        {
            FreeLocationPickerViewController *free = [[FreeLocationPickerViewController alloc] init];
            free.delegate = self;
            [self.navigationController pushViewController:free animated:YES];
            
        }
            break;
//        case PLUGIN_BOARD_ITEM_ALBUM_TAG:
//        {
//            UIImagePickerController *ipc = [[UIImagePickerController alloc]init];
//            [ipc setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//            ipc.delegate = self;
//            //编辑
//            //    ipc.allowsEditing = YES;
//            [self presentViewController:ipc animated:YES completion:nil];
//        }
        default:
            break;
    }
    
    
    
    
    
//    if(tag == PLUGIN_BOARD_ITEM_LOCATION_TAG){
//            //这里加你自己的事件处理
//        [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
//    
//        }
////    else
////    {
////        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ZC_NOTIFICATION_NEED_DELETE_NOTIFICATION];
////    }

}

#pragma mark - 地图delegate
//-(void)locationPicker:(RCLocationPickerViewController *)locationPicker didSelectLocation:(CLLocationCoordinate2D)location locationName:(NSString *)locationName mapScreenShot:(UIImage *)mapScreenShot
//{
//    RCLocationMessageCell *cell = [[RCLocationMessageCell alloc] init];
//    cell.pictureView.image = mapScreenShot;
//}

#pragma mark -头像点击事件
- (void)didTapCellPortrait:(NSString *)userId
{
    NSString *str = [NSString stringWithFormat:@"%@", [[FreeSingleton sharedInstance] getAccountId]];
    
    if ([userId isEqual:str]) {
        return;
    }
    
    if ([userId isEqual:SERVICE_ID]) {
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main"
                                                 bundle:nil];
    UserInfoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UserInfoViewController"];
    vc.friend_id = userId;
    NSString *name = [[FreeSQLite sharedInstance] selectFreeSQLiteFriendName:userId];
    vc.friend_name = name;
    vc.hidesBottomBarWhenPushed = YES;
    UINavigationController *navigationController = self.navigationController;
    [navigationController pushViewController:vc animated:YES];
}
-(void)registerNotificationForIndividualdelete
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IndividualdeleteDidChange:) name:ZC_NOTIFICATION_DID_INDIVIDUALDELETE  object:nil];
}
-(void)IndividualdeleteDidChange:(NSNotification *)notification
{
    [self.conversationDataRepository removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationMessageCollectionView reloadData];
    });
}

-(void)registerNotificationFordelete
{
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteDidChange:) name:ZC_NOTIFICATION_DID_DELETE  object:nil];
}
-(void)deleteDidChange:(NSNotification *) notification
{
    [self.conversationDataRepository removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationMessageCollectionView reloadData];
    });
}
@end