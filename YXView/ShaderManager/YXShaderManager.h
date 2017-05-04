//
//  YXShaderManager.h
//  YXRenderEngine
//
//  Created by enghou on 17/4/16.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "YXShaderAnalyser.h"
@interface YXShaderManager : NSObject

@property(nonatomic,assign,readonly)GLuint program;

@property(nonatomic,strong,readonly)YXShaderAnalyser *analyser;

-(instancetype)initWithDefault;

-(instancetype)initWithVertexShader:(NSString *)vPath fragShader:(NSString *)fShader;

@end
