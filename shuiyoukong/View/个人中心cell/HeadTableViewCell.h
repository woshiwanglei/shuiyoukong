//
//  HeadTableViewCell.h
//  Free
//
//  Created by yangcong on 15/5/12.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeadCellModel.h"
#import "InterfaceImageView.h"


@interface HeadTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet InterfaceImageView *headImage;

@property (weak, nonatomic) IBOutlet UILabel *headUserName;

@property (strong, nonatomic) HeadCellModel *headCell;
@property (weak, nonatomic) IBOutlet UIButton *btn_lv;
@property (weak, nonatomic) IBOutlet UILabel *label_Lv;


@end
