//
//  ViewController.m
//  iOpenGL
//
//  Created by zhangyuanke on 17/2/16.
//  Copyright © 2017年 zhangyuanke. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLViewController.h"
#import "OpenGLTestView.h"
#import "UIKitMacros.h"
#import "iTestView.h"
#import "KBViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    OpenGLTestView *_glView = [[OpenGLTestView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    [self.view addSubview:_glView];
    iTestView *itestview =  [[iTestView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.view addSubview:itestview];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    KBViewController *vc = [[KBViewController alloc] init];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}


@end
