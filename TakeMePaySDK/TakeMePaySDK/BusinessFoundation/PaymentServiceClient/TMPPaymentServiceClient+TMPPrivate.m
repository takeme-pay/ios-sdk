//
//  TMPPaymentServiceClient+TMPPrivate.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/27.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPPaymentServiceClient+TMPPrivate.h"

@interface TMPPaymentServiceClient (__Private)

- (TMEndpointAPIManager *)endpointAPIManager;

@end

@implementation TMPPaymentServiceClient (TMPPrivate)

- (TMEndpointAPIManager *)tmp_endpointApiManager {
    return [self endpointAPIManager];
}

@end
