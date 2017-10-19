//
//  SharePictureNoFriendsView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharePictureNoFriendsView : UIView <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *text_input;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;
@property (weak, nonatomic) IBOutlet UIButton *btn_commit;
@property (weak, nonatomic) IBOutlet UILabel *label_notice;
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@end
