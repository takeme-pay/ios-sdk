//
//  TMPPaymentAuthViaWebRedirect.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPPaymentAuthorizable.h"
#import "TMPPaymentSourceParamsProcessable.h"
#import "TMPURLListener.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMPPaymentAuthViaWebRedirect : NSObject <TMPPaymentAuthorizable, TMPPaymentSourceParamsProcessable, TMPURLListener>

@end

NS_ASSUME_NONNULL_END
