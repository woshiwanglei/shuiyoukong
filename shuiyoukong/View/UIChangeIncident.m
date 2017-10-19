//
//  UIChangeIncident.m
//  Free
//
//  Created by yangcong on 15/5/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "UIChangeIncident.h"

@implementation UIChangeIncident

+(void)ButtonChangPattern:(UIButton *)sender;
{
    sender.layer.masksToBounds = YES;
    sender.layer.cornerRadius = 6;
    sender.layer.borderWidth = 1;
    sender.layer.borderColor = [[UIColor blackColor] CGColor];
    sender.backgroundColor = [UIColor clearColor];
    
    [sender setTitleColor:[UIColor colorWithRed:77/255.0 green:74/255.0 blue:77/255.0 alpha:1] forState:UIControlStateNormal];
    
   [sender setTitleColor:[UIColor colorWithRed:87/255.0 green:226/255.0 blue:202/255.0 alpha:1]forState:UIControlStateHighlighted];
}




@end
