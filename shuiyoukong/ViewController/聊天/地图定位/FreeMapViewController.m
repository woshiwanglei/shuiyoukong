//
//  FreeMapViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/26.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FreeMapViewController.h"
#import <MAMapKit/MAMapKit.h>


@interface FreeMapViewController ()<MAMapViewDelegate>
{
    MAMapView *_mapView;
}

@end

@implementation FreeMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *title = _locationName;
    if ([title length] > 5) {
        title = [title substringToIndex:5];
        title = [NSString stringWithFormat:@"%@...", title];
    }
    
    self.navigationItem.title = title;
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 10.5, 20)];
//    [btn addTarget:self action:@selector(leftLongPress:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc ] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftLongPress:)];
    self.navigationItem.leftBarButtonItem = backItem;
    [self initMapView];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftLongPress:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(_location.latitude, _location.longitude);
    pointAnnotation.title = _locationName;
    
    [_mapView addAnnotation:pointAnnotation];
}

- (void)initMapView
{
//    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
//    _mapView.delegate = self;
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    
    [self performSelector:@selector(delaySetCenter) withObject:nil afterDelay:0.5f];
    
    [self.view addSubview:_mapView];
    _mapView.showsUserLocation = NO;
//    
    [_mapView setZoomLevel:18 animated:NO];
//    _mapView.showsCompass= NO;//不要指南针
//    _mapView.showsScale= NO;//不要比例尺
//    _mapView.userInteractionEnabled = YES;
//    [self.view addSubview:_mapView];
}

- (void)delaySetCenter
{
    _mapView.centerCoordinate = _location;
    [_mapView setCenterCoordinate:_location animated:NO];
}

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
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
//        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorGreen;
        return annotationView;
    }
    return nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
