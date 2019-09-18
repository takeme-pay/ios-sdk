//
//  TMLogConsolePrinter.m
//  TakeMeFoundation
//
//  Created by tianren.zhu on 2019/1/10.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMLogConsolePrinter.h"
#import "TMLogService.h"

@implementation TMLogConsolePrinter

#pragma mark - TMLogLevelObserver

- (void)consumeObservedInformation:(TMLogInformation *)information {
    NSLog(@"[TMP] log level: %@\nmessage: %@\nextraInfo:%@", information.logLevelLiteral, information.message, information.extraInfo);
}

@end
