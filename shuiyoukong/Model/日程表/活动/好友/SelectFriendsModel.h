//
//  SelectFriensModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/2.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectFriendsModel : NSObject

@property (nonatomic, strong)NSString *img_url;

@property (nonatomic, strong)NSString *name;

@property (nonatomic, strong)NSString *accountId;

@property (nonatomic, assign)NSInteger fromInfo;

@property (nonatomic, assign)BOOL isSelected;

@property (nonatomic, assign)NSInteger status;

@property (nonatomic, strong)NSString *pinyin;

@end
