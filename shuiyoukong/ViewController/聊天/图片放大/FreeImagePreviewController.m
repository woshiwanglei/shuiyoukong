//
//  FreeImagePreviewController.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/25.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FreeImagePreviewController.h"
#import "settings.h"

@interface FreeImagePreviewController ()

@end

@implementation FreeImagePreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *btnitem = self.navigationItem.rightBarButtonItem;
    UIBarButtonItem *btnitem2 = self.navigationItem.leftBarButtonItem;
    btnitem.tintColor = [UIColor whiteColor];
    btnitem2.tintColor = [UIColor whiteColor];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
