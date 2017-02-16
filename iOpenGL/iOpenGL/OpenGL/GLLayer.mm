//
//  GLLayer.m
//
//  Created by zhangyuanke on 17/2/12.
//  Copyright © 2017年 zhangyuanke. All rights reserved.
//

#import "GLLayer.h"
#import "GLContextManager.h"
#include <netinet/in.h>
#include <sys/sysctl.h>
#include <stdlib.h>
#include <pthread.h>
#import "UIKitMacros.h"
#import <CoreMotion/CoreMotion.h>

pthread_mutex_t mutRender = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutRender2 = PTHREAD_MUTEX_INITIALIZER;

@interface GLLayer ()
{
    GLuint  m_renderbuffer;
    GLuint  m_framebuffer;
    // fps动态改变timer
    NSTimer        *m_fpstimer;
    
    //
    GLuint textureID;
}
@property (nonatomic, strong) CADisplayLink *displayLink;   // 绘制fps
@property (nonatomic, assign) BOOL isAPPActive;

@property (nonatomic, strong) CMMotionManager *motionManager;
/*!
 *  @brief  是否使用方向传感器自动移动视角
 */
@property (nonatomic, getter=isMotionEnable) BOOL motionEnable;

@end

@implementation GLLayer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupGL];
        [self setupData];
        [self initGLScreen];
    }
    
    return self;
}

- (void)setupData
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    _isAPPActive = YES;
    self.clipsToBounds = YES;
    
    textureID = [self getTextureIDFromImage:[UIImage imageNamed:@"test.jpeg"]];
//    NSLog(@"%d", textureID);
    _motionManager = [[CMMotionManager alloc] init];
}


- (void)setupGL
{
    pthread_mutex_lock(&mutRender);
    
    CAEAGLLayer* eaglLayer = (CAEAGLLayer*)super.layer;
    eaglLayer.opaque = NO;
    
    self.context = [GLContextManager sharedManager].context;
    
    // 设置为当前Context
    if (![EAGLContext setCurrentContext:self.context]) {
        return ;
    }
    
    // 创建render buffer 也叫 color buffer
    
    glGenRenderbuffersOES(1, &m_renderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_renderbuffer);
    
    // step 4, 这一步一定要在step 3之后，否则会失败
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    
    
    int width;
    int height;
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &width);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &height);
    
    // step 5 创建frame buffer
    glGenFramebuffersOES(1, &m_framebuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_framebuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, m_renderbuffer);
    // 这句可有可无
    GLenum status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
    if (status != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"err");
    }
    
    pthread_mutex_unlock(&mutRender);
}

// 设置layerClass
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    _displayLink.frameInterval = 1;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode]; // 支持滑动刷新
    
    if (m_fpstimer) {
        [m_fpstimer invalidate];
        m_fpstimer = nil;
    }
    //    m_fpstimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(fpstimerRun:) userInfo:nil repeats:YES];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    if (m_fpstimer) {
        [m_fpstimer invalidate];
        m_fpstimer = nil;
    }
}

- (float)fps
{
    if (_displayLink) {
        return 60.0/_displayLink.frameInterval;
    }
    return 0;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    _isAPPActive = NO;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    _isAPPActive = YES;
}


// render
- (void)render:(CADisplayLink *)displayLink
{
    if ([displayLink isPaused]) {
        return;
    }
    if (!_isAPPActive) {
        return;
    }
    pthread_mutex_lock(&mutRender);
    
    [EAGLContext setCurrentContext:self.context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, m_framebuffer);
//    glClearColor(0, 0, 0, 0);
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // render
//    glClearColor(1, 1, 1, 1);
//    NSLog(@"1234");
    [self testRender];
    
    GLenum attachments[] = { GL_COLOR_ATTACHMENT0_OES, GL_DEPTH_ATTACHMENT_OES, GL_STENCIL_ATTACHMENT_OES };
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 3, attachments);
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, m_renderbuffer);
    GLenum status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
    if (status == GL_FRAMEBUFFER_COMPLETE_OES && glGetError() == GL_NO_ERROR) {
        [self.context presentRenderbuffer:GL_RENDERBUFFER_OES];
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, 0);
    }
    
    pthread_mutex_unlock(&mutRender);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[GLContextManager sharedManager] removeReferenceForContext];
}

// render

- (void)initGLScreen
{
     float scale = [UIScreen mainScreen].scale;
    glViewport(0, 0, SCREEN_WIDTH * scale, SCREEN_HEIGHT * scale);
    
    glMatrixMode(GL_PROJECTION);        // 设置矩阵模式为投影变换矩阵，
    glLoadIdentity();
    gluPerspective_ishow(120, (GLfloat)SCREEN_WIDTH / SCREEN_HEIGHT, 0, 1);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

- (void)beforeRender
{
    glMatrixMode(GL_PROJECTION);        // 设置矩阵模式为投影变换矩阵，
    glLoadIdentity();
    glShadeModel(GL_SMOOTH);
    glEnable(GL_DEPTH_TEST);            // 所作深度测试的类型
    glDepthFunc(GL_LEQUAL);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glAlphaFunc(GL_GREATER ,0.99);//
    gluPerspective_ishow(120, (GLfloat)SCREEN_WIDTH / SCREEN_HEIGHT, 0, 1);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    float scale = [UIScreen mainScreen].scale;
    glViewport(0, 0, SCREEN_WIDTH * scale, SCREEN_HEIGHT * scale);
    
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);    // 清除颜色数据和深度数据（清屏）
   
//    glLoadIdentity();
}

- (void)testRender
{
    // 重设绘制设置信息
    [self beforeRender];
    // 开始绘制
//    glPushMatrix();
////    [self trangle];
//    glPopMatrix();
    
    glPushMatrix();
//    pthread_mutex_lock(&mutRender2);
//    [self sibianxing];
//     pthread_mutex_unlock(&mutRender2);
    glPopMatrix();
    
    glPushMatrix();
    [self drawTextureImage];
    glPopMatrix();
}

//- (void)trangle
//{
//    glClearColor(0, 0, 0, 1);
//    GLfloat trangleVerts[] = {
//        -100, 100, -300,
//        -100, -100, -300,
//        100, -100, -300,
//        100, 100, -300
//    };
//    glEnableClientState(GL_VERTEX_ARRAY);
//    glClear(GL_COLOR_BUFFER_BIT);
//    glColor4f(1, 0, 0, 1);
//    
//    glVertexPointer(3, GL_FLOAT, 0, trangleVerts);
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
//    glDisableClientState(GL_VERTEX_ARRAY);
//}

- (void)trangle
{
    
    GLfloat squareVerts[] = {
        
        -1, 1, -1,
        -1, -1, -1,
        1, -1, -1,
        1, 1, -1
    };
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glColor4f(1, 1, 1, 0.2);
    
    glVertexPointer(3, GL_FLOAT, 0, squareVerts);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glDisableClientState(GL_VERTEX_ARRAY);
}

float changeValue = 0;

- (void)drawTextureImage
{
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_DEPTH_TEST);
    
    GLfloat texCoords[] = {
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    static float x = -1;
    static float w = 0.2;
    
    if (self.motionEnable) {
        x = changeValue;
    } else {
        if (x >= 0.5) {
            x = 0.5;
            if (!self.motionEnable) {
                [self setMotionEnable:YES];
            }
        } else {
            x += 0.01;
        }
    }
    
    
    
    GLfloat coords[] = {
        
        x, x, -1,
        x, (x-w), -1,
        x+w, (x-w), -1,
        x+w, x, -1
    };

    
    glBindTexture(GL_TEXTURE_2D, textureID);
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(3, GL_FLOAT, 0, coords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    
    
    glDisable(GL_TEXTURE_2D);
}

- (void)sibianxing
{
    glMatrixMode(GL_MODELVIEW);
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_DEPTH_TEST);
    
    
//    GLfloat squareVerts[] = {
//        
//        -100, 100, -1000,
//        -100, -100, -1000,
//        100, -100, -1000,
//        100, 100, -1000
//    };
//
    
    static float x = -1;
    static float w = 0.1;
    
    if (x >= 0.5) {
        x = 0.5;
//        if (!self.motionEnable) {
//            [self setMotionEnable:YES];
//        }
    } else {
        x += 0.01;
    }
    
    
    GLfloat squareVerts[] = {
        
        x, x, -1,
        x, (x-w), -1,
        x+w, (x-w), -1,
        x+w, x, -1
    };
    
//    GLfloat squareVerts[] = {
//        
//        -0.3, 0.3, -1,
//        -0.3, -0.3, -1,
//        0.3, -0.3, -1,
//        0.3, 0.3, -1
//    };
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glColor4f(0, 1, 0, 0.5);
    
    glVertexPointer(3, GL_FLOAT, 0, squareVerts);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    
    
    
    glDisable(GL_TEXTURE_2D);
}


/* 判断一个整数是否为2的次方幂 */
-(BOOL)isValidWidthForTextureWithWidth:(int)value
{
    BOOL flag = NO;
    if((value > 0) && (value & (value - 1)) == 0) {
        flag = YES;
    }
    return flag;
}

- (unsigned char *)getImageDataFromImage:(UIImage *)image
{
    if (!image) {
        return NULL;
    }
    
    size_t width = image.size.width;
    size_t height = image.size.height;
    if (![self isValidWidthForTextureWithWidth:width] || ![self isValidWidthForTextureWithWidth:height]) {
        return NULL;
    }
    
    unsigned char *data = [self convertUIImageToBitmapRGBA8:image];
    return data;
}

- (GLuint)getTextureIDFromImage:(UIImage *)image
{
    if (!image) {
        return 0;
    }
    
    size_t width = image.size.width;
    size_t height = image.size.height;
    if (![self isValidWidthForTextureWithWidth:width] || ![self isValidWidthForTextureWithWidth:height]) {
        return 0;
    }
    
    unsigned char *data = [self convertUIImageToBitmapRGBA8:image];
    if (data == NULL) {
        return 0;
    }
    
    GLuint textureId = 0;
    
    glGenTextures(1, &textureId);
    
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, textureId);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width,  (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    free(data);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_TEXTURE_2D);
    
    return textureId;
}

- (unsigned char *)convertUIImageToBitmapRGBA8:(UIImage *)image {
    
    // is image texture
    CGImageRef cgimage = image.CGImage;
    if(!cgimage)
        return nil;
    
    CGSize textureSize = CGSizeMake((int)CGImageGetWidth(cgimage), (int)CGImageGetHeight(cgimage));
    
    int size = textureSize.width * textureSize.height * 4;
    unsigned char *textureBuffer = (unsigned char *)malloc(size);
    memset(textureBuffer, 0, size);
    // Use  the bitmatp creation function provided by the Core Graphics framework.
    CGContextRef brushContext = CGBitmapContextCreate(textureBuffer, textureSize.width, textureSize.height, 8, textureSize.width * 4, CGImageGetColorSpace(cgimage), kCGImageAlphaPremultipliedLast);
    //    for(int i = 0; i < size; i+=4) {
    //        textureBuffer[i+0] = 0xFF;
    //        textureBuffer[i+1] = 0xFF;
    //        textureBuffer[i+2] = 0xFF;
    //        textureBuffer[i+3] = 0x00;
    //    }
    
    //    CGContextTranslateCTM(brushContext, 0.0, CGImageGetHeight(cgimage));
    //    CGContextScaleCTM(brushContext, 1.0f, -1.0f);
    // After you create the context, you can draw the  image to the context.
    CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)textureSize.width, (CGFloat)textureSize.height), cgimage);
    // You don't need the context at this point, so you need to release it to avoid memory leaks.
    CGContextRelease(brushContext);
    
    return textureBuffer;
}

/*!
 *  @brief  是否使用方向传感器自动移动视角
 */
- (void)setMotionEnable:(BOOL)motionEnable
{
    _motionEnable = motionEnable;
    if (motionEnable) {
        if (self.motionManager.isDeviceMotionAvailable) {
            
            self.motionManager.deviceMotionUpdateInterval = 0.05;
            __weak GLLayer* weakSelf = self;
            [weakSelf.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                __strong GLLayer* strongSelf = self;
                double gravityX = motion.gravity.x;
                double gravityY = motion.gravity.y;
                double gravityZ = motion.gravity.z;
                
                double roll = motion.attitude.roll/M_PI*180.0;
                double pitch = motion.attitude.pitch/M_PI*180.0;
                double yaw = -motion.attitude.yaw/M_PI*180.0-90;//  偏转90度
                //                NSLog(@"%lf",yaw);
                // 获取手机的倾斜角度：
                double zTheta = atan2(gravityZ,sqrtf(gravityX*gravityX+gravityY*gravityY))/M_PI*180.0;
//                NSLog(@"%lf",zTheta);
                changeValue = zTheta / 90;
                
            }];
        }
    } else {
        
        [self.motionManager stopDeviceMotionUpdates];
    }
}


@end
