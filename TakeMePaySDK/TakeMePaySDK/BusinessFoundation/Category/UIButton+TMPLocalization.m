//
//  UIButton+TMPLocalization.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/11.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "UIButton+TMPLocalization.h"
#import "TMLocalizationUtils.h"

@implementation UIButton (TMPLocalization)

- (void)setTmp_localizedTitleNormalState:(NSString *)tmp_localizedTitle {
    [self setTitle:TMLocalizedString(tmp_localizedTitle) forState:UIControlStateNormal];
}

- (NSString *)tmp_localizedTitleNormalState {
    return self.currentTitle;
}

@end
