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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    OpenGLTestView *_glView = [[OpenGLTestView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:_glView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
//    OpenGLViewController *vc = [[OpenGLViewController alloc] init];
//    [self presentViewController:vc animated:YES completion:^{
//        
//    }];
}


@end
