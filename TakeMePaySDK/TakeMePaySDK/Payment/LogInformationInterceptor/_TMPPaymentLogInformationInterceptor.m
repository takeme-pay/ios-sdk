//
//  _TMPPaymentLogInformationInterceptor.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/10.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "_TMPPaymentLogInformationInterceptor.h"
#import "TMLogService.h"
#import "TMPSource.h"
#import "TMLogInformation+TMPErrorConvertible.h"

static NSString *const TMP_LOG_PREFIX = @"[TMP]";

@implementation _TMPPaymentLogInformationInterceptor

#pragma mark - TMPPaymentDelegate

- (void)payment:(TMPPayment *)payment willCreateSourceByUsing:(TMPSourceParams *)params {
    [TMLogService.shared receivedInformation:({
        TMLogInformation *info = [[TMLogInformation alloc] init];
        info.logLevel = TMLogLevelDebug;
        info.message = [NSString stringWithFormat:@"is requesting source generation by params: %@", params];
        info;
    })];
}

- (void)payment:(TMPPayment *)payment didCreateSource:(TMPSource *)source error:(nullable NSError *)error userInfo:(nullable __unused  NSDictionary *)userInfo {
    if (error) {
        [TMLogService.shared receivedInformation:[TMLogInformation convertFromError:error]];
    } else {
        [TMLogService.shared receivedInformation:({
            TMLogInformation *info = [[TMLogInformation alloc] init];
            info.logLevel = TMLogLevelDebug;
            info.message = [NSString stringWithFormat:@"did created source successfully, source id is: %@", source.sourceId];
            info;
        })];
    }
}

- (void)payment:(TMPPayment *)payment didReceivedSourceTypes:(nullable NSArray<NSString *> *)sourceTypes selectedSourceType:(nullable NSString *)selectedSourceType error:(nullable NSError *)error userInfo:(nullable __unused NSDictionary *)userInfo {
    if (error) {
        [TMLogService.shared receivedInformation:[TMLogInformation convertFromError:error]];
    } else {
        [TMLogService.shared receivedInformation:({
            TMLogInformation *info = [[TMLogInformation alloc] init];
            info.logLevel = TMLogLevelDebug;
            info.message = [NSString stringWithFormat:@"did received source types: %@, selected source type is: %@", sourceTypes, selectedSourceType];
            info;
        })];
    }
}

- (void)payment:(TMPPayment *)payment didFinishAuthorization:(TMPPaymentAuthorizationState)state error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo {
    if (error) {
        [TMLogService.shared receivedInformation:[TMLogInformation convertFromError:error]];
    } else {
        [TMLogService.shared receivedInformation:({
            TMLogInformation *info = [[TMLogInformation alloc] init];
            info.logLevel = TMLogLevelDebug;
            
            NSString *statusLiteral;
            
            if (state == TMPPaymentAuthorizationStateSuccess) {
                statusLiteral = @"success";
            }
            
            info.message = [NSString stringWithFormat:@"did finish authorization with status: %@", statusLiteral];
            
            info;
        })];
    }
}

- (void)payment:(TMPPayment *)payment didPolledSource:(TMPSource *)source state:(TMPPaymentPollingResultState)state error:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo {
    if (error) {
        [TMLogService.shared receivedInformation:[TMLogInformation convertFromError:error]];
    } else if (state == TMPPaymentPollingResultStateTimeout) {
        [TMLogService.shared receivedInformation:({
            TMLogInformation *info = [[TMLogInformation alloc] init];
            info.logLevel = TMLogLevelError;
            info.message = [NSString stringWithFormat:@"polling source: %@ timeout", source.sourceId];
            info;
        })];
    } else if (state == TMPPaymentPollingResultStateSuccess){
        [TMLogService.shared receivedInformation:({
            TMLogInformation *info = [[TMLogInformation alloc] init];
            info.logLevel = TMLogLevelDebug;
            info.message = [NSString stringWithFormat:@"polling source: %@ and get successful result", source.sourceId];
            info;
        })];
    }
}

- (void)payment:(TMPPayment *)payment willFinishWithState:(TMPPaymentResultState)state error:(nullable NSError *)error userInfo:(nullable __unused NSDictionary *)userInfo {
    if (error) {
        [TMLogService.shared receivedInformation:[TMLogInformation convertFromError:error]];
    } else {
        [TMLogService.shared receivedInformation:({
            TMLogInformation *info = [[TMLogInformation alloc] init];
            info.logLevel = TMLogLevelDebug;
            
            NSString *statusLiteral;
            
            if (state == TMPPaymentResultStateSuccess) {
                statusLiteral = @"success";
            } else if (state == TMPPaymentResultStateCanceled) {
                statusLiteral = @"canceled";
            }
            
            info.message = [NSString stringWithFormat:@"will finish payment with status: %@", statusLiteral];
            info;
        })];
    }
}

- (void)payment:(TMPPayment *)payment didFinishWithState:(TMPPaymentResultState)state error:(nullable NSError *)error userInfo:(nullable __unused NSDictionary *)userInfo {
    if (error) {
        [TMLogService.shared receivedInformation:[TMLogInformation convertFromError:error]];
    } else {
        [TMLogService.shared receivedInformation:({
            TMLogInformation *info = [[TMLogInformation alloc] init];
            info.logLevel = TMLogLevelDebug;
            
            NSString *statusLiteral;
            
            if (state == TMPPaymentResultStateSuccess) {
                statusLiteral = @"success";
            } else if (state == TMPPaymentResultStateCanceled) {
                statusLiteral = @"canceled";
            }
            
            info.message = [NSString stringWithFormat:@"did finish payment with status: %@", statusLiteral];
            info;
        })];
    }
}

@end
