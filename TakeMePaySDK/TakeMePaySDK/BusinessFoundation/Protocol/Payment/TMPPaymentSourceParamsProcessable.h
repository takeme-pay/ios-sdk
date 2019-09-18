//
//  TMPPaymentSourceParamsProcessable.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/9.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMPSourceParams, TMPPayment;

NS_ASSUME_NONNULL_BEGIN

@protocol TMPPaymentSourceParamsProcessable <NSObject>

@required

/**
 Process the source params, it should pass the final source params ( means it could be used to create source ) to the completion in any cases.
 IMPORTANT: Whether in the case of success or failure, you should and must always call completion, otherwise, the TMPPayment might be in memory leaked status.

 @param payment The parent payment instance.
 @param params Raw source params, may only contains very limit information provided by you in the init method of TMPPayment, you might need to process it and fill every required property in the decorator.
 @param userInfo Extra information, for extensible abilities in the future.
 @param completion You must call this completion callback in success or failure case, if it is failed case, just pass nil simply, the completion MAY be retained by the decorator, you should always assume it would be retained.
 */
- (void)payment:(TMPPayment *)payment processSourceParams:(TMPSourceParams *)params userInfo:(nullable NSDictionary *)userInfo completion:(void(^)(TMPSourceParams * __nullable processedSourceParams))completion;

@end

NS_ASSUME_NONNULL_END
