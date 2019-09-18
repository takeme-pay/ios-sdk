//
//  TMLogLevelObserver.h
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2019/1/10.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMLogInformation;

NS_ASSUME_NONNULL_BEGIN

@protocol TMLogLevelObserver <NSObject>

@required
- (void)consumeObservedInformation:(TMLogInformation *)information;

@end

NS_ASSUME_NONNULL_END
