//
//  SendNumberViewController.h
//  Free
//
//  Created by yangcong on 15/5/4.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendNumberViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;

@property (weak, nonatomic) IBOutlet UIView *phoneBgview;

@end
