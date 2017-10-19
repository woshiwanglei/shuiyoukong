//
//  AllCityTableViewController.m
//  Free
//
//  Created by yangcong on 15/5/14.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "AllCityTableViewController.h"
#import "CityNameCell.h"
#import "citypinyin.h"
#import "trendTableViewCell.h"
#import "FreeSingleton.h"
#import "FreeTabBarViewController.h"
#import "FreeMap.h"
#import "AMapSearchAPI.h"
#import "MyInfoTableViewController.h"

#define SCROllVIEW_TAG 123

@interface AllCityTableViewController ()<AMapSearchDelegate>

@property (nonatomic,strong) NSDictionary *dicCity;

@property (nonatomic,strong) NSArray *list;

@property (nonatomic,strong) UISearchDisplayController *search;

@property (nonatomic, strong) AMapSearchAPI *searcha;
//数组搜索
@property (nonatomic, retain) NSArray *AllcityName;

@property (nonatomic, retain) NSArray *searchData;

@property (nonatomic, retain) NSMutableArray *allCitys;

@property (nonatomic, strong) NSMutableArray * tempArray;//中间数组

@property (nonatomic, strong) FreeTabBarViewController *cityLast;

@property (nonatomic, strong) UILabel *leftlable;

@end

@implementation AllCityTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    UIViewController *setPrizeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    if ([setPrizeVC isKindOfClass:[MyInfoTableViewController class]]) {
        MyInfoTableViewController *vc = (MyInfoTableViewController *)setPrizeVC;
        vc.isNeedRefresh = YES;
    }
}

-(void)initView
{
    [self.tableView registerNib:[UINib nibWithNibName:@"trendTableViewCell" bundle:nil] forCellReuseIdentifier:@"trendTableViewCell"];
    
    self.tabBarController.tabBar.hidden = YES;

    _tempArray = [[NSMutableArray alloc] init];
    _AllcityName = [NSArray array];
    _allCitys = [NSMutableArray array];
    
    
        NSString *path = [[NSBundle mainBundle] pathForResource:@"allCityList" ofType:@"plist"];
        
        NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];

            _dicCity = dic;
            
            NSArray *array = [[_dicCity allKeys] sortedArrayUsingSelector:@selector(compare:)];
            
            _list = array;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        for (int i = 0; i<_list.count; i++) {
        
            NSString *name = _list[i];
            
            _AllcityName = [_dicCity objectForKey:name];
            
            for (int j = 0; j<[_AllcityName count]; j++) {
                citypinyin *citypy = [[citypinyin alloc] init];
            
                citypy.cityName = _AllcityName[j];
            
            //汉字转拼音，比较排序时候用
                NSMutableString *ms = [[NSMutableString alloc] initWithString:citypy.cityName];
            
                if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
                }
                if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO))
                {
                
                citypy.letter = ms;
                
                }
            
                [_allCitys addObject:citypy];
                
            }
        }
   });
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    
    searchBar.delegate = self;
    
    searchBar.placeholder = @"搜索";
    
    self.tableView.tableHeaderView = searchBar;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _search = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    _search.delegate = self;
    _search.searchResultsDelegate = self;
    
    _search.searchResultsDataSource = self;
    
    _search.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
//    [self setLocation];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == self.tableView)
    {
      return [_list count];
    }
    else
    {
         return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if (tableView == self.tableView) {
        
        
        NSString *key = [_list objectAtIndex:section];
        
        NSArray *arry = [_dicCity objectForKey:key];
        
        return [arry count];
     
    }
    else
    {
       return [_tempArray count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        if (section == 0)
        {
            return 65.0f;
        }
        else
        {
            return 25.0f;
        }
    }
    else
    {
        if (section == 0)
        {
            return 25.0f;
        }
        else
        {
            return 25.0f;
        }
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.tableView) {
        
        return index;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    
    if (tableView == self.tableView)
    {
            switch (indexPath.section) {
        
                case 0:
                {
                    trendTableViewCell *cellcity = [tableView dequeueReusableCellWithIdentifier:@"trendTableViewCell"];
        
                    if (!cellcity)
                    {
                        cellcity = [[trendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"trendTableViewCell"];
                    }
        
                    for (UIButton *btn in cellcity.cityNames) {
        
                        [btn addTarget:self action:@selector(Getcellctiy:) forControlEvents:UIControlEventTouchUpInside];
        
                    }
                    cellcity.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        
                    return cellcity;
                }
                  break;
        
                default:
                {
        
                    static NSString *tipCellIdentifier = @"tipCellIdentifier";
        
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];
        
                    if (cell == nil)
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                      reuseIdentifier:tipCellIdentifier];
                    }
        
                    NSInteger section = [indexPath section];
                    NSInteger  row = [indexPath row];
                    NSString *key = [_list objectAtIndex:section];
                    NSArray *array = [_dicCity objectForKey:key];
                    cell.textLabel.text = [array objectAtIndex:row];
                    
                    return cell;
                    
                 }
                    
                    break;
                }

    }
    else
    {
        
        citypinyin *city;

        static NSString *tipCellIdentifier = @"tipCellIdentifier";

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];

        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:tipCellIdentifier];
        }

        city = [_tempArray objectAtIndex:indexPath.row];

        cell.textLabel.text = city.cityName;
        
     
        
        return cell;
    }
}


#pragma mark - "热门城市"
-(void)Getcellctiy:(UIButton *)sender
{
    if (sender.tag) {
        
        [FreeSingleton sharedInstance].city = sender.titleLabel.text;
        
        NSString *tagcity= [FreeSingleton sharedInstance].city;
        
        [[NSUserDefaults standardUserDefaults] setObject:tagcity forKey:KEY_CITY_NAME];
        
        [[FreeSingleton sharedInstance] postCityOnCompletion:tagcity block:^(NSUInteger ret, id data) {
            if (ret != RET_SERVER_SUCC) {
                [KVNProgress showErrorWithStatus:@"修改城市失败"];
            }
        }];
        
        
        [self.navigationController popViewControllerAnimated:YES];

    }

}
#pragma mark - UISearchDisplayController delegate methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller  shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:[_search.searchBar scopeButtonTitles][_search.searchBar.selectedScopeButtonIndex]];
    
    return YES;
    
    
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller  shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    [self filterContentForSearchText:[self.search.searchBar text] scope:[[self.search.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    [self.tempArray removeAllObjects];
    
    for (citypinyin * city in  _allCitys) {
        
                    NSRange chinese = [city.cityName rangeOfString:searchText options:NSCaseInsensitiveSearch];
                    NSRange  letters = [city.letter rangeOfString:searchText options:NSCaseInsensitiveSearch];
                    if (chinese.location != NSNotFound) {
                        [self.tempArray addObject:city];
                    }else if (letters.location != NSNotFound){
                        [self.tempArray addObject:city];
                    }

    }
}

//获取分组标题并显示
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   
    UIView *cityview ;
    UILabel *holde = [[UILabel alloc] initWithFrame:CGRectMake(10,35,200,20)];
    
    if (tableView == self.tableView) {
        
        if (section == 0)
           {
            _leftlable = [[UILabel alloc] initWithFrame:CGRectMake(10,5,200,30)];
            
            cityview = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.tableView.frame.size.width, self.tableView.frame.size.height)];
            
            _leftlable.text = @"你还没有定位城市噢";
            
            holde.text = @"热门城市";
            NSString *name = [FreeSingleton sharedInstance].city;
            _leftlable.text = name;
            
            cityview.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
            
            [cityview addSubview:_leftlable];
            [cityview addSubview:holde];
            
        }
        
      return cityview;
    
    }
    else
    {
        return nil;
    }

    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        NSString *key = [_list objectAtIndex:section];
        
        return key;
    }
    else
    {
        return @"搜索结果";
    }
    return nil;
}

//给tableviewcell添加索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _list;
}


//重新设置一下tableviewcell的行高为70
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        
        if (indexPath.section == 0)
        {
            return 150;
        }
        else
        {
            return 70;
        }
    
    }
    else
    {
        return 70;
    }
}
#pragma mark - 每行触发的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    

    if (tableView == self.tableView) {
        
        if (indexPath.section == 0) {
            
        }
        else
        {
        NSInteger section = indexPath.section;
        NSInteger  row = indexPath.row;
        NSString *key = [_list objectAtIndex:section];
        NSArray *array = [_dicCity objectForKey:key];
        NSString *name = [array objectAtIndex:row];
        
        [FreeSingleton sharedInstance].city = name;
        
        NSString *city = [FreeSingleton sharedInstance].city;
        
        [[NSUserDefaults standardUserDefaults] setObject:city forKey:KEY_CITY_NAME];
            
        [[FreeSingleton sharedInstance] postCityOnCompletion:city block:^(NSUInteger ret, id data) {
            if (ret != RET_SERVER_SUCC) {
                [KVNProgress showErrorWithStatus:@"修改城市失败"];
            }
        }];
            
        [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        citypinyin *city;
        
        city = [_tempArray objectAtIndex:indexPath.row];
        
        NSString *names = city.cityName;
        
        [FreeSingleton sharedInstance].city = names;
        
        NSString *citys = [FreeSingleton sharedInstance].city;
        
        [[NSUserDefaults standardUserDefaults] setObject:citys forKey:KEY_CITY_NAME];
        
        [[FreeSingleton sharedInstance] postCityOnCompletion:citys block:^(NSUInteger ret, id data) {
            if (ret != RET_SERVER_SUCC) {
                [KVNProgress showErrorWithStatus:@"修改城市失败"];
            }
        }];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}


@end
