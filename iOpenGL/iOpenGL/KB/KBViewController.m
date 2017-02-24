//
//  KBViewController.m
//  iStudyDemo
//
//  Created by zhangyuanke on 16/3/23.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import "KBViewController.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "masonry.h"
#import "UIKitMacros.h"
#import "UIScrollRollView.h"
#import "KBScrollView.h"
#import "KBScrollView2.h"

#define MyColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@implementation KBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    /*
     
     在 iOS 7 中，如果某个 UIViewController 的 self.view 第一个子视图是 UIScollView， 同时当这个 UIViewController 被 push 或 initWithRootController 成为 UINavigationController控制的Controller时，这个 UIViewController的 view 的子视图 UIScollView 的所有子视图， 都会被下移 64px。
     这个下移 64px 的前提是 navigationBar 和 statusBar 没有隐藏。因为为 statusBar 默认的 Height 是 20px，而 navigatiBar  默认的 Height 是 44px。下面来比较一下
     实例
     
     如结果显示， scrollView 背景色为蓝色的子视图位置自动下移了。 而这个下移的距离刚好是 64.0px。
     
     解决方法：
     第一种：在 ViewController 的 init 的方法中增加一行代码：
     
     
     Obj-c代码 收藏代码
     self.automaticallyAdjustsScrollViewInsets = NO;
     
     
     第二种： 让UIScrollView 不要成为 ViewController 的 View 的第一个子视图。
     */


    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIScrollRollView *rollView=[[UIScrollRollView alloc] init];
    
    rollView.frame=CGRectMake(0, 100, SCREEN_WIDTH, 100);
    rollView.backgroundColor=MyColor(208, 19, 60);
    NSMutableArray *imageArray=[NSMutableArray arrayWithObjects:@"1.jpg",@"2.jpg",@"3.jpg", nil];
    [rollView setupScroollArray:imageArray isAutoRun:NO];
    [self.view addSubview:rollView];
    
    KBScrollView *sv = [[KBScrollView alloc] init];
    sv.frame=CGRectMake(0, 210, SCREEN_WIDTH, 100);
    [sv setupScroollArray:imageArray isAutoRun:NO];
    [self.view addSubview:sv];
    
    KBScrollView2 *sv2 = [[KBScrollView2 alloc] init];
    sv2.frame=CGRectMake(0, 320, SCREEN_WIDTH, 180);
    [sv2 setupScroollArray:imageArray isAutoRun:NO];
    [self.view addSubview:sv2];
}

@end
