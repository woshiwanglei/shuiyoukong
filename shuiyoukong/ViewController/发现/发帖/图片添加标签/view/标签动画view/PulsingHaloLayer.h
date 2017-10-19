//
//  PulsingHaloLayer.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/19.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface PulsingHaloLayer : CALayer

@property (nonatomic, assign) CGFloat radius;                   // default:60pt
@property (nonatomic, assign) NSTimeInterval animationDuration; // default:3s
@property (nonatomic, assign) NSTimeInterval pulseInterval; // default is 0s

@end
