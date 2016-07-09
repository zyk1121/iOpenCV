//
//  OpenCVTools.h
//  iOpenCV
//
//  Created by zhangyuanke on 16/7/9.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenCVTools : NSObject

+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromIplImage:(IplImage *)image;

@end
