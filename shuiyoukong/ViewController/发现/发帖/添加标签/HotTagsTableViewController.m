//
//  HotTagsTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/17.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "HotTagsTableViewController.h"
#import "HotTagsHeaderView.h"
#import "HotTagsTableViewCell.h"
#import "HotTagsSectionHeader.h"
#import "AddHotTagsTableViewCell.h"
#import "SubTagsView.h"
#import "FreeSingleton.h"
#import "WritePostViewController.h"

#define TAG_NUM 7

@interface HotTagsTableViewController ()<UITextFieldDelegate>

@property (nonatomic, strong)NSArray *dataArray;

@property (nonatomic, weak)NSString *identifier;

@property (nonatomic, weak)NSString *identifier_add;

@property (nonatomic, strong)HotTagsHeaderView *hot_header_view;

@end

@implementation HotTagsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:nil];
}

#pragma mark - init
- (void)initView
{
    _identifier = @"HotTagsTableViewCell";
    _identifier_add = @"AddHotTagsTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    [self.tableView registerNib:[UINib nibWithNibName:_identifier_add bundle:nil] forCellReuseIdentifier:_identifier_add];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.title = @"添加标签";
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 90)];
    self.tableView.tableHeaderView = headerView;
    
    _hot_header_view = [[[NSBundle mainBundle] loadNibNamed:@"HotTagsHeaderView"
                                   owner:self
                                 options:nil] objectAtIndex:0];
    _hot_header_view.frame = headerView.frame;
    _hot_header_view.input_text.delegate = self;
    [_hot_header_view.btn_add addTarget:self action:@selector(btn_addTags:) forControlEvents:UIControlEventTouchDown];
    _hot_header_view.input_text.returnKeyType = UIReturnKeyDone;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_hot_header_view.input_text];
    
    [headerView addSubview:_hot_header_view];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(sendTags)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)initData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hotTagsList" ofType:@"plist"];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    _dataArray = [[NSArray alloc] initWithArray:dic[@"tags"]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if ([_addArray count]) {
                return 1;
            }
            return 0;
            break;
        case 1:
            if ([_dataArray count]) {
                return [_dataArray count];
            }
            return 0;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    HotTagsSectionHeader *hot_header_view = [[[NSBundle mainBundle] loadNibNamed:@"HotTagsSectionHeader" owner:self
                                                                         options:nil] objectAtIndex:0];
    hot_header_view.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);

    if (section == 0) {
        [hot_header_view.btn_img setImage:[UIImage imageNamed:@"icon_add_tags"] forState:UIControlStateNormal];
        hot_header_view.label_name.text = @"已添加";
        return hot_header_view;
    }
    else
    {
        [hot_header_view.btn_img setImage:[UIImage imageNamed:@"icon_hot_tags"] forState:UIControlStateNormal];
        hot_header_view.label_name.text = @"热门标签";
        return hot_header_view;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
        {
            AddHotTagsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier_add forIndexPath:indexPath];
            
            if (!cell)
            {
                if (cell == nil)
                {
                    cell = [[AddHotTagsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_add];
                    
                }
            }
            [self addChoseTags:cell];
            
            return cell;
        }
            break;
            
        default:
        {
            HotTagsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
            
            if (!cell)
            {
                if (cell == nil)
                {
                    cell = [[HotTagsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
                    
                }
            }
            cell.label_name.text = _dataArray[indexPath.row];
            
            return cell;
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return;
            break;
        default:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self selectHotTags:indexPath];
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}



#pragma mark - 初始化添加标签
- (void)addChoseTags:(AddHotTagsTableViewCell *)cell
{
    for (UIView *view in cell.scroll_view.subviews) {
//        if ([view isKindOfClass:[UIScrollView class]]) {
            [view removeFromSuperview];
//        }
    }
    
    float totalX = 15.f;
    
    NSMutableArray *array_over = (NSMutableArray *)[[_addArray reverseObjectEnumerator] allObjects];
    
    for (int i = 0; i < [array_over count]; i++) {
        NSString *str = array_over[i];
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.alignment = NSLineBreakByWordWrapping;
        NSDictionary *attribute = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:15], NSParagraphStyleAttributeName: paragraph};
        
        CGSize size = [str boundingRectWithSize:CGSizeMake(300, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        
        totalX += (size.width + 25);
    }
    
    cell.scroll_view.contentSize = CGSizeMake(totalX, 0);
    
    UIView *sub_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, totalX, 40)];
    
    [cell.scroll_view addSubview:sub_view];
    
    totalX = 15.f;
    
    for (int i = 0; i < [array_over count]; i++) {
        SubTagsView *view = [[[NSBundle mainBundle] loadNibNamed:@"SubTagsView"
                                                                            owner:self
                                                                          options:nil] objectAtIndex:0];
        NSInteger num = [array_over count] - 1 - i;
        
        view.btn_delete.tag = num;
        [view.btn_delete addTarget:self action:@selector(btn_Tapped_delete:) forControlEvents:UIControlEventTouchDown];
        NSString *str = array_over[i];
        view.label_name.text = str;
       CGSize size = [view.label_name sizeThatFits:CGSizeMake(300 , FLT_MAX)];
        view.frame = CGRectMake(totalX, 5, size.width + 20, 30);
        totalX += (size.width + 25);

        [sub_view addSubview:view];
    }
}

#pragma mark - 其他
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [_hot_header_view.input_text resignFirstResponder];
}

#pragma mark - 功能
- (void)sendTags
{
    WritePostViewController *setPrizeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    if ([_addArray count]) {
        //初始化其属性
        setPrizeVC.tags_array = nil;
        NSMutableArray *array = [NSMutableArray arrayWithArray:_addArray];
        setPrizeVC.tags_array = array;
    }
    //使用popToViewController返回并传值到上一页面
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btn_addTags:(UIButton *)btn
{
    if([_addArray count] >= TAG_NUM)
    {
        [KVNProgress showErrorWithStatus:@"最多只能附加7个标签噢"];
        return;
    }
    
    HotTagsHeaderView *view = (HotTagsHeaderView *)btn.superview;
    
    if([view.input_text.text length] <= 0)
        return;
    
    if(!_addArray)
    {
        _addArray = [NSMutableArray array];
    }
    
    NSString *str = view.input_text.text;
    [_addArray addObject:str];
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
    view.input_text.text = nil;
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)selectHotTags:(NSIndexPath *)indexPath
{
    if([_addArray count] >= TAG_NUM)
    {
        [KVNProgress showErrorWithStatus:@"最多只能附加7个标签噢"];
        return;
    }
    
    if(!_addArray)
    {
        _addArray = [NSMutableArray array];
    }
    
    NSString *str = [_dataArray[indexPath.row] mutableCopy];
    [_addArray addObject:str];
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)btn_Tapped_delete:(UIButton *)btn
{
    [_addArray removeObjectAtIndex:btn.tag];
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -textFiled

/**
 *  点击完成收入键盘
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_hot_header_view.input_text resignFirstResponder];
    
    return YES;
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    
    // NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > 15) {
                textField.text = [toBeString substringToIndex:15];
            }
        }
        else{
            
        }
    }
    else{
        if (toBeString.length > 15) {
            textField.text = [toBeString substringToIndex:15];
        }
    }
}

@end
