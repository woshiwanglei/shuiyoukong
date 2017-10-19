//
//  AddressListTableViewCell.h
//  Free
//
//  Created by 勇拓 李 on 15/5/5.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressListCellModel.h"
#import "FreeSQLite.h"

#import "FontSizemodle.h"

@class AddressListCellModel;

#define MY_CARE 1
#define CARE_ME 2
#define CARE_EACH 3

#define COME_FROM_FANS 321
#define COME_FROM_CARE 123

@interface AddressListTableViewCell : UITableViewCell

//@property (weak, nonatomic) IBOutlet UISwitch *switch_attention;
@property (weak, nonatomic) IBOutlet UIImageView *img_head;
//@property (weak, nonatomic) IBOutlet UILabel *label_attention;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UIButton *btn_followed;

@property(nonatomic,strong) AddressListCellModel *model;

@end
