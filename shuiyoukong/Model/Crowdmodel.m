//
//  Crowdmodel.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "Crowdmodel.h"
#import "CrowdPersonModel.h"

@implementation Crowdmodel

- (void)initWithDic:(NSDictionary*)dictionary
{
    _groupName = [dictionary objectForKey:@"groupName"];
    _groupInfoList = [[NSMutableArray alloc] init];
    NSArray *array = [dictionary objectForKey:@"groupInfoList"];

        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             NSDictionary *dic = (NSDictionary*)obj;
             CrowdPersonModel *model = [[CrowdPersonModel alloc] init];
             [model initWithDic:dic];
             [_groupInfoList addObject:model];
             
         }];
}
@end
