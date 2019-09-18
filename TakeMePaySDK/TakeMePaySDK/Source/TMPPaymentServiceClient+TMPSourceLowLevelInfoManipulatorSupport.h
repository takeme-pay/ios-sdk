//
//  TMPPaymentServiceClient+TMPSourceLowLevelInfoManipulatorSupport.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/20.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPPaymentServiceClient.h"
#import "TMPSourceParams.h"

@class TMPSource;

typedef void(^TMPSourceCompletionBlock)(TMPSource * __nullable source, NSURLResponse * __nullable urlResponse, NSError * __nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface TMPPaymentServiceClient (TMPSourceLowLevelInfoManipulatorSupport)

- (void)createSource:(TMPSourceParams *)params completion:(TMPSourceCompletionBlock)completion;
- (void)retrieveSource:(TMPSourceParams *)params completion:(TMPSourceCompletionBlock)completion;
- (void)updateSource:(TMPSourceParams *)params completion:(TMPSourceCompletionBlock)completion; // unused

@end

NS_ASSUME_NONNULL_END
