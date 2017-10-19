//
//  FreeWebViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FreeWebViewController : UIViewController

@property (nonatomic, strong)NSString *url;
@property (nonatomic, strong)NSString *url_title;

@property (nonatomic, strong)UIImage *img;

@property (nonatomic, strong)NSString *content;

@property (nonatomic, strong)NSString *imgUrl;

@property (nonatomic, assign)NSInteger fromTag;

@end
