//
//  SuperSquareView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/3.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SuperSquareView.h"

@implementation SuperSquareView

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
    
    for (int i = 0; i < 3; i++) {
        CarlendSquaresView *subView =
        [[[NSBundle mainBundle] loadNibNamed:@"CarlendSquaresView"
                                       owner:self
                                     options:nil] objectAtIndex:0];
        subView.translatesAutoresizingMaskIntoConstraints = NO;
        [_subViewArray addObject:subView];
    }
    
    for (int i = 0; i < 3; i++) {
        CarlendSquaresView *subView = _subViewArray[i];
        [self addSubview:subView];
    }
    
    CarlendSquaresView *subView0 = _subViewArray[0];
    CarlendSquaresView *subView1 = _subViewArray[1];
    CarlendSquaresView *subView2 = _subViewArray[2];
    
    NSDictionary *metrics = @{
                              @"height" : @(90),
                              @"width" : @(90)
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(subView0, subView1, subView2);
    
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-5-[subView0(width)]-10-[subView1(subView0)]-10-[subView2(subView0)]-5-|"
      options:0
      metrics:metrics
      views:views]];
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|-0-[subView0(height)]-0-|"
      options:0
      metrics:metrics
      views:views]];
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|-0-[subView1(height)]-0-|"
      options:0
      metrics:metrics
      views:views]];
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|-0-[subView2(height)]-0-|"
      options:0
      metrics:metrics
      views:views]];
    
}

- (void)setModelArray:(NSMutableArray *)modelArray
{
    for (int i = 0; i < 3; i++) {
        CarlendSquaresView *subView = _subViewArray[i];
        subView.model = modelArray[i];
    }
}



@end