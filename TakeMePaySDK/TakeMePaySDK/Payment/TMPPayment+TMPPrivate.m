//
//  TMPPayment+TMPPrivate.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/22.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPPayment+TMPPrivate.h"
#import <objc/runtime.h>

@implementation TMPPayment (TMPPrivate)

- (void)setClient:(TMPPaymentServiceClient *)client {
    if ([client isKindOfClass:TMPPaymentServiceClient.class]) {
        objc_setAssociatedObject(self, @selector(client), client, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (TMPPaymentServiceClient *)client {
    return objc_getAssociatedObject(self, _cmd);
}

@end
