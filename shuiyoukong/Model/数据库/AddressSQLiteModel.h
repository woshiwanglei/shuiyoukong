//
//  AddressSQLiteModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/7.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressSQLiteModel : NSObject

@property (nonatomic, strong) NSString *phoneNo;
@property (nonatomic, strong) NSString *friendName;
@property (nonatomic, strong) NSString *imgUrl;
@property (nonatomic, strong) NSString *pinyin;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *friendAccountId;
@property (nonatomic, strong) NSNumber *type;

@end
