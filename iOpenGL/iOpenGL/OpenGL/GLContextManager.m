//
//  GLContextManager.m
//
//  Created by zhangyuanke on 17/2/12.
//  Copyright © 2017年 zhangyuanke. All rights reserved.
//

#import "GLContextManager.h"

@interface GLContextManager ()
{
    NSUInteger count;
    EAGLSharegroup *_sharegroup;
}

@end

@implementation GLContextManager

+ (GLContextManager *)sharedManager
{
    static GLContextManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        count = 0;
    }
    return self;
}

- (EAGLContext *)context
{
    if (count == 0) {
        // 创建Context
        EAGLContext *tempContext = [EAGLContext currentContext];
        if (tempContext) {
            _context = [[EAGLContext alloc] initWithAPI:tempContext.API
                                             sharegroup:tempContext.sharegroup];
        } else {
            EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
            _context = [[EAGLContext alloc] initWithAPI:api];
            _sharegroup = _context.sharegroup;
        }
        count = 1;
    } else {
        [self addReferenceForContext];
    }
    return _context;
}

- (void)addReferenceForContext
{
    count++;
}
- (void)removeReferenceForContext
{
    if (count > 0) {
        count--;
        if (count == 0) {
            _sharegroup = nil;
            _context = nil;
        }
    }
}

@end
