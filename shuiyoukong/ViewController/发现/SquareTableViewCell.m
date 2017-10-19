//
//  SquareTableViewCell.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/7/16.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "SquareTableViewCell.h"
#import "settings.h"

@implementation SquareTableViewCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _modelArray = [NSMutableArray array];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self initView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initView
{
    _leftSubView =
    [[[NSBundle mainBundle] loadNibNamed:@"SubSquareView"
                                   owner:self
                                 options:nil] objectAtIndex:0];
    _leftSubView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_leftSubView];
    
    _rightSubView =
    [[[NSBundle mainBundle] loadNibNamed:@"SubSquareView"
                                   owner:self
                                 options:nil] objectAtIndex:0];
    _rightSubView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_rightSubView];
    
    NSDictionary *metrics = @{
                              @"height" : @([UIScreen mainScreen].bounds.size.width/2 + 66 - 12),
                              @"width" : @([UIScreen mainScreen].bounds.size.width/2 - 12)
                              };
    NSDictionary *views = NSDictionaryOfVariableBindings(_leftSubView, _rightSubView);
    
    [self addConstraints:
     [NSLayoutConstraint
      constraintsWithVisualFormat:@"H:|-8-[_leftSubView(width)]-8-[_rightSubView(_leftSubView)]-8-|"
      options:0
      metrics:metrics
      views:views]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|-6-[_leftSubView(height)]-0-|"
                          options:0
                          metrics:metrics
                          views:views]];
    [self addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:
                          @"V:|-6-[_rightSubView(height)]-0-|"
                          options:0
                          metrics:metrics
                          views:views]];
}

- (void)setModelArray:(NSMutableArray *)modelArray
{
    _leftSubView.discover_vc = _discover_vc;
    _leftSubView.model = modelArray[0];
    if ([modelArray count] > 1) {
        _rightSubView.discover_vc = _discover_vc;
        _rightSubView.model = modelArray[1];
    }
    else
    {
        _rightSubView.model = nil;
    }
}

@end
