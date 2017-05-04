//
//  YXShaderAnalyser.m
//  YXRenderEngine
//
//  Created by enghou on 17/4/16.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//

#import "YXShaderAnalyser.h"
@implementation YXShaderAnalyser
-(instancetype)initWithVertexShader:(NSString *)vPath fragShader:(NSString *)fShader{
    self=[super init];
    if (self) {
        _attributes = [NSMutableArray array];
        _uniforms = [NSMutableArray array];
        FILE *file = fopen([vPath UTF8String], "r");
        char *lineBuffer = NULL;
        size_t wordCount = 0;
        ssize_t read;
        while ((read = getline(&lineBuffer, &wordCount, file))>=0) {
            NSString *lineString = [[NSString stringWithUTF8String:lineBuffer]substringToIndex:read-2];
            NSArray *splitedElement = [lineString componentsSeparatedByString:@" "];
            if ([[splitedElement firstObject] isEqualToString:@"attribute"]) {
                NSString *kind = [splitedElement objectAtIndex:1];
                NSString *name = [splitedElement objectAtIndex:2];
                YXAttribute *attribute = [[YXAttribute alloc]initWithKind:kind name:name];
                [_attributes addObject:attribute];
            }else if ([[splitedElement firstObject] isEqualToString:@"uniform"]){
                NSString *kind  = [splitedElement objectAtIndex:1];
                NSString *name = [splitedElement objectAtIndex:2];
                YXUniform *uniform = [[YXUniform alloc]initWithKind:kind name:name];
                [_uniforms addObject:uniform];
            }else if ([[splitedElement firstObject] isEqualToString:@"void"]){
                fclose(file);
            }
        }
        
        FILE *fileFrag = fopen([fShader UTF8String], "r");
        while ((read = getline(&lineBuffer, &wordCount, fileFrag))>=0) {
            NSString *lineString = [[NSString stringWithUTF8String:lineBuffer]substringToIndex:read-2];
            NSArray *splitedElement = [lineString componentsSeparatedByString:@" "];
            if ([[splitedElement firstObject] isEqualToString:@"attribute"]) {
                NSString *kind = [splitedElement objectAtIndex:1];
                NSString *name = [splitedElement objectAtIndex:2];
                YXAttribute *attribute = [[YXAttribute alloc]initWithKind:kind name:name];
                [_attributes addObject:attribute];
            }else if ([[splitedElement firstObject] isEqualToString:@"uniform"]){
                NSString *kind  = [splitedElement objectAtIndex:1];
                NSString *name = [splitedElement objectAtIndex:2];
                YXUniform *uniform = [[YXUniform alloc]initWithKind:kind name:name];
                [_uniforms addObject:uniform];
            }else if ([[splitedElement firstObject] isEqualToString:@"void"]){
                fclose(fileFrag);
                return self;
            }
        }
    }
    return self;
}
@end
