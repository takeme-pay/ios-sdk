//
//  TMPPaymentDefaultUIPaymentMethodItemCellTableViewCell.m
//  TakeMePaySDK
//
//  Created by tianren.zhu on 2019/1/3.
//  Copyright © 2019 JapanFoodie. All rights reserved.
//

#import "TMPPaymentDefaultUIPaymentMethodItemCellTableViewCell.h"
#import "UIImageView+TMDownLoadImage.h"
#import "TMPPaymentMethodItem+TMPUIInfo.h"
#import "UIImage+TMPLoadImageFromSDKBundle.h"


NSString *const TMP_DEFAULT_PAYMENT_METHOD_ITEM_REUSE_IDENTIFIER = @"TMP_DEFAULT_PAYMENT_METHOD_ITEM";

@interface TMPPaymentDefaultUIPaymentMethodItemCellTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *radiobox;
@property (weak, nonatomic) IBOutlet UIView *radioboxSelectedView;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation TMPPaymentDefaultUIPaymentMethodItemCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - public

- (void)configCellFrom:(TMPPaymentMethod *)item {
    self.itemNameLabel.text = item.title;
    
    if ([item.iconUris isKindOfClass:NSArray.class] && item.iconUris.count > 0) {
        NSString *uri = item.iconUris.firstObject;
        
        if ([uri hasPrefix:@"http"]) {
            [self.iconImageView tm_setImageUrl:uri];
        } else {
            [self.iconImageView setImage:[UIImage tmp_imageNamed:uri]];
        }
    }
    
    
    self.radioboxSelectedView.hidden = !item.tmp_selected;
}

@end
