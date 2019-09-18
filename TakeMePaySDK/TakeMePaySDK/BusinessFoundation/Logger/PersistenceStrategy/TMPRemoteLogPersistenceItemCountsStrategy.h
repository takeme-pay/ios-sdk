//
//  TMPRemoteLogPersistenceItemCountsStrategy.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/3/1.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPRemoteLogPersistenceStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMPRemoteLogPersistenceItemCountsStrategyBuilder : NSObject

@property (nonatomic, weak) id<TMPRemoteLogPersistenceDelegate> delegate;
@property (nonatomic, assign) NSUInteger persistenceMaxCount;
@property (nonatomic, assign) NSUInteger pendingMaxCount;

@end

@interface TMPRemoteLogPersistenceItemCountsStrategy : NSObject <TMPRemoteLogPersistenceStrategy>

- (instancetype)initWithBuilder:(void(^)(TMPRemoteLogPersistenceItemCountsStrategyBuilder *builder))block;

#pragma mark - unavailable

- (instancetype)init __attribute__((unavailable("Use `initWithBuilder:` instead")));

@end

NS_ASSUME_NONNULL_END
