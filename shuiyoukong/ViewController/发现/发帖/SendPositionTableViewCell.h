//
//  SendPositionTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PositionModel.h"

@interface SendPositionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label_position;
@property (weak, nonatomic) IBOutlet UIButton *btn_chosen;
@property (weak, nonatomic) IBOutlet UILabel *label_name;

@property (strong, nonatomic)PositionModel *model;

@end
