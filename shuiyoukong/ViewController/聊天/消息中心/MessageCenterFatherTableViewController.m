//
//  MessageCenterFatherTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "MessageCenterFatherTableViewController.h"
#import "MessageFatherCenterTableViewCell.h"
#import "MessageCenterTableViewController.h"
#import "settings.h"

@interface MessageCenterFatherTableViewController ()

@property (nonatomic, weak)NSString *identifier;

@end

@implementation MessageCenterFatherTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newNoticeCome:) name:FREE_NOTIFICATION_NEW_NOTICE object:nil];
    }
    
    return self;
}

- (void)newNoticeCome:(NSNotification *)notification
{
    NSString *typeStr = notification.object;
    NSInteger row = 0;
    if ([typeStr isEqualToString:KEY_IS_HAS_NEW_OFFICIAL])
    {
        row = 0;
    }
    else if ([typeStr isEqualToString:KEY_IS_HAS_NEW_COMMENT])
    {
        row = 1;
    }
    else
    {
        row = 2;
    }
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    MessageFatherCenterTableViewCell* cell = (MessageFatherCenterTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.red_point.hidden = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _identifier = @"MessageFatherCenterTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    
    self.tableView.decelerationRate = 0.5;
    self.navigationItem.title = @"通知";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageFatherCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MessageFatherCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.label_title.text = @"官方";
            cell.head_img.image = [UIImage imageNamed:@"icon_official"];
            if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_HAS_NEW_OFFICIAL]) {
                cell.red_point.hidden = NO;
            }
            else
            {
                cell.red_point.hidden = YES;
            }
        }
            break;
        case 1:
        {
            cell.label_title.text = @"评论";
            cell.head_img.image = [UIImage imageNamed:@"icon_reply"];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_HAS_NEW_COMMENT]) {
                cell.red_point.hidden = NO;
            }
            else
            {
                cell.red_point.hidden = YES;
            }
        }
            break;
        default:
        {
            cell.head_img.image = [UIImage imageNamed:@"notice"];
            cell.label_title.text = @"活动";
            if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_HAS_NEW_ACTIVITY]) {
                cell.red_point.hidden = NO;
            }
            else
            {
                cell.red_point.hidden = YES;
            }
        }
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger type = indexPath.row;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MessageCenterTableViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MessageCenterTableViewController"];
    viewController.type = type;
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    
    MessageFatherCenterTableViewCell* cell = (MessageFatherCenterTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.red_point.hidden = YES;
    
    switch (indexPath.row) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_IS_HAS_NEW_OFFICIAL];
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_IS_HAS_NEW_COMMENT];
            break;
        default:
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KEY_IS_HAS_NEW_ACTIVITY];
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        //        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 8, 0, 0)];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        //        [cell setLayoutMargins:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 8, 0, 0)];
        
    }
    
}

@end
