//
//  BtnModel.h
//  Free
//
//  Created by yangcong on 15/5/8.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BtnModel : NSObject
@property (nonatomic, assign) BOOL isSucceed;
@property (nonatomic, copy) NSString *btnTitle;
@property (nonatomic,copy) NSString *tag;
@property (nonatomic, weak) NSString *type;

@end
