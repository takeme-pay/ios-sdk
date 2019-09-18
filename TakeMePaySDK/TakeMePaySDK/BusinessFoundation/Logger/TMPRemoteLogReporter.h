//
//  TMPRemoteLogReporter.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/10.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMLogLevelObserver.h"
#import "TMDictionaryConvertible.h"

NS_ASSUME_NONNULL_BEGIN

@interface TMPRemoteLogInfo : NSObject <TMDictionaryConvertible, NSCoding>

@property (nonatomic, strong) NSString *level;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *metadata;
@property (nonatomic, strong) NSNumber *timestamp;

@end

@interface TMPRemoteLogReporter : NSObject <TMLogLevelObserver>

@end

NS_ASSUME_NONNULL_END
