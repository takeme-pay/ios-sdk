//
//  TMPPaymentMethod+TMPPrivate.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/21.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPPaymentMethod+TMPPrivate.h"
#import "TMPSourceParams+TMPPrivate.h"
#import "TMPSourceTypeConstants.h"

@implementation TMPPaymentMethod (TMPPrivate)

- (TMPSourceType)tmp_sourceType {
    NSAssert(NO, @"subclass override");
    return TMPSourceTypeUnknown;
}

- (TMPSourceFlow)tmp_sourceFlow {
    NSAssert(NO, @"subclass override");
    return TMPSourceFlowUnknown;
}

- (NSDictionary<NSString *, id<TMPPaymentAuthorizable>> *)tmp_internalPaymentAuthorizableHandlers {
    NSAssert(NO, @"subclass override");
    return @{};
}

@end
