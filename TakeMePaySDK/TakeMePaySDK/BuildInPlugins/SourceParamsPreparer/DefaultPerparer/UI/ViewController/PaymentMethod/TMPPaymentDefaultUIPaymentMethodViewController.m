//
//  TMPPaymentDefaultUIPaymentMethodViewController.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2018/12/24.
//  Copyright © 2018 JapanFoodie. All rights reserved.
//

#import "TMPPaymentDefaultUIPaymentMethodViewController.h"
#import "TMPPaymentDefaultUIPaymentMethodItemCellTableViewCell.h"
#import "TMPPaymentMethod.h"
#import "TMPSDKConstants.h"
#import "TMUtils.h"

@interface TMPPaymentDefaultUIPaymentMethodViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) TMPPaymentUITheme *theme;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *itemList;

@property (nonatomic, assign) CGFloat contentHeight;

@end

@implementation TMPPaymentDefaultUIPaymentMethodViewController

@synthesize responder = _responder;
@synthesize items = _items;
@synthesize userInfo = _userInfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.itemList registerNib:[UINib nibWithNibName:NSStringFromClass(TMPPaymentDefaultUIPaymentMethodItemCellTableViewCell.class) bundle:[NSBundle bundleWithIdentifier:TMP_SDK_BUNDLE_IDENTIFIER]] forCellReuseIdentifier:TMP_DEFAULT_PAYMENT_METHOD_ITEM_REUSE_IDENTIFIER];
    
    self.contentViewHeightConstraint.constant = self.contentHeight;
}

#pragma mark - TMPPaymentUIThemeAcceptable

- (instancetype)initFromTheme:(TMPPaymentUITheme *)theme {
    if (self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleWithIdentifier:TMP_SDK_BUNDLE_IDENTIFIER]]) {
        _theme = theme;
    }
    return self;
}

- (void)setUITheme:(TMPPaymentUITheme *)theme {
    if (![theme isKindOfClass:TMPPaymentUITheme.class]) {
        return;
    }
    _theme = theme;
}

- (TMPPaymentUITheme *)currentUITheme {
    return self.theme;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMPPaymentDefaultUIPaymentMethodItemCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TMP_DEFAULT_PAYMENT_METHOD_ITEM_REUSE_IDENTIFIER];
    
    [cell configCellFrom:self.items[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self.responder paymentMethodView:self didSelect:self.items[indexPath.row] atIndex:indexPath.row];
}

#pragma mark - setters

- (void)setItems:(NSArray<TMPPaymentMethod *> *)items {
    _items = items;
    
    [TMUtils executeOnMainQueue:^{
        CGFloat offsetY = self.itemList.contentOffset.y;
        
        [self.itemList reloadData];
        [self.itemList setContentOffset:CGPointMake(0, offsetY)];
    } sync:NO];
}

- (void)setUserInfo:(NSDictionary *)userInfo {
    _userInfo = userInfo;
    
    if ([userInfo isKindOfClass:NSDictionary.class] && [userInfo[@"contentHeight"] isKindOfClass:NSNumber.class]) {
        NSNumber *height = userInfo[@"contentHeight"];
        
        self.contentHeight = height.doubleValue;
    }
}

#pragma mark - actions

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
