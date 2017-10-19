//
//  FreeAddressBook.h
//  Free
//
//  Created by 勇拓 李 on 15/5/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "FreeSQLite.h"
#import "FreeSingleton.h"

@interface FreeAddressBook : NSObject

+ (void)initAddressList:(NSMutableArray *)dataSource;

//+ (void)updateData;
+ (void)synAddressListData:(NSMutableArray *)dataSource freeblock:(FreeBlock)freeblock;

+ (void)getAddressListData;

+ (void)insertFreeDataSource:(id)data dataSource:(NSMutableArray *)dataSource;
@end