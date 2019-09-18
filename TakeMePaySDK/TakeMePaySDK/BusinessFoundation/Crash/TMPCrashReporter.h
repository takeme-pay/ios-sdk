//
//  TMPCrashReporter.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/3/4.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMPCrashReport : NSObject <NSCoding>

@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray<NSString *> *callstackInfo;
@property (nonatomic, assign, readonly) NSTimeInterval timestamp;

@end

@interface TMPCrashReporter : NSObject

+ (void)start;

+ (nullable TMPCrashReport *)existedCrashReport:(BOOL)autoRemove;

@end

NS_ASSUME_NONNULL_END
