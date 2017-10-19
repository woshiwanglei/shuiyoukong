//
//  SquareTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubSquareView.h"
//#import "DiscoverViewController.h"

@interface SquareTableViewCell : UITableViewCell

@property(strong, nonatomic)SubSquareView *leftSubView;

@property(strong, nonatomic)SubSquareView *rightSubView;

@property(strong, nonatomic)NSMutableArray *modelArray;

@property (weak, nonatomic) UIViewController *discover_vc;

@end
