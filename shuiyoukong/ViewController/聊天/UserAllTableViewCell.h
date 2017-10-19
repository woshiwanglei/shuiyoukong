//
//  UserAllTableViewCell.h
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Crowdmodel.h"
#import "personnelView.h"
@interface UserAllTableViewCell : UITableViewCell

@property(nonatomic,strong)   UITapGestureRecognizer *tapView;

@property(nonatomic,strong) Crowdmodel *model;

@property(nonatomic,strong) personnelView *view;

+ (float)cellHeight:(Crowdmodel *)model;

@end
