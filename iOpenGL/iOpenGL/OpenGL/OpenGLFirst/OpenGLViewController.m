//
//  OpenGLViewController.m
//  iStudyDemo
//
//  Created by zhangyuanke on 16/3/6.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import "OpenGLViewController.h"
#import "UIKitMacros.h"
#import "OpenGLTestView.h"

@interface OpenGLViewController ()

@property (nonatomic, strong) OpenGLTestView *glView;

@end

@implementation OpenGLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self.view setNeedsUpdateConstraints];
}

#pragma mark - masonry

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
//    [self.glView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).offset(64);
//        make.left.right.equalTo(self.view);
//        make.bottom.equalTo(self.view);
//    }];
}

#pragma mark - private method

- (void)setupUI
{
//    _glView = [[OpenGLTestView alloc] init];
    _glView = [[OpenGLTestView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    [self.view addSubview:_glView];
}


@end
