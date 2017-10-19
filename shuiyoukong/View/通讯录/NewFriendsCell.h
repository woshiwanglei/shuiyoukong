//
//  NewFriendsCell.h
//  Free
//
//  Created by 勇拓 李 on 15/5/9.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontSizemodle.h"
@interface NewFriendsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btn_newFriends;
@property (weak, nonatomic) IBOutlet UILabel *label_name;

@property (assign, nonatomic) BOOL isNew;

@property (assign, nonatomic) BOOL isFirst;

@end
