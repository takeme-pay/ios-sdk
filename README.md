# TakeMePaySDK

This is the source code of TakeMePaySDK from TakeMe Pay on iOS platform. The SDK is used and designed to help users to integrate multiple payment brands in their apps. We open source it to help developers understand the architechture and design of the TakeMePaySDK well.

> Because we provide the payment SDK to developers, our SDK doesn't contain any 3rd libraries.

## Component and Concept of SDK

### Payment

`Payment` indicates a payment, we provide the initializer which accepts a `source params` instance and `startPaymentAction` method, let us issue a payment in just few lines.

```objc

TMPSourceParams *params = [[TMPSourceParams alloc] initWithDescription:@"description" amount:100 currency:@"JPY"];
    
TMPPayment *payment = [[TMPPayment alloc] initWithSourceParams:params delegate:nil];

[payment startPaymentAction];

```

### Source

`Source` indicates the details of a payment, `sourceId`, `amount`, `clientSecret`, etc. An instance of `Source` is created by SDK framework and TakeMe Pay backend, when you create the `SourceParams` with its initializer, then the `Payment` instance will create a `Source` for you, you could retrieve the `Source` object via `PaymentDelegate`.

### SourceParams

`SourceParams` is used to create the `Source` object, and issue a payment successfully by `Payment` instance. We recommend developer always use the convenience initializer of `SourceParams` to initialize it, because some fields of `SourceParams` will be handled by SDK, the framework will fill them during the payment.

### SourceParamsPreparer

`SourceParamsPreparer` indicates the `SourceParams` provider in SDK framework, we want to improve the scalability and flexibility of the SDK, so we abstract all actions for building the `SourceParams` as `SourceParamsPreparer`.

For example, TakeMePaySDK provides a default user interface for checkout view, the checkout view shows the detail of the product and allows user to choose a payment method as the expected one, then press the `Pay` button to issue the payment.

Here, the checkout view is responsible for constructing the `SourceParams`, appends some very important properties of the `SourceParams` such as `type`, `flow` and `metadata`, these properties will be used to request the payment with specific payment method, like `Alipay`, `WeChat Pay`, etc.

We realized that our brilliant developers might have many different requirements with `SourceParams` construction, the requirement might be a different user interface, or even without any user interface, build the `SourceParams` just in codes, so we abstract the concept as `SourceParamsPreparer`, if you have any other requirement, just conform to the `PaymentSourceParamsPreparer` protocol and implement those required methods, you can find detailed documentations for `PaymentSourceParamsPreparer`.

### PaymentMethod

Every payment brand is an instance of `PaymentMethod`, they are not a part of TakeMePaySDK, we managed them as separated dynamic libraries, every `PaymentMethod` is registered by `TMPRegisterPaymentMethod()` macro, in `PaymentMethodRegisterSupport` file, the TakeMePaySDK will initialize every supported payment method while the SDK initialization phrase.

### Others

In TakeMePaySDK source code, you can find a lot of files in `Foundation` and `BusinessFoundation` folder, they support the TakeMePaySDK together, the SDK contains features like `logs when development`, `crash report`, etc.

## Documentations

* How to integrate TakeMePay in your app
* How to customize your user interface for checkout view
