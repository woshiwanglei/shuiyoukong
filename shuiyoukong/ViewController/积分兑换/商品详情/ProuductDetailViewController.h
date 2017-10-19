//
//  ProuductDetailViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/24.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordModel.h"

@interface ProuductDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scroll_img_view;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_code;
@property (weak, nonatomic) IBOutlet UITextView *text_content;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textView_height;

@property (strong, nonatomic)RecordModel *model;

@end
