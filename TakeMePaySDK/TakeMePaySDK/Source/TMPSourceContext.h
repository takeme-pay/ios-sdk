//
//  TMPSourceContext.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/20.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMPPaymentServiceClient, TMPSourceParams, TMPSource, TMPSourceTypeListParams, TMPPaymentMethod;

NS_ASSUME_NONNULL_BEGIN

/**
 This is a helper class for handling TMPSource retrieving, init it with client then use the instant methods of context to manipulate TMPSource instance.
 
 Only if you want to use those underlying features, or otherwise you should always use TMPPayment class to handle with a payment, TMPPayment class will manage all details of payment. Features of TMPSourceContext supports TMPPayment beneath.
 */
@interface TMPSourceContext : NSObject

/**
 The payment service client be used to connect with TakeMe Pay backend.
 */
@property (nonatomic, strong, readonly) TMPPaymentServiceClient *client;

/**
 Designated initializer of TMPSourceContext, client is required.

 @param client Handles network connection with TakeMe SDK backend, you could use TMPPaymentServiceClient with default TMPConfiguration.
 @return Source context instance, if client is nil, the return result would be nil.
 */
- (instancetype)initWithClient:(TMPPaymentServiceClient *)client;

/**
 Retrieve source with params, `sourceId` and `clientSecret` is required for this method, clientSecret is getting from TakeMe Pay backend, all you need to do is assigning it from TMPSource instance.

 @param params TMPSourceParams instance, for this method, all arguments could be nil, besides `sourceId` and `clientSecret`.
 @param completion Can't be nil, invoked when retrieve source process completed, successfully with a TMPSource instance, nor an error.
 */
- (void)retrieveSourceWithParams:(TMPSourceParams *)params completion:(void(^)(TMPSource * __nullable source, NSError * __nullable error))completion;

#pragma mark - unavailable

- (instancetype)init __attribute__((unavailable("You can't instantiate TMPSourceContext directly, use the designated initializer instead.")));

@end

NS_ASSUME_NONNULL_END
