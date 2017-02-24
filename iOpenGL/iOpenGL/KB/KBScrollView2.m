//
//  KBScrollView.m
//  iStudyDemo
//
//  Created by zhangyuanke on 16/6/24.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import "KBScrollView2.h"
#import "UIView+Extension.h"

/*
 我们可以在scrollview里面这样添加图片的顺序， img 4,  img1,  img2, img3, img 4  ,img1位置分别是 0，1，2，3，4，5，    大家想到怎么回事了吧，这样，手指从img 4到img1循环的时候 （也就是位置4到位置5）是有个过度的，一旦滑动到第6个位置，那么我就让scrollview  setContentOffset: 位置1 动画设置为no。相反，如果手指从img1滑动到img4（也就是位置1到位置0）也是有个过度的，一旦滑动到位置0，那么我就可以让scrollview  setContentOffset: 位置4 动画依然设置为no， 就可以了。 
 */
#define MyColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

@interface KBScrollView2 ()<UIScrollViewDelegate>

@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, copy) NSArray *imageArray;
@property (weak, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isRun;

@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;
@property (nonatomic, strong) UIButton *button3;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, strong) UILabel *label3;


@end

@implementation KBScrollView2

/* 初始化 UISrollView begin*/
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
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
    _isRun=isAutoRun;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.添加UISrollView
    [self setupScrollView];
    
    // 2.添加pageControl
    [self setupPageControl];
    
    [self setupButton];
    
}

- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

/*
 button 分类
 - (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
 [self setBackgroundImage:[UIButton imageWithColor:backgroundColor] forState:state];
 }
 
 + (UIImage *)imageWithColor:(UIColor *)color {
 CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
 UIGraphicsBeginImageContext(rect.size);
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 CGContextSetFillColorWithColor(context, [color CGColor]);
 CGContextFillRect(context, rect);
 
 UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 return image;
 }
 */

- (void)setupButton
{
    CGFloat buttonW = self.bounds.size.width / 3.0;
    CGFloat buttonH = 80;

    
    _button1 = ({
        UIButton *button = [[UIButton alloc] init];
        button.tag = 1;
        button.backgroundColor = [UIColor whiteColor];
//        [button setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//        [button setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
//        [button setBackgroundImage:[UIImage imageNamed:@"route_selected"] forState:UIControlStateSelected];
        button.frame = CGRectMake(0, 0, buttonW, buttonH);
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    _button2 = ({
        UIButton *button = [[UIButton alloc] init];
button.tag = 2;
        button.backgroundColor = [UIColor whiteColor];
//        [button setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//        [button setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
//        [button setBackgroundImage:[UIImage imageNamed:@"route_selected"] forState:UIControlStateSelected];
        button.frame = CGRectMake(buttonW, 0, buttonW, buttonH);
         [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
    _button3 = ({
        UIButton *button = [[UIButton alloc] init];
        button.tag = 3;
        button.backgroundColor = [UIColor whiteColor];
//        [button setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//        [button setBackgroundImage:[self createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
////        [button setImage:[UIImage imageNamed:@"route_selected"] forState:UIControlStateHighlighted];
//        
//        [button setBackgroundImage:[UIImage imageNamed:@"route_selected"] forState:UIControlStateSelected];
        button.frame = CGRectMake(buttonW * 2, 0, buttonW, buttonH);
//        button.adjustsImageWhenHighlighted = NO;//  // default is YES. if YES, image is drawn darker when highlighted(pressed)
         [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button;
    });
//    self.button1.selected = YES;
    
    _imageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"route_selected"];
        imageView.frame = CGRectMake(0, 0, buttonW, buttonH);
        [self addSubview:imageView];
        imageView;
    });
    
    
    _label1 = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"ceshi";
        label.frame = CGRectMake(0, 0, buttonW, buttonH);
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        label;
    });
    _label2 = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"ceshi";
        label.frame = CGRectMake(buttonW, 0, buttonW, buttonH);
        label.textAlignment = NSTextAlignmentCenter;
         label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        label;
    });
    _label3 = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"ceshi";
        label.frame = CGRectMake(buttonW *2, 0, buttonW, buttonH);
        label.textAlignment = NSTextAlignmentCenter;
         label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        label;
    });
    
    
  self.button1.backgroundColor = [UIColor clearColor];
  
//    self.backgroundColor = [UIColor whiteColor];

}

/**
 *  添加UISrollView
 */
- (void)setupScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 80, self.bounds.size.width, self.bounds.size.height - 80);
    scrollView.delegate = self;
    [self addSubview:scrollView];
    
    // 2.添加图片
    CGFloat imageW = scrollView.frame.size.width;
    CGFloat imageH = scrollView.frame.size.height;
    
    // 多加一个
    UIImageView *imageViewStart = [[UIImageView alloc] init];
    imageViewStart.image = [UIImage imageNamed:self.imageArray[self.imageArray.count - 1]];
    CGFloat imageX = 0 * imageW;
    imageViewStart.frame = CGRectMake(imageX, 0, imageW, imageH);
    
    [scrollView addSubview:imageViewStart];
    
    for (int index = 0; index<self.imageArray.count; index++) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:self.imageArray[index]];
        CGFloat imageX = (index+1) * imageW;
        imageView.frame = CGRectMake(imageX, 0, imageW, imageH);
        [scrollView addSubview:imageView];
    }
    
    UIImageView *imageViewEnd = [[UIImageView alloc] init];
    imageViewEnd.image = [UIImage imageNamed:self.imageArray[0]];
    imageX = (self.imageArray.count + 1) * imageW;
    imageViewEnd.frame = CGRectMake(imageX, 0, imageW, imageH);
    
    [scrollView addSubview:imageViewEnd];
    
    // 3.设置滚动的内容尺寸
    scrollView.contentSize = CGSizeMake(imageW * (self.imageArray.count + 2), 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
    scrollView.contentOffset = CGPointMake(imageW, 0);
    _scrollView=scrollView;
    
    
    if(self.isRun)
        [self addScrollTimer];
}

/*定时器设置  begin*/
- (void)addScrollTimer
{
    [self removeScrollTimer];
    self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}


- (void)removeScrollTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self setCurrentPage:scrollView];
    
}

- (void)setCurrentPage:(UIScrollView *)scrollView
{
    // 1.取出水平方向上滚动的距离
    CGFloat offsetX = scrollView.contentOffset.x;
    // 2.求出页码
    double pageDouble = offsetX / scrollView.frame.size.width;
    int pageInt = (int)(pageDouble + 0.5);
    if (pageInt == 0) {
        pageInt = 3;
    } else {
        if (pageInt == 4) {
            pageInt = 1;
        }
    }
    self.pageControl.currentPage = pageInt - 1;
    
}

- (void)buttonClicked:(UIButton *)button
{
    NSUInteger tag = button.tag;
    [self.scrollView setContentOffset:CGPointMake(self.width * tag, 0) animated:YES];
    [self setCurrentPage:self.scrollView];
}

- (void)nextPage
{
    long currentPage = self.pageControl.currentPage;
    currentPage ++;
    if (currentPage == self.imageArray.count) {
        currentPage = 0;
    }
    
    CGFloat width = self.scrollView.frame.size.width;
    CGPoint offset = CGPointMake(currentPage * width, 0.f);
    [UIView animateWithDuration:.2f animations:^{
        self.scrollView.contentOffset = offset;
    }];
}

- (int)currentPage
{
    return floor(self.scrollView.contentOffset.x / self.scrollView.width);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int curPage = [self currentPage];
    
    if (curPage == 0) {
        [self.scrollView setContentOffset:CGPointMake(self.width * [self.imageArray count], 0) animated:NO];
//        [self.scrollView scrollRectToVisible:CGRectMake(self.width * [self.imageArray count], 0, self.width, self.height) animated:NO];
    } else if (curPage == ([self.imageArray count] + 1)) {
        [self.scrollView setContentOffset:CGPointMake(self.width, 0) animated:NO];
//        [self.scrollView scrollRectToVisible:CGRectMake(self.width, 0, self.width, self.height) animated:NO];
    }
    [self setCurrentPage:scrollView];
    
    
    // 1.取出水平方向上滚动的距离
    CGFloat offsetX = scrollView.contentOffset.x;
    // 2.求出页码
    double pageDouble = offsetX / scrollView.frame.size.width;
    int pageInt = (int)(pageDouble + 0.5);
    if (pageInt == 0) {
        pageInt = 3;
    } else {
        if (pageInt == 4) {
            pageInt = 1;
        }
    }
    
    self.button1.backgroundColor = [UIColor whiteColor];
    self.button2.backgroundColor = [UIColor whiteColor];
    self.button3.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.2 animations:^{
        
        
        CGFloat buttonW = self.bounds.size.width / 3.0;
        CGFloat buttonH = 80;
        self.imageView.frame = CGRectMake(buttonW * (pageInt - 1), 0, buttonW, buttonH);
        
    } completion:^(BOOL finished) {
        
        
        switch (pageInt) {
            case 1:
                self.button1.backgroundColor = [UIColor clearColor];
                break;
            case 2:
                self.button2.backgroundColor = [UIColor clearColor];
                break;
            case 3:
                self.button3.backgroundColor = [UIColor clearColor];
                break;
                
            default:
                break;
        }

    }];
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    int curPage = [self currentPage];
    
    if (curPage == self.imageArray.count + 1) {
        [self setCurrentPage:scrollView];
    }
    [self setCurrentPage:scrollView];
    
    
    // 1.取出水平方向上滚动的距离
    CGFloat offsetX = scrollView.contentOffset.x;
    // 2.求出页码
    double pageDouble = offsetX / scrollView.frame.size.width;
    int pageInt = (int)(pageDouble + 0.5);
    if (pageInt == 0) {
        pageInt = 3;
    } else {
        if (pageInt == 4) {
            pageInt = 1;
        }
    }
self.button1.backgroundColor = [UIColor whiteColor];
    self.button2.backgroundColor = [UIColor whiteColor];
    self.button3.backgroundColor = [UIColor whiteColor];

    [UIView animateWithDuration:0.2 animations:^{
        
        
        CGFloat buttonW = self.bounds.size.width / 3.0;
        CGFloat buttonH = 80;
        self.imageView.frame = CGRectMake(buttonW * (pageInt - 1), 0, buttonW, buttonH);
        
    }completion:^(BOOL finished) {
        
        switch (pageInt) {
            case 1:
                self.button1.backgroundColor = [UIColor clearColor];
                break;
            case 2:
                self.button2.backgroundColor = [UIColor clearColor];
                break;
            case 3:
                self.button3.backgroundColor = [UIColor clearColor];
                break;
                
            default:
                break;
        }
    }];
}

/*
 下面来看buttonselected:里面的实现过程
 
 iOS 实现多个按钮，点选一个其它都取消选中状态的最佳方法
 
 // 按钮状态??
 
 -（void）buttonSelected:(UIButton*)sender{
 if (_tmpBtn == nil){
 sender.selected = YES;
 _tmpBtn = sender;
 }
 else if (_tmpBtn !=nil && _tmpBtn == sender){
 sender.selected = YES;
 
 }
 else if (_tmpBtn!= btn && _tmpBtn!=nil){
 _tmpBtn.selected = NO;
 sender.selected = YES;
 _tmpBtn = btn;
 }
}
 */

@end

/*
 我们可以在scrollview里面这样添加图片的顺序， img 4,  img1,  img2, img3, img 4  ,img1位置分别是 0，1，2，3，4，5，    大家想到怎么回事了吧，这样，手指从img 4到img1循环的时候 （也就是位置4到位置5）是有个过度的，一旦滑动到第6个位置，那么我就让scrollview  setContentOffset: 位置1 动画设置为no。相反，如果手指从img1滑动到img4（也就是位置1到位置0）也是有个过度的，一旦滑动到位置0，那么我就可以让scrollview  setContentOffset: 位置4 动画依然设置为no， 就可以了。
 
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 if ([[[UIDevice currentDevice] systemVersion]floatValue]>=7) {
 self.automaticallyAdjustsScrollViewInsets=NO;
 }
 self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, 320, 400)];
 self.scrollView.pagingEnabled=YES;
 self.scrollView.delegate=self;
 self.scrollView.showsHorizontalScrollIndicator=NO;
 self.scrollView.showsVerticalScrollIndicator=NO;
 
 [self.view addSubview:self.scrollView];
 
 for (int i=0; i<6; i++) {
 UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(320*i, 0, 320, self.scrollView.frame.size.height)];
 imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"image%d",i]];
 [self.scrollView addSubview:imageView];
 UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
 label.text=[NSString stringWithFormat:@"%d",i];
 label.center=imageView.center;
 [imageView addSubview:label];
 }
 [self.scrollView setContentSize:CGSizeMake(320*6, 400)];
 [self.scrollView setContentOffset:CGPointMake(320, 0) animated:NO];
 }
 -(void)scrollViewDidScroll:(UIScrollView *)scrollView
 {
 CGPoint point=scrollView.contentOffset;
 if ((int)point.x==0) {
 [scrollView setContentOffset:CGPointMake(320*4, 0) animated:NO];
 }else if ((int)point.x==320*5)
 {
 [scrollView setContentOffset:CGPointMake(320, 0) animated:NO];
 }
 }
 - (void)didReceiveMemoryWarning
 {
 [super didReceiveMemoryWarning];
 // Dispose of any resources that can be recreated.
 
 }

 */
