//
//  CrowdPersonModel.h
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrowdPersonModel : NSObject
@property (nonatomic,copy) NSString *imageUrl;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) int crowdId;

- (void)initWithDic:(NSDictionary*)dictionary;
@end
