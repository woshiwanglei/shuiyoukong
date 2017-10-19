//
//  ActiveFriendsView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectFriendsModel.h"

@interface ActiveFriendsView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_fromInfo;

@property (copy, nonatomic) NSString *friendId;
@property (copy, nonatomic) NSString *friendName;
@property (strong, nonatomic)SelectFriendsModel *model;

@end
