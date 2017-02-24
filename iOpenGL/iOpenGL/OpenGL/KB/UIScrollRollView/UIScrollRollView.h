//
//  UIScrollRollView.h
//  huiyi_expert
//
//  Created by chenkq on 16/3/7.
//  Copyright © 2016年 huiyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollRollView : UIView<UIScrollViewDelegate>
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic,strong) NSArray *imageArray;
@property (weak, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL *isRun;
/*设置参数
  ＊imageArray  图片名称数组
  ＊isAutoRun  是否自动轮播
 */
-(void)setupScroollArray:(NSArray *)imageArray isAutoRun:(BOOL)isAutoRun;
@end
