//
//  TakeMePay+TMPPrivate.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/9.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TakeMePay+TMPPrivate.h"
#import "TMPConfiguration.h"

@implementation TakeMePay (TMPPrivate)

+ (void)unregisterListener:(id<TMPURLListener>)listener {
    dispatch_async(self.workQueue, ^{
        if (listener) {
            [self.callbacks removeObject:listener];
        }
    });
}

+ (dispatch_queue_t)workQueue {
    static dispatch_queue_t workQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        workQueue = dispatch_queue_create("com.takemepay.url_handle", DISPATCH_QUEUE_SERIAL);
    });
    return workQueue;
}

+ (NSMutableSet<id<TMPURLListener>> *)callbacks {
    static NSMutableSet *callbacks;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        callbacks = [[NSMutableSet alloc] init];
    });
    return callbacks;
}

@end
