//
//  TMPSourceContext+TMPPrivate.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/15.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPSourceContext+TMPPrivate.h"
#import "TMPPaymentServiceClient+TMPSourceLowLevelInfoManipulatorSupport.h"

@interface TMPSourceContext (TMPPrivateExpose)

- (void(^)(TMPSource *source, NSURLResponse *urlResponse, NSError *error))sourceHandleBlock:(void(^)(TMPSource * __nullable source, NSError * __nullable error))handleBlock;

@end

@implementation TMPSourceContext (TMPPrivate)

- (void)createSourceWithParams:(TMPSourceParams *)params completion:(void (^)(TMPSource * _Nullable, NSError * _Nullable))completion {
    NSAssert([params isKindOfClass:TMPSourceParams.class], @"params can't be nil");
    NSAssert(completion, @"completion can't be nil");
    
    [self.client createSource:params completion:[self sourceHandleBlock:completion]];
}

@end
