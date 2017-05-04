//
//  YXAttribute.m
//  YXRenderEngine
//
//  Created by enghou on 17/4/16.
//  Copyright © 2017年 xyxorigation. All rights reserved.
//
//position YXPosition
//normal   YXNormal
//color    YXColor
//texcoords YXTexCoords
//other

#import "YXAttribute.h"
#import "DefaultVariableName.h"
@implementation YXAttribute
-(instancetype)initWithKind:(NSString *)kind name:(NSString *)name{
    if (self=[super init]) {
        _name = name;
        _kind = kind;
        if([name isEqualToString:XYXPosition]){
            _position = YXPosition;
        }else if ([name isEqualToString:XYXNormal]){
            _position = YXNormal;
        }else if ([name isEqualToString:XYXColor]){
            _position = YXColor;
        }else if ([name isEqualToString:XYXTexCoords]){
            _position = YXTexCoords;
        }else{
            _position = YXOther;
        }
    }
    return self;
}
@end
