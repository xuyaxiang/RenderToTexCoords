//
//  YXShaderAnalyser.h
//  YXRenderEngine
//
//  Created by enghou on 17/4/16.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXUniform.h"
#import "YXAttribute.h"
@interface YXShaderAnalyser : NSObject

-(instancetype)initWithVertexShader:(NSString *)vPath fragShader:(NSString *)fShader;

@property(nonatomic,strong,readonly)NSMutableArray<YXAttribute *> *attributes;

@property(nonatomic,strong,readonly)NSMutableArray<YXUniform *> *uniforms;

@end
