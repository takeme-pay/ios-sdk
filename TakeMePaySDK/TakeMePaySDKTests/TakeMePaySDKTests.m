//
//  TakeMePaySDKTests.m
//  TakeMePaySDKTests
//
//  Created by tianren.zhu on 2018/12/17.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TakeMePaySDK/TakeMePaySDK.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>

#import "TMPTestSourceParamsPreparer.h"

static NSString *const RETRIEVE_SOURCETYPE_URL = @"";
static NSString *const CREATE_SOURCE_URL = @"";

@interface TakeMePaySDKTests : XCTestCase <TMPPaymentDelegate>

@property (nonatomic, strong) TMPPaymentServiceClient *client;

@end

@implementation TakeMePaySDKTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    TakeMePay.publicKey = @"publicKey";
    TakeMePay.wechatPayAppId = @"wechatPayAppId";
    
    self.client = [[TMPPaymentServiceClient alloc] initWithConfiguration:TMPConfiguration.defaultConfiguration];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [OHHTTPStubs removeAllStubs];
    self.client = nil;
}

#pragma mark - TMPPayment tests

- (void)testCreateBuiltInPreparer {
    TMPSourceParams *params = [[TMPSourceParams alloc] initWithDescription:@"description" amount:100 currency:@"JPY"];
    
    TMPPayment *payment = [[TMPPayment alloc] initWithSourceParams:params delegate:nil];
    
    XCTAssertTrue([payment isKindOfClass:TMPPayment.class]);
    XCTAssertTrue([payment.sourceParamsPreparer isKindOfClass:NSClassFromString(@"TMPUIPaymentSourceParamsPreparer")]);
}

- (void)testSuccessfulPaymentFlow {
    {
        // fake source types
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.absoluteString isEqualToString:RETRIEVE_SOURCETYPE_URL] && [request.HTTPMethod.lowercaseString isEqualToString:@"get"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return ({
                OHHTTPStubsResponse *res = [OHHTTPStubsResponse responseWithJSONObject:@[@{@"type": @"TestPaymentMethod"}] statusCode:200 headers:nil];
                res;
            });
        }];
        
        // fake create source
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.absoluteString isEqualToString:CREATE_SOURCE_URL] && [request.HTTPMethod.lowercaseString isEqualToString:@"post"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return ({
                OHHTTPStubsResponse *res = [OHHTTPStubsResponse responseWithJSONObject:@{
                                                                                         @"amount": @(100),
                                                                                         @"clientSecret": @"",
                                                                                         @"created": @(1555565482000),
                                                                                         @"currency": @"JPY",
                                                                                         @"description": @"description",
                                                                                         @"flow": @"redirect",
                                                                                         @"id": @"",
                                                                                         @"liveMode": @(YES),
                                                                                         @"merchantAppId": @"123456",
                                                                                         @"merchantId": @"1234567890",
                                                                                         @"metadata": @{},
                                                                                         @"object": @"source",
                                                                                         @"payload": @{},
                                                                                         @"status": @"chargeable",
                                                                                         @"subType": @"",
                                                                                         @"type": @"TestPaymentMethod",
                                                                                         @"updated": @(1555565482000)
                                                                                         } statusCode:200 headers:nil];
                res;
            });
        }];
        
        // fake retrieve source
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.absoluteString isEqualToString:[NSString stringWithFormat:@"%@/?clientSecret=", CREATE_SOURCE_URL]] && [request.HTTPMethod.lowercaseString isEqualToString:@"get"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return ({
                OHHTTPStubsResponse *res = [OHHTTPStubsResponse responseWithJSONObject:@{
                                                                                         @"amount": @(100),
                                                                                         @"clientSecret": @"",
                                                                                         @"created": @(1555565482000),
                                                                                         @"currency": @"JPY",
                                                                                         @"description": @"description",
                                                                                         @"flow": @"redirect",
                                                                                         @"id": @"",
                                                                                         @"liveMode": @(YES),
                                                                                         @"merchantAppId": @"123456",
                                                                                         @"merchantId": @"1234567890",
                                                                                         @"metadata": @{},
                                                                                         @"object": @"source",
                                                                                         @"payload": @{},
                                                                                         @"status": @"consumed",
                                                                                         @"subType": @"",
                                                                                         @"type": @"TestPaymentMethod",
                                                                                         @"updated": @(1555565482000)
                                                                                         } statusCode:200 headers:nil];
                res;
            });
        }];
    }
    
    TMPSourceParams *params = [[TMPSourceParams alloc] initWithDescription:@"description" amount:100 currency:@"JPY"];
    
    TMPPayment *payment = [[TMPPayment alloc] initWithSourceParams:params sourceParamsPreparer:[[TMPTestSourceParamsPreparer alloc] init] delegate:nil];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:NSStringFromSelector(_cmd)];
    
    [[[[[[payment setWillCreateSourceByUsingBlock:^(TMPPayment * _Nonnull payment, TMPSourceParams * _Nonnull params) {
        XCTAssertTrue([params.sourceDescription isEqualToString:@"description" ]);
        XCTAssertEqual(params.amount.integerValue, 100);
        XCTAssertTrue([params.currency isEqualToString:@"JPY"]);
    }] setDidReceivedSourceTypesBlock:^(TMPPayment * _Nonnull payment, NSArray<NSString *> * _Nullable sourceTypes, NSString * _Nullable selectedSourceType, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(sourceTypes.count == 1);
        XCTAssertTrue([sourceTypes.firstObject isEqualToString:@"TestPaymentMethod"]);
        XCTAssertTrue([selectedSourceType isEqualToString:@"TestPaymentMethod"]);
    }] setDidCreateSourceBlock:^(TMPPayment * _Nonnull payment, TMPSource * _Nullable source, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertNil(error);
        XCTAssertTrue([source.sourceId isEqualToString:@""]);
        XCTAssertTrue([source.clientSecret isEqualToString:@""]);
    }] setDidFinishAuthorizationBlock:^(TMPPayment * _Nonnull payment, TMPPaymentAuthorizationState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(state == TMPPaymentAuthorizationStateSuccess);
        XCTAssertNil(error);
    }] setWillFinishWithStateBlock:^(TMPPayment * _Nonnull payment, TMPPaymentResultState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(state == TMPPaymentResultStateSuccess);
        XCTAssertTrue(!userInfo && !error);
    }] setDidFinishWithStateBlock:^(TMPPayment * _Nonnull payment, TMPPaymentResultState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(state == TMPPaymentResultStateSuccess);
        XCTAssertTrue(!userInfo && !error);
        
        [expectation fulfill];
    }];
    
    [payment startPaymentAction];
    
    [self waitForExpectations:@[expectation] timeout:20];
}

- (void)testFailedRetrieveSourceTypesWithPaymentFlow {
    {
        // fake source types
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.absoluteString isEqualToString:RETRIEVE_SOURCETYPE_URL] && [request.HTTPMethod.lowercaseString isEqualToString:@"get"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return ({
                OHHTTPStubsResponse *res = [OHHTTPStubsResponse responseWithJSONObject:@[@{}] statusCode:400 headers:nil];
                res;
            });
        }];        
    }
    
    TMPSourceParams *params = [[TMPSourceParams alloc] initWithDescription:@"description" amount:100 currency:@"JPY"];
    
    TMPPayment *payment = [[TMPPayment alloc] initWithSourceParams:params sourceParamsPreparer:[[TMPTestSourceParamsPreparer alloc] init] delegate:nil];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:NSStringFromSelector(_cmd)];
    
    [[[payment setDidReceivedSourceTypesBlock:^(TMPPayment * _Nonnull payment, NSArray<NSString *> * _Nullable sourceTypes, NSString * _Nullable selectedSourceType, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
           XCTAssertNotNil(error);
           XCTAssertTrue(sourceTypes.count == 0);
           XCTAssertNil(selectedSourceType);
    }] setWillFinishWithStateBlock:^(TMPPayment * _Nonnull payment, TMPPaymentResultState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
          XCTAssertTrue(state == TMPPaymentResultStateFailure);
    }] setDidFinishWithStateBlock:^(TMPPayment * _Nonnull payment, TMPPaymentResultState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
         XCTAssertTrue(state == TMPPaymentResultStateFailure);
         
         [expectation fulfill];
     }];
    
    [payment startPaymentAction];
    
    [self waitForExpectations:@[expectation] timeout:20];
}

- (void)testFailedCreateSourceWithPaymentFlow {
    {
        // fake source types
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            
            return [request.URL.absoluteString isEqualToString:RETRIEVE_SOURCETYPE_URL] && [request.HTTPMethod.lowercaseString isEqualToString:@"get"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return ({
                OHHTTPStubsResponse *res = [OHHTTPStubsResponse responseWithJSONObject:@[@{@"type": @"TestPaymentMethod"}] statusCode:200 headers:nil];
                res;
            });
        }];

        // fake create source
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.absoluteString isEqualToString:CREATE_SOURCE_URL] && [request.HTTPMethod.lowercaseString isEqualToString:@"post"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return ({
                OHHTTPStubsResponse *res = [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:400 headers:nil];
                res;
            });
        }];
    }

    TMPSourceParams *params = [[TMPSourceParams alloc] initWithDescription:@"description" amount:100 currency:@"JPY"];

    TMPPayment *payment = [[TMPPayment alloc] initWithSourceParams:params sourceParamsPreparer:[[TMPTestSourceParamsPreparer alloc] init] delegate:nil];

    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:NSStringFromSelector(_cmd)];

    [[[[payment setDidReceivedSourceTypesBlock:^(TMPPayment * _Nonnull payment, NSArray<NSString *> * _Nullable sourceTypes, NSString * _Nullable selectedSourceType, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertNil(error);
        XCTAssertTrue(sourceTypes.count == 1);
        XCTAssertTrue([selectedSourceType isEqualToString:@"TestPaymentMethod"] && [sourceTypes.firstObject isEqualToString:selectedSourceType]);
    }] setDidCreateSourceBlock:^(TMPPayment * _Nonnull payment, TMPSource * _Nullable source, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertNotNil(error);
        XCTAssertNil(source);
    }] setWillFinishWithStateBlock:^(TMPPayment * _Nonnull payment, TMPPaymentResultState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(state == TMPPaymentResultStateFailure);
    }] setDidFinishWithStateBlock:^(TMPPayment * _Nonnull payment, TMPPaymentResultState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(state == TMPPaymentResultStateFailure);

        [expectation fulfill];
    }];

    [payment startPaymentAction];

    [self waitForExpectations:@[expectation] timeout:20];
}

- (void)testFailedAuthorizationWithPaymentFlow {
    {
        // fake source types
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.absoluteString isEqualToString:RETRIEVE_SOURCETYPE_URL] && [request.HTTPMethod.lowercaseString isEqualToString:@"get"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return ({
                OHHTTPStubsResponse *res = [OHHTTPStubsResponse responseWithJSONObject:@[@{@"type": @"TestPaymentMethod"}] statusCode:200 headers:nil];
                res;
            });
        }];
        
        // fake create source
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.absoluteString isEqualToString:CREATE_SOURCE_URL] && [request.HTTPMethod.lowercaseString isEqualToString:@"post"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return ({
                OHHTTPStubsResponse *res = [OHHTTPStubsResponse responseWithJSONObject:@{
                                                                                         @"amount": @(100),
                                                                                         @"clientSecret": @"",
                                                                                         @"created": @(1555565482000),
                                                                                         @"currency": @"JPY",
                                                                                         @"description": @"description",
                                                                                         @"flow": @"redirect",
                                                                                         @"id": @"",
                                                                                         @"liveMode": @(YES),
                                                                                         @"merchantAppId": @"123456",
                                                                                         @"merchantId": @"1234567890",
                                                                                         @"metadata": @{},
                                                                                         @"object": @"source",
                                                                                         @"payload": @{},
                                                                                         @"status": @"chargeable",
                                                                                         @"subType": @"",
                                                                                         @"type": @"TestPaymentMethod",
                                                                                         @"updated": @(1555565482000)
                                                                                         } statusCode:200 headers:nil];
                res;
            });
        }];
    }
    
    TMPSourceParams *params = [[TMPSourceParams alloc] initWithDescription:@"description" amount:100 currency:@"JPY"];
    
    TMPPayment *payment = [[TMPPayment alloc] initWithSourceParams:params sourceParamsPreparer:[[TMPTestSourceParamsPreparer alloc] init] delegate:nil];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:NSStringFromSelector(_cmd)];
    
    [[[[[[payment setWillCreateSourceByUsingBlock:^(TMPPayment * _Nonnull payment, TMPSourceParams * _Nonnull params) {
        XCTAssertTrue([params.sourceDescription isEqualToString:@"description" ]);
        XCTAssertEqual(params.amount.integerValue, 100);
        XCTAssertTrue([params.currency isEqualToString:@"JPY"]);
    }] setDidReceivedSourceTypesBlock:^(TMPPayment * _Nonnull payment, NSArray<NSString *> * _Nullable sourceTypes, NSString * _Nullable selectedSourceType, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(sourceTypes.count == 1);
        XCTAssertTrue([sourceTypes.firstObject isEqualToString:@"TestPaymentMethod"]);
        XCTAssertTrue([selectedSourceType isEqualToString:@"TestPaymentMethod"]);
    }] setDidCreateSourceBlock:^(TMPPayment * _Nonnull payment, TMPSource * _Nullable source, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertNil(error);
        XCTAssertTrue([source.sourceId isEqualToString:@""]);
        XCTAssertTrue([source.clientSecret isEqualToString:@""]);
    }] setDidFinishAuthorizationBlock:^(TMPPayment * _Nonnull payment, TMPPaymentAuthorizationState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(state == TMPPaymentAuthorizationStateFailure);
        XCTAssertNotNil(error);
    }] setWillFinishWithStateBlock:^(TMPPayment * _Nonnull payment, TMPPaymentResultState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(state == TMPPaymentResultStateFailure);
        XCTAssertNotNil(error);
    }] setDidFinishWithStateBlock:^(TMPPayment * _Nonnull payment, TMPPaymentResultState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(state == TMPPaymentResultStateFailure);
        XCTAssertNotNil(error);
        
        [expectation fulfill];
    }];
    
    [payment startPaymentAction:@{@"authStatus" : @(TMPPaymentAuthorizationStateFailure)}];
    
    [self waitForExpectations:@[expectation] timeout:20];
}

- (void)testPollerTimeoutWithPaymentFlow {
    {
        // fake source types
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.absoluteString isEqualToString:RETRIEVE_SOURCETYPE_URL] && [request.HTTPMethod.lowercaseString isEqualToString:@"get"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return ({
                OHHTTPStubsResponse *res = [OHHTTPStubsResponse responseWithJSONObject:@[@{@"type": @"TestPaymentMethod"}] statusCode:200 headers:nil];
                res;
            });
        }];
        
        // fake create source
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.absoluteString isEqualToString:CREATE_SOURCE_URL] && [request.HTTPMethod.lowercaseString isEqualToString:@"post"];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return ({
                OHHTTPStubsResponse *res = [OHHTTPStubsResponse responseWithJSONObject:@{
                                                                                         @"amount": @(100),
                                                                                         @"clientSecret": @"",
                                                                                         @"created": @(1555565482000),
                                                                                         @"currency": @"JPY",
                                                                                         @"description": @"description",
                                                                                         @"flow": @"redirect",
                                                                                         @"id": @"",
                                                                                         @"liveMode": @(YES),
                                                                                         @"merchantAppId": @"123456",
                                                                                         @"merchantId": @"1234567890",
                                                                                         @"metadata": @{},
                                                                                         @"object": @"source",
                                                                                         @"payload": @{},
                                                                                         @"status": @"chargeable",
                                                                                         @"subType": @"",
                                                                                         @"type": @"TestPaymentMethod",
                                                                                         @"updated": @(1555565482000)
                                                                                         } statusCode:200 headers:nil];
                res;
            });
        }];
        
        // fake retrieve source
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
            return [request.URL.absoluteString isEqualToString:[NSString stringWithFormat:@"%@/?clientSecret=", CREATE_SOURCE_URL]];
        } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
            return ({
                OHHTTPStubsResponse *res = [OHHTTPStubsResponse responseWithJSONObject:@{
                                                                                         @"amount": @(100),
                                                                                         @"clientSecret": @"",
                                                                                         @"created": @(1555565482000),
                                                                                         @"currency": @"JPY",
                                                                                         @"description": @"description",
                                                                                         @"flow": @"redirect",
                                                                                         @"id": @"",
                                                                                         @"liveMode": @(YES),
                                                                                         @"merchantAppId": @"123456",
                                                                                         @"merchantId": @"1234567890",
                                                                                         @"metadata": @{},
                                                                                         @"object": @"source",
                                                                                         @"payload": @{},
                                                                                         @"status": @"consumed",
                                                                                         @"subType": @"",
                                                                                         @"type": @"TestPaymentMethod",
                                                                                         @"updated": @(1555565482000)
                                                                                         } statusCode:200 headers:nil];
                res.responseTime = 5;
                res;
            });
        }];
    }
    
    TMPSourceParams *params = [[TMPSourceParams alloc] initWithDescription:@"description" amount:100 currency:@"JPY"];
    
    TMPPayment *payment = [[TMPPayment alloc] initWithSourceParams:params sourceParamsPreparer:[[TMPTestSourceParamsPreparer alloc] init] delegate:nil];
    
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:NSStringFromSelector(_cmd)];
    
    [[[[[[payment setWillCreateSourceByUsingBlock:^(TMPPayment * _Nonnull payment, TMPSourceParams * _Nonnull params) {
        XCTAssertTrue([params.sourceDescription isEqualToString:@"description" ]);
        XCTAssertEqual(params.amount.integerValue, 100);
        XCTAssertTrue([params.currency isEqualToString:@"JPY"]);
    }] setDidReceivedSourceTypesBlock:^(TMPPayment * _Nonnull payment, NSArray<NSString *> * _Nullable sourceTypes, NSString * _Nullable selectedSourceType, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(sourceTypes.count == 1);
        XCTAssertTrue([sourceTypes.firstObject isEqualToString:@"TestPaymentMethod"]);
        XCTAssertTrue([selectedSourceType isEqualToString:@"TestPaymentMethod"]);
    }] setDidCreateSourceBlock:^(TMPPayment * _Nonnull payment, TMPSource * _Nullable source, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertNil(error);
        XCTAssertTrue([source.sourceId isEqualToString:@""]);
        XCTAssertTrue([source.clientSecret isEqualToString:@""]);
    }] setDidFinishAuthorizationBlock:^(TMPPayment * _Nonnull payment, TMPPaymentAuthorizationState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(state == TMPPaymentAuthorizationStateSuccess);
        XCTAssertNil(error);
    }] setWillFinishWithStateBlock:^(TMPPayment * _Nonnull payment, TMPPaymentResultState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(state == TMPPaymentResultStateFailure);
        XCTAssertTrue(error && [error.userInfo[NSLocalizedDescriptionKey] isEqualToString:@"Source polling timeout, stop polling"]);
    }] setDidFinishWithStateBlock:^(TMPPayment * _Nonnull payment, TMPPaymentResultState state, NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
        XCTAssertTrue(state == TMPPaymentResultStateFailure);
        XCTAssertTrue(error && [error.userInfo[NSLocalizedDescriptionKey] isEqualToString:@"Source polling timeout, stop polling"]);
        
        [expectation fulfill];
    }];
    
    [payment startPaymentAction:@{@"__timeout": @(1.f)}];
    
    [self waitForExpectations:@[expectation] timeout:20];
}

@end
