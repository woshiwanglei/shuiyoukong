//
//  ProductModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductModel : NSObject
@property (nonatomic, strong)NSString *itemId;
@property (nonatomic, strong)NSString *itemName;// 商品名称
@property (nonatomic, strong)NSNumber *needPoints;// 需要的积分数
@property (nonatomic, strong)NSString *imgUrl;// 商品描述图片
@property (nonatomic, strong)NSString *Description;// 描述
@property (nonatomic, strong)NSString *expireDate;
@property (nonatomic, strong)NSNumber *itemCount;// 商品数量
@property (nonatomic, strong)NSNumber *type;// 商品类型

@property (nonatomic, strong)NSMutableArray *imgArray;

@end
