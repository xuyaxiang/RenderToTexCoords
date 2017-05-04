//
//  YXUniform.m
//  YXRenderEngine
//
//  Created by enghou on 17/4/16.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//

#import "YXUniform.h"

@implementation YXUniform
-(instancetype)initWithKind:(NSString *)kind name:(NSString *)name{
    if (self=[super init]) {
        _kind = kind;
        _name = name;
    }
    return self;
}
@end
