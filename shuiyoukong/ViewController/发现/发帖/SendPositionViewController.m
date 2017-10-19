//
//  SendPositionViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SendPositionViewController.h"
#import <MAMapKit/MAMapKit.h>
#import "FreeSingleton.h"
#import "AMapSearchAPI.h"
#import "SendPositionTableViewCell.h"
#import "WritePostViewController.h"
#import "CreateActivityViewController.h"

@interface SendPositionViewController ()<MAMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, AMapSearchDelegate>
{
    MAMapView *_mapView;
}
@property (weak, nonatomic) IBOutlet UIView *top_view;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property AMapSearchAPI *search;
@property (nonatomic,strong) UISearchDisplayController *searchdisplay;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, weak)NSString *identifier;
@property (nonatomic, strong)NSMutableArray *search_ModelArray;
@property (nonatomic, strong)PositionModel *chosen_model;

@property (nonatomic, strong)NSMutableArray *AnnotationArray;

@property (nonatomic, strong)NSString *my_city;
@end

@implementation SendPositionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _search.delegate = nil;
    _mapView.delegate = nil;
}

#pragma mark - initView
- (void)initView
{
    self.navigationItem.title = @"位置信息";
    _identifier = @"SendPositionTableViewCell";
    [_mTableView registerNib:[UINib nibWithNibName:_identifier bundle:nil] forCellReuseIdentifier:_identifier];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(sendPosition)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self initMapView];
    [self initSearchBar];
}

- (void)initMapView
{
    //    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    //    _mapView.delegate = self;
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_top_view.bounds), CGRectGetHeight(_top_view.bounds))];
    
    [_top_view addSubview:_mapView];
    _mapView.showsUserLocation = YES;
    _mapView.showsCompass= NO;//不要指南针
    _mapView.showsScale= NO;//不要比例尺

    [_mapView setUserTrackingMode: MAUserTrackingModeNone animated:YES]; //地图跟着位置 移动
    [_mapView setZoomLevel:18 animated:NO];
    
    UIButton *position_center = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 42, (_top_view.frame.size.height - 47)/2, 84, 47)];
    [position_center setImage:[UIImage imageNamed:@"icon_position"] forState:UIControlStateNormal];
    position_center.userInteractionEnabled = NO;
    
    [_mapView addSubview:position_center];
    _mapView.delegate = self;
}

- (void)initSearchBar
{
    _search_bar.placeholder = @"搜索";
    [_search_bar setTintColor:FREE_BACKGOURND_COLOR];
    
    _searchdisplay = [[UISearchDisplayController alloc] initWithSearchBar:_search_bar contentsController:self];
    
    _search_bar.delegate = self;
    _searchdisplay.delegate = self;
    // searchResultsDataSource 就是 UITableViewDataSource
    _searchdisplay.searchResultsDataSource = self;
    // searchResultsDelegate 就是 UITableViewDelegate
    _searchdisplay.searchResultsDelegate = self;
    
    _searchdisplay.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    _mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];//隐藏空的 cell
    self.navigationItem.title = @"位置信息";
}


- (void)initData
{
    _dataSource = [NSMutableArray array];
    _AnnotationArray = [NSMutableArray array];
    
//    _search = [[AMapSearchAPI alloc] initWithSearchKey:GAODE_MAP_KEY Delegate:self];
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;

    [self performSelector:@selector(delaySetCenter) withObject:nil afterDelay:0.5f];
}

- (void)delaySetCenter
{
    if (_mapView.userLocation.location == nil) {
        [self performSelector:@selector(delaySetCenter) withObject:nil afterDelay:0.5f];
        return;
    }
    _mapView.centerCoordinate =_mapView.userLocation.location.coordinate;
    //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
//    regeoRequest.searchType = AMapSearchType_ReGeocode;
    
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:_mapView.userLocation.location.coordinate.latitude longitude:_mapView.userLocation.location.coordinate.longitude];
    regeoRequest.radius = 1000;
    regeoRequest.requireExtension = YES;
    
    //发起逆地理编码
    [_search AMapReGoecodeSearch: regeoRequest];
}

//实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    if(response.regeocode != nil)
    {
        
        NSString *province = response.regeocode.addressComponent.province;
        if (![province length]) {
            province = @"";
        }
        
        NSString *city = response.regeocode.addressComponent.city;
        if (![city length]) {
            city = @"";
        }
        if ([province length] && ![city length]) {
            _my_city = province;
        }
        else
        {
            _my_city = city;
        }
        
        NSString *district = response.regeocode.addressComponent.district;
        if (![district length]) {
            district = @"";
        }
        
        NSString *township = response.regeocode.addressComponent.township;
        if (![township length]) {
            township = @"";
        }
        
        NSString *positionStr = [NSString stringWithFormat:@"%@%@%@%@", province, city, district, township];
        
        [_dataSource removeAllObjects];
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        int i = 0;
        for (AMapPOI *p in response.regeocode.pois) {
            PositionModel *model = [[PositionModel alloc] init];
            model.latitude = p.location.latitude;
            model.longitude = p.location.longitude;
            NSString *name = p.name;
            if (!name || [name length] == 0) {
                name = @"";
            }
            model.name = name;
            NSString *address = p.address;
            if (!address || [address length] == 0) {
                address = @"";
            }

            NSString *position_address = [NSString stringWithFormat:@"%@%@", positionStr, address];
            model.address = address;
            model.city = city;
            model.position_name = [NSString stringWithFormat:@"%@%@", position_address, name];
            if (i == 0) {
                model.isChosen = YES;
            }
            else
            {
                model.isChosen = NO;
            }
            i = 1;
            [_dataSource addObject:model];
        }
        
        if ([_search_ModelArray count]) {
            _chosen_model.isChosen = YES;
            [_dataSource replaceObjectAtIndex:0 withObject:_chosen_model];
            [_search_ModelArray removeAllObjects];
        }
        else
        {
            if([_dataSource count])
            {
                _chosen_model = [[PositionModel alloc] init];
                _chosen_model = _dataSource[0];
            }
        }
        
        [_mTableView reloadData];
    }
}

- (void)searchPosition:(NSString *)keywords
{
//    AMapPlaceSearchRequest *poiRequest = [[AMapPlaceSearchRequest alloc] init];
//    poiRequest.searchType = AMapSearchType_PlaceKeyword;
//    poiRequest.keywords = keywords;
//    if ([_my_city length]) {
//        poiRequest.city = @[_my_city];
//    }
//    
//    poiRequest.requireExtension = YES;
//    //发起 POI 搜索
//    [_search AMapPlaceSearch: poiRequest];
    AMapPOIKeywordsSearchRequest *poiRequest = [[AMapPOIKeywordsSearchRequest alloc] init];
//    poiRequest.searchType = AMapSearchType_PlaceKeyword;
    poiRequest.keywords = keywords;
    if ([_my_city length]) {
        poiRequest.city = _my_city;
    }
    poiRequest.requireExtension = YES;
    //发起 POI 搜索
    [_search AMapPOIKeywordsSearch: poiRequest];
}

//实现 POI 搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0) {
        return;
    }
    
    _search_ModelArray = [NSMutableArray array];
    
    //处理搜索结果
    for (AMapPOI *p in response.pois) {
        PositionModel *model = [[PositionModel alloc] init];
        model.latitude = p.location.latitude;
        model.longitude = p.location.longitude;
        NSString *name = p.name;
        if (!name || [name length] == 0) {
            name = @"";
        }
        model.name = name;
        NSString *province = p.province;
        if (!province || [province length] == 0) {
            province = @"";
        }
        NSString *city = p.city;
        model.city = city;
        if (!city || [city length] == 0) {
            if (province) {
                model.city = province;
            }
            else
            {
                city = @"";
                model.city = city;
            }
        }
        NSString *district = p.district;
        if (!district || [district length] == 0) {
            district = @"";
        }
        
        NSString *address = p.address;
        if (!address || [address length] == 0) {
            address = @"";
        }
        NSString *positionStr;
        if ([province isEqualToString:city]) {
            positionStr = [NSString stringWithFormat:@"%@%@%@", province,district,address];
        }
        else
        {
            positionStr = [NSString stringWithFormat:@"%@%@%@%@", province,city,district,address];
        }
        model.address = positionStr;
        model.position_name = [NSString stringWithFormat:@"%@ %@", positionStr, name];
        
        [_search_ModelArray addObject:model];
    }
    
    [_searchdisplay.searchResultsTableView reloadData];
}

#pragma mark - search

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (_mapView.userLocation.location == nil) {
        return;
    }
    //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
    AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
//    regeoRequest.searchType = AMapSearchType_ReGeocode;
    
    regeoRequest.location = [AMapGeoPoint locationWithLatitude:_mapView.centerCoordinate.latitude longitude:_mapView.centerCoordinate.longitude];
    regeoRequest.radius = 1000;
    regeoRequest.requireExtension = YES;
    
    //发起逆地理编码
    [_search AMapReGoecodeSearch: regeoRequest];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchPosition:searchText];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (tableView == _mTableView) {
        if (_dataSource) {
            return [_dataSource count];
        }
        return 0;
    }
    else
    {
        if (_search_ModelArray) {
            return [_search_ModelArray count];
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SendPositionTableViewCell *cell = [_mTableView dequeueReusableCellWithIdentifier:_identifier];
    if (cell == nil) {
        cell = [[SendPositionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_identifier];
    }
    
    if (tableView == _mTableView) {
        
        cell.model = _dataSource[indexPath.row];
    }
    else
    {
        cell.model = _search_ModelArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.f + 1;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _mTableView) {
        _chosen_model = _dataSource[indexPath.row];
        
        CLLocationCoordinate2D loction;
        loction.latitude = _chosen_model.latitude;
        loction.longitude = _chosen_model.longitude;
        _my_city = _chosen_model.city;
        [_mapView setCenterCoordinate:loction];
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(_chosen_model.latitude, _chosen_model.longitude);
        pointAnnotation.title = _chosen_model.position_name;
        [_AnnotationArray addObject:pointAnnotation];
        [_mapView removeAnnotations:_AnnotationArray];
        [_mapView addAnnotation:pointAnnotation];
        for (int i = 0; i < [_dataSource count]; i++) {
            SendPositionTableViewCell* cell = (SendPositionTableViewCell *)[_mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (i != indexPath.row) {
                _chosen_model.isChosen = NO;
                cell.btn_chosen.hidden = YES;
            }
            else
            {
                _chosen_model.isChosen = YES;
                cell.btn_chosen.hidden = NO;
            }
        }
    }
    else
    {
        _chosen_model = _search_ModelArray[indexPath.row];
        for (int i = 0; i < [_search_ModelArray count]; i++) {
            SendPositionTableViewCell* cell = (SendPositionTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (i != indexPath.row) {
                _chosen_model.isChosen = NO;
                cell.btn_chosen.hidden = YES;
            }
            else
            {
                _chosen_model.isChosen = YES;
                cell.btn_chosen.hidden = NO;
            }
        }
//        [_dataSource removeAllObjects];
//        [_dataSource addObject:_chosen_model];
        SendPositionTableViewCell* cell = (SendPositionTableViewCell *)[_mTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//        _chosen_model.isChosen = YES;
        cell.model = _chosen_model;
        CLLocationCoordinate2D loction;
        loction.latitude = _chosen_model.latitude;
        loction.longitude = _chosen_model.longitude;
        _my_city = _chosen_model.city;
        [_mapView setCenterCoordinate:loction];
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(loction.latitude, loction.longitude);
        pointAnnotation.title = _chosen_model.position_name;
        [_AnnotationArray addObject:pointAnnotation];
        [_mapView removeAnnotations:_AnnotationArray];
        [_mapView addAnnotation:pointAnnotation];
        [_searchdisplay setActive:NO animated:YES];
        [_mTableView reloadData];
    }
}

#pragma mark - map
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = NO;        //设置标注动画显示，默认为NO
        //        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorRed;
        return annotationView;
    }
    return nil;
}

#pragma mark - 其他功能
//发送位置
- (void)sendPosition
{
    if (_my_city == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法定位您的位置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    UIViewController *setPrizeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    if ([setPrizeVC isKindOfClass:[WritePostViewController class]]) {
        
        if (![_my_city isEqualToString:@"成都市"] && ![_my_city isEqualToString:@"北京市"] && ![_my_city isEqualToString:@"上海市"] && ![_my_city isEqualToString:@"广州市"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"目前版本只能分享成都、北京、上海、广州四个城市的内容，更多城市敬请期待" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        WritePostViewController *vc = (WritePostViewController *)setPrizeVC;
        if (_chosen_model) {
            //初始化其属性
            vc.positionModel = nil;
            PositionModel *model = [[PositionModel alloc] init];
            model.position_name = _chosen_model.name;
            model.longitude = _chosen_model.longitude;
            model.latitude = _chosen_model.latitude;
            vc.city = _my_city;
            vc.positionModel = model;
        }
    }
    else if ([setPrizeVC isKindOfClass:[CreateActivityViewController class]])
    {
        CreateActivityViewController *vc = (CreateActivityViewController *)setPrizeVC;
        if (_chosen_model) {
            //初始化其属性
            vc.positionModel = nil;
            PositionModel *model = [[PositionModel alloc] init];
            model.position_name = _chosen_model.name;
            model.longitude = _chosen_model.longitude;
            model.latitude = _chosen_model.latitude;
            vc.positionModel = model;
        }
    }
    
    //使用popToViewController返回并传值到上一页面
    [self.navigationController popViewControllerAnimated:YES];
}

@end
