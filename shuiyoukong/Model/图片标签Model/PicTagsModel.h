//
//  PicTagsModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/20.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "addTagsModel.h"

@interface PicTagsModel : NSObject

@property (nonatomic, strong)NSString *imgUrl;

@property (nonatomic, strong)NSMutableArray *imgTagList;

@end
