//
//  KBScrollView.h
//  iStudyDemo
//
//  Created by zhangyuanke on 16/6/24.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KBScrollView2 : UIView

/*设置参数
 ＊imageArray  图片名称数组
 ＊isAutoRun  是否自动轮播
 */
-(void)setupScroollArray:(NSArray *)imageArray isAutoRun:(BOOL)isAutoRun;

@end
