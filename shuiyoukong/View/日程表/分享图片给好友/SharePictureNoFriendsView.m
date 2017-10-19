//
//  SharePictureNoFriendsView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/6.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SharePictureNoFriendsView.h"
#import "settings.h"

@implementation SharePictureNoFriendsView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 5.f;
    _label_notice.hidden = YES;
    _text_input.text = @"从前共你，促膝把酒倾通宵都不够";
    [_text_input setTintColor:FREE_BACKGOURND_COLOR];
    _text_input.clearButtonMode = UITextFieldViewModeAlways;
    _myTextView.userInteractionEnabled = NO;
    
    _text_input.returnKeyType = UIReturnKeyDone;
    _text_input.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    
    _text_input.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_text_input];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:nil];
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    
    // NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *current = [currentar firstObject];
    
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > 20) {
                textField.text = [toBeString substringToIndex:20];
            }
        }
        else{
            
        }
    }
    else{
        if (toBeString.length > 20) {
            textField.text = [toBeString substringToIndex:20];
        }
    }
}

@end