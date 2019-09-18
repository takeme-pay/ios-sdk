//
//  TMPSourceContext+TMPPrivate.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/15.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <TakeMePaySDK/TakeMePaySDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface TMPSourceContext (TMPPrivate)

- (void)createSourceWithParams:(TMPSourceParams *)params completion:(void(^)(TMPSource * __nullable source, NSError * __nullable error))completion;

@end

NS_ASSUME_NONNULL_END
