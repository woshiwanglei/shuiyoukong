//
//  CarlendSquaresView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarlendSquaresModel.h"

@interface CarlendSquaresView : UIView
@property (weak, nonatomic) IBOutlet UIView *view_square;
@property (weak, nonatomic) IBOutlet UIButton *btn_choose;

@property (strong, nonatomic)CarlendSquaresModel *model;
@end
