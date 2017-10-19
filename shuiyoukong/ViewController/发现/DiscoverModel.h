//
//  DiscoverModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/15.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "PicTagsModel.h"

@interface DiscoverModel : NSObject

@property (nonatomic, strong)NSString *accountId;
@property (nonatomic, strong)NSString *head_Img;
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *big_Img;
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *content;
@property (nonatomic, strong)NSString *editor_comment;
@property (nonatomic, strong)NSString *num;
@property (nonatomic, strong)NSString *postId;
@property (nonatomic, strong)NSString *reCount;
@property (nonatomic, strong)NSString *address;
@property (nonatomic, assign)CGFloat latitude;
@property (nonatomic, assign)CGFloat longitude;
@property (nonatomic, assign)BOOL isUp;
@property (nonatomic, strong)NSMutableArray *img_array;
@property (nonatomic, strong)NSString *recommendTime;
@property (nonatomic, strong)NSString *type;
@property (nonatomic, strong)NSString *distance;

@property (nonatomic, strong)NSMutableArray *imgTagsArray;
@end
