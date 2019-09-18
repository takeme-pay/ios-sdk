//
//  TMPPaymentServiceClient+TMPSourceLowLevelInfoManipulatorSupport.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/20.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPPaymentServiceClient+TMPSourceLowLevelInfoManipulatorSupport.h"
#import "TMPSource.h"
#import "TMPSourceParams.h"
#import "TMEndpointAPIRequest.h"
#import "TMEndpointAPIManager.h"
#import "NSMutableDictionary+TMFExtension.h"
#import "TMPPaymentServiceClient+TMPPrivate.h"
#import "TMDictionaryConvertible.h"
#import "NSError+TMPErrorGenerator.h"
#import "TMUtils.h"
#import "TMPSourceParams+TMPPrivate.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, TMPSourceRequestType) {
    TMPSourceRequestTypeCreate,
    TMPSourceRequestTypeRetrieve,
    TMPSourceRequestTypeUpdate
};

@interface TMPSourceParams (TMPEndpointAPIRequest) <TMEndpointAPIRequest>

@property (nonatomic, assign) TMPSourceRequestType requestType;

@end

@implementation TMPSourceParams (TMPEndpointAPIRequest)

- (void)setRequestType:(TMPSourceRequestType)requestType {
    objc_setAssociatedObject(self, @selector(requestType), @(requestType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TMPSourceRequestType)requestType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

#pragma mark - TMPEndpointAPIRequest

- (NSString *)endpoint {
    switch (self.requestType) {
        case TMPSourceRequestTypeCreate:
            return @"";
        case TMPSourceRequestTypeRetrieve:
        case TMPSourceRequestTypeUpdate:
            return @"";
    }
}

- (NSString *)httpMethod {
    switch (self.requestType) {
        case TMPSourceRequestTypeCreate:
        case TMPSourceRequestTypeUpdate:
            return @"";
        case TMPSourceRequestTypeRetrieve:
            return @"";
    }
}

- (NSDictionary *)params {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params tmf_safeSetObject:self.amount forKey:@"amount"];
    [params tmf_safeSetObject:self.currency forKey:@"currency"];
    
    [params tmf_safeSetObject:self.metadata forKey:@"metadata"];
    [params tmf_safeSetObject:self.redirectReturnUrl forKey:@"redirectReturnUrl"];
    [params tmf_safeSetObject:self.clientSecret forKey:@"clientSecret"];
    [params tmf_safeSetObject:self.sourceDescription forKey:@"description"];
     
    {
        if (self.type != TMPSourceTypeUnknown) {
            [params tmf_safeSetObject:self._rawType forKey:@"type"];
        }
        if (self.flow != TMPSourceFlowUnknown) {
            [params tmf_safeSetObject:self._rawFlow forKey:@"flow"];
        }
    }    
    
    return params.copy;
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

@implementation TMPPaymentServiceClient (TMPSourceLowLevelInfoManipulatorSupport)

- (void)createSource:(nonnull TMPSourceParams *)params completion:(nonnull TMPSourceCompletionBlock)completion {
    [self requestSourceParams:params type:TMPSourceRequestTypeCreate completion:completion];
}

- (void)retrieveSource:(nonnull TMPSourceParams *)params completion:(nonnull TMPSourceCompletionBlock)completion {
    NSAssert([params.clientSecret isKindOfClass:NSString.class], @"clientSecret can't be nil if a public key is used to retreive the source");
    
    if (![params.clientSecret isKindOfClass:NSString.class] && completion) {
        completion(nil, nil, [NSError tmp_requestSourceFromRemoteErrorBecauseOfParams]);
        return;
    }
    
    [self requestSourceParams:params type:TMPSourceRequestTypeRetrieve completion:completion];
}

- (void)updateSource:(nonnull TMPSourceParams *)params completion:(nonnull TMPSourceCompletionBlock)completion {
    [self requestSourceParams:params type:TMPSourceRequestTypeUpdate completion:completion];
}

#pragma mark - private

- (void)requestSourceParams:(TMPSourceParams *)params type:(TMPSourceRequestType)type completion:(TMPSourceCompletionBlock)completion {
    NSAssert([params isKindOfClass:TMPSourceParams.class], @"sourceId can't be nil");
    NSAssert(completion, @"completion can't be nil");
    
    if (!params && completion) {
        completion(nil, nil, [NSError tmp_requestSourceFromRemoteErrorBecauseOfParams]);
        return;
    }
    
    // attach request type
    params.requestType = type;
    
    [self.tmp_endpointApiManager startEndpointRequest:params completion:[self sourceConverterThenInvoke:completion]];
}

- (void(^)(NSURLResponse *, NSDictionary *, NSError *))sourceConverterThenInvoke:(TMPSourceCompletionBlock)completion {
    if (!completion) {
        return nil;
    }
    
    return ^(NSURLResponse *urlResponse, id data, NSError *error) {
        if (error || ![data isKindOfClass:NSDictionary.class]) {
            completion(nil, urlResponse, [NSError tmp_requestSourceFromRemoteError:error]);
            return;
        }
        
        TMPSource *source = [TMPSource convertFromDictionary:data];
        if (source) {
            completion(source, urlResponse, nil);
            return;
        }
                
        completion(nil, urlResponse, [NSError tmp_createSourceObjectFromDictionaryFailedError:data]);
    };
}

@end
