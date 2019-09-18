//
//  UIImage+TMPLoadImageFromSDKBundle.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/7.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "UIImage+TMPLoadImageFromSDKBundle.h"
#import "TMPSDKConstants.h"

@implementation UIImage (TMPLoadImageFromSDKBundle)

+ (instancetype)tmp_imageNamed:(NSString *)imageName {
    return [UIImage imageNamed:imageName inBundle:[NSBundle bundleWithIdentifier:TMP_SDK_BUNDLE_IDENTIFIER] compatibleWithTraitCollection:nil];
}

@end
