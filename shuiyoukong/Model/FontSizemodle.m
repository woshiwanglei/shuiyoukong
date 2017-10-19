//
//  FontSizemodle.m
//  谁有空—不约而同
//
//  Created by smileSoWhat on 15/6/26.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "FontSizemodle.h"

@implementation FontSizemodle

+(void)setfontSizeLableSize:(UILabel *)lable
{
    if (SCREEN_HEIGHT == 480)
    {
        lable.font = [UIFont systemFontOfSize:15.0];
    }
    else if(SCREEN_HEIGHT == 568)
    {
        lable.font = [UIFont systemFontOfSize:15.0];
    }
    else if(SCREEN_HEIGHT == 667)
    {
        lable.font = [UIFont systemFontOfSize:17.0];
    }
    else if(SCREEN_HEIGHT == 736)
    {
       lable.font = [UIFont systemFontOfSize:18.0];
    }
    else
    {
       lable.font = [UIFont systemFontOfSize:15.0];
    }
}
@end
