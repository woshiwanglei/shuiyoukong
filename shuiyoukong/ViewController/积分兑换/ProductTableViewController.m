//
//  ProductTableViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ProductTableViewController.h"
#import "ProductTableViewCell.h"
#import "FreeSingleton.h"
#import "ProuductDetailViewController.h"

@interface ProductTableViewController ()

@property (weak, nonatomic)NSString *identifier;

@property (strong, nonatomic)NSMutableArray *modelArray;

@end

@implementation ProductTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -initView
- (void)initView
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
//    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    //设置tableview滑动速度
    //    self.mTableView.decelerationRate = 0.5;
    _identifier = @"ProductTableViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    
    self.navigationItem.title = @"兑换清单";
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem=backItem;
    
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//取消分割线
}

#pragma mark - initData
- (void)initData
{
    [KVNProgress showWithStatus:@"Loading"];
    __weak ProductTableViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] queryRecordOnCompletion:@"1" pageSize:@"50" block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"items"] count]) {
                [weakSelf add2ModelArray:data[@"items"]];
                [weakSelf.tableView reloadData];
            }
            else
            {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_product"]];
                imageView.frame = CGRectMake(([[UIScreen mainScreen] bounds].size.width - 90)/2, ([[UIScreen mainScreen] bounds].size.height - 239)/2 , 90, 119);
                
                [weakSelf.tableView addSubview:imageView];
            }
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"未知错误"];
        }
    }];
}

- (void)add2ModelArray:(id)data
{
    _modelArray = [NSMutableArray array];
    
    for (int i = 0; i < [data count]; i++) {
        NSDictionary *dic = data[i];
        RecordModel *recordModel = [[RecordModel alloc] init];
        recordModel.barcode = dic[@"barcode"];
        recordModel.exchangeDate = [NSString stringWithFormat:@"%@", dic[@"exchangeDate"]];
        [self addProduct2Model:recordModel dataSource:dic[@"exchangeItem"]];
        [_modelArray addObject:recordModel];
    }
}

- (void)addProduct2Model:(RecordModel *)model dataSource:(id)data
{
    if ([data isKindOfClass:[NSNull class]]) {
        return;
    }
    
    ProductModel *productModel = [[ProductModel alloc] init];
    productModel.Description = data[@"description"];
    productModel.expireDate = [NSString stringWithFormat:@"%@", data[@"expireDate"]];
    if (![data[@"imgUrl"] isKindOfClass:[NSNull class]]) {
        NSArray *array = [data[@"imgUrl"] componentsSeparatedByString:@"#%#"];
        productModel.imgUrl = array[0];
        for (int k = 0; k < [array count]; k++)
        {
            [productModel.imgArray addObject:array[k]];
        }
    }
    productModel.itemName = data[@"itemName"];
    productModel.itemId = [NSString stringWithFormat:@"%@", data[@"itemId"]];
    productModel.needPoints = data[@"needPoints"];
    
    model.model = productModel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([_modelArray count]) {
        return [_modelArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:_identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[ProductTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    cell.model = _modelArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 71 + 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ProuductDetailViewController *vc = [[ProuductDetailViewController alloc] initWithNibName:@"ProuductDetailViewController" bundle:nil];
    //    game.playsName = _choosearry;
    vc.model = _modelArray[indexPath.row];
    //    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
