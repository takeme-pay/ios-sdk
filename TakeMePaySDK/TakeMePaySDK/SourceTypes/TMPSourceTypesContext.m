//
//  TMPSourceTypesContext.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/4/16.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPSourceTypesContext.h"
#import "TMPPaymentServiceClient+TMPSourceTypeListLowLevelInfoManipulatorSupport.h"

@interface TMPSourceTypesContext ()

@property (nonatomic, strong, readwrite) TMPPaymentServiceClient *client;

@end

@implementation TMPSourceTypesContext

- (instancetype)initWithClient:(TMPPaymentServiceClient *)client {
    NSAssert(client, @"client can't be nil");
    if (self = [super init]) {
        _client = client;
    }
    return self;
}

#pragma mark - public

- (void)retrieveSourceTypes:(void (^)(NSArray<TMPPaymentMethod *> * _Nullable, NSError * _Nullable))completion {
    NSAssert(completion, @"completion can't be nil");
    
    [self.client retrieveSourceTypeList:[[TMPSourceTypeListParams alloc] init] completion:^(NSArray<TMPPaymentMethod *> * _Nullable sourceList, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || ![sourceList isKindOfClass:NSArray.class]) {
            completion(nil, error);
            return;
        }
        
        completion(sourceList, nil);
    }];
}

@end
