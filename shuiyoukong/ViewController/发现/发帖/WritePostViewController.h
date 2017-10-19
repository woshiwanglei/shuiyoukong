//
//  WritePostViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PositionModel.h"

@interface WritePostViewController : UIViewController

@property (nonatomic, strong)UIImage *cover_url;

@property (nonatomic, strong)PositionModel *positionModel;

@property (nonatomic, strong)NSString *share_Content;

@property (nonatomic, strong)NSMutableArray *tags_array;

@property (nonatomic, strong)NSMutableArray *pic_tags_Array;

@property (nonatomic, strong)NSString *city;//选择的城市

//添加标签图片的编号
@property (nonatomic, assign)NSInteger pic_index;

@end
