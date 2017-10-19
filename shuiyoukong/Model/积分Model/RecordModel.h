//
//  RecordModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductModel.h"

@interface RecordModel : NSObject
@property (nonatomic, strong)NSString *recordId;
@property (nonatomic, strong)NSString *itemId;// 商品id
@property (nonatomic, strong)NSString *exchangeDate;// 兑换日期
@property (nonatomic, strong)NSString *barcode;// 兑换码

@property (nonatomic, strong)ProductModel *model;
@end
