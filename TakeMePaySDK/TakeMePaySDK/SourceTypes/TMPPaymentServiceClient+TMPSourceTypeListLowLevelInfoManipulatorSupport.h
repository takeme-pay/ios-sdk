//
//  TMPPaymentServiceClient+TMPSourceTypeListLowLevelInfoManipulatorSupport.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/3.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPPaymentServiceClient.h"
#import "TMPPaymentMethod.h"
#import "TMPSourceTypeListParams.h"

typedef void(^TMPSourceTypeListCompletionBlock)(NSArray<TMPPaymentMethod *> * _Nullable sourceList, NSURLResponse * _Nullable response, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface TMPPaymentServiceClient (TMPSourceTypeListLowLevelInfoManipulatorSupport)

- (void)retrieveSourceTypeList:(TMPSourceTypeListParams *)params completion:(TMPSourceTypeListCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
