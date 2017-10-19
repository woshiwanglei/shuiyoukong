//
//  CoupleSuccTableViewController.h
//  Free
//
//  Created by 勇拓 李 on 15/5/14.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarCollectionViewCell.h"


@interface CoupleSuccTableViewController : UIViewController

@property (nonatomic, copy)NSString *freeDate;
@property (nonatomic, copy)NSString *freeStartTime;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (nonatomic, assign)NSInteger fromTag;

@property (nonatomic, copy)NSString *remark;
@property (nonatomic, weak)CalendarCollectionViewCell *cell_view;

@end
