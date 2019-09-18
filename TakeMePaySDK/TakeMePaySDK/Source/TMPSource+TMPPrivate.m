//
//  TMPSource+TMPPrivate.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/4/9.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPSource+TMPPrivate.h"
#import <objc/runtime.h>

@implementation TMPSource (TMPPrivate)

- (void)setTmp_subType:(NSString *)tmp_subType {
    objc_setAssociatedObject(self, @selector(tmp_subType), tmp_subType, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)tmp_subType {
    return objc_getAssociatedObject(self, _cmd);
}

@end
