//
//  FreeLocationPickerViewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/26.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FreeLocationPickerViewController.h"
#import "settings.h"

@interface FreeLocationPickerViewController ()

@end

@implementation FreeLocationPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *btnitem = self.navigationItem.rightBarButtonItem;
    btnitem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)rightBarButtonItemPressed:(id)sender
//{
//    [super rightBarButtonItemPressed:sender];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
