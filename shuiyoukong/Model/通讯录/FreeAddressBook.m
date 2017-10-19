//
//  FreeAddressBook.m
//  Free
//
//  Created by 勇拓 李 on 15/5/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//


#import "FreeAddressBook.h"
#import "FreeSingleton.h"
#import "settings.h"
#import "Error.h"
#import "Utils.h"
#import "AddressSQLiteModel.h"
#import "AddressListCellModel.h"

@implementation FreeAddressBook


+ (void)initAddressList:(NSMutableArray *)dataSource
{
    
    NSMutableArray *insideArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    ABAddressBookRef tmpAddressBook = nil;
    
    tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
        dispatch_semaphore_signal(sema);
    });
    
//    ABAddressBookRegisterExternalChangeCallback(tmpAddressBook, addressBookChanged, (__bridge void *)(self));
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    //取得通讯录失败
    if (tmpAddressBook == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
        return;
    };
    [KVNProgress showWithStatus:@"同步通讯录中，请稍候..."];
    
    //将通讯录中的信息用数组方式读出
    CFArrayRef peoples = ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
    NSArray* tmpPeoples = (__bridge NSArray *)peoples;
    CFRelease(peoples);
    
    //遍历通讯录中的联系人
    for(id tmpPerson in tmpPeoples)
    {
        //获取的联系人单一属性:Generic phone number
        ABMultiValueRef tmpPhones = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonPhoneProperty);
        for(NSInteger j = 0; j < ABMultiValueGetCount(tmpPhones); j++)
        {
            CFStringRef tmpPhoneIndex = ABMultiValueCopyValueAtIndex(tmpPhones, j);
            NSString* tmpPhoneIndexTmp = (__bridge NSString *)tmpPhoneIndex;
            tmpPhoneIndexTmp = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@"-" withString:@""];
            tmpPhoneIndexTmp = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString* tmpPhoneIndexReal = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@"+86" withString:@""];
            CFRelease(tmpPhoneIndex);
            
            if ([tmpPhoneIndexReal length] != 11) {
                continue;
            }
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:MOBILE_NUM_REGEX options:0 error:nil];
            NSUInteger numOfMatch = [regex numberOfMatchesInString:tmpPhoneIndexReal
                                                           options:NSMatchingAnchored
                                                             range:NSMakeRange(0, [tmpPhoneIndexReal length])];
            if (numOfMatch == 0) {
                continue;
            }
            
            if ([tmpPhoneIndexReal isEqualToString:[[FreeSingleton sharedInstance] getPhoneNo]])
            {
                continue;
            }
            
            //获取的联系人单一属性:First name
            CFStringRef firstName = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonFirstNameProperty);
            NSString* tmpFirstName = (__bridge NSString *)firstName;
            //获取的联系人单一属性:Last name
            CFStringRef lastName = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonLastNameProperty);
            NSString* tmpLastName = (__bridge NSString *)lastName;
            
            NSString *name = [NSString stringWithFormat:@"%@%@", tmpLastName, tmpFirstName];
            
            name  = [name stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            
            if (lastName != nil) {
                CFRelease(lastName);
            }
            if (firstName != nil) {
                CFRelease(firstName);
            }
            
            if (name == nil || [name isEqualToString:@""] || [name length] == 0) {
                continue;
            }
            
            NSString *pinyin = [name mutableCopy];
            CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformMandarinLatin,NO);
            //再转换为不带声调的拼音
            CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformStripDiacritics,NO);
            
            pinyin = [NSString stringWithFormat:@"\"%@\"", pinyin];
            name = [NSString stringWithFormat:@"\"%@\"", name];
            
            [dic setObject:tmpPhoneIndexReal forKey:@"phoneNo"];
            [dic setObject:name forKey:@"friendName"];
            [dic setObject:pinyin forKey:@"pinyin"];
            [insideArray addObject:[dic mutableCopy]];
            
        }
        CFRelease(tmpPhones);
    }
    
    //释放内存
    CFRelease(tmpAddressBook);
    
    NSSet *set = [NSSet setWithArray:insideArray];
    
    NSString *phoneList = [[set allObjects] componentsJoinedByString:@" "];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"{" withString:@"[{"];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"}" withString:@"}]"];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"] [" withString:@","];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@";" withString:@","];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@",\n}" withString:@"}"];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"U" withString:@"u"];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"\\\"" withString:@""];
    
    NSInteger ret = [[FreeSingleton sharedInstance] sendAddressListOnCompletion:phoneList block:^(NSUInteger retcode, id data) {
        
        if (retcode == RET_SERVER_SUCC) {
            
            [[FreeSQLite sharedInstance] clearAllTable:ADDRESS_TABLE_NAME];
            
            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:ADDRESS_TABLE tableName:ADDRESS_TABLE_NAME];
            
            NSMutableArray *modelArray = [NSMutableArray array];
            [self insertFreeDataSource:data dataSource:modelArray];
            [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:modelArray];
            [FreeAddressBook add2Model:dataSource data:data phoneNo:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress dismiss];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [KVNProgress dismiss];
            });
        }
    }];
    
    if (ret != RET_OK) {
        [KVNProgress dismiss];
        NSLog(@"AddressList error: %@", zcErrMsg(ret));
    }
    
}

+ (void)updateData
{
    NSMutableArray *outsideArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:ADDRESS_TABLE tableName:ADDRESS_TABLE_NAME];
    
    ABAddressBookRef tmpAddressBook = nil;
    
    tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
        dispatch_semaphore_signal(sema);
    });
    
    //    ABAddressBookRegisterExternalChangeCallback(tmpAddressBook, addressBookChanged, (__bridge void *)(self));
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    //取得通讯录失败
    if (tmpAddressBook == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
        //释放内存
        return;
    };
    
    //将通讯录中的信息用数组方式读出
    CFArrayRef peoples = ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
    NSArray* tmpPeoples = (__bridge NSArray *)peoples;
    CFRelease(peoples);
//    NSArray* tmpPeoples = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        for(id tmpPerson in tmpPeoples)
        {
            //获取的联系人单一属性:Generic phone number
            ABMultiValueRef tmpPhones = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonPhoneProperty);
            for(NSInteger j = 0; j < ABMultiValueGetCount(tmpPhones); j++)
            {
                CFStringRef tmpPhoneIndex = ABMultiValueCopyValueAtIndex(tmpPhones, j);
                NSString* tmpPhoneIndexTmp = (__bridge NSString *)tmpPhoneIndex;
                tmpPhoneIndexTmp = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@"-" withString:@""];
                tmpPhoneIndexTmp = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSString* tmpPhoneIndexReal = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                CFRelease(tmpPhoneIndex);
                
                if ([tmpPhoneIndexReal length] != 11) {
                    continue;
                }
                
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:MOBILE_NUM_REGEX options:NSRegularExpressionCaseInsensitive error:nil];
                NSUInteger numOfMatch = 0;
                numOfMatch = [regex numberOfMatchesInString:tmpPhoneIndexReal
                                                    options:NSMatchingAnchored
                                                      range:NSMakeRange(0, [tmpPhoneIndexReal length])];
                if (numOfMatch == 0) {
                    continue;
                }
                
                if ([tmpPhoneIndexReal isEqualToString:[[FreeSingleton sharedInstance] getPhoneNo]])
                {
                    continue;
                }
                
                //获取的联系人单一属性:First name
                CFStringRef firstName = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonFirstNameProperty);
                NSString* tmpFirstName = (__bridge NSString *)firstName;
                //获取的联系人单一属性:Last name
                CFStringRef lastName = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonLastNameProperty);
                NSString* tmpLastName = (__bridge NSString *)lastName;
                NSString *name = [NSString stringWithFormat:@"%@%@", tmpLastName, tmpFirstName];
                name  = [name stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                if (lastName != nil) {
                    CFRelease(lastName);
                }
                if (firstName != nil) {
                    CFRelease(firstName);
                }
                
                if (name == nil || [name isEqualToString:@""] || [name length] == 0) {
                    continue;
                }
                
                NSString *pinyin = [name mutableCopy];
                
                CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformMandarinLatin,NO);
                //再转换为不带声调的拼音
                CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformStripDiacritics,NO);
                pinyin = [NSString stringWithFormat:@"\"%@\"", pinyin];
                name = [NSString stringWithFormat:@"\"%@\"", name];
                
                [dic setObject:tmpPhoneIndexReal forKey:@"phoneNo"];
                [dic setObject:name forKey:@"friendName"];
                [dic setObject:pinyin forKey:@"pinyin"];
                
                if ([[[FreeSQLite sharedInstance] selectFreeSQLitePhoneNo:tmpPhoneIndexReal]
                     isEqualToString:NOTINADDRESSLIST]) {
                    [outsideArray addObject:[dic mutableCopy]];
                }
                
            }
            CFRelease(tmpPhones);
        }
    
    //遍历通讯录中的联系人
    
    
    //释放内存
    CFRelease(tmpAddressBook);
    
    if ([outsideArray count] == 0) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
        return;
    }
    
    NSSet *set = [NSSet setWithArray:outsideArray];
    
    NSString *phoneList = [[set allObjects] componentsJoinedByString:@" "];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"{" withString:@"[{"];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"}" withString:@"}]"];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"] [" withString:@","];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@";" withString:@","];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@",\n}" withString:@"}"];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"U" withString:@"u"];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneList = [phoneList stringByReplacingOccurrencesOfString:@"\\\"" withString:@""];
    
    NSInteger ret = [[FreeSingleton sharedInstance] sendAddressListOnCompletion:phoneList block:^(NSUInteger retcode, id data) {
        if (retcode == RET_SERVER_SUCC) {
            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[FreeSQLite sharedInstance] clearAllTable:ADDRESS_TABLE_NAME];
                
                [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:ADDRESS_TABLE tableName:ADDRESS_TABLE_NAME];
                
            NSMutableArray *modelArray = [NSMutableArray array];
            [self insertFreeDataSource:data dataSource:modelArray];
            [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:modelArray];
            
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
//            });
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
            [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
        }
    }];
    
    if (ret != RET_OK) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
        NSLog(@"AddressList error: %@", zcErrMsg(ret));
    }
    
}

+ (void)getAddressListData
{
    NSMutableArray *outsideArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    ABAddressBookRef tmpAddressBook = nil;
    
    tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
        dispatch_semaphore_signal(sema);
    });
    
    
//    ABAddressBookRegisterExternalChangeCallback(tmpAddressBook, addressBookChanged, (__bridge void *)(self));
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    //取得通讯录失败
    if (tmpAddressBook == nil) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
//        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:@"请先开启通讯录权限" onView:[[UIApplication sharedApplication].delegate window]];
        return;
    };
    
    [[FreeSingleton sharedInstance] getAddressListOnCompletion:^(NSUInteger retcode, id data) {
        if (retcode == RET_SERVER_SUCC) {
            
            [[FreeSQLite sharedInstance] clearAllTable:ADDRESS_TABLE_NAME];
            
            [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:ADDRESS_TABLE tableName:ADDRESS_TABLE_NAME];
            
            NSMutableArray *modelArray = [NSMutableArray array];
            [self insertFreeDataSource:data dataSource:modelArray];
            [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:modelArray];
            
            CFArrayRef peoples = ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
            NSArray* tmpPeoples = (__bridge NSArray *)peoples;
            CFRelease(peoples);
            NSMutableArray *phoneNoArray = [NSMutableArray array];
            [[FreeSQLite sharedInstance] selectFreeSQLiteADdressListAll:phoneNoArray];
            
            //遍历通讯录中的联系人
            for(id tmpPerson in tmpPeoples)
            {
                //获取的联系人单一属性:Generic phone number
                ABMultiValueRef tmpPhones = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonPhoneProperty);
                for(NSInteger j = 0; j < ABMultiValueGetCount(tmpPhones); j++)
                {
                    CFStringRef tmpPhoneIndex = ABMultiValueCopyValueAtIndex(tmpPhones, j);
                    NSString* tmpPhoneIndexTmp = (__bridge NSString *)tmpPhoneIndex;
                    tmpPhoneIndexTmp = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    tmpPhoneIndexTmp = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSString* tmpPhoneIndexReal = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                    CFRelease(tmpPhoneIndex);
                    if ([tmpPhoneIndexReal length] != 11) {
                        continue;
                    }
                    
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:MOBILE_NUM_REGEX options:NSRegularExpressionCaseInsensitive error:nil];
                    NSUInteger numOfMatch = 0;
                    numOfMatch = [regex numberOfMatchesInString:tmpPhoneIndexReal
                                                        options:NSMatchingAnchored
                                                          range:NSMakeRange(0, [tmpPhoneIndexReal length])];
                    if (numOfMatch == 0) {
                        continue;
                    }
                    
                    if ([tmpPhoneIndexReal isEqualToString:[[FreeSingleton sharedInstance] getPhoneNo]])
                    {
                        continue;
                    }
                    
                    //获取的联系人单一属性:First name
                    CFStringRef firstName = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonFirstNameProperty);
                    NSString* tmpFirstName = (__bridge NSString *)firstName;
                    //获取的联系人单一属性:Last name
                    CFStringRef lastName = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonLastNameProperty);
                    NSString* tmpLastName = (__bridge NSString *)lastName;
                    
                    NSString *name = [NSString stringWithFormat:@"%@%@", tmpLastName, tmpFirstName];
                    
                    name  = [name stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                    if (lastName != nil) {
                        CFRelease(lastName);
                    }
                    if (firstName != nil) {
                        CFRelease(firstName);
                    }
                    
                    if (name == nil || [name isEqualToString:@""] || [name length] == 0) {
                        continue;
                    }
                    
                    NSString *pinyin = [name mutableCopy];
                    CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformMandarinLatin,NO);
                    //再转换为不带声调的拼音
                    CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformStripDiacritics,NO);
                    
                    pinyin = [NSString stringWithFormat:@"\"%@\"", pinyin];
                    name = [NSString stringWithFormat:@"\"%@\"", name];
                    
                    [dic setObject:tmpPhoneIndexReal forKey:@"phoneNo"];
                    [dic setObject:name forKey:@"friendName"];
                    [dic setObject:pinyin forKey:@"pinyin"];
                    
                    for (int i = 0; i < [phoneNoArray count]; i++) {
                        NSDictionary *dic = phoneNoArray[i];
                        if ([dic[@"phoneNo"] isEqualToString:tmpPhoneIndexReal]) {
                            continue;
                        }
                    }
                    
                    [outsideArray addObject:[dic mutableCopy]];
                    
                }
                CFRelease(tmpPhones);
            }
            
            //释放内存
            CFRelease(tmpAddressBook);
            
            if ([outsideArray count] == 0) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
                return;
            }
            
            NSSet *set = [NSSet setWithArray:outsideArray];
            NSString *phoneList = [[set allObjects] componentsJoinedByString:@" "];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"{" withString:@"[{"];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"}" withString:@"}]"];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"] [" withString:@","];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@";" withString:@","];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@",\n}" withString:@"}"];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"=" withString:@":"];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"U" withString:@"u"];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"\\\"" withString:@""];
            
            NSInteger ret = [[FreeSingleton sharedInstance] sendAddressListOnCompletion:phoneList block:^(NSUInteger retcode, id data) {
                if (retcode == RET_SERVER_SUCC) {
                    
                    [[FreeSQLite sharedInstance] clearAllTable:ADDRESS_TABLE_NAME];
                    
                    [[FreeSQLite sharedInstance] openFreeSQLiteAddressList:ADDRESS_TABLE tableName:ADDRESS_TABLE_NAME];
                    NSMutableArray *modelArray = [NSMutableArray array];
                    [self insertFreeDataSource:data dataSource:modelArray];
                    [[FreeSQLite sharedInstance] insertFreeSQLiteAddressList:modelArray];
                    
                        NSLog(@"检索完成");
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
                        [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
//                        });
                }
                else
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
                    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
                }
            }];
            
            if (ret != RET_OK) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ZC_NOTIFICATION_LOADING];//消除loading
                [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
                NSLog(@"AddressList error: %@", zcErrMsg(ret));
            }
        }
    }];
    
}


+ (void)synAddressListData:(NSMutableArray *)dataSource freeblock:(FreeBlock)freeblock
{
    NSMutableArray *outsideArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSMutableArray *phoneNoArray = [[NSMutableArray alloc] init];
    
    ABAddressBookRef tmpAddressBook = nil;
    
    tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
        dispatch_semaphore_signal(sema);
    });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    //取得通讯录失败
    if (tmpAddressBook == nil) {
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:@"请先开启通讯录权限" onView:[[UIApplication sharedApplication].delegate window]];
        freeblock(RET_SERVER_FAIL, nil);
        return;
    };
    
    [[FreeSingleton sharedInstance] getAddressListOnCompletion:^(NSUInteger retcode1, id data) {
        if (retcode1 == RET_SERVER_SUCC) {
                        
            NSMutableArray *modelArray = [NSMutableArray array];
            [FreeAddressBook add2Model:modelArray data:data phoneNo:nil];
            CFArrayRef peoples = ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
            NSArray* tmpPeoples = (__bridge NSArray *)peoples;
            CFRelease(peoples);
            
            //遍历通讯录中的联系人
            for(id tmpPerson in tmpPeoples)
            {
                //获取的联系人单一属性:Generic phone number
                ABMultiValueRef tmpPhones = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonPhoneProperty);
                for(NSInteger j = 0; j < ABMultiValueGetCount(tmpPhones); j++)
                {
                    CFStringRef tmpPhoneIndex = ABMultiValueCopyValueAtIndex(tmpPhones, j);
                    NSString* tmpPhoneIndexTmp = (__bridge NSString *)tmpPhoneIndex;
                    tmpPhoneIndexTmp = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    tmpPhoneIndexTmp = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSString* tmpPhoneIndexReal = [tmpPhoneIndexTmp stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                    CFRelease(tmpPhoneIndex);
                    if ([tmpPhoneIndexReal length] != 11) {
                        continue;
                    }
                    
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:MOBILE_NUM_REGEX options:NSRegularExpressionCaseInsensitive error:nil];
                    NSUInteger numOfMatch = 0;
                    numOfMatch = [regex numberOfMatchesInString:tmpPhoneIndexReal
                                                        options:NSMatchingAnchored
                                                          range:NSMakeRange(0, [tmpPhoneIndexReal length])];
                    if (numOfMatch == 0) {
                        continue;
                    }
                    
                    if ([tmpPhoneIndexReal isEqualToString:[[FreeSingleton sharedInstance] getPhoneNo]])
                    {
                        continue;
                    }
                    
                    //获取的联系人单一属性:First name
                    CFStringRef firstName = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonFirstNameProperty);
                    NSString* tmpFirstName = (__bridge NSString *)firstName;
                    //获取的联系人单一属性:Last name
                    CFStringRef lastName = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonLastNameProperty);
                    NSString* tmpLastName = (__bridge NSString *)lastName;
                    
                    NSString *name = [NSString stringWithFormat:@"%@%@", tmpLastName, tmpFirstName];
                    
                    name  = [name stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
                    if (lastName != nil) {
                        CFRelease(lastName);
                    }
                    if (firstName != nil) {
                        CFRelease(firstName);
                    }
                    
                    if (name == nil || [name isEqualToString:@""] || [name length] == 0) {
                        continue;
                    }
                    
                    NSString *pinyin = [name mutableCopy];
                    CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformMandarinLatin,NO);
                    //再转换为不带声调的拼音
                    CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformStripDiacritics,NO);
                    
                    pinyin = [NSString stringWithFormat:@"\"%@\"", pinyin];
                    name = [NSString stringWithFormat:@"\"%@\"", name];
                    
                    [dic setObject:tmpPhoneIndexReal forKey:@"phoneNo"];
                    [dic setObject:name forKey:@"friendName"];
                    [dic setObject:pinyin forKey:@"pinyin"];
                    
                    [phoneNoArray addObject:tmpPhoneIndexReal];
                    for (int i = 0; i < [modelArray count]; i++) {
                        AddressListCellModel *dic = modelArray[i];
                        
                        if ([dic.phoneNo isKindOfClass:[NSNull class]]) {
                            continue;
                        }
                        
                        if ([dic.phoneNo isEqualToString:tmpPhoneIndexReal]) {
                            continue;
                        }
                    }
                    
                    [outsideArray addObject:[dic mutableCopy]];
                    
                }
                CFRelease(tmpPhones);
            }
            
            //释放内存
            CFRelease(tmpAddressBook);
            
            if ([outsideArray count] == 0) {
                [KVNProgress dismiss];
                freeblock(RET_SERVER_FAIL, nil);
                return;
            }
            
            NSSet *set = [NSSet setWithArray:outsideArray];
            NSString *phoneList = [[set allObjects] componentsJoinedByString:@" "];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"{" withString:@"[{"];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"}" withString:@"}]"];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"] [" withString:@","];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@";" withString:@","];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@",\n}" withString:@"}"];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"=" withString:@":"];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"U" withString:@"u"];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneList = [phoneList stringByReplacingOccurrencesOfString:@"\\\"" withString:@""];
            
            NSInteger ret = [[FreeSingleton sharedInstance] sendAddressListOnCompletion:phoneList block:^(NSUInteger retcode, id data) {
                if (retcode == RET_SERVER_SUCC) {
                    [FreeAddressBook add2Model:dataSource data:data phoneNo:phoneNoArray];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:ZC_NOTIFICATION_UPLOAD_ADDRESSLIST object:self];//触发刷新通知
                    [KVNProgress dismiss];
                    freeblock(RET_SERVER_SUCC, nil);
                    NSLog(@"检索完成");
                }
                else
                {
                    [KVNProgress dismiss];
                }
            }];
            
            if (ret != RET_OK) {
                [KVNProgress dismiss];
                NSLog(@"AddressList error: %@", zcErrMsg(ret));
            }
        }
        else
        {
            [KVNProgress dismiss];
        }
    }];
    
}


+ (void)add2Model:(NSMutableArray *)modelArray data:(id)data phoneNo:(NSMutableArray *)phoneNoArray
{
    for (int i = 0; i < [data count]; i++) {
        NSDictionary *dic = data[i];
        
        if ([phoneNoArray count]) {
            BOOL ifInPhoneArray = NO;
            for (NSString *phoneNO in phoneNoArray) {
                if ([phoneNO isEqualToString:dic[@"phoneNo"]]) {
                    ifInPhoneArray = YES;
                }
            }
            if (!ifInPhoneArray) {
                continue;
            }
        }
        
        AddressListCellModel *model = [[AddressListCellModel alloc] init];
        model.Id = [NSString stringWithFormat:@"%@", dic[@"id"]];
        model.friendId = [NSString stringWithFormat:@"%@", dic[@"friendAccountId"]];
        if (![dic[@"friendName"] isKindOfClass:[NSNull class]]) {
            model.user_name = dic[@"friendName"];
        }
        if (![dic[@"headImg"] isKindOfClass:[NSNull class]]) {
            model.img_url = dic[@"headImg"];
        }
        model.phoneNo = dic[@"phoneNo"];
        if (![dic[@"pinyin"] isKindOfClass:[NSNull class]]) {
            model.pinyin = dic[@"pinyin"];
        }
        else
        {
            NSString *pinyin = [model.user_name mutableCopy];
            CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformMandarinLatin,NO);
            //再转换为不带声调的拼音
            CFStringTransform((CFMutableStringRef)pinyin,NULL, kCFStringTransformStripDiacritics,NO);
            model.pinyin = pinyin;
        }
        
        model.status = dic[@"status"];
        [modelArray addObject:model];
    }
}

+ (void)insertFreeDataSource:(id)data dataSource:(NSMutableArray *)dataSource
{
    for (int i = 0; i < [data count]; i++) {
        AddressSQLiteModel *model = [[AddressSQLiteModel alloc] init];
        model.phoneNo = data[i][@"phoneNo"];
        model.friendName = data[i][@"friendName"];
        model.imgUrl = data[i][@"headImg"];
        model.pinyin = data[i][@"pinyin"];
        model.status = data[i][@"status"];
        model.Id = data[i][@"id"];
        model.friendAccountId = data[i][@"friendAccountId"];
        model.type = [NSNumber numberWithInt:0];
        [dataSource addObject:model];
    }
}

@end