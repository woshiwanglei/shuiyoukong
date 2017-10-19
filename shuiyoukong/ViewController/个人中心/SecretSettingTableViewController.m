//
//  SecretSettingTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/9/15.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SecretSettingTableViewController.h"
#import "TimeRemindTableViewCell.h"
#import "FreeSingleton.h"

@interface SecretSettingTableViewController ()
@property (nonatomic, weak) NSString *identifier;

@end

@implementation SecretSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _identifier = @"TimeRemindTableViewCell";
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -initView
- (void)initView
{
    self.navigationItem.title = @"隐私设置";
    
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    
    self.tableView.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, 100, 30)];
    [label setFont:[UIFont systemFontOfSize:16.f]];
    label.textColor = FREE_BLACK_COLOR;
    label.text = @"隐私设置";
    [headerView addSubview:label];
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TimeRemindTableViewCell *cell = (TimeRemindTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:_identifier];
    if (!cell) {
        cell = [[TimeRemindTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    
    if (![[FreeSingleton sharedInstance] getErDu]) {
        [cell.yesOrNo setOn:YES];
    }
    else
    {
        [cell.yesOrNo setOn:NO];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.yesOrNo addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    cell.label_name.text = @"开启我的二度人脉";
    return cell;
}

- (void)switchAction:(UISwitch *)swtich_btn
{
    [KVNProgress showWithStatus:@"Loading"];
    [[FreeSingleton sharedInstance] editErDu:YES block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            if (data) {
                NSString *erdu_tag = [NSString stringWithFormat:@"%@",data];
                [[NSUserDefaults standardUserDefaults] setObject:erdu_tag forKey:KEY_ERDU_TAG];
                [FreeSingleton sharedInstance].erdu = erdu_tag;
                if (![[FreeSingleton sharedInstance] getErDu]) {
                    [swtich_btn setOn:YES];
                }
                else
                {
                    [swtich_btn setOn:NO];
                }
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:data];
        }
    }];
}


@end
