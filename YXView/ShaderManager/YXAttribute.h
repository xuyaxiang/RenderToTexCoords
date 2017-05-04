//
//  YXAttribute.h
//  YXRenderEngine
//
//  Created by enghou on 17/4/16.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
typedef NS_ENUM(NSInteger,YXAttributeName){
    YXPosition = GLKVertexAttribPosition,
    YXNormal = GLKVertexAttribNormal,
    YXColor = GLKVertexAttribColor,
    YXTexCoords = GLKVertexAttribTexCoord0,
    YXOther = 5
};
@interface YXAttribute : NSObject
@property(nonatomic,assign,readonly)YXAttributeName position;

@property(nonatomic,copy,readonly)NSString *kind;

@property(nonatomic,copy,readonly)NSString *name;

-(instancetype)initWithKind:(NSString *)kind name:(NSString *)name;
@end
