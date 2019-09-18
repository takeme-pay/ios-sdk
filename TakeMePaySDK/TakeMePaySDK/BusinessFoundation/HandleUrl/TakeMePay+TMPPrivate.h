//
//  TakeMePay+TMPPrivate.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/9.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TakeMePay.h"
#import "TMPURLListener.h"

NS_ASSUME_NONNULL_BEGIN

@interface TakeMePay (TMPPrivate)

+ (dispatch_queue_t)workQueue;
+ (NSMutableSet<id<TMPURLListener>> *)callbacks;

+ (void)unregisterListener:(id<TMPURLListener>)listener;

@end

NS_ASSUME_NONNULL_END
