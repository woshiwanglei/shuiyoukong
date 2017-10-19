//
//  ActivityCalendarParentView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/2.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "ActivityCalendarParentView.h"
#import "ActivityCalendarSubView.h"

@implementation ActivityCalendarParentView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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
        ActivityCalendarSubView *subView =
        [[[NSBundle mainBundle] loadNibNamed:@"ActivityCalendarSubView"
                                       owner:self
                                     options:nil] objectAtIndex:0];
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        [_subViewArray addObject:subView];
    }
    
    for (int i = 0; i < 7; i++) {
        ActivityCalendarSubView *subView = _subViewArray[i];
        [self addSubview:subView];
    }
    
    ActivityCalendarSubView *subView0 = _subViewArray[0];
    ActivityCalendarSubView *subView1 = _subViewArray[1];
    ActivityCalendarSubView *subView2 = _subViewArray[2];
    ActivityCalendarSubView *subView3 = _subViewArray[3];
    ActivityCalendarSubView *subView4 = _subViewArray[4];
    ActivityCalendarSubView *subView5 = _subViewArray[5];
    ActivityCalendarSubView *subView6 = _subViewArray[6];
    
    NSDictionary *metrics = @{
                              @"height" : @(70),
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
        ActivityCalendarSubView *subView = _subViewArray[i];
        subView.model = modelArray[i];
    }
}

@end