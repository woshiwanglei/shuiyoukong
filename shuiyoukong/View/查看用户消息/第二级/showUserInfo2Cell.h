//
//  showUserInfo2Cell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/27.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "showUserInfo2Model.h"

@interface showUserInfo2Cell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet UILabel *label_content;

@property (strong, nonatomic)showUserInfo2Model *model;

@end
