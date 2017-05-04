//
//  YXView.m
//  YXView
//
//  Created by enghou on 17/5/3.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//

#import "YXView.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "YXShaderManager.h"
typedef struct {
    GLKVector3 position;
    GLKVector2 texCoords;
}SceneVertex;

SceneVertex a[4] = {
    {{-0.5,-0.5,0},{0,0}},
    {{0.5,-0.5,0},{1,0}},
    {{0.5,0.5,0},{1,1}},
    {{-0.5,0.5,0},{0,1}}
};

unsigned short b[6] = {
    0,1,3,2,3,1
};

@implementation YXView
{
    GLuint quad[2];
    
    GLuint framebuffer;
    GLuint renderbuffer;
    EAGLContext *context;
    GLuint texture;
    GLuint fbotex;
    
    GLKBaseEffect *effect;
    
    GLint viewWidth;
    GLint viewHeight;
    
    GLuint tmpQuad[2];
    GLuint fbo;
    
    GLuint pos;
    GLuint texCoords;
    GLuint tx;
    GLuint program;
}
+(Class)layerClass{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CAEAGLLayer *layer = (CAEAGLLayer*)self.layer;
        layer.opaque = NO;
        layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
                                    kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8,
                                    kEAGLDrawablePropertyColorFormat,
                                    nil];
      context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
      [EAGLContext setCurrentContext:context];
        glGenRenderbuffers(1, &renderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &viewWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &viewHeight);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glGenFramebuffers(1, &framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
      
      //shader
        NSString *vShader  = [[NSBundle mainBundle]pathForResource:@"TexCoords" ofType:@"vsh"];
        NSString *fShader  = [[NSBundle mainBundle]pathForResource:@"TexCoords" ofType:@"fsh"];
        YXShaderManager *manager  = [[YXShaderManager alloc]initWithVertexShader:vShader fragShader:fShader];
        program = manager.program;
        [manager.analyser.attributes enumerateObjectsUsingBlock:^(YXAttribute * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name isEqualToString:@"position"]) {
                pos = obj.position;
            }
            if ([obj.name isEqualToString:@"texcoords"]) {
                texCoords = obj.position;
            }
        }];
        [manager.analyser.uniforms enumerateObjectsUsingBlock:^(YXUniform * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name isEqualToString:@"tex"]) {
                tx = obj.pos;
            }
        }];
        //shader
        
        //接下来开始准备数据
        glGenBuffers(2, quad);
        glBindBuffer(GL_ARRAY_BUFFER, quad[0]);
        glBufferData(GL_ARRAY_BUFFER, sizeof(a), a, GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, quad[1]);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(b), b, GL_STATIC_DRAW);
        
       glGenTextures(1, &fbotex);
       glBindTexture(GL_TEXTURE_2D, fbotex);
       glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, viewWidth, viewHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
       glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
       glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
       glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
       glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
       glBindTexture(GL_TEXTURE_2D, 0);
       glGenFramebuffers(1, &fbo);
       glBindFramebuffer(GL_FRAMEBUFFER, fbo);
       glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fbotex, 0);
       glBindFramebuffer(GL_FRAMEBUFFER, 0);
        
        
        UIImage *img = [UIImage imageNamed:@"1.png"];
        
        CFDataRef rawdata = CGDataProviderCopyData(CGImageGetDataProvider(img.CGImage));
        GLuint *pixels = (GLuint *)CFDataGetBytePtr(rawdata);
        
        int width = img.size.width;
        int height = img.size.height;
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glBindTexture(GL_TEXTURE_2D, 0);
        CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(Render)];
        [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
    }
    return self;
}

-(void)Render{
    //先将图形绘制到fbo中,缺少了useprogram
    glClearColor(0, 0, 0, 1);
    glUseProgram(program);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindBuffer(GL_ARRAY_BUFFER, quad[0]);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, quad[1]);
    glEnableVertexAttribArray(pos);
    glVertexAttribPointer(pos, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    glEnableVertexAttribArray(texCoords);
    glVertexAttribPointer(texCoords, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL+offsetof(SceneVertex, texCoords));
    glUniform1i(tx, 0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, NULL);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    
    
    glClearColor(1, 0, 0, 1);
    glUseProgram(program);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindBuffer(GL_ARRAY_BUFFER, quad[0]);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, quad[1]);
    glEnableVertexAttribArray(pos);
    glVertexAttribPointer(pos, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    glEnableVertexAttribArray(texCoords);
    glVertexAttribPointer(texCoords, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL+offsetof(SceneVertex, texCoords));
    glUniform1i(tx, 0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, NULL);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
