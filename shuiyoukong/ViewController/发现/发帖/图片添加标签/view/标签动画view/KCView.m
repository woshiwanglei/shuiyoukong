//
//  KCView.m
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/19.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import "KCView.h"
#import "PulsingHaloLayer.h"
#import "settings.h"

#define CENTER_X _white_point.center.x
#define CENTER_Y _white_point.center.y

#define LABEL_HEIGHT 17.f

@implementation KCView

- (void)awakeFromNib
{
    [super awakeFromNib];
    _white_point.layer.cornerRadius = 4.f;
    _black_point.layer.cornerRadius = 6.f;
    _white_point.layer.masksToBounds = YES;
    _black_point.layer.masksToBounds = YES;
    UITapGestureRecognizer* tapGes2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTags:)];
    [self addGestureRecognizer:tapGes2];
//    _white_point.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(doHandlePanAction:)];
    [self addGestureRecognizer:panGestureRecognizer];
    
}

- (void) doHandlePanAction:(UIPanGestureRecognizer *)paramSender{
    
    if (_cannottBeMove == YES) {
        return;
    }
    
    CGPoint point = [paramSender translationInView:self];
    
    CGPoint centerPoint = CGPointMake(paramSender.view.center.x + point.x, paramSender.view.center.y + point.y);
    
    CGFloat maxLeftWidth = MAX(_model.firstLength, _model.thridLength);
    CGFloat maxRightWidth = MAX(_model.secondLength, _model.forthLength);
    
    if (maxLeftWidth != 0) {
        maxLeftWidth += 30.f;
    }
    
    if (maxRightWidth != 0) {
        maxRightWidth += 30.f;
    }
    
    if (centerPoint.x - maxLeftWidth < 5 || centerPoint.x + maxRightWidth > ([UIScreen mainScreen].bounds.size.width - 5)) {
        return;
    }
    BOOL isBottom = NO;
    BOOL isTop = NO;
    if (_model.fristLabel || _model.secondLength) {
        isTop = YES;
    }
    if (_model.thirdLabel || _model.forthLength) {
        isBottom = YES;
    }
    
    if (isTop) {
        if ((centerPoint.y - LABEL_HEIGHT - 15 - 2) < 5) {
            return;
        }
    }
    else
    {
        if ((centerPoint.y - 10) < 0) {
            return;
        }
    }
    
    if (isBottom) {
        if ((centerPoint.y + 15) > ([UIScreen mainScreen].bounds.size.width - 5)) {
            return;
        }
    }
    else
    {
        if (centerPoint.y > [UIScreen mainScreen].bounds.size.width - 10) {
            return;
        }
    }
    
    
    paramSender.view.center = centerPoint;
    
    _model.point = paramSender.view.center;
    
    [paramSender setTranslation:CGPointMake(0, 0) inView:self];
}

- (void)setModel:(addTagsModel *)model
{
    _model = model;
}

- (void)setCannottBeMove:(BOOL)cannottBeMove
{
    _cannottBeMove = cannottBeMove;
    if (_cannottBeMove) {
        self.userInteractionEnabled = NO;
    }
    else
    {
        self.userInteractionEnabled = YES;
    }
}

- (void)drawRect:(CGRect)rect
{
    
//    CGSize s_label = [_postHeaderView.label_tags sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 39 , FLT_MAX)]
    [self addPath:_model.fristLabel type:4];
    [self addPath:_model.secondLabel type:3];
    [self addPath:_model.thirdLabel type:2];
    [self addPath:_model.forthLabel type:1];
    
    PulsingHaloLayer *lolayer = [PulsingHaloLayer layer];
    
    lolayer.position = _white_point.center;
    lolayer.animationDuration = 1.5;
    lolayer.radius = 0.4 * 40;
    
    [self.layer addSublayer:lolayer];
}

- (void)addPath:(NSString *)label type:(NSInteger)type
{
    if (label) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        [path moveToPoint:_white_point.center];
        UILabel *ui_Label = [[UILabel alloc] init];
//        [ui_Label.titleLabel setFont:[UIFont systemFontOfSize:10.f]];
//        [ui_Label setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [ui_Label addTarget:self action:@selector(editTags:) forControlEvents:UIControlEventTouchDown];
//        [ui_Label setTitle:label forState:UIControlStateNormal];
        ui_Label.text = label;
        [self adjustLabelFont:ui_Label];
        ui_Label.textColor = [UIColor whiteColor];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label];
        
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowBlurRadius = 5;
        shadow.shadowColor = [UIColor blackColor];
        shadow.shadowOffset = CGSizeMake(1, 2);
        
        [str addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0,[label length])];
        
        ui_Label.attributedText = str;
        
        CGSize size = [ui_Label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, FLT_MAX)];
        
        switch (type) {
            case 1:
            {
                ui_Label.frame = CGRectMake(CENTER_X + 20, CENTER_Y - 2, size.width, size.height);
                [path addLineToPoint:CGPointMake(CENTER_X + 15, CENTER_Y + 15)];
                [path addLineToPoint:CGPointMake(CENTER_X + 25 + size.width, CENTER_Y + 15)];
            }
                break;
            case 2:
            {
                ui_Label.frame = CGRectMake(CENTER_X - 20 - size.width, CENTER_Y - 2, size.width, size.height);
                [path addLineToPoint:CGPointMake(CENTER_X - 15, CENTER_Y + 15)];
                [path addLineToPoint:CGPointMake(CENTER_X - 15 - 10 - size.width, CENTER_Y + 15)];
            }
                break;
            case 3:
            {
                ui_Label.frame = CGRectMake(CENTER_X + 20, CENTER_Y - 15 - size.height - 2, size.width, size.height);
                [path addLineToPoint:CGPointMake(CENTER_X + 15, CENTER_Y - 15)];
                [path addLineToPoint:CGPointMake(CENTER_X + 15 + 10 + size.width, CENTER_Y - 15)];
            }
                break;
            case 4:
            {
                ui_Label.frame = CGRectMake(CENTER_X - 20 - size.width, CENTER_Y - 15 - size.height - 2, size.width, size.height);
                [path addLineToPoint:CGPointMake(CENTER_X - 15, CENTER_Y - 15)];
                [path addLineToPoint:CGPointMake(CENTER_X - 15 - 10 - size.width, CENTER_Y - 15)];
            }
                break;
            default:
                return;
                break;
        }
        
        CAShapeLayer *pathLayer = [CAShapeLayer layer];
        //    pathLayer.frame = self.bounds;
        pathLayer.path = path.CGPath;
        pathLayer.strokeColor = [[UIColor whiteColor] CGColor];
        pathLayer.fillColor = nil;
        pathLayer.lineWidth = 1.2;
        pathLayer.lineJoin = kCALineJoinBevel;
        
        pathLayer.masksToBounds = NO;
        
        pathLayer.shadowColor = [UIColor blackColor].CGColor;
        
        pathLayer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        pathLayer.shadowOpacity = 0.5f;
        
        [self.layer addSublayer:pathLayer];
        
        [self bringSubviewToFront:_white_point];
        
        [self performSelector:@selector(showLabel:) withObject:ui_Label afterDelay:0.5];
        
        
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = 0.5;
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    }
}

- (void)showLabel:(UILabel *)label
{
    [self addSubview:label];
}


- (void)adjustLabelFont:(UILabel *)label
{
    if ([UIScreen mainScreen].bounds.size.width <= 320) {
        label.font = [UIFont boldSystemFontOfSize:10.f];
    }
    else
    {
        label.font = [UIFont boldSystemFontOfSize:12.f];
    }
    
}

- (void)addTags:(UITapGestureRecognizer *)gesture
{
    if (_cannottBeMove == YES) {
        return;
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_EDIT_TAG object:_model];
}

- (void)editTags:(id)btn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FREE_NOTIFICATION_EDIT_TAG object:_model];
}


@end
