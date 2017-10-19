//
//  MyindividualTableViewController.h
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/25.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>
#import <RongIMKit/RongIMKit.h>
@interface MyindividualTableViewController : UITableViewController<UIActionSheetDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,assign) RCConversationType IndividualType;
@property(nonatomic,copy) NSString *IndividualId;
@property(nonatomic,copy) clearHistory IndividualclearHistory;

@end
