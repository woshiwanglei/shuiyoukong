//
//  PostViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/21.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverModel.h"

@interface PostViewController : UIViewController

@property (nonatomic, strong)DiscoverModel *model;

@property (nonatomic, strong)NSString *postId;

@end
