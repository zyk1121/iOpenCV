//
//  YKScrollView.h
//  iOpenGL
//
//  Created by zhangyuanke on 17/2/19.
//  Copyright © 2017年 zhangyuanke. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 实现多个视图时滚动切换模式，子类实现子View布局等详细功能
 */
@interface YKScrollView : UIView

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) NSInteger currentIndex;
- (instancetype)initWithFrame:(CGRect)frame andSubViewClass:(Class)subViewClass;
- (void)scrollToIndex:(NSInteger)index;

@end
