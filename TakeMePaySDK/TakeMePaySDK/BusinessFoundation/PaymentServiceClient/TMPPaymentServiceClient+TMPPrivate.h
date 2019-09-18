//
//  TMPPaymentServiceClient+TMPPrivate.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/27.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPPaymentServiceClient.h"

@class TMEndpointAPIManager;

NS_ASSUME_NONNULL_BEGIN

@interface TMPPaymentServiceClient (TMPPrivate)

- (TMEndpointAPIManager *)tmp_endpointApiManager;

@end

NS_ASSUME_NONNULL_END
