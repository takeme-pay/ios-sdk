//
//  TMPSource.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPSource.h"
#import <objc/runtime.h>
#import "TMPSourceTypeConstants.h"
#import "NSMutableDictionary+TMFExtension.h"
#import "TMPSource+TMPPrivate.h"
#import "TMUtils.h"

@interface TMPSource ()

@property (nonatomic, strong, readwrite) NSString *sourceId;
@property (nonatomic, strong, readwrite) NSNumber *amount;
@property (nonatomic, strong, readwrite) NSString *clientSecret;
@property (nonatomic, strong, readwrite) NSDate *created;
@property (nonatomic, strong, readwrite) NSDate *updated;
@property (nonatomic, strong, readwrite) NSString *currency;
@property (nonatomic, strong, readwrite) NSDictionary<NSString *, NSString *> *metadata;
@property (nonatomic, strong, readwrite) NSString *sourceDescription;

@property (nonatomic, assign, readwrite) BOOL sandboxEnv;

@property (nonatomic, assign, readwrite) TMPSourceType type;
@property (nonatomic, assign, readwrite) TMPSourceFlow flow;
@property (nonatomic, assign, readwrite) TMPSourceStatus status;

@end

@implementation TMPSource

#pragma mark - TMDictionaryConvertible

+ (instancetype)convertFromDictionary:(NSDictionary *)dict {
    if (![dict[@"object"] isEqualToString:@"source"]) {
        return nil;
    }
    
    TMPSource *result = [TMPSource new];
    
    result.sourceId = dict[@"id"];
    result.amount = dict[@"amount"];
    result.clientSecret = dict[@"clientSecret"];
    result.currency = dict[@"currency"];
    result.metadata = dict[@"metadata"];
    result.sourceDescription = dict[@"description"];
    
    if ([dict[@"created"] isKindOfClass:NSNumber.class]) {
        result.created = [NSDate dateWithTimeIntervalSince1970:[dict[@"created"] integerValue] / 1000];
    }
    
    if ([dict[@"updated"] isKindOfClass:NSNumber.class]) {
        result.updated = [NSDate dateWithTimeIntervalSince1970:[dict[@"updated"] integerValue] / 1000];
    }
    
    if ([dict[@"redirect"] isKindOfClass:NSDictionary.class]) {
        NSDictionary *redirectDict = dict[@"redirect"];
        
        TMPSourceRedirectInfo *redirect = [[TMPSourceRedirectInfo alloc] init];
        
        if (![TMUtils isNilOrNull:redirectDict[@"url"]]) {
            redirect.redirectUrl = [NSURL URLWithString:redirectDict[@"url"]] ;
        }
        
        if (![TMUtils isNilOrNull:redirectDict[@"returnUrl"]]) {
            redirect.returnUrl = [NSURL URLWithString:redirectDict[@"returnUrl"]];
        }
        
        if (![TMUtils isNilOrNull:redirectDict[@"status"]]) {
            redirect.redirectStatus = redirectStatusConvert(redirectDict[@"status"]);
        }
                
        result.redirect = redirect;
    }
        
    result.status = sourceStatusConvert(dict[@"status"]);
    result.type = sourceTypeConvert(dict[@"type"]);
    result.flow = sourceFlowConvert(dict[@"flow"]);
    
    result.sandboxEnv = [dict[@"liveMode"] boolValue];
    
    // related to payment payload and handler
    result.tmp_subType = dict[@"subType"];
    
    if ([dict[@"payload"] isKindOfClass:NSDictionary.class]) {
        result.payload = dict[@"payload"];
    }
    
    return result;
}

+ (NSDictionary *)convertToDictionary:(id)obj {
    if (![obj isKindOfClass:self]) {
        return nil;
    }
    
    TMPSource *source = (TMPSource *)obj;
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result tmf_safeSetObject:@"source" forKey:@"object"];
    [result tmf_safeSetObject:source.sourceId forKey:@"id"];
    [result tmf_safeSetObject:source.amount forKey:@"amount"];
    [result tmf_safeSetObject:source.clientSecret forKey:@"clientSecret"];
    [result tmf_safeSetObject:source.currency forKey:@"currency"];
    [result tmf_safeSetObject:source.metadata forKey:@"metadata"];
    [result tmf_safeSetObject:source.sourceDescription forKey:@"description"];
    [result tmf_safeSetObject:source.created forKey:@"created"];
    [result tmf_safeSetObject:source.updated forKey:@"updated"];
    
    NSMutableDictionary *redirectInfo = [[NSMutableDictionary alloc] init];
    [redirectInfo tmf_safeSetObject:source.redirect.redirectUrl forKey:@"url"];
    [redirectInfo tmf_safeSetObject:source.redirect.returnUrl forKey:@"returnUrl"];
    [redirectInfo tmf_safeSetObject:@(source.redirect.redirectStatus) forKey:@"status"];
    [redirectInfo tmf_safeSetObject:source.redirect.userInfo forKey:@"userInfo"];
    
    [result tmf_safeSetObject:redirectInfo forKey:@"redirect"];
    
    [result tmf_safeSetObject:@(source.sandboxEnv) forKey:@"liveMode"];
    
    [result tmf_safeSetObject:source.tmp_subType forKey:@"subType"];
    [result tmf_safeSetObject:source.payload forKey:@"payload"];
    
    // todo: enum values
    
    return result.copy;
}

#define SOURCE_XXX_CONVERT(_xxx, _functionName, _mapper) \
static inline _xxx _functionName(NSString *_value) { \
if (!_value) { \
return 0; \
} \
\
NSNumber *result = _mapper[_value];\
\
if (result) {\
return result.integerValue;\
}\
return 0; \
}

SOURCE_XXX_CONVERT(TMPSourceFlow, sourceFlowConvert, (@{@"redirect" : @(TMPSourceFlowRedirect)}));

SOURCE_XXX_CONVERT(TMPSourceStatus, sourceStatusConvert, (@{@"pending" : @(TMPSourceStatusPending),
                                                            @"chargeable" : @(TMPSourceStatusChargeable),
                                                            @"consumed" : @(TMPSourceStatusConsumed),
                                                            @"failed" : @(TMPSourceStatusFailed)}));

SOURCE_XXX_CONVERT(TMPSourceType, sourceTypeConvert, (@{TMPSourceTypeWeChatPayString : @(TMPSourceTypeWeChatPay)}));

SOURCE_XXX_CONVERT(TMPSourceRedirectStatus, redirectStatusConvert, (@{@"pending" : @(TMPSourceRedirectStatusPending),
                                                                      @"succeeded" : @(TMPSourceRedirectStatusSucceeded),
                                                                      @"failed" : @(TMPSourceRedirectStatusFailed)}));

@end

@implementation TMPSource (TMPPayment)

- (void)setPayload:(NSDictionary *)payload {
    objc_setAssociatedObject(self, @selector(payload), payload, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)payload {
    return objc_getAssociatedObject(self, _cmd);
}

@end

@implementation TMPSource (TMPRedirect)

- (void)setRedirect:(TMPSourceRedirectInfo *)redirect {
    if (!redirect) {
        return;
    }
    
    objc_setAssociatedObject(self, @selector(redirect), redirect, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TMPSourceRedirectInfo *)redirect {
    return objc_getAssociatedObject(self, _cmd);
}

@end

@implementation TMPSourceRedirectInfo

@end
