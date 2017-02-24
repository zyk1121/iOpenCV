//
//  iTestView.m
//  iOpenGL
//
//  Created by zhangyuanke on 17/2/19.
//  Copyright © 2017年 zhangyuanke. All rights reserved.
//

#import "iTestView.h"

@interface iTestView ()

@property (nonatomic, strong) UIImage * image1;

@end

@implementation iTestView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"tile" ofType:@"png"];
        self.image1 = [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [self.image1 drawInRect:CGRectMake(0, 0, 320, 480)];
     [self.image1 drawInRect:CGRectMake(200, 200, 256, 256)];
}


@end
