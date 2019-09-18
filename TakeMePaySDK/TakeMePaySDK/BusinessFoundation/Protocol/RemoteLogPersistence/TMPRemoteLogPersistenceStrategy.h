//
//  TMPPersistenceStrategy.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/3/1.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMPRemoteLogInfo;
@protocol TMPRemoteLogPersistenceStrategy;

NS_ASSUME_NONNULL_BEGIN

@protocol TMPRemoteLogPersistenceDelegate <NSObject>

@required
- (void)persistItemFinished:(id<TMPRemoteLogPersistenceStrategy>)strategy isTouchWaterMark:(BOOL)touchwaterMark;

@optional
- (void)sendDirectlyIfInEmergencyCase:(NSArray<TMPRemoteLogInfo *> *)pendings completion:(void(^)(BOOL success))completion;

@end

@protocol TMPRemoteLogPersistenceStrategy <NSObject>

@required
@property (nonatomic, weak) id<TMPRemoteLogPersistenceDelegate> delegate;

- (void)receivedData:(TMPRemoteLogInfo *)data;
- (BOOL)purgeData:(NSArray<TMPRemoteLogInfo *> *)toBePurgedData;
- (NSArray<TMPRemoteLogInfo *> *)persistedData;

@end

NS_ASSUME_NONNULL_END
