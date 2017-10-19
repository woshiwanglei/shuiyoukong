//
//  SearchFriendsTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchFriendsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (strong, nonatomic)NSString *url;
@end
