//
//  YXShaderManager.m
//  YXRenderEngine
//
//  Created by enghou on 17/4/16.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//

#import "YXShaderManager.h"
@implementation YXShaderManager

-(instancetype)initWithDefault{
    self = [super init];
    if (self) {
        NSString *defaultVertexSh = [[NSBundle mainBundle]pathForResource:@"DefaultVertex" ofType:@"vsh"];
        NSString *defaultFragSh = [[NSBundle mainBundle]pathForResource:@"DefaultFrag" ofType:@"fsh"];
        _program = [self loadShaders:defaultVertexSh fragShader:defaultFragSh];
    }
    return self;
}//生成一个最基本的shader

-(instancetype)initWithVertexShader:(NSString *)vPath fragShader:(NSString *)fShader{
    if (nil!=(self = [super init])) {
        _program = [self loadShaders:vPath fragShader:fShader];
    }
    return self;
}


- (GLint)loadShaders:(NSString *)vPath fragShader:(NSString *)fPath
{
    GLuint vertShader, fragShader;
    GLint program;
    program = glCreateProgram();
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vPath]) {
        NSLog(@"Failed to compile vertex shader");
        return 0;
    }
    
    // Create and compile fragment shader.
    
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fPath]) {
        NSLog(@"Failed to compile fragment shader");
        return 0;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    _analyser = [[YXShaderAnalyser alloc]initWithVertexShader:vPath fragShader:fPath];
    if ([_analyser.attributes count]>0) {
        [_analyser.attributes enumerateObjectsUsingBlock:^(YXAttribute * obj, NSUInteger idx, BOOL * stop) {
            if (obj.position != YXOther) {
                glBindAttribLocation(program, obj.position, [obj.name UTF8String]);
            }
        }];
    }//常规属性的绑定
    
    if (![self linkProgram:program]) {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program) {
            glDeleteProgram(program);
            program = 0;
        }
        return 0;
    }
    
    if ([_analyser.uniforms count]>0) {
        [_analyser.uniforms enumerateObjectsUsingBlock:^(YXUniform *obj, NSUInteger idx, BOOL * stop) {
            GLint position = glGetUniformLocation(program, [obj.name UTF8String]);
            if (position !=-1) {
                obj.pos = position;
            }

        }];
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    
    if (fragShader) {
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return program;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}
@end
