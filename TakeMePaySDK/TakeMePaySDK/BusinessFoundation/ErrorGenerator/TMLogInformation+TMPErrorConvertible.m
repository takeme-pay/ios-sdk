//
//  TMLogInformation+TMPErrorConvertible.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/10.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMLogInformation+TMPErrorConvertible.h"

@implementation TMLogInformation (TMPErrorConvertible)

+ (instancetype)convertFromError:(NSError *)error {
    if (!error) {
        return nil;
    }
    
    TMLogInformation *instance = [[TMLogInformation alloc] init];
    
    instance.logLevel = TMLogLevelError;
    instance.message = error.userInfo[NSLocalizedDescriptionKey];
    instance.extraInfo = error.userInfo;
    
    return instance;
}

@end
