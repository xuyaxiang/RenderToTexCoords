//
//  YXUniform.h
//  YXRenderEngine
//
//  Created by enghou on 17/4/16.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXUniform : NSObject

-(instancetype)initWithKind:(NSString *)kind name:(NSString *)name;

@property(nonatomic,copy,readonly)NSString *kind;

@property(nonatomic,copy,readonly)NSString *name;

@property(nonatomic,assign)int pos;

@end
