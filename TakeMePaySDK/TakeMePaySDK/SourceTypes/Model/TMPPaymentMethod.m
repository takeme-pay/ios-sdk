//
//  TMPPaymentMethod.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/24.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPPaymentMethod.h"
#import "TMUtils.h"
#import "TMLocalizationUtils.h"
#import "TMPSDKConstants.h"
#import "TMPSourceTypeConstants.h"
#import "NSDictionary+TMPExtension.h"
#import "TMPPaymentMethodRegisterSupport.h"
#import "TMPPaymentMethod+TMPPrivate.h"
#import "NSMutableDictionary+TMFExtension.h"
#import "TMPSource+TMPPrivate.h"
#import "NSError+TMPErrorGenerator.h"
#import "TMLogService.h"

@interface TMPPaymentMethod ()

@property (nonatomic, strong, readwrite) NSString *paymentMethodId;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, nullable, strong, readwrite) NSArray<NSString *> *iconUris;

@end

@implementation TMPPaymentMethod

+ (instancetype)convertFromDictionary:(NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    NSString *uniqueType = dict[@"type"];
    if (![TMUtils stringIsEmpty:uniqueType]) {
        Class class = TMPPaymentMethodRegisterSupport.registeredPaymentMethods[uniqueType];
        if (!class) {
            [TMLogService.shared receivedInformation:({
                TMLogInformation *info = [[TMLogInformation alloc] init];
                info.logLevel = TMLogLevelWarn;
                info.message = [NSString stringWithFormat:@"you received source type: %@, but can't find the specific payment method handler, please check the doc if you have added the dependency of the speicific library", uniqueType];
                info;
            })];
            return nil;
        }
        
        TMPPaymentMethod *instance = [[class alloc] init];
        if (![instance isKindOfClass:TMPPaymentMethod.class]) {
            [TMLogService.shared receivedInformation:({
                TMLogInformation *info = [[TMLogInformation alloc] init];
                info.logLevel = TMLogLevelWarn;
                info.message = [NSString stringWithFormat:@"you received source type: %@, but can't find the specific payment method handler, please check the doc if you have added the dependency of the speicific library", uniqueType];
                info;
            })];
            return nil;
        }
        
        // if the payment method is unavailable, we still return the payment method to developer
        if (!instance.available) {
            [TMLogService.shared receivedInformation:({
                TMLogInformation *info = [[TMLogInformation alloc] init];
                info.logLevel = TMLogLevelError;    // should be error level because it might be a runtime bug
                info.message = [NSString stringWithFormat:@"the payment method: %@ is unavailable, the reason is: %@", instance.title, instance.unavailableReason];
                info;
            })];
        }
        
        return instance;
    }
    
    return nil;
}

+ (NSDictionary *)convertToDictionary:(TMPPaymentMethod *)obj {
    if (![obj isKindOfClass:TMPPaymentMethod.class]) {
        return nil;
    }
    
    // TODO: convertTo and convertFrom not matched...
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    [result tmf_safeSetObject:obj.paymentMethodId forKey:@"type"];
    [result tmf_safeSetObject:obj.title forKey:@"title"];
    [result tmf_safeSetObject:obj.iconUris forKey:@"iconUris"];
    
    return result.copy;
}

- (NSString *)paymentMethodId {
    NSAssert(NO, @"subclass override");
    return @"";
}

- (NSString *)title {
    NSAssert(![TMUtils stringIsEmpty:self.paymentMethodId], @"subclass should fill unique type");
    
    return TMLocalizedString(@"TMP_PaymentMethod:%@", self.paymentMethodId);
}

- (NSArray<NSString *> *)iconUris {
    NSAssert(![TMUtils stringIsEmpty:self.paymentMethodId], @"subclass should fill unique type");
    
    NSDictionary *paymentIcons = [NSDictionary tmp_dictionaryFromPlistWithFileName:@"PaymentIcons"];
    
    NSAssert([paymentIcons isKindOfClass:NSDictionary.class] && [paymentIcons[self.paymentMethodId] isKindOfClass:NSString.class], @"couldn't find payment icon");
        
    return @[paymentIcons[self.paymentMethodId]];
}

#pragma mark - TMPPaymentSourceParamsProcessable

- (void)payment:(TMPPayment *)payment processSourceParams:(TMPSourceParams *)params userInfo:(nullable NSDictionary *)userInfo completion:(void (^)(TMPSourceParams * _Nullable))completion {
    params.type = self.tmp_sourceType;
    params.flow = self.tmp_sourceFlow;
    
    if (completion) {
        completion(params);
    }
}

#pragma mark - TMPPaymentAuthorizable

- (void)requestPaymentAuthorization:(TMPPayment *)payment source:(TMPSource *)source userInfo:(NSDictionary *)userInfo completion:(void (^)(TMPPaymentAuthorizationState, NSError * _Nullable))completion {
    NSAssert(![TMUtils stringIsEmpty:source.tmp_subType], @"need subType");
    NSAssert([self.tmp_internalPaymentAuthorizableHandlers isKindOfClass:NSDictionary.class], @"internalPaymentAuthorizableHandlers should be dictionary");
    
    if (!self.available) {
        completion(TMPPaymentAuthorizationStateFailure, [NSError tmp_authorizationErrorFromDictionaryError:@{@"reason" : [NSString stringWithFormat:@"current payment method: %@ is unavailable, the reason is: %@", self.title, self.unavailableReason]}]);
        return;
    }
    
    if ([TMUtils stringIsEmpty:source.tmp_subType] && completion) {
        completion(TMPPaymentAuthorizationStateFailure, [NSError tmp_authorizationErrorFromDictionaryError:@{@"reason" : [NSString stringWithFormat:@"need subType for source: %@", source.sourceId]}]);
        return;
    }
    
    id<TMPPaymentAuthorizable> authorizableHandler = self.tmp_internalPaymentAuthorizableHandlers[source.tmp_subType];
    
    if (![authorizableHandler conformsToProtocol:@protocol(TMPPaymentAuthorizable)] && completion) {
        completion(TMPPaymentAuthorizationStateFailure, [NSError tmp_authorizationErrorFromDictionaryError:@{@"reason" : [NSString stringWithFormat:@"need handler for subType: %@", source.tmp_subType]}]);
        return;
    }
    
    NSAssert([authorizableHandler respondsToSelector:@selector(requestPaymentAuthorization:source:userInfo:completion:)], @"each internal handler must response the method");
    
    // ignore checking responseToSelector here, each internal handler must response it
    [authorizableHandler requestPaymentAuthorization:payment source:source userInfo:userInfo completion:completion];
}

@end

@implementation TMPPaymentMethod (TMPPaymentMethodAvailability)

- (BOOL)available {
    NSAssert(NO, @"subclass override");
    return NO;
}

- (NSString *)unavailableReason {
    // empty string as default
    return @"";
}

@end
