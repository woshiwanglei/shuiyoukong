//
//  KCView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/19.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addTagsModel.h"

@interface KCView : UIView

@property (strong, nonatomic)addTagsModel *model;
@property (weak, nonatomic) IBOutlet UIView *white_point;
//@property (assign, nonatomic)BOOL not_needToHidden;//判断是否会继续显示
@property (weak, nonatomic) IBOutlet UIView *black_point;
@property (assign, nonatomic)BOOL cannottBeMove;
@end
