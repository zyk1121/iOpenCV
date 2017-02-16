//
//  GLContextManager.h
//
//  Created by zhangyuanke on 17/2/12.
//  Copyright © 2017年 zhangyuanke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKView.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/EAGL.h>

@interface GLContextManager : NSObject

+ (GLContextManager *)sharedManager;

@property (nonatomic, strong) EAGLContext *context;
- (void)addReferenceForContext;
- (void)removeReferenceForContext;

@end
