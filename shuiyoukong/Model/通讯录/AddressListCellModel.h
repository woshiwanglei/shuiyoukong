//
//  AddressListCellModel.h
//  Free
//
//  Created by 勇拓 李 on 15/5/5.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressListCellModel : NSObject <NSCopying>

@property(nonatomic, copy)NSString *session_id;
@property(nonatomic, copy)NSString *img_url;
@property(nonatomic, copy)NSString *user_name;
@property(nonatomic, copy)NSString *Id;
@property(nonatomic, copy)NSNumber *status;
@property(nonatomic, copy)NSString *friendId;
@property(nonatomic, copy)NSString *pinyin;
@property(nonatomic, copy)NSString *phoneNo;

@property(assign)BOOL isTurnOn;


@end
