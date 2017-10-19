//
//  FreeImagePreviewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/25.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface FreeImagePreviewController : RCImagePreviewController

/**
 *  会话数据模型
 */
@property (strong,nonatomic) RCConversationModel *conversation;

@property (strong, nonatomic) NSMutableArray *dataSource;

@end
