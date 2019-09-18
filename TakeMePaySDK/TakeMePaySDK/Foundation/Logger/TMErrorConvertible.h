//
//  TMErrorConvertible.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2019/1/10.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TMErrorConvertible <NSObject>

@required
+ (nullable instancetype)convertFromError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
