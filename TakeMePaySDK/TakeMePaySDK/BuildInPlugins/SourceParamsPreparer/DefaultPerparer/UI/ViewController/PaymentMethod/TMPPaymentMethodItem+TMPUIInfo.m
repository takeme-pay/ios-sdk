//
//  TMPPaymentMethod+TMPUIInfo.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/21.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPPaymentMethodItem+TMPUIInfo.h"
#import <objc/runtime.h>

@implementation TMPPaymentMethod (TMPUIInfo)

- (void)setTmp_selected:(BOOL)tmp_selected {
    objc_setAssociatedObject(self, @selector(tmp_selected), @(tmp_selected), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tmp_selected {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTmp_subtitle:(NSString *)tmp_subtitle {
    if (tmp_subtitle) {
        objc_setAssociatedObject(self, @selector(tmp_subtitle), tmp_subtitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSString *)tmp_subtitle {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTmp_itemDescription:(NSString *)tmp_itemDescription {
    if (tmp_itemDescription) {
        objc_setAssociatedObject(self, @selector(tmp_itemDescription), tmp_itemDescription, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSString *)tmp_itemDescription {
    return objc_getAssociatedObject(self, _cmd);
}

@end
