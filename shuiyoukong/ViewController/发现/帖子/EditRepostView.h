//
//  EditRepostView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/21.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditRepostView : UIView <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;
@property (weak, nonatomic) IBOutlet UIButton *btn_send;
@property (weak, nonatomic) IBOutlet UITextView *text_content;
@property (weak, nonatomic) IBOutlet UILabel *label_placeholder;
@property (strong, nonatomic)NSString *repostName;
@end
