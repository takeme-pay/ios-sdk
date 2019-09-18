//
//  TMPPaymentDefaultUICheckoutCounterViewController.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/24.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPPaymentDefaultUICheckoutCounterViewController.h"
#import "TMPSDKConstants.h"
#import "TMPPaymentMethod.h"
#import "TMUtils.h"
#import "UIImageView+TMDownLoadImage.h"
#import "UIImage+TMPLoadImageFromSDKBundle.h"
#import "TMLocalizationUtils.h"

@interface TMPPaymentDefaultUICheckoutCounterViewController ()

@property (nonatomic, strong) TMPPaymentUITheme *theme;

@property (weak, nonatomic) IBOutlet UIStackView *itemImageAndNameStackView;
@property (nonatomic, assign) CGFloat originalItemImageAndNameStackViewSpacing;
@property (weak, nonatomic) IBOutlet UIView *checkoutCounterContentView;

@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemPriceCurrencyLabel;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation TMPPaymentDefaultUICheckoutCounterViewController

@synthesize responder = _responder;
@synthesize itemImageUrl = _itemImageUrl;
@synthesize itemName = _itemName;
@synthesize itemPrice = _itemPrice;
@synthesize itemCurrency = _itemCurrency;
@synthesize paymentMethodItem = _paymentMethodItem;
@synthesize itemDescription = _itemDescription;
@synthesize paymentStatus = _paymentStatus;
@synthesize userInfo = _userInfo;

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.originalItemImageAndNameStackViewSpacing = self.itemImageAndNameStackView.spacing;
    
    [self.payButton setBackgroundImage:[TMUtils imageWithColor:[TMUtils colorWithHex:@"#0179FF"]] forState:UIControlStateNormal];
    [self.payButton setBackgroundImage:[TMUtils imageWithColor:[TMUtils colorWithHex:@"0054B2"]] forState:UIControlStateSelected];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.itemName = self.itemName;
    self.itemPrice = self.itemPrice;
    self.itemCurrency = self.itemCurrency;
    self.itemImageUrl = self.itemImageUrl;
    self.paymentMethodItem = self.paymentMethodItem;
    self.itemDescription = self.itemDescription;
    self.paymentStatus = self.paymentStatus;
}

#pragma mark - TMPPaymentUIThemeAcceptable

- (instancetype)initFromTheme:(TMPPaymentUITheme *)theme {
    if (self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleWithIdentifier:TMP_SDK_BUNDLE_IDENTIFIER]]) {
        _theme = theme;
    }
    return self;
}

- (void)setUITheme:(nonnull TMPPaymentUITheme *)theme {
    if (![theme isKindOfClass:TMPPaymentUITheme.class]) {
        return;
    }
    _theme = theme;
}

- (nullable TMPPaymentUITheme *)currentUITheme {
    return self.theme;
}

#pragma mark - setters

- (void)setItemImageUrl:(NSString *)itemImageUrl {
    [TMUtils executeOnMainQueue:^{
        self->_itemImageUrl = itemImageUrl;
        
        if (![itemImageUrl isKindOfClass:NSString.class]) {
            self.itemImageView.hidden = YES;
            self.itemImageAndNameStackView.spacing = 0.f;
        } else {
            self.itemImageView.hidden = NO;
            self.itemImageAndNameStackView.spacing = self.originalItemImageAndNameStackViewSpacing;
        }
        
        [self.itemImageView tm_setImageUrl:itemImageUrl];
    } sync:NO];
}

- (void)setItemName:(NSString *)itemName {
    [TMUtils executeOnMainQueue:^{
        self->_itemName = itemName;
        
        self.itemNameLabel.text = itemName;
    } sync:NO];
}

- (void)setItemPrice:(NSNumber *)itemPrice {
    [TMUtils executeOnMainQueue:^{
        self->_itemPrice = itemPrice;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.currencySymbol = @"";
        
        if (itemPrice.doubleValue == itemPrice.integerValue) {
            formatter.maximumFractionDigits = 0;
        }
        
        self.itemPriceLabel.text = [formatter stringFromNumber:itemPrice];
    } sync:NO];
}

- (void)setItemCurrency:(NSString *)itemCurrency {
    [TMUtils executeOnMainQueue:^{
        self->_itemCurrency = itemCurrency;
        
        self.itemPriceCurrencyLabel.text = itemCurrency;
    } sync:NO];
}

- (void)setPaymentMethodItem:(TMPPaymentMethod *)defaultPaymentMethod {
    [TMUtils executeOnMainQueue:^{
        self->_paymentMethodItem = defaultPaymentMethod;
        
        self.paymentMethodLabel.text = defaultPaymentMethod.title;
    } sync:NO];
}

- (void)setItemDescription:(NSString *)itemDescription {
    [TMUtils executeOnMainQueue:^{
        // todo: not supported now
        self->_itemDescription = itemDescription;
    } sync:NO];
}

- (void)setPaymentStatus:(TMPPaymentResultState)paymentStatus {
    [TMUtils executeOnMainQueue:^{
        self->_paymentStatus = paymentStatus;
        
        [self stopLoadingIndicatorIfNeeded];
        
        switch (paymentStatus) {
            case TMPPaymentResultStateIdle: {
                self.payButton.hidden = NO;
                self.statusImageView.hidden = YES;
                self.statusLabel.hidden = YES;
                break;
            }
            case TMPPaymentResultStateInProgress: {
                self.payButton.hidden = YES;
                self.statusImageView.hidden = NO;
                self.statusLabel.hidden = NO;
                self.statusLabel.text = TMLocalizedString(@"TMP_CheckoutCounter:Please wait...");
                
                [self runLoadingIndicator];
                
                break;
            }
            case TMPPaymentResultStateSuccess: {
                self.payButton.hidden = YES;
                self.statusImageView.hidden = NO;
                self.statusImageView.image = [UIImage tmp_imageNamed:@"checkout_counter_success"];
                self.statusLabel.hidden = NO;
                self.statusLabel.text = TMLocalizedString(@"TMP_CheckoutCounter:Success");
                break;
            }
            case TMPPaymentResultStateFailure: {
                self.payButton.hidden = YES;
                self.statusImageView.hidden = NO;
                self.statusImageView.image = [UIImage tmp_imageNamed:@"checkout_counter_failed"];
                self.statusLabel.hidden = NO;
                self.statusLabel.text = TMLocalizedString(@"TMP_CheckoutCounter:Please try again");
                break;
            }
            case TMPPaymentResultStatePossibleSuccess: {
                self.payButton.hidden = YES;
                self.statusImageView.hidden = NO;
                self.statusImageView.image = [UIImage tmp_imageNamed:@"checkout_counter_failed"];
                self.statusLabel.hidden = NO;
                self.statusLabel.text = TMLocalizedString(@"TMP_CheckoutCounter:Please try again");
                break;
            }
            default:
                break;
        }
    } sync:NO];
}

#pragma mark - private

- (void)runLoadingIndicator {
    [self _indicatorAnimate:YES];
}

- (void)stopLoadingIndicatorIfNeeded {
    [self _indicatorAnimate:NO];
}

- (void)_indicatorAnimate:(BOOL)animated {
    NSAssert(NSThread.isMainThread, @"must on main thread");
    
    if (animated) {        
        self.statusImageView.image = [UIImage tmp_imageNamed:@"checkout_counter_loading"];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.duration = 0.8;
        animation.removedOnCompletion = YES;
        animation.fromValue = @(0);
        animation.toValue = @(2 * M_PI);
        animation.repeatCount = HUGE_VALF;
        
        [self.statusImageView.layer addAnimation:animation forKey:@"run_indicator"];
    } else {
        [self.statusImageView.layer removeAnimationForKey:@"run_indicator"];
    }
}

#pragma mark - actions

- (IBAction)dismiss:(id)sender {
    [self.responder dismissCheckoutCounter:self];
}

- (IBAction)payButtonPressed:(id)sender {
    [self.responder checkoutCounter:self payPressed:nil];
}

- (IBAction)changePaymentMethodPressed:(id)sender {
    if (self.paymentStatus != TMPPaymentResultStateIdle) {
        return;
    }
    
    if (![self.responder respondsToSelector:@selector(checkoutCounter:changePaymentMethodPressed:)]) {
        return;
    }
    
    [self.responder checkoutCounter:self changePaymentMethodPressed:@{@"contentHeight" : @(self.checkoutCounterContentView.bounds.size.height)}];
}

#pragma mark - notification

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    // force in progress
    if (self.paymentStatus == TMPPaymentResultStateInProgress) {
        self.paymentStatus = TMPPaymentResultStateInProgress;
    }
}

@end
