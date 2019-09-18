//
//  TMEndpointServiceImpl.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TMEndpointServiceImpl.h"
#import "TMUtils.h"

static NSTimeInterval const TIMEOUT_INTERVAL = 30.f;

@interface TMEndpointServiceImpl ()

@property (nonatomic, strong) TMNetworkConfiguration *configuration;
@property (nonatomic, strong, readwrite) id<TMEndpointAPIRequest> request;
@property (nonatomic, strong) NSURLSessionTask *task;

@end

@implementation TMEndpointServiceImpl

@synthesize request = _request;

- (instancetype)initWithConfiguration:(TMNetworkConfiguration *)configuration {
    NSAssert(configuration, @"configuration should never be nil");
    if (self = [super init]) {
        _configuration = configuration;
    }
    return self;
}

- (void)request:(id<TMEndpointAPIRequest>)request completion:(void(^)(NSURLResponse *, id, NSError *))completion {
    NSAssert(request, @"request should never be nil");
    self.request = request;
    
    NSURLRequest *urlRequest = [self generateUrlRequestFrom:request];
    
    if (urlRequest) {
        // replace NSURLSession.sharedSession if needed.
        self.task = [NSURLSession.sharedSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error && completion) {
                completion(response, nil, error);
                return;
            }
            
            if (data != nil && data.length != 0) {
                NSError *deserializeError;
                id responseJsonObject = [[self.configuration serializer:request.deserializerType] deserializeData:data error:&deserializeError];
                if (!deserializeError && responseJsonObject && completion) {
                    completion(response, responseJsonObject, nil);
                    return;
                }
                
                completion(response, nil, deserializeError);
            } else {
                completion(response, nil, nil);
            }
        }];
        
        [self.task resume];
    }
}

- (void)cancel {
    [self.task cancel];
}

- (void)setRequest:(id<TMEndpointAPIRequest>)request {
    NSAssert([self validateEndpointRequest:request], @"request format error");
    _request = request;
}

#pragma mark - private
                                              
- (NSURL *)formalUrl:(id<TMEndpointAPIRequest>)request {
    NSAssert(request, @"request should be nil");
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:[NSString stringWithFormat:@"%@%@", self.configuration.baseUrl, request.endpoint]];
    
    // handle with the params when using GET method
    if ([request.httpMethod caseInsensitiveCompare:@"get"] == NSOrderedSame && request.params.count != 0) {
        NSMutableArray *queryItems = [[NSMutableArray alloc] init];
        
        for (NSString *key in request.params.allKeys) {
            NSString *value = request.params[key];
            if (![TMUtils stringIsEmpty:value]) {
                [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:value]];
            }
        }
        
        urlComponents.queryItems = queryItems.copy;
    }
    
    return urlComponents.URL;
}

- (NSURLRequest *)generateUrlRequestFrom:(id<TMEndpointAPIRequest>)request {
    NSMutableURLRequest *mutableUrlRequest = [[NSMutableURLRequest alloc] initWithURL:[self formalUrl:request] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:TIMEOUT_INTERVAL];
    mutableUrlRequest.HTTPMethod = request.httpMethod;
    
    // inject necessary information into header fields
    NSMutableDictionary *mutableHeaders = [[NSMutableDictionary alloc] initWithDictionary:request.additionalHeaders];
        
    // the request doesn't conform to the protocol in default case, means that the framework should inject the default headers
    // if the request conforms to the protocol, the framework will check the `injectDefaultHeaders` flag in order to inject default headers
    if (![request conformsToProtocol:@protocol(TMEndpointAPIRequestInjectDefaultHeaders)] || [[request performSelector:@selector(injectDefaultHeaders)] boolValue]) {
        if (![TMUtils stringIsEmpty:self.configuration.authToken] && !mutableHeaders[@"Authorization"]) {
            mutableHeaders[@"Authorization"] = self.configuration.authToken;
        }
        
        [mutableHeaders addEntriesFromDictionary:self.configuration.defaultHeaders];
    }
    
    if ([request.httpMethod caseInsensitiveCompare:@"post"] == NSOrderedSame) {
        Class<TMNetworkDataSerializer> serializer = [self.configuration serializer:request.serializerType];
        
        NSError *serializeError;
        NSData *bodyData = [serializer serializeDictionary:request.params error:&serializeError];
        
        if (!serializeError) {
            mutableHeaders[@"Content-Type"] = [serializer contentType];
            mutableHeaders[@"Content-Length"] = [NSString stringWithFormat:@"%lu", (unsigned long)bodyData.length];
            
            mutableUrlRequest.HTTPBody = bodyData;
        }
    }
    
    mutableUrlRequest.allHTTPHeaderFields = mutableHeaders.copy;
    
    return mutableUrlRequest.copy;
}

- (BOOL)validateEndpointRequest:(id<TMEndpointAPIRequest>)request {
    if ([TMUtils stringIsEmpty:request.endpoint]) {
        return NO;
    }
    
    if ([TMUtils stringIsEmpty:request.httpMethod]) {
        return NO;
    }
    
    if (![request.params isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    
    if (![request.additionalHeaders isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    
    return YES;
}

@end
