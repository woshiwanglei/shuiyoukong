//
//  InterfaceImageView.m
//  Free
//
//  Created by yangcong on 15/5/13.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "InterfaceImageView.h"

@implementation InterfaceImageView
-(void)awakeFromNib
{
    self.layer.masksToBounds = YES;
    [self setContentMode:UIViewContentModeScaleAspectFill];
    switch (self.Tag) {
        case 1:
            self.layer.cornerRadius = 18;//头像控件
            break;
        case 2:
            self.layer.cornerRadius = 8;//图片控件
            break;
        case 3:
            self.layer.cornerRadius = 25;//图标控件
        default:
            //            self.layer.cornerRadius = 8;
            break;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
