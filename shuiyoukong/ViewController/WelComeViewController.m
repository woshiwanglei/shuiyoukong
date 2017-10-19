//
//  WelComeViewController.m
//  Free
//
//  Created by yangcong on 15/5/7.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "WelComeViewController.h"
#import "LoginViewController.h"
#import "settings.h"

@interface WelComeViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;

//@property (strong, nonatomic) UIButton *enterBtn;
@end

@implementation WelComeViewController
-(NSArray *)images
{
    if (!_images)
    {
        _images = @[@"1",@"2",@"3",@"4",@"5"];
    }
    return _images;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self initView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)dealloc
{
    NSLog(@"dealloc Welcome");
}

-(void)initView
{
    //创建scroollview对象
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    scrollview.contentSize = CGSizeMake(scrollview.frame.size.width*self.images.count, 0);
    [scrollview setShowsHorizontalScrollIndicator:NO];
    scrollview.pagingEnabled = YES;
    
    scrollview.delegate = self;
    
    
    for (int i = 0; i < [_images count]; i++)
    {
        UIImage *image = [UIImage imageNamed:_images[i]];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        //计算坐标
        CGRect frame = CGRectZero;
        
        frame.origin.x = i*scrollview.frame.size.width;
        
        frame.origin.y = 0;
        //大小
        frame.size = scrollview.frame.size;
        
        imageView.frame = frame;
        
        //跳过 确定按钮
        UIButton *button = [[UIButton alloc] init];
        button.layer.borderColor = [[UIColor clearColor] CGColor];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 5;
        
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button addTarget:self action:@selector(Loginincident) forControlEvents:UIControlEventTouchUpInside];
        imageView.userInteractionEnabled = YES;
        
        if (i != 4) {
            [imageView addSubview: button];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            button.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
            [button setTitle:@"跳过" forState:UIControlStateNormal];
            
            NSDictionary *metrics = @{
                                      @"height" : @(30),
                                      @"width" : @(40)
                                      };
            
            NSDictionary *views= NSDictionaryOfVariableBindings(button);
            
            [imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(width)]-20-|"options:0 metrics:metrics views:views]];
            
            [imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[button(height)]"options:0 metrics:metrics views:views]];
            
        }
        else
        {
            [imageView addSubview: button];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            button.backgroundColor = FREE_BACKGOURND_COLOR;
            [button setTitle:@"进入" forState:UIControlStateNormal];
            
            NSDictionary *metrics = @{
                                      @"height" : @(35),
                                      @"width" : @(60)
                                      };
            
            NSDictionary *views = NSDictionaryOfVariableBindings(button);
            
            [imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(width)]"options:0 metrics:metrics views:views]];
            
            [imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(height)]-60-|"options:0 metrics:metrics views:views]];
            [imageView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
            
        }
        [scrollview addSubview:imageView];
    }
    
    [self.view addSubview:scrollview];
    
    UIPageControl *pageCont = [[UIPageControl alloc] init];
    
    self.pageControl = pageCont;
    
    self.pageControl.userInteractionEnabled = NO;
    pageCont.numberOfPages = [_images count];
    
    pageCont.pageIndicatorTintColor = [UIColor colorWithRed:135/255.0 green:135/255.0 blue:135/255.0 alpha:1];
    
    pageCont.currentPageIndicatorTintColor = [UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1];
    
    pageCont.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:pageCont];
    
    NSDictionary *metricss = @{
                               @"height" : @(35),
                               @"width" : @(self.view.frame.size.width)
                               };
    
    NSDictionary *viewss = NSDictionaryOfVariableBindings(pageCont);
    //宽度
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[pageCont(width)]"options:0 metrics:metricss views:viewss]];
    //居中
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:pageCont attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    //高度和距离底部的间距
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageCont(height)]-20-|"options:0 metrics:metricss views:viewss]];
    
//    [self addConstraints:
//     [NSLayoutConstraint
//      constraintsWithVisualFormat:@"H:|-0-[subView0(width)]-0-[subView1(subView0)]-0-[subView2(subView0)]-0-[subView3(subView0)]-0-[subView4(subView0)]-0-[subView5(subView0)]-0-[subView6(width)]-0-|"
//      options:0
//      metrics:metrics
//      views:views]];
//    [self addConstraints:[NSLayoutConstraint
//                          constraintsWithVisualFormat:
//                          @"V:|-0-[subView0(height)]-0-|"
//                          options:0
//                          metrics:metrics
//                          views:views]];
//    [self addConstraints:[NSLayoutConstraint
//                          constraintsWithVisualFormat:
//                          @"V:|-0-[subView1(height)]-0-|"
//                          options:0
//                          metrics:metrics
//                          views:views]];
    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_enterBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    
}
//添加一个滑动图片的时间方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint ofsize = scrollView.contentOffset;
    
    if (ofsize.x < 0)
    {
        ofsize.x = 0;
        
        scrollView.contentOffset = ofsize;
    }
    
    NSInteger index = round(ofsize.x/scrollView.frame.size.width);

    self.pageControl.currentPage = index;
    
}

//按键触发的事件
-(void)Loginincident
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController * vc = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:NO completion:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = vc;

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

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
