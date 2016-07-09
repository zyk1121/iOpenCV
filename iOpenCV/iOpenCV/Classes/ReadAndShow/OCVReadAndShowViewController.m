//
//  OCVReadAndShowViewController.m
//  iOpenCV
//
//  Created by zhangyuanke on 16/7/9.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import "OCVReadAndShowViewController.h"

@interface OCVReadAndShowViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

@end

@implementation OCVReadAndShowViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupData];
    [self setupUI];
    [self.view setNeedsUpdateConstraints];
}

#pragma mark - masonry

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(@200);
    }];
}

#pragma mark - private method

- (void)setupUI
{
    _imageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = self.image;
        imageView;
    });
    [self.view addSubview:_imageView];
}

- (void)setupData
{
//    self.image = [UIImage imageNamed:@"lena.BMP"];
    self.image = [UIImage imageNamed:@"lena.jpg"];
    // open cv process
    [self process];
    //
}

#pragma mark - private method

- (void)process
{
    /*
//    cv::Mat matImage = self.image.CVMat;
    IplImage *iplImage = [OpenCVTools CreateIplImageFromUIImage:self.image];
    IplImage *ret = cvCreateImage(cvSize(100, 100), IPL_DEPTH_8U, 4);
    
//    cvSmooth(iplImage, ret);
   // cvSobel(iplImage, ret, 3, 3);
//    cvCvtColor(iplImage, ret, CV_RGBA2GRAY);
    cvResize(iplImage, ret);
    cvReleaseImage(&iplImage);
    
    self.image = [OpenCVTools UIImageFromIplImage:ret];
    
    cvReleaseImage(&ret);
     */
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        // 图像灰度化 两种方式
        //    cv::Mat matImage = self.image.CVMat;
        //    IplImage *iplImage = [OpenCVTools CreateIplImageFromUIImage:self.image];
        cv::Mat matImage;
        cv::cvtColor(self.image.CVMat, matImage, CV_RGBA2GRAY);// 转换成灰色
        //    self.image = [UIImage imageWithCVMat:matImage];
        self.image = [UIImage imageWithCVMat:self.image.CVGrayscaleMat];
        self.imageView.image = self.image;
        
//        [self.view layoutIfNeeded];
        
    });
    
    

}

@end
