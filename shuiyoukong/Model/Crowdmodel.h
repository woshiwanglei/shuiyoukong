//
//  Crowdmodel.h
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Crowdmodel : NSObject
@property(nonatomic,copy)NSString *groupName;
@property(nonatomic,strong)NSMutableArray *groupInfoList;
@property(nonatomic,copy) NSString *activityID;

- (void)initWithDic:(NSDictionary*)dictionary;

@end
