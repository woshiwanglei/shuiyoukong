//
//  FreeTabBarViewController.m
//  Free
//
//  Created by 勇拓 李 on 15/4/29.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FreeTabBarViewController.h"
#import "Base64codeFunc.h"
#import "settings.h"
#import "FreeAddressBook.h"
#import "Utils.h"
#import "FreeSingleton.h"

@interface FreeTabBarViewController ()

@property (weak, nonatomic) NSString *status;
@property ABAddressBookRef addressBook;
@property BOOL isNew;//判断是否有新消息
@property BOOL isAddressListAlreadyChange;//判断通讯录是否改变

@end

@implementation FreeTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -注册和注销通知
- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ZC_NOTIFICATION_DID_LOGIN object:nil];
//        [self registerNotificationForUpdateAddressList];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteObserver:) name:ZC_NOTIFICATION_DELETE_OBSERVER object:nil];
    }
    return self;
}

- (void) dealloc
{
//    ABAddressBookUnregisterExternalChangeCallback(_addressBook, addressBookChanged, nil);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -init

- (void)initView
{
 
    self.delegate = self;
    
    for (int i = 0; i < 4; i++) {
        [self.tabBar.items[i] setTitleTextAttributes:@{ NSForegroundColorAttributeName:FREE_BLACK_COLOR}
                                            forState:UIControlStateNormal];
        [self.tabBar.items[i] setTitleTextAttributes:@{ NSForegroundColorAttributeName:FREE_BACKGOURND_COLOR}
                                            forState:UIControlStateSelected];
    }
    
    [self.tabBar.items[0] setImage:[[UIImage imageNamed:@"icon_discover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBar.items[0] setSelectedImage:[[UIImage imageNamed:@"icon_discover_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [self.tabBar.items[1] setImage:[[UIImage imageNamed:@"calendar.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBar.items[1] setSelectedImage:[[UIImage imageNamed:@"calendar_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_IF_HAS_NEW_FRIENDS]) {
//        [self.tabBar.items[2] setImage:[[UIImage imageNamed:@"address_listRed.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//    }
//    else
//    {
//        [self.tabBar.items[2] setImage:[[UIImage imageNamed:@"address_list.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//    }
//    [self.tabBar.items[2] setSelectedImage:[[UIImage imageNamed:@"address_list_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_IF_HAS_NEW_NOTICE])
    {
        [self.tabBar.items[2] setImage:[[UIImage imageNamed:@"message_new.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }
    else
    {
        [self.tabBar.items[2] setImage:[[UIImage imageNamed:@"message.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }
    [self.tabBar.items[2] setSelectedImage:[[UIImage imageNamed:@"message_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [self.tabBar.items[3] setImage:[[UIImage imageNamed:@"me.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [self.tabBar.items[3] setSelectedImage:[[UIImage imageNamed:@"me_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)initData
{
    _isNew = NO;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -TabBar
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController*)viewController
{
//    if(tabBarController.selectedIndex == 2)
//    {
//        [self.tabBar.items[2] setImage:[[UIImage imageNamed:@"address_list.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//    }
    return YES;
}

#pragma mark -通知
//- (void)registerNotificationForUpdateAddressList
//{
//    _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
//    
//    //注册通讯录更新回调
//    ABAddressBookRegisterExternalChangeCallback(_addressBook, addressBookChanged, (__bridge void *)(self));
//}
//
//void addressBookChanged(ABAddressBookRef addressBook, CFDictionaryRef info, void* context)
//{
//    FreeTabBarViewController *viewController = objc_unretainedObject(context);
//    [viewController updateAddressList];
//}

#pragma mark -通讯录更新
//- (void)updateAddressList
//{
//    if (_isAddressListAlreadyChange == YES) {
//        return;
//    }
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [FreeAddressBook updateData];
//    });
//    
//    _isAddressListAlreadyChange = YES;
//    
//}


@end