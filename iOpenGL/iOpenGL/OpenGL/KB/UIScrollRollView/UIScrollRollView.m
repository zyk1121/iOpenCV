//
//  UIScrollRollView.m
//  huiyi_expert
//
//  Created by chenkq on 16/3/7.
//  Copyright © 2016年 huiyi. All rights reserved.
//

#import "UIScrollRollView.h"
#define MyColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@implementation UIScrollRollView

/* 初始化 UISrollView begin*/
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
/* 初始化 UISrollView end*/

/*设置参数
 ＊imageArray  图片名称数组
 ＊isAutoRun  是否自动轮播
 */
-(void)setupScroollArray:(NSArray *)imageArray isAutoRun:(BOOL)isAutoRun
{
    _imageArray=imageArray;
    _isRun=&isAutoRun;
}

/**
 *  添加UISrollView
 */
- (void)setupScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.bounds;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    
    // 2.添加图片
    CGFloat imageW = scrollView.frame.size.width;
    CGFloat imageH = scrollView.frame.size.height;
    for (int index = 0; index<self.imageArray.count; index++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:self.imageArray[index]];
        CGFloat imageX = index * imageW;
        imageView.frame = CGRectMake(imageX, 0, imageW, imageH);
        [scrollView addSubview:imageView];
    }
    
    // 3.设置滚动的内容尺寸
    scrollView.contentSize = CGSizeMake(imageW * self.imageArray.count, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    _scrollView=scrollView;
    
    if(*(self.isRun))
    {
        [self addScrollTimer];
    }
}

/*定时器设置  begin*/
- (void)addScrollTimer
{
    self.timer = [NSTimer timerWithTimeInterval:5.f target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}


- (void)removeScrollTimer
{
    [self.timer invalidate];
     self.timer = nil;
}

/*定时器设置  begin*/


/**
 *  添加pageControl
 */
- (void)setupPageControl
{
    // 1.添加
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = self.imageArray.count;
    CGFloat centerX = self.frame.size.width * 0.5;
    CGFloat centerY = self.frame.size.height - 20;
    pageControl.center = CGPointMake(centerX, centerY);
    pageControl.bounds = CGRectMake(0, 0, 100, 30);
    pageControl.userInteractionEnabled = NO;
    [self addSubview:pageControl];
    self.pageControl = pageControl;
    
    // 2.设置圆点的颜色
    pageControl.currentPageIndicatorTintColor = MyColor(208, 19, 60);
    pageControl.pageIndicatorTintColor = MyColor(189, 189, 189);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.添加UISrollView
    [self setupScrollView];
    
    // 2.添加pageControl
    [self setupPageControl];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 1.取出水平方向上滚动的距离
    CGFloat offsetX = scrollView.contentOffset.x;
    // 2.求出页码
    double pageDouble = offsetX / scrollView.frame.size.width;
    int pageInt = (int)(pageDouble + 0.5);
    self.pageControl.currentPage = pageInt;
}

- (void)nextPage
{
    int currentPage = self.pageControl.currentPage;
    currentPage ++;
    if (currentPage == self.imageArray.count) {
        currentPage = 0;
    }
    
    CGFloat width = self.scrollView.frame.size.width;
    CGPoint offset = CGPointMake(currentPage * width, 0.f);
    //    self.scrollView.contentOffset = offset;
    //    [self.scrollView setContentOffset:offset animated:YES];
    [UIView animateWithDuration:.2f animations:^{
        self.scrollView.contentOffset = offset;
    }];
}


//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    [self removeScrollTimer];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    //NSLog(@"scrollViewDidEndDragging");
//    [self addScrollTimer];
//}

@end
