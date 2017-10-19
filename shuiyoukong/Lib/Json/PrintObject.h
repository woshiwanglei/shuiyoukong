//
//  PrintObject.h
//  谁有空—不约而同
//
//  Created by 勇拓 李 on 15/6/11.
//  Copyright (c) 2015年 知春. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrintObject : NSObject

//通过对象返回一个NSDictionary，键是属性名称，值是属性值。

+(NSDictionary*)getObjectData:(id)obj;



//将getObjectData方法返回的NSDictionary转化成JSON

+(NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;



//直接通过NSLog输出getObjectData方法返回的NSDictionary

+(void)print:(id)obj;

@end
