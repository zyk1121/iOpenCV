//
//  OpenGLTestView.m
//  iStudyDemo
//
//  Created by zhangyuanke on 16/3/6.
//  Copyright © 2016年 zhangyuanke. All rights reserved.
//

#import "OpenGLTestView.h"
//#import "masonry.h"
//#import "ReactiveCocoa/ReactiveCocoa.h"
#import "UIKitMacros.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "CC3GLMatrix.h"

// http://www.cnblogs.com/andyque/archive/2011/08/08/2131019.html

// 定义Vertex数据结构
typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

//const Vertex Vertices[] = {
//    {{1, -1, 0}, {1, 0, 0, 1}},
//    {{1, 1, 0}, {0, 1, 0, 1}},
//    {{-1, 1, 0}, {0, 0, 1, 1}},
//    {{-1, -1, 0}, {0, 0, 0, 1}},
//};
//
////const Vertex Vertices[] = {
////    {{1, -1, -7}, {1, 0, 0, 1}},
////    {{1, 1, -7}, {0, 1, 0, 1}},
////    {{-1, 1, -7}, {0, 0, 1, 1}},
////    {{-1, -1, -7}, {0, 0, 0, 1}},
////};
//
//const GLubyte Indices[] = {
//    0, 1, 2,
//    2, 3, 0
//};


const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {1, 0, 0, 1}},
    {{-1, 1, 0}, {0, 1, 0, 1}},
    {{-1, -1, 0}, {0, 1, 0, 1}},
    {{1, -1, -1}, {1, 0, 0, 1}},
    {{1, 1, -1}, {1, 0, 0, 1}},
    {{-1, 1, -1}, {0, 1, 0, 1}},
    {{-1, -1, -1}, {0, 1, 0, 1}}
};

const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 7, 6,
    // Left
    2, 7, 3,
    7, 6, 2,
    // Right
    0, 4, 1,
    4, 1, 5,
    // Top
    6, 2, 1,
    1, 6, 5,
    // Bottom
    0, 3, 7,
    0, 7, 4    
};

@interface OpenGLTestView ()

@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint colorRenderBuffer;

@property (nonatomic, assign) GLuint positonSlot;
@property (nonatomic, assign) GLuint colorSolt;

@property (nonatomic, assign) GLuint projectionUnform;

@property (nonatomic, assign) GLuint modelViewUnform;
@property (nonatomic, assign) float currentRotation;
@property (nonatomic, assign) GLuint depthRenderBuffer;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation OpenGLTestView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        //
        [self compileShaders];
        [self setupVBOs];
        //
//        [self render];
//        [self setupDisplayLink];
    }
    
//    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}

#pragma mark - masonry

//+ (BOOL)requiresConstraintBasedLayout
//{
//    return YES;
//}
//
//- (void)updateConstraints
//{
//    // 添加布局
//    [super updateConstraints];
//}

#pragma mark - opengl

// 设置layerClass
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

// 设置layer为不透明
- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
}

// 创建OpenGL context
- (void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Filed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Filed to set current OpenGLES context");
        exit(1);
    }
}

// 创建render buffer
- (void)setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

// 创建一个frame buffer(帧缓冲区)
- (void)setupFrameBuffer
{
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

// 清理屏幕
//- (void)render
//{
//    glClearColor(0, 104.0 / 255.0, 55.0 / 255.0, 1.0);
//    glClear(GL_COLOR_BUFFER_BIT);
//    
//    CC3GLMatrix *projection = [CC3GLMatrix matrix];
//    float h = 4.0f * self.frame.size.height / self.frame.size.width;
//    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h / 2 andTop:h / 2 andNear:4 andFar:10];
//    glUniformMatrix4fv(_projectionUnform, 1, 0, projection.glMatrix);
//    
//    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
//    [modelView populateFromTranslation:CC3VectorMake(sin(CACurrentMediaTime()), 0, -7)];
//    glUniformMatrix4fv(_modelViewUnform, 1, 0, modelView.glMatrix);
//    
//    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
//    glVertexAttribPointer(_positonSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)0);
//    glVertexAttribPointer(_colorSolt, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(float) * 3));
//    glDrawElements(GL_TRIANGLES, sizeof(Indices) / sizeof(Indices[0]), GL_UNSIGNED_BYTE, (GLvoid *)0);
//    
//    [_context presentRenderbuffer:GL_RENDERBUFFER];
//}

- (void)render:(CADisplayLink *)displayLink
{
    glClearColor(0, 104.0 / 255.0, 55.0 / 255.0, 1.0);
//    glClear(GL_COLOR_BUFFER_BIT);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h / 2 andTop:h / 2 andNear:4 andFar:10];
    glUniformMatrix4fv(_projectionUnform, 1, 0, projection.glMatrix);
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(sin(CACurrentMediaTime()), 0, -7)];
    _currentRotation += displayLink.duration * 90;
    [modelView rotateBy:CC3VectorMake(_currentRotation, _currentRotation, 0)];
    glUniformMatrix4fv(_modelViewUnform, 1, 0, modelView.glMatrix);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glVertexAttribPointer(_positonSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)0);
    glVertexAttribPointer(_colorSolt, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(float) * 3));
    glDrawElements(GL_TRIANGLES, sizeof(Indices) / sizeof(Indices[0]), GL_UNSIGNED_BYTE, (GLvoid *)0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
//    [self setupDisplayLink];// 加上之后有问题
}

#pragma mark - 编译 Vertex shader 和 Fragment shader

- (GLuint)compileShader:(NSString *)shaderName withType:(GLenum)shaderType
{
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    GLuint shaderHandle = glCreateShader(shaderType);
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    glCompileShader(shaderHandle);
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

- (void)compileShaders
{
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    glUseProgram(programHandle);
    
    self.positonSlot = glGetAttribLocation(programHandle, "Position");
    self.colorSolt = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(self.positonSlot);
    glEnableVertexAttribArray(self.colorSolt);
    
    //
    _projectionUnform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUnform = glGetUniformLocation(programHandle, "ModelView");
}

// 创建Vertex Buffer 对象
- (void)setupVBOs
{
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

// Add new method right after setupRenderBuffer
- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}

@end
