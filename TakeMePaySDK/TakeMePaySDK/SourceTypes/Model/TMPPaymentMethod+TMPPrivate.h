//
//  TMPPaymentMethod+TMPPrivate.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/21.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <TakeMePaySDK/TakeMePaySDK.h>
#import "TMPSourceEnums.h"

@protocol TMPPaymentAuthorizable;

NS_ASSUME_NONNULL_BEGIN

@interface TMPPaymentMethod (TMPPrivate)

- (TMPSourceType)tmp_sourceType; // subclass override it
- (TMPSourceFlow)tmp_sourceFlow; // subclass override it

- (NSDictionary<NSString *, id<TMPPaymentAuthorizable>> *)tmp_internalPaymentAuthorizableHandlers; // subclass override it

@end

NS_ASSUME_NONNULL_END
