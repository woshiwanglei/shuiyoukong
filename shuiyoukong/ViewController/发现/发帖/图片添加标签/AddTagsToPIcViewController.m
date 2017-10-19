//
//  AddTagsToPIcViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/19.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "AddTagsToPIcViewController.h"
#import "AddTagsToPicView.h"
#import "settings.h"
#import "AppDelegate.h"
#import "KCView.h"
#import "WritePostViewController.h"

@interface AddTagsToPIcViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;
@property (weak, nonatomic) IBOutlet UIButton *btn_commit;

@property (strong, nonatomic)AddTagsToPicView *addTagsView;

//用来保存标签的view
@property (strong, nonatomic)NSMutableArray *viewArray;
//背景蒙层
@property (strong, nonatomic)UIView *blackbackground;

@end

@implementation AddTagsToPIcViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self resignNotice];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


#pragma mark - notice
- (void)resignNotice
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imgAddTags:) name:FREE_NOTIFICATION_ADD_TAG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editTags:) name:FREE_NOTIFICATION_EDIT_TAG object:nil];
}

//点击完成，在图片上显示图标
- (void)imgAddTags:(NSNotification *)notification
{
    [_addTagsView removeFromSuperview];
    [_blackbackground removeFromSuperview];
    
    addTagsModel *model = notification.object;
    
    for (KCView *view in _viewArray) {
        if (view.model.point.x == model.point.x && view.model.point.y == model.point.y) {
            [view removeFromSuperview];
            [_viewArray removeObject:view];
            break;
        }
    }
    
    if (!model.fristLabel && !model.secondLabel && !model.thirdLabel && !model.forthLabel) {
        return;
    }
    
    [self addViewInPoint:model];
}

- (void)addViewInPoint:(addTagsModel *)model
{
    KCView *view = [[[NSBundle mainBundle] loadNibNamed:@"KCView"
                                                  owner:self
                                                options:nil] objectAtIndex:0];
    for (int i = 0; i < 4; i++) {
        [self adjustPoint:i + 1 model:model];
    }
    view.model = model;
    view.bounds = (CGRect){CGPointZero, CGSizeMake(30, 30)};
    
    view.center = model.point;
    [_viewArray addObject:view];
    [self.view addSubview:view];
}

- (void)adjustPoint:(NSInteger )type model:(addTagsModel *)model
{
    UILabel *ui_Label = [[UILabel alloc] init];
    
    NSString *strLabel;
    switch (type) {
        case 4:
            strLabel = model.fristLabel;
            if (strLabel == nil) {
                model.firstLength = 0;
                return;
            }
            break;
        case 3:
            strLabel = model.secondLabel;
            if (strLabel == nil) {
                model.secondLabel = 0;
                return;
            }
            break;
        case 2:
            strLabel = model.thirdLabel;
            if (strLabel == nil) {
                model.thirdLabel = 0;
                return;
            }
            break;
        default:
            strLabel = model.forthLabel;
            if (strLabel == nil) {
                model.forthLength = 0;
                return;
            }
            break;
    }
    
    ui_Label.text = strLabel;
    [self adjustLabelFont:ui_Label];
    ui_Label.textColor = [UIColor whiteColor];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strLabel];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 5;
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowOffset = CGSizeMake(1, 2);
    
    [str addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0,[strLabel length])];
    
    ui_Label.attributedText = str;
    CGSize size = [ui_Label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, FLT_MAX)];
    CGFloat x = model.point.x;
    CGFloat y = model.point.y;
    switch (type) {
        case 1:
        {
            if ((x + 15 + 10 + size.width) > [UIScreen mainScreen].bounds.size.width)
            {
                x = model.point.x - (model.point.x + 15 + 10 + size.width) + [UIScreen mainScreen].bounds.size.width;
                x = x - 5;//留5的padding
            };
            if ((y + 15) >= [UIScreen mainScreen].bounds.size.width) {
                y = [UIScreen mainScreen].bounds.size.width - 15;
                y = y - 5;
            }
            model.forthLength = size.width;
        }
            break;
        case 2:
        {
            if ((x - 15 - 10 - size.width) < 0)
            {
                x = 15 + 10 + size.width;
                x = x + 5;//留5的padding
            };
            if ((y + 15) >= [UIScreen mainScreen].bounds.size.width) {
                y = [UIScreen mainScreen].bounds.size.width - 15;
                y = y - 5;
            }
            model.thridLength = size.width;
        }
            break;
        case 3:
        {
            if ((x + 15 + 10 + size.width) > [UIScreen mainScreen].bounds.size.width)
            {
                x = model.point.x - (model.point.x + 15 + 10 + size.width) + [UIScreen mainScreen].bounds.size.width;
                x = x - 5;//留5的padding
            };
            if ((y - size.height - 15 - 2) < 0) {
                y = size.height + 15 + 2;
                y = y + 5;
            }
            model.secondLength = size.width;
        }
            break;
        default:
        {
            if ((x - 15 - 10 - size.width) < 0)
            {
                x = 15 + 10 + size.width;
                x = x + 5;//留5的padding
            };
            if ((y - size.height - 15 - 2) < 0) {
                y = size.height + 15 + 2;
                y = y + 5;
            }
            model.firstLength = size.width;
        }
            break;
    }
    
    model.point = CGPointMake(x, y);
    
}

- (void)adjustLabelFont:(UILabel *)label
{
    if ([UIScreen mainScreen].bounds.size.width <= 320) {
        label.font = [UIFont boldSystemFontOfSize:10.f];
    }
    else
    {
        label.font = [UIFont boldSystemFontOfSize:12.f];
    }
}

//点击图标，进入编辑界面
- (void)editTags:(NSNotification *)notification
{
    addTagsModel *model = notification.object;
    [self showEditTags:model];
}


#pragma mark - initView
- (void)initView
{
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTags:)];
    [_cover_img addGestureRecognizer:tapGes];
    _cover_img.userInteractionEnabled = YES;
    
    _viewArray = [NSMutableArray array];
    //不会超出图片
    _cover_img.clipsToBounds = YES;
    _cover_img.image = _img;
    
    [_btn_commit addTarget:self action:@selector(btn_commit_Tapped:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_cancel addTarget:self action:@selector(btn_cancel_Tapped:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 通知方法
//通知方法
- (void)addTags:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture locationInView:self.view];
    CGFloat x = touchPoint.x;
    CGFloat y = touchPoint.y;
    //判断边际
    if(y > ([UIScreen mainScreen].bounds.size.width - 15))
    {
        y = [UIScreen mainScreen].bounds.size.width - 15;
    }
    
    if (y < 15) {
        y = 15;
    }
    
    if (x < 15) {
        x = 15;
    }
    
    if (x > ([UIScreen mainScreen].bounds.size.width - 15)) {
        x = ([UIScreen mainScreen].bounds.size.width - 15);
    }
    
    addTagsModel *model = [[addTagsModel alloc] init];
    model.point = CGPointMake(x, y);
    [self showEditTags:model];
}

- (void)showEditTags:(addTagsModel *)model
{
    if (!_blackbackground) {
        _blackbackground = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _blackbackground.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
    }
    
//    if (!_addTagsView) {
        _addTagsView =
        [[[NSBundle mainBundle] loadNibNamed:@"AddTagsToPicView"
                                       owner:self
                                     options:nil] objectAtIndex:0];
        _addTagsView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _addTagsView.vc = self;
//    }
    
    //touchPoint.x ，touchPoint.y 就是触点的坐标。
    
    //    view.bounds = (CGRect){CGPointZero, CGSizeMake(120, 80)};
    //    view.center = CGPointMake(touchPoint.x, touchPoint.y - 20);
    _addTagsView.model = model;
    [_blackbackground addSubview:_addTagsView];
    [[AppDelegate getMainWindow] addSubview:_blackbackground];
}


#pragma mark - 按钮方法
- (void)btn_cancel_Tapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//确认
- (void)btn_commit_Tapped:(id)sender
{
    UIViewController *setPrizeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    if ([setPrizeVC isKindOfClass:[WritePostViewController class]]) {
        if ([_viewArray count]) {
            NSMutableArray *array = [NSMutableArray array];
            for (KCView *view in _viewArray) {
                addTagsModel *model = view.model;
                [array addObject:model];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_CHANGE_TAG object:array];//有标签传数据
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_CHANGE_TAG object:nil];//没标签传空
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        WritePostViewController *vc =
        [[WritePostViewController alloc] initWithNibName:@"WritePostViewController" bundle:nil];
        vc.cover_url = _img;
        vc.hidesBottomBarWhenPushed = YES;
        vc.pic_index = 1;//第一次传封面的索引为1, 0代表没进入别的界面
        if ([_viewArray count]) {
            NSMutableArray *array = [NSMutableArray array];
            for (KCView *view in _viewArray) {
                addTagsModel *model = view.model;
                [array addObject:model];
            }
            vc.pic_tags_Array = array;
        }
        UINavigationController *nav = self.navigationController;
        [nav popViewControllerAnimated:NO];
        [nav pushViewController:vc animated:YES];
    }
}

@end
