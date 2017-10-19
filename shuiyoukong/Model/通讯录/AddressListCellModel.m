//
//  AddressListCellModel.m
//  Free
//
//  Created by 勇拓 李 on 15/5/5.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "AddressListCellModel.h"

@implementation AddressListCellModel

- (id)copyWithZone:(NSZone *)zone
{
    AddressListCellModel *copy = [[[self class] allocWithZone:zone] init];
    copy.session_id = self.session_id;
    copy.img_url = self.img_url;
    copy.user_name = self.user_name;
    copy.Id = self.Id;
    copy.status = self.status;
    copy.friendId = self.friendId;
    copy.pinyin = self.pinyin;
    copy.phoneNo = self.phoneNo;
    
    return copy;
}

@end