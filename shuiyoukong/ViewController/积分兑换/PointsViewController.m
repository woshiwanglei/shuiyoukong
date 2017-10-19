//
//  PointsViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "PointsViewController.h"
#import "PointsCollectionViewCell.h"
#import "PointCollectionReusableView.h"
#import "FreeSingleton.h"
#import "BuyProductViewController.h"
#import "ProductTableViewController.h"
#import "PointRuleViewController.h"
#import "menuTableViewCell.h"
#import "FreeWebViewController.h"

@interface PointsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak)NSString *identifier;
@property (nonatomic, weak)NSString *headerIdentifier;
@property (nonatomic, strong)NSMutableArray *modelArray;

@property (nonatomic, strong)PointModel *header_model;

@property (nonatomic, strong)UITableView *menuTableview;
@property (nonatomic, weak) NSString *identifier_menu;
@property (nonatomic, strong)UIView *backgroudView;

@property BOOL isSuccees;//判断左上角table
//是否需要刷新等级
@property BOOL isNeedRefreshLv;

@end

@implementation PointsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPoint:) name:ZC_NOTIFICATION_REFRESH_POINT object:nil];
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshPoint:(NSNotification *) notification
{
    __weak PointsViewController *weakSelf = self;
    [[FreeSingleton sharedInstance] queryProductsOnCompletion:@"1" pageSize:@"100" block:^(NSUInteger ret, id data) {
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"item"] count]) {
                [weakSelf initHeaderModel:data[@"item"]];
            }
            if (data[@"items"]) {
                [weakSelf initModelArray:data[@"items"]];
            }
            [_collection_view reloadData];
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_isSuccees) {
        _isSuccees = NO;
        [UIView animateWithDuration:.2 animations:^{
            _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
        } completion:^(BOOL finished) {
            [_backgroudView removeFromSuperview];
            [_menuTableview removeFromSuperview];
        }];
    }
}

#pragma mark - initView
- (void)initView
{
    _collection_view.delegate = self;
    _collection_view.dataSource = self;
    _identifier = @"PointsCollectionViewCell";
    [_collection_view registerNib:[UINib nibWithNibName:@"PointsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:_identifier];
    _headerIdentifier = @"PointCollectionReusableView";
    [_collection_view registerNib:[UINib nibWithNibName:@"PointCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:_headerIdentifier];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @" ";
    self.navigationItem.backBarButtonItem = backItem;

    _collection_view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    
    self.navigationItem.title = @"积分商城";
    self.automaticallyAdjustsScrollViewInsets = NO;//去掉tableview上方的空白
    if([UIDevice currentDevice].systemVersion.floatValue < 8.0) {
        
        [self.navigationController.navigationBar setTranslucent:NO];
    }
    
//    [self initMenuTable];
}

- (void)initMenuTable
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -btn.titleLabel.bounds.size.width-30);
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -30);
    [btn addTarget:self action:@selector(functionIncident) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"成都" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//设置title在一般情况下为白色字体
    btn.titleLabel.font = [UIFont systemFontOfSize:15];//title字体大小
    //    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];//设置title在button被选中情
    [btn setImage:[UIImage imageNamed:@"icon_more_city"] forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = backItem;
    
    _backgroudView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _backgroudView.backgroundColor = [UIColor clearColor];
    _menuTableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, 120, 98) style:UITableViewStylePlain];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_menuTableview.bounds];
    
    _menuTableview.layer.masksToBounds = NO;
    
    _menuTableview.layer.shadowColor = [UIColor blackColor].CGColor;
    
    _menuTableview.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    
    _menuTableview.layer.shadowOpacity = 0.5f;
    
    _menuTableview.layer.shadowPath = shadowPath.CGPath;
    
    _isSuccees = NO;
    
    [_menuTableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    _menuTableview.delegate = self;
    _menuTableview.dataSource = self;
    
    _menuTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    _menuTableview.scrollEnabled = NO;
    
    _identifier_menu = @"menuTableViewCell";
    [_menuTableview registerNib:[UINib nibWithNibName:_identifier_menu bundle:nil] forCellReuseIdentifier:_identifier_menu];
    
    if ([_menuTableview respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [_menuTableview setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([_menuTableview respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [_menuTableview setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - initData
- (void)initData
{
    __weak PointsViewController *weakSelf = self;
    [KVNProgress showWithStatus:@"Loading" onView:self.view];
    [[FreeSingleton sharedInstance] queryProductsOnCompletion:@"1" pageSize:@"100" block:^(NSUInteger ret, id data) {
        [KVNProgress dismiss];
        if (ret == RET_SERVER_SUCC) {
            if ([data[@"item"] count]) {
                [weakSelf initHeaderModel:data[@"item"]];
            }
            if ([data[@"items"] count]) {
                [weakSelf initModelArray:data[@"items"]];
            }
            [_collection_view reloadData];
        }
        else
        {
            [KVNProgress showErrorWithStatus:@"网络异常"];
        }
    }];
}

- (void)initHeaderModel:(id)data
{
    _header_model = [[PointModel alloc] init];
    _header_model.points = [NSString stringWithFormat:@"%@", data[@"effect"]];
    if ([data[@"level"] isKindOfClass:[NSNull class]] || [data[@"level"] length] == 0) {
        _header_model.Lv = @"Lv1盖碗茶";
    }
    else
    {
        _header_model.Lv = data[@"level"];
        if (![[[FreeSingleton sharedInstance] getLevel] isEqual:data[@"level"]]) {
            [FreeSingleton sharedInstance].level = data[@"level"];
            [[NSUserDefaults standardUserDefaults] setObject:data[@"level"] forKey:KEY_LEVEL];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_DID_IMG_CHANGED object:nil];//触发刷新通知
        }
    }
    
    _header_model.high_points = [NSString stringWithFormat:@"%@", data[@"point"]];
}

- (void)initModelArray:(id)data
{
    _modelArray = [NSMutableArray array];
    for (int i = 0; i < [data count]; i++) {
        NSDictionary *dict = data[i];
        ProductModel *model = [[ProductModel alloc] init];
        if (![dict[@"description"] isKindOfClass:[NSNull class]]) {
            model.Description = dict[@"description"];
        }
        model.expireDate = [NSString stringWithFormat:@"%@", dict[@"expireDate"]];
        
        if (![dict[@"imgUrl"] isKindOfClass:[NSNull class]]) {
            NSArray *array = [dict[@"imgUrl"] componentsSeparatedByString:@"#%#"];
            model.imgUrl = array[0];
            for (int k = 0; k < [array count]; k++)
            {
                [model.imgArray addObject:array[k]];
            }
        }
        model.itemCount = dict[@"itemCount"];
        
        model.itemId = [NSString stringWithFormat:@"%@", dict[@"itemId"]];
        if (![dict[@"itemName"] isKindOfClass:[NSNull class]]) {
            model.itemName = dict[@"itemName"];
        }
        if (![dict[@"needPoints"] isKindOfClass:[NSNull class]]) {
            model.needPoints = dict[@"needPoints"];
        }
        [_modelArray addObject:model];
    }
    
}

#pragma mark - CollectionView Controll

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([_modelArray count]) {
        return [_modelArray count];
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PointsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    
    cell.model = _modelArray[indexPath.row];
    
    return cell;
}

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat height = (self.view.bounds.size.width - 6)/2 + 40;
    CGFloat width = (self.view.bounds.size.width - 6)/2;
    
    return CGSizeMake(width, height);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath

{
    
    PointCollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader){
        
        PointCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:_headerIdentifier forIndexPath:indexPath];
        
        headerView.model = _header_model;
        [headerView.btn_left removeTarget:self action:@selector(gotoMall:) forControlEvents:UIControlEventTouchDown];
        [headerView.btn_left addTarget:self action:@selector(gotoMall:) forControlEvents:UIControlEventTouchDown];
        [headerView.btn_right removeTarget:self action:@selector(gotoRule:) forControlEvents:UIControlEventTouchDown];
        [headerView.btn_right addTarget:self action:@selector(gotoRule:) forControlEvents:UIControlEventTouchDown];
        reusableview = headerView;
    }
    
    return reusableview;
    
}

////返回头headerView的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    CGSize size = {self.view.frame.size.width, 99};
    return size;
}

//每个item之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 6;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BuyProductViewController *vc = [[BuyProductViewController alloc] initWithNibName:@"BuyProductViewController" bundle:nil];
    
    //    game.playsName = _choosearry;
    vc.model = _modelArray[indexPath.row];
//    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 跳转功能
- (void)gotoMall:(id)sender
{
    ProductTableViewController *vc = [[ProductTableViewController alloc] initWithNibName:@"ProductTableViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoRule:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIImage *img = [[UIImage alloc] init];
    UIImage *img = [UIImage imageNamed:@"glass"];
    
    FreeWebViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"FreeWebViewController"];

    viewController.url = @"http://mp.weixin.qq.com/s?__biz=MzA3Nzg3OTk4MQ==&mid=209232477&idx=1&sn=44e99ae90976f0c8129a870dc9b52b33#rd";
    viewController.url_title = @"茶杯计划";
    viewController.content = @"下载谁有空参与玩什么频道！加入茶杯计划，好礼拿不停！";
    viewController.img = img;
    viewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
//
//    PointRuleViewController *vc = [[PointRuleViewController alloc] initWithNibName:@"PointRuleViewController" bundle:nil];
//    
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -菜单栏目
-(void)functionIncident
{
    
    _isSuccees = !(_isSuccees);
    
    if (_isSuccees)
    {
        _menuTableview.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,0, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
    }
    else
    {
        [UIView animateWithDuration:.2 animations:^{
            _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
        } completion:^(BOOL finished) {
            [_backgroudView removeFromSuperview];
            [_menuTableview removeFromSuperview];
        }];
        
        return;
    }
    
    [self.view addSubview:_backgroudView];
    
    [_backgroudView addSubview:_menuTableview];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    _isSuccees = NO;
    [UIView animateWithDuration:.2 animations:^{
        _menuTableview.frame=CGRectMake([UIScreen mainScreen].bounds.size.width-_menuTableview.frame.size.width,[UIScreen mainScreen].bounds.origin.y-_menuTableview.frame.size.height, _menuTableview.frame.size.width, _menuTableview.frame.size.height);
    } completion:^(BOOL finished) {
        [_backgroudView removeFromSuperview];
        [_menuTableview removeFromSuperview];
    }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        switch (indexPath.section) {
            case 0:
                [_backgroudView removeFromSuperview];
                [_menuTableview removeFromSuperview];
                _isSuccees = NO;
                break;
            default:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"目前版本只开放了成都市，更多城市会陆续开放" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                [alert show];
                [_backgroudView removeFromSuperview];
                [_menuTableview removeFromSuperview];
                _isSuccees = NO;
            }
                break;
        }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            menuTableViewCell *cell = [_menuTableview dequeueReusableCellWithIdentifier:_identifier_menu forIndexPath:indexPath];
            
            if (!cell)
            {
                
                cell = [[menuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier_menu];
            }
            cell.menuName.font = [UIFont systemFontOfSize:15.f];
            cell.menuName.text = @"成都市";
            NSLog(@"%@", NSStringFromCGRect(cell.frame));
            return cell;
        }
            break;
            
        default:
        {
            menuTableViewCell *cell = [_menuTableview dequeueReusableCellWithIdentifier:_identifier_menu forIndexPath:indexPath];
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, _menuTableview.bounds.size.width);
            if (!cell)
            {
                cell = [[menuTableViewCell alloc] init];
            }
            cell.menuName.font = [UIFont systemFontOfSize:14.f];
            cell.menuName.text = @"更多城市敬请期待";
            NSLog(@"%@", NSStringFromCGRect(cell.frame));
            return cell;
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        return 49;
}

@end
