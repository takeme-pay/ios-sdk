//
//  UIImage+TMPLoadImageFromSDKBundle.h
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/7.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TMPLoadImageFromSDKBundle)

+ (instancetype)tmp_imageNamed:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
