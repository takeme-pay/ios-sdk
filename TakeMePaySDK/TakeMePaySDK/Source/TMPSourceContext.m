//
//  TMPSourceContext.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/20.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPSourceContext.h"
#import "TMPSource.h"
#import "TMPPaymentServiceClient+TMPSourceLowLevelInfoManipulatorSupport.h"

@interface TMPSourceContext ()

@property (nonatomic, strong, readwrite) TMPPaymentServiceClient *client;

@end

@implementation TMPSourceContext

- (instancetype)initWithClient:(TMPPaymentServiceClient *)client {
    NSAssert(client, @"client can't be nil");
    
    if (self = [super init]) {
        _client = client;
    }
    
    return self;
}

#pragma mark - public

- (void)retrieveSourceWithParams:(TMPSourceParams *)params completion:(void (^)(TMPSource * _Nullable, NSError * _Nullable))completion {
    NSAssert([params isKindOfClass:TMPSourceParams.class], @"params can't be nil");
    NSAssert(completion, @"completion can't be nil");
    
    [self.client retrieveSource:params completion:[self sourceHandleBlock:completion]];
}

#pragma mark - private

- (void(^)(TMPSource *source, NSURLResponse *urlResponse, NSError *error))sourceHandleBlock:(void(^)(TMPSource * __nullable source, NSError * __nullable error))handleBlock {
    return ^(TMPSource *source, NSURLResponse *urlResponse, NSError *error) {
        NSAssert(handleBlock, @"handle block can't be nil");
        
        if (error || ![source isKindOfClass:TMPSource.class]) {
            handleBlock(nil, error);
            return;
        }
        
        handleBlock(source, error);
        return;
    };
}

@end
