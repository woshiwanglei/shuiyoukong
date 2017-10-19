//
//  CreateActivityViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PositionModel.h"

@interface CreateActivityViewController : UIViewController

@property (nonatomic, strong)NSString *activity_title;

@property (nonatomic, strong)PositionModel *positionModel;

@property (nonatomic, strong)NSString *activity_content;

@property (nonatomic, strong)NSMutableArray *friendsArray;

@property (nonatomic, strong)NSString *post_Id;

@property (nonatomic, strong)NSString *cover_img_url;

//@property (nonatomic, strong)UIImage *cover_img;

@end
