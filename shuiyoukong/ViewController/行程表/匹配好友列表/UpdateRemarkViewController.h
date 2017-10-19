//
//  UpdateRemarkViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/9.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateRemarkViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *label_placeholder;
@property (weak, nonatomic) IBOutlet UITextView *input_textView;
@property (weak, nonatomic) IBOutlet UILabel *label_num;

@property (copy, nonatomic) NSString *remark;

@end
