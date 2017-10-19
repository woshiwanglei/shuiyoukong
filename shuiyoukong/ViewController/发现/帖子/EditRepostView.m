//
//  EditRepostView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/21.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "EditRepostView.h"

@implementation EditRepostView

- (void)awakeFromNib
{
    _text_content.layer.borderWidth = 0.5f;
    _text_content.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _text_content.delegate = self;
    _label_placeholder.hidden = YES;
}

- (void)dealloc
{
    _text_content.delegate = nil;
}

- (void)setRepostName:(NSString *)repostName
{
    _label_placeholder.text = [NSString stringWithFormat:@"@%@", repostName];
    _label_placeholder.hidden = NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text == nil || [textView.text length] == 0) {
        _label_placeholder.hidden = NO;
    }
    else
    {
        _label_placeholder.hidden = YES;
    }
    
    if ([textView.text length] > 100) {
        textView.text = [textView.text substringToIndex:100];
    }
}

@end
