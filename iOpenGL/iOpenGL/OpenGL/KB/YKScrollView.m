//
//  ISMScrollView.m
//  iShowMap
//
//  Created by zhangyuanke on 17/2/24.
//  Copyright © 2017年 zhangyuanke. All rights reserved.
//

#import "YKScrollView.h"

@interface YKScrollView ()<UIScrollViewDelegate>
{
    Class       _subViewClass;
    NSUInteger  _totalCount;
    CGFloat     _subViewWidth;
    CGFloat     _subViewHeight;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *subViewsDic;
@property (nonatomic, copy) dispatch_block_t block;

@end

@implementation YKScrollView

- (instancetype)initWithFrame:(CGRect)frame andSubViewClass:(Class)subViewClass
{
    self = [super initWithFrame:frame];
    if (self) {
        if (![subViewClass isSubclassOfClass:[UIView class]]) {
            return nil;
        }
        _subViewClass = subViewClass;
        _currentIndex = 0;
        _totalCount = 0;
        _subViewWidth = self.bounds.size.width;
        _subViewHeight = self.bounds.size.height;
        _subViewsDic = [[NSMutableDictionary alloc] init];
        self.scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [self addSubview:self.scrollView];
    }
    return self;
}

- (UIScrollView *)scrollView {
    
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (void)setData:(NSArray *)data
{
    if (data.count == 0) {
        return;
    }
    
    [[_subViewsDic allValues] enumerateObjectsUsingBlock:^(UIView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [_subViewsDic removeAllObjects];
    
    _data = data;
    if (data.count == 1) {
        self.scrollView.scrollEnabled = NO;
    }
    _totalCount = data.count;
    self.scrollView.contentSize = CGSizeMake(_subViewWidth * _totalCount, 0);
    self.currentIndex = 0;
    // init data
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [self updateViewWithIndex:self.currentIndex];
}

- (void)scrollToIndex:(NSInteger)index
{
    if (index < 0 || index > _data.count - 1) {
        return;
    }
    if (index == self.currentIndex) {
        return;
    }
    NSInteger tempIndex = -1;
    if (index > self.currentIndex) {
        if (index == self.currentIndex + 1) {
            [self.scrollView setContentOffset:CGPointMake(_subViewWidth * index, 0) animated:YES];
        } else {
            tempIndex = self.currentIndex + 1;
        }
    }
    if (index < self.currentIndex) {
        if (index == self.currentIndex -1) {
            [self.scrollView setContentOffset:CGPointMake(_subViewWidth * index, 0) animated:YES];
        } else {
            tempIndex = self.currentIndex - 1;
        }
    }
    // 修改数据
    [self updateViewWithIndex:tempIndex andData:self.data[index]];
    // 移动
    [self.scrollView setContentOffset:CGPointMake(_subViewWidth * tempIndex, 0) animated:YES];
    // 动画执行完毕时机？
    __weak YKScrollView *weakSelf = self;
    weakSelf.block = ^{
        __strong YKScrollView *strongSelf = self;
        [strongSelf updateViewWithIndex:index andData:strongSelf.data[index]];
        [strongSelf.scrollView setContentOffset:CGPointMake(_subViewWidth * index, 0) animated:NO];
        // 还原数据
        [strongSelf updateViewWithIndex:tempIndex andData:strongSelf.data[tempIndex]];
    };
}

- (void)updateViewWithIndex:(NSInteger)index andData:(id)data
{
    if (index < 0 || index > _totalCount - 1) {
        return;
    }
    NSString *indexKey = [NSString stringWithFormat:@"%ld", index];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    UIView *subView = (UIView *)[_subViewsDic objectForKey:indexKey];
    if (subView) {
        // 存在数据View
        if (subView && [subView isKindOfClass:[UIView class]]) {
            if ([subView respondsToSelector:@selector(updateData:)]) {
                [subView performSelector:@selector(updateData:) withObject:data];
            }
        }
    } else {
        // 创建一个新的View
        subView = [[_subViewClass alloc] init];
        subView.frame = CGRectMake(_subViewWidth * index, 0, _subViewWidth, _subViewHeight);
        if (subView && [subView isKindOfClass:[UIView class]]) {
            if ([subView respondsToSelector:@selector(updateData:)]) {
                [subView performSelector:@selector(updateData:) withObject:data];
            }
        }
        [_scrollView addSubview:subView];
        [_subViewsDic setObject:subView forKey:indexKey];
    }
#pragma clang diagnostic pop
}

- (void)updateViewWithIndex:(NSInteger)index
{
    if (index < 0 || index > _data.count - 1) {
        return;
    }
    [self updateViewWithIndex:index andData:self.data[index]];
}

//
- (int)currentPage
{
    return floor(self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.block) {
        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    int page1 = floor(scrollView.contentOffset.x / pageWidth);
    int page2 = floor((scrollView.contentOffset.x + pageWidth - 2) / pageWidth);
    if (page1 < 0 || page2 < 0) {
        return;
    }
    // 更新数据
    [self updateViewWithIndex:page1];
    [self updateViewWithIndex:page2];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor(scrollView.contentOffset.x / pageWidth);
    if (page >= 0 && page <= _totalCount - 1) {
        if (page != self.currentIndex) {
            self.currentIndex = page;
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
{
    if (self.block) {
        self.block();
        self.block = nil;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor(scrollView.contentOffset.x / pageWidth);
    if (page >= 0 && page <= _totalCount - 1) {
        self.currentIndex = page;
    }
}

@end
