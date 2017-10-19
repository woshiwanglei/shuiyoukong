//
//  BottomCalendarScrollView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/5/22.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "BottomCalendarView.h"
#import "SubBottonCalendarView.h"

@implementation BottomCalendarView


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _subViewArray = [NSMutableArray array];
        _modelArray = [NSMutableArray array];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initView];
}

- (void)initView
{
    self.backgroundColor = [UIColor clearColor];
    
    for (int i = 0; i < 7; i++) {
        SubBottonCalendarView *subView =
        [[[NSBundle mainBundle] loadNibNamed:@"SubBottonCalendarView"
                                       owner:self
                                     options:nil] objectAtIndex:0];
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        [_subViewArray addObject:subView];
    }
    
    for (int i = 0; i < 7; i++) {
        SubBottonCalendarView *subView = _subViewArray[i];
        [self addSubview:subView];
    }
    
    SubBottonCalendarView *subView0 = _subViewArray[0];
    SubBottonCalendarView *subView1 = _subViewArray[1];
    SubBottonCalendarView *subView2 = _subViewArray[2];
    SubBottonCalendarView *subView3 = _subViewArray[3];
    SubBottonCalendarView *subView4 = _subViewArray[4];
    SubBottonCalendarView *subView5 = _subViewArray[5];
    SubBottonCalendarView *subView6 = _subViewArray[6];
    
    NSDictionary *metrics = @{
                              @"height" : @(40),
                              @"width" : @([UIScreen mainScreen].bounds.size.width/7)
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(subView0, subView1, subView2, subView3, subView4, subView5, subView6);
    
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-0-[subView0(width)]-0-[subView1(subView0)]-0-[subView2(subView0)]-0-[subView3(subView0)]-0-[subView4(subView0)]-0-[subView5(subView0)]-0-[subView6(width)]-0-|"
      options:0
      metrics:metrics
      views:views]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|-0-[subView0(height)]-0-|"
                          options:0
                          metrics:metrics
                          views:views]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|-0-[subView1(height)]-0-|"
                          options:0
                          metrics:metrics
                          views:views]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|-0-[subView2(height)]-0-|"
                          options:0
                          metrics:metrics
                          views:views]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|-0-[subView3(height)]-0-|"
                          options:0
                          metrics:metrics
                          views:views]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|-0-[subView4(height)]-0-|"
                          options:0
                          metrics:metrics
                          views:views]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|-0-[subView5(height)]-0-|"
                          options:0
                          metrics:metrics
                          views:views]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|-0-[subView6(height)]-0-|"
                          options:0
                          metrics:metrics
                          views:views]];

}

- (void)setModelArray:(NSMutableArray *)modelArray
{
    for (int i = 0; i < 7; i++) {
        SubBottonCalendarView *subView = _subViewArray[i];
        subView.model = modelArray[i];
    }
}

@end