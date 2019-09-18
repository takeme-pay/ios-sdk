//
//  TMPPaymentServiceClient+TMPSourceTypeListLowLevelInfoManipulatorSupport.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/3.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPPaymentServiceClient+TMPSourceTypeListLowLevelInfoManipulatorSupport.h"
#import "TMEndpointAPIRequest.h"
#import "TMEndpointAPIManager.h"
#import "TMDictionaryConvertible.h"
#import "NSMutableDictionary+TMFExtension.h"
#import "TMPPaymentServiceClient+TMPPrivate.h"
#import "TMUtils.h"
#import "NSError+TMPErrorGenerator.h"
#import <objc/runtime.h>
#import "TMLocalizationUtils.h"
#import "TMPSDKConstants.h"

typedef NS_ENUM(NSInteger, TMPSourceTypeListRequestType) {
    TMPSourceTypeListRequestTypeRetrieve
};

@interface TMPSourceTypeListParams (TMPEndpointAPIRequest) <TMEndpointAPIRequest>

@property (nonatomic, assign) TMPSourceTypeListRequestType requestType;

@end

@implementation TMPSourceTypeListParams (TMPEndpointAPIRequest)

- (void)setRequestType:(TMPSourceTypeListRequestType)requestType {
    objc_setAssociatedObject(self, @selector(requestType), @(requestType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TMPSourceTypeListRequestType)requestType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

#pragma mark - TMPEndpointAPIRequest

- (NSString *)endpoint {
    switch (self.requestType) {
        case TMPSourceTypeListRequestTypeRetrieve:
            return @"";
    }
}

- (NSString *)httpMethod {
    switch (self.requestType) {
        case TMPSourceTypeListRequestTypeRetrieve:
            return @"";
    }
}

- (NSDictionary *)params {
    return @{};
}

- (NSDictionary *)additionalHeaders {
    return @{};
}

- (TMNetworkDataSerializerType)serializerType {
    return TMNetworkDataSerializerJSONType;
}

- (TMNetworkDataSerializerType)deserializerType {
    return TMNetworkDataSerializerJSONType;
}

@end

@implementation TMPPaymentServiceClient (TMPSourceTypeListLowLevelInfoManipulatorSupport)

- (void)retrieveSourceTypeList:(TMPSourceTypeListParams *)params completion:(TMPSourceTypeListCompletionBlock)completion {
    NSAssert([params isKindOfClass:TMPSourceTypeListParams.class], @"params can't be nil");
    NSAssert(completion, @"completion can't be nil");
    
    if (!params && completion) {
        completion(nil, nil, [NSError tmp_requestSourceTypesFromRemoteErrorBecauseOfParams]);
        return;
    }
    
    params.requestType = TMPSourceTypeListRequestTypeRetrieve;
    
    [self.tmp_endpointApiManager startEndpointRequest:params completion:^(NSURLResponse *urlResponse, id data, NSError *error) {
        if (error || ![data isKindOfClass:NSArray.class] || ((NSArray *)data).count == 0) {
            completion(nil, urlResponse, [NSError tmp_requestSourceTypesFromRemoteError:error]);
            return;
        }
        
        NSMutableArray<TMPPaymentMethod *> *result = [[NSMutableArray alloc] init];
        
        for (NSDictionary *paymentMethodDict in data) {
            TMPPaymentMethod *item = [TMPPaymentMethod convertFromDictionary:paymentMethodDict];
            if ([item isKindOfClass:TMPPaymentMethod.class]) {
                [result addObject:item];
            }
        }
        
        if (result.count == 0) {
            completion(nil, urlResponse, [NSError tmp_requestSourceTypesFromRemoteParsedError]);
            return;
        }
        
        completion(result.copy, urlResponse, nil);
        return;
    }];
}

@end
