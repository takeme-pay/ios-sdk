//
//  TMDeviceInfo.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/15.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMDeviceInfo : NSObject

+ (NSString *)osVersion;
+ (NSString *)deviceType;
+ (NSString *)networkType;
+ (NSString *)carrier;
+ (BOOL)isJailbreak;

@end

NS_ASSUME_NONNULL_END
