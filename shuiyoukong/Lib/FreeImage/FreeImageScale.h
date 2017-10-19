//
//  FreeImage.h
//  Free
//
//  Created by 勇拓 李 on 15/5/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define ORIGINAL_MAX_WIDTH 640.0f
@interface FreeImageScale : NSObject

//等比例压缩
//+ (UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
//+ (UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;

+ (UIImage *)compressImage:(UIImage *)image ratio:(float)ratio;

+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage;

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;

@end
