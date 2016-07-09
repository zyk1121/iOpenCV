//
//  OpenCVTools.m
//  iOpenCV
//
//  Created by zhangyuanke on 16/7/9.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import "OpenCVTools.h"

@implementation OpenCVTools

+ (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
    
    // Getting CGImage from UIImage
    
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Creatingtemporal IplImage for drawing
    
    IplImage *iplimage= cvCreateImage(cvSize(image.size.width,image.size.height), IPL_DEPTH_8U,4   );
    
    // CreatingCGContext for temporal IplImage
    
    CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width,iplimage->height, iplimage->depth, iplimage->widthStep, colorSpace,kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    
    // Drawing CGImageto CGContext
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width,image.size.height), imageRef);
    
    CGContextRelease(contextRef);
    
    CGColorSpaceRelease(colorSpace);
    
    // Creating resultIplImage
    
//    IplImage *ret =cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
//    
//    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
//    
//    cvReleaseImage(&iplimage);
    
    return iplimage;
    
}


// NOTE You should convert color mode as RGB before passing to thisfunction

+ (UIImage *)UIImageFromIplImage:(IplImage *)image {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Allocating thebuffer for CGImage
    
    NSData *data =[NSData dataWithBytes:image->imageData length:image->imageSize];
    
    CGDataProviderRef provider =    CGDataProviderCreateWithCFData((CFDataRef)data);
    
    // CreatingCGImage from chunk of IplImage
    
    CGImageRef imageRef = CGImageCreate(image->width, image->height,     image->depth,image->depth * image->nChannels, image->widthStep,     colorSpace,kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false,kCGRenderingIntentDefault);
    
    // Getting UIImagefrom CGImage
    
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    CGDataProviderRelease(provider);
    
    CGColorSpaceRelease(colorSpace);
    
    return ret;
    
}


@end
