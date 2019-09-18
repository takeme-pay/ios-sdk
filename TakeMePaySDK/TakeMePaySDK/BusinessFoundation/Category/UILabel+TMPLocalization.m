//
//  UILabel+TMPLocalization.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/11.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "UILabel+TMPLocalization.h"
#import "TMLocalizationUtils.h"

@implementation UILabel (TMPLocalization)

- (void)setTmp_localizedText:(NSString *)tmp_localizedText {
    self.text = TMLocalizedString(tmp_localizedText);
}

- (NSString *)tmp_localizedText {
    return self.text;
}

@end
