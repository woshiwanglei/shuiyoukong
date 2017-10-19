//
//  MyHeadImgTableViewCell.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyHeadImgTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *head_img;

@property (strong, nonatomic)NSString *url;

@end
