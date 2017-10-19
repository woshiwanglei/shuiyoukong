//
//  ActivityTableViewController.h
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/23.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>
#import <RongIMKit/RongIMKit.h>
@interface ActivityTableViewController : UITableViewController<UIActionSheetDelegate>

@property(nonatomic,assign) RCConversationType activityType;
@property(nonatomic,copy) NSString *activityId;
@property(nonatomic,copy) clearHistory clearHistoryCompletion;
@property(nonatomic,copy) NSString *titileName;
@end
