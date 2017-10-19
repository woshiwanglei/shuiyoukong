//
//  MessageCenterTableViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OFFICIAL 0
#define COMMENT  1
#define ACTIVITY 2

@interface MessageCenterTableViewController : UITableViewController

@property (nonatomic, assign)NSInteger type;

@end
