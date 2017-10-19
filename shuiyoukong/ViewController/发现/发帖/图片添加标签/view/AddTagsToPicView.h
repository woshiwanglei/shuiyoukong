//
//  AddTagsToPicView.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/19.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addTagsModel.h"

@interface AddTagsToPicView : UIView <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *text_frist;
@property (weak, nonatomic) IBOutlet UITextField *text_second;
@property (weak, nonatomic) IBOutlet UITextField *text_third;
@property (weak, nonatomic) IBOutlet UITextField *text_forth;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;
@property (weak, nonatomic) IBOutlet UIButton *btn_commit;
@property (weak, nonatomic) IBOutlet UIView *black_view;
@property (weak, nonatomic) IBOutlet UILabel *left_label;

@property (strong, nonatomic)addTagsModel *model;

@property (weak, nonatomic)UIViewController *vc;

@property (assign, nonatomic)BOOL isEdit;

@end
