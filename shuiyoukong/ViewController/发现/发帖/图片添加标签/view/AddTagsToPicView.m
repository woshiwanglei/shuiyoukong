//
//  AddTagsToPicView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/19.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "AddTagsToPicView.h"
#import "settings.h"

@implementation AddTagsToPicView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_btn_commit addTarget:self action:@selector(commitTags:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_cancel addTarget:self action:@selector(cancelTags:) forControlEvents:UIControlEventTouchUpInside];
    _btn_cancel.layer.cornerRadius = 3.f;
    _btn_cancel.layer.masksToBounds = YES;
    _btn_commit.layer.cornerRadius = 3.f;
    _btn_commit.layer.masksToBounds = YES;
    _black_view.layer.cornerRadius = 5.f;
    _black_view.layer.masksToBounds = YES;
    
    _text_frist.delegate = self;
    _text_frist.tintColor = [UIColor whiteColor];
    _text_second.delegate = self;
    _text_second.tintColor = [UIColor whiteColor];
    _text_third.delegate = self;
    _text_third.tintColor = [UIColor whiteColor];
    _text_forth.delegate = self;
    _text_forth.tintColor = [UIColor whiteColor];
    
    UIButton *clearButton1 = [_text_frist valueForKey:@"_clearButton"];
    [clearButton1 setImage:[UIImage imageNamed:@"icon_clear_btn"] forState:UIControlStateNormal];
    UIButton *clearButton2 = [_text_second valueForKey:@"_clearButton"];
    [clearButton2 setImage:[UIImage imageNamed:@"icon_clear_btn"] forState:UIControlStateNormal];
    UIButton *clearButton3 = [_text_third valueForKey:@"_clearButton"];
    [clearButton3 setImage:[UIImage imageNamed:@"icon_clear_btn"] forState:UIControlStateNormal];
    UIButton *clearButton4 = [_text_forth valueForKey:@"_clearButton"];
    [clearButton4 setImage:[UIImage imageNamed:@"icon_clear_btn"] forState:UIControlStateNormal];
    
    
    _text_frist.returnKeyType = UIReturnKeyDone;
    _text_second.returnKeyType = UIReturnKeyDone;
    _text_third.returnKeyType = UIReturnKeyDone;
    _text_forth.returnKeyType = UIReturnKeyDone;
    
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignTextFiled:)];
    [self addGestureRecognizer:tapGes];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_text_frist];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_text_second];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_text_third];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:_text_forth];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commitTags:(id)sender
{
    if ([_text_frist.text length]) {
        _model.fristLabel = _text_frist.text;
    }
    else
    {
        _model.fristLabel = nil;
    }
    
    if ([_text_second.text length]) {
        _model.secondLabel = _text_second.text;
    }
    else
    {
        _model.secondLabel = nil;
    }
    
    if ([_text_third.text length]) {
        _model.thirdLabel = _text_third.text;
    }
    else
    {
        _model.thirdLabel = nil;
    }
    
    if ([_text_forth.text length]) {
         _model.forthLabel = _text_forth.text;
    }
    else
    {
        _model.forthLabel = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_ADD_TAG object:_model];
}

- (void)cancelTags:(id)sender
{
    UIView *view = self.superview;
    if (_isEdit) {
        _model.fristLabel = nil;
        _model.secondLabel = nil;
        _model.thirdLabel = nil;
        _model.forthLabel = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_ADD_TAG object:_model];
    }
    
    [self removeFromSuperview];
    [view removeFromSuperview];
}

- (void)setModel:(addTagsModel *)model
{
    _model = model;
    _isEdit = NO;
    if (_model.fristLabel) {
        _text_frist.text = _model.fristLabel;
        _isEdit = YES;
    }
    
    if (_model.secondLabel) {
        _text_second.text = _model.secondLabel;
        _isEdit = YES;
    }
    
    if (_model.thirdLabel) {
        _text_third.text = _model.thirdLabel;
        _isEdit = YES;
    }
    
    if (_model.forthLabel) {
        _text_forth.text = _model.forthLabel;
        _isEdit = YES;
    }
    
    if (_isEdit) {
        _left_label.text = @"删除";
    }
    else
    {
        _left_label.text = @"取消";
    }
}

//空白处取消键盘
- (void)resignTextFiled:(UITapGestureRecognizer *)tap
{
    [_text_forth resignFirstResponder];
    [_text_third resignFirstResponder];
    [_text_second resignFirstResponder];
    [_text_frist resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFiledEditChanged:(NSNotification *)obj
{
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
