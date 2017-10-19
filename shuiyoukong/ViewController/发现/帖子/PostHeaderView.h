//
//  PostHeaderView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/21.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverModel.h"
#import "PostViewController.h"
#import "SelectFriendsModel.h"

@interface PostHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *head_img;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
//@property (weak, nonatomic) IBOutlet UIScrollView *scroll_view;
@property (weak, nonatomic) IBOutlet UITextView *text_content;
//@property (weak, nonatomic) IBOutlet UILabel *label_tags;
@property (weak, nonatomic) IBOutlet UIView *view_tags;
@property (weak, nonatomic) IBOutlet UILabel *label_position;
@property (weak, nonatomic) IBOutlet UIView *view_position;
@property (weak, nonatomic) IBOutlet UIView *view_imgs;
@property (weak, nonatomic) IBOutlet UILabel *label_num_bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *text_height;
@property (weak, nonatomic) IBOutlet UIButton *btn_location;
@property (weak, nonatomic) IBOutlet UIView *big_img_view;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *big_img_height;
@property (weak, nonatomic) IBOutlet UIButton *btn_wx;
@property (weak, nonatomic) IBOutlet UIButton *btn_friends;
@property (weak, nonatomic) IBOutlet UIButton *btn_qq;
@property (weak, nonatomic) IBOutlet UIButton *btn_more;
@property (weak, nonatomic) IBOutlet UIView *head_view;
@property (weak, nonatomic) IBOutlet UIButton *btn_delete_Mypost;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view_tags_height;

//@property (strong, nonatomic)UIImage *cover_img;
@property (weak, nonatomic)PostViewController *vc;
@property (strong, nonatomic)DiscoverModel *model;
@property (strong, nonatomic)NSMutableArray *imgArray;

@property (strong, nonatomic)NSMutableArray *accountList;

@property (assign, nonatomic)float tagsView_height;

@end
