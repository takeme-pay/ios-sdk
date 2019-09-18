//
//  TMLogService.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2019/1/8.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMLoggerEnums.h"

@protocol TMLogLevelObserver;

NS_ASSUME_NONNULL_BEGIN

@interface TMLogInformation : NSObject <NSCopying>

@property (nonatomic, assign) TMLogLevel logLevel;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *extraInfo;
@property (nonatomic, assign, readonly) NSTimeInterval timestamp;

@end

@interface TMLogInformation (TMLogLevelLiteral)

- (NSString *)logLevelLiteral;

@end

@interface TMLogService : NSObject

+ (instancetype)shared;

- (void)registerObserver:(id<TMLogLevelObserver>)observer onLevel:(TMLogLevel)level;
- (void)setUpDone;

- (void)receivedInformation:(TMLogInformation *)information;

@end

NS_ASSUME_NONNULL_END
