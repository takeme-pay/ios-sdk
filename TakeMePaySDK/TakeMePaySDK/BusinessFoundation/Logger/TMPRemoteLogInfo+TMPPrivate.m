//
//  TMPRemoteLogInfo+TMPPrivate.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/3/3.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPRemoteLogInfo+TMPPrivate.h"
#import <objc/runtime.h>

@implementation TMPRemoteLogInfo (TMPPrivate)

- (void)setTmp_associatedFileName:(NSString *)tmp_associatedFileName {
    objc_setAssociatedObject(self, @selector(tmp_associatedFileName), tmp_associatedFileName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)tmp_associatedFileName {
    return objc_getAssociatedObject(self, _cmd);
}

@end
