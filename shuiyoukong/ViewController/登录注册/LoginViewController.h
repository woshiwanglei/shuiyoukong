//
//  LoginViewController.h
//  Free
//
//  Created by 勇拓 李 on 15/5/4.
//  Copyright (c) 2015年 知春. All rights reserved.
//
//
//  Created by   on 14-7-31.
//  Copyright (c) 2014年   All rights reserved.
//


//                    _oo0oo_
//                   o8888888o
//                   88" . "88
//                   (| -_- |)
//                   0\  =  /0
//                 ___/`___'\___
//               .' \\|     |// '.
//              / \\|||  :  |||// \
//             / _||||| -:- |||||_ \
//            |   | \\\  _  /// |   |
//            | \_|  ''\___/''  |_/ |
//            \  .-\__  '_'  __/-.  /
//          ___'. .'  /--.--\  '. .'___
//        ."" '<  .___\_<|>_/___. '>' "".
//     | | :  `_ \`.;` \ _ / `;.`/ - ` : | |
//     \ \  `_.   \_ ___\ /___ _/   ._`  / /
//  ====`-.____` .__ \_______/ __. -` ___.`====
//                   `=-----='
//
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//           佛祖保佑           永无BUG

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
@property (weak, nonatomic) IBOutlet UIButton *btn_login;
@property (weak, nonatomic) IBOutlet UIButton *btn_register;
@property (weak, nonatomic) IBOutlet UIButton *btn_forget;
@property (weak, nonatomic) IBOutlet UIView *backgroudView;

@property (weak, nonatomic) IBOutlet UIView *PWbgView;

@end
