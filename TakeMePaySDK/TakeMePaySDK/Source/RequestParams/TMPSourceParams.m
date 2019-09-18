//
//  TMPSourceParam.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/18.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPSourceParams.h"
#import <objc/runtime.h>
#import "TMPSourceTypeConstants.h"
#import "TMPSourceParams+TMPPrivate.h"

@implementation TMPSourceParams

- (instancetype)init {
    return [self initWithDescription:nil amount:0 currency:nil];
}

- (instancetype)initWithDescription:(NSString *)description amount:(NSUInteger)amount currency:(NSString *)currency {
    if (self = [super init]) {
        _sourceDescription = description;
        _amount = @(amount);
        _currency = currency;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"sourceId: %@, amount: %@, currency: %@, sourceDescription: %@, type: %@, flow: %@, metadata: %@", self.sourceId, self.amount.stringValue, self.currency, self.sourceDescription, self._rawType, self._rawFlow, self.metadata];
}

@end

@implementation TMPSourceParams (TMPSourceAuthorization)

- (void)setClientSecret:(NSString *)clientSecret {
    objc_setAssociatedObject(self, @selector(clientSecret), clientSecret ?: @"", OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)clientSecret {
    return objc_getAssociatedObject(self, _cmd);
}

@end
