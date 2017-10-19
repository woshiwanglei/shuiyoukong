//
//  addTagsModel.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/8/19.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface addTagsModel : NSObject

@property (nonatomic,strong)NSString* fristLabel;
@property (nonatomic,strong)NSString* secondLabel;
@property (nonatomic,strong)NSString* thirdLabel;
@property (nonatomic,strong)NSString* forthLabel;
@property (nonatomic,assign)CGPoint point;

@property (nonatomic,assign)CGFloat firstLength;
@property (nonatomic,assign)CGFloat secondLength;
@property (nonatomic,assign)CGFloat thridLength;
@property (nonatomic,assign)CGFloat forthLength;

@end
