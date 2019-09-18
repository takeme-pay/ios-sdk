//
//  NSDictionary+TMPExtension.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/22.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "NSDictionary+TMPExtension.h"
#import "TMPSDKConstants.h"

@implementation NSDictionary (TMPExtension)

+ (instancetype)tmp_dictionaryFromPlistWithFileName:(NSString *)fileName {
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleWithIdentifier:TMP_SDK_BUNDLE_IDENTIFIER] pathForResource:fileName ofType:@"plist"]];
}

@end
