//
//  YKImageView.m
//  iOpenGL
//
//  Created by zhangyuanke on 17/2/19.
//  Copyright © 2017年 zhangyuanke. All rights reserved.
//

#import "YKImageView.h"

@implementation YKImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateData:(id)data
{
    self.image = [UIImage imageNamed:data];
}

@end
