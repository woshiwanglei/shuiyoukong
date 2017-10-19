//
//  AddressBookTableViewController.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/5/26.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "AddressBookTableViewController.h"

#import "AddressListTableViewCell.h"
#import "FreeSQLite.h"
#import "FreeSingleton.h"
#import "FreeAddressBook.h"

@interface AddressBookTableViewController ()

@property (nonatomic,weak) NSString* identifier_already;
@property (nonatomic,weak) NSString* identifier_not_yet;

@property (nonatomic, strong)NSMutableArray *modelArray;

@end

@implementation AddressBookTableViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    _identifier_already = @"AddressListTableViewCell";
    
    [self initData];
    [self initView];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerNotificationForAddressList];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initView
{
    //cell添加
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_already bundle:nil] forCellReuseIdentifier:_identifier_already];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    [self.navigationItem setHidesBackButton:YES];
}
- (void)initData
{
    _modelArray = [NSMutableArray array];
    //上传通讯录
    [FreeAddressBook initAddressList:_modelArray];
}

//下一步 跳转页面的操作
- (IBAction)sendAddressBook:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"pushaddressbook" sender:self];
    
    [[FreeSingleton sharedInstance] getUserInfoOnCompletion:^(NSUInteger ret, id data){
        if (ret == RET_SERVER_SUCC) {
        if (data) {
            if (![data[@"id"] isKindOfClass:[NSNull class]]) {
                [FreeSingleton sharedInstance].accountId = [NSString stringWithFormat:@"%@", data[@"id"]];
                [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].accountId forKey:KEY_ACCOUNT_ID];
            } else {
                NSLog(@"ID为空");
            }
            if (![data[@"phoneNo"] isKindOfClass:[NSNull class]]) {
                [FreeSingleton sharedInstance].phoneNo = data[@"phoneNo"];
                [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"phoneNo"] forKey:KEY_PHONE_NO];
            } else {
                NSLog(@"PhoneNo为空");
            }
            if (![data[@"nickName"] isKindOfClass:[NSNull class]]) {
                [FreeSingleton sharedInstance].nickName = data[@"nickName"];
                [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"nickName"] forKey:KEY_NICK_NAME];
            } else {
                NSLog(@"昵称为空");
            }
            
            if (![data[@"status"] isKindOfClass:[NSNull class]]) {
                [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"status"] forKey:KEY_USER_STATUS];
                [FreeSingleton sharedInstance].status = data[@"status"];
            } else {
                NSLog(@"状态为空");
            }
            
            if (![data[@"headImg"] isKindOfClass:[NSNull class]]) {
                [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"headImg"] forKey:KEY_HEAD_IMG_URL];
                [FreeSingleton sharedInstance].head_img = data[@"headImg"];
                
            }//未加判空告警
            
            if (![data[@"gender"] isKindOfClass:[NSNull class]]) {
                [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"gender"] forKey:KEY_GENDER];
                [FreeSingleton sharedInstance].gender = data[@"gender"];
            }
            else
            {
                NSLog(@"性别为空");
            }
            
            if (![data[@"tagList"] isKindOfClass:[NSNull class]]) {
                [[NSUserDefaults standardUserDefaults] setObject:[data mutableCopy][@"tagList"] forKey:KEY_LABLE_NUM];
                [FreeSingleton sharedInstance].lableArray = data[@"tagList"];
            }
            
            if (![data[@"level"] isKindOfClass:[NSNull class]]) {
                [FreeSingleton sharedInstance].level = data[@"level"];
                [[NSUserDefaults standardUserDefaults] setObject:data[@"level"] forKey:KEY_LEVEL];
            } else {
                NSLog(@"Lv为空");
            }
            
            if (![data[@"point"] isKindOfClass:[NSNull class]]) {
                [FreeSingleton sharedInstance].point = [NSString stringWithFormat:@"%@", data[@"point"]];
                [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].point forKey:KEY_POINT];
            } else {
                NSLog(@"point为空");
            }
            
            if (![data[@"followNum"] isKindOfClass:[NSNull class]]) {
                [FreeSingleton sharedInstance].my_Followed_Num = [NSString stringWithFormat:@"%@", data[@"followNum"]];
                [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].my_Followed_Num forKey:KEY_FOLLOWED_NUM];
            }
            else
            {
                NSLog(@"关注为空");
            }
            
            if (![data[@"followerNum"] isKindOfClass:[NSNull class]]) {
                [FreeSingleton sharedInstance].my_Follower_Num = [NSString stringWithFormat:@"%@", data[@"followerNum"]];
                [[NSUserDefaults standardUserDefaults] setObject:[FreeSingleton sharedInstance].my_Follower_Num forKey:KEY_FOLLOWER_NUM];
            }
            else
            {
                NSLog(@"关注者为空");
            }
            
        }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_modelArray count])
        return [_modelArray count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddressListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier_already forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[AddressListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_already];
    }
    cell.model = _modelArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.f + 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50.f + 1;
    return 50.f + 1;
}


#pragma mark 注册通知
//上传通讯录
- (void) registerNotificationForAddressList {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressListUpload:) name:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:nil];
}

//上传通讯录
- (void) addressListUpload:(NSNotification *) notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        //已加入的好友
        [self.tableView reloadData];
    });
}

@end
