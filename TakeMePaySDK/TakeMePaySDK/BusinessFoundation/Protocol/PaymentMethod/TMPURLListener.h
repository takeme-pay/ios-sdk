//
//  TMPURLListener.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/2/14.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TMPURLListener <NSObject>

@required
- (BOOL)shouldHandleWithUrl:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
