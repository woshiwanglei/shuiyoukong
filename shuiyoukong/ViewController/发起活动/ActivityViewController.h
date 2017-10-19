//
//  ActivityViewController.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/2.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *text_input;
@property (weak, nonatomic) IBOutlet UIScrollView *activity_scrollview;
@property (weak, nonatomic) IBOutlet UIScrollView *super_scrollview;

@property (weak, nonatomic) IBOutlet UIView *filedView;

@end
