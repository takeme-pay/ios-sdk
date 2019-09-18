//
//  TMPPayment+TMPClosureSupport.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/5/14.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <TakeMePaySDK/TakeMePaySDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMPPayment (TMPClosureSupport)

- (instancetype)setWillCreateSourceByUsingBlock:(void(^)(TMPPayment *payment, TMPSourceParams *params))willCreateSourceByUsing;
- (instancetype)setDidCreateSourceBlock:(void(^)(TMPPayment *payment, TMPSource * __nullable source, NSError * __nullable error, NSDictionary * __nullable userInfo))didCreateSource;
- (instancetype)setDidReceivedSourceTypesBlock:(void(^)(TMPPayment *payment, NSArray<NSString *> * __nullable sourceTypes, NSString * __nullable selectedSourceType, NSError * __nullable error, NSDictionary * __nullable userInfo))didReceivedSourceTypes;
- (instancetype)setDidFinishAuthorizationBlock:(void(^)(TMPPayment *payment, TMPPaymentAuthorizationState state, NSError * __nullable error, NSDictionary * __nullable userInfo))didFinishAuthorization;
- (instancetype)setDidPolledSourceBlock:(void(^)(TMPPayment *payment, TMPSource * __nullable source, TMPPaymentPollingResultState state, NSError * __nullable error, NSDictionary * __nullable userInfo))didPolledSource;
- (instancetype)setWillFinishWithStateBlock:(void(^)(TMPPayment *payment, TMPPaymentResultState state, NSError * __nullable error, NSDictionary * __nullable userInfo))willFinishWithState;
- (instancetype)setDidFinishWithStateBlock:(void(^)(TMPPayment *payment, TMPPaymentResultState state, NSError * __nullable error, NSDictionary * __nullable userInfo))didFinishWithState;

@end

NS_ASSUME_NONNULL_END
