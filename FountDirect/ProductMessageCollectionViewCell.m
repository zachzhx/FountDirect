//
//  ProductMessageCollectionViewCell.m
//  Fount
//
//  Created by Zhang Xu on 7/12/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "ProductMessageCollectionViewCell.h"
#import "UIColor+CustomColors.h"
#import "Product.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ProductMessageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bigView.layer.borderColor = [UIColor selectedGrayColor].CGColor;
    self.bigView.layer.borderWidth = 1;
    self.bigView.layer.cornerRadius = 5;
    self.bigView.layer.masksToBounds = YES;
    self.productInfoView.layer.borderColor = [UIColor selectedGrayColor].CGColor;
    self.productInfoView.layer.borderWidth = 1;
}

-(void)setupCell{
    
    self.brandNameLabel.text = self.product.brand.name;
    self.productNameLabel.text = self.product.name;
    if (self.product.brand == nil) {
        self.brandNameLabel.text = @" ";
    }
    
    NSString *priceText = [NSNumberFormatter localizedStringFromNumber:@(self.product.price) numberStyle:NSNumberFormatterCurrencyStyle];
    NSString *finalPriceText = [NSNumberFormatter localizedStringFromNumber:@(self.product.finalPrice) numberStyle:NSNumberFormatterCurrencyStyle];
    
    
    NSString *TTprice = [self.product.TTPrice stringByReplacingOccurrencesOfString:@"$" withString:@""];
    NSString *TTOriginalPrice = [self.product.TTOriginalPrice stringByReplacingOccurrencesOfString:@"$" withString:@""];
    NSString *TTpriceText = [NSNumberFormatter localizedStringFromNumber:@(TTprice.floatValue) numberStyle:NSNumberFormatterCurrencyStyle];
    NSString *TTOriginalPriceText = [NSNumberFormatter localizedStringFromNumber:@(TTOriginalPrice.floatValue) numberStyle:NSNumberFormatterCurrencyStyle];
    
    if (self.product.twoTapDictionary){
        
        self.salePrice.text = TTOriginalPriceText;
        self.priceLabel.text = TTpriceText;
        if (TTOriginalPrice.floatValue > TTprice.floatValue) {
            self.salePrice.hidden = NO;
            self.salePrice.attributedText = [self addCrossingLineToString:priceText];
        }else{
            self.salePrice.hidden = YES;
        }
    }else{
        self.salePrice.text = priceText;
        self.priceLabel.text = finalPriceText;
        
        if (self.product.price > self.product.finalPrice) {
            
            self.salePrice.hidden = NO;
            self.salePrice.attributedText = [self addCrossingLineToString:priceText];
        }else{
            self.salePrice.hidden = YES;
        }
    }
    
    if (self.product.inStock) {
        self.addToCartButton.enabled = YES;
        self.addToCartButton.alpha = 1;
    }else{
        self.salePrice.hidden = NO;
        self.salePrice.attributedText = [self addCrossingLineToString:finalPriceText];
        self.priceLabel.text = @"Out Of Stock";
        self.addToCartButton.enabled = NO;
        self.addToCartButton.alpha = 0.5;
    }
    
    if ([self.product.seller.quality isEqualToString:@"LOW"]) {
        [self.addToCartButton setTitle:[NSString stringWithFormat:@"Shop Now on %@",self.product.seller.name] forState:UIControlStateNormal];
    }else{
        [self.addToCartButton setTitle:@"Add To Cart" forState:UIControlStateNormal];
    }
    
    [self.productImageView sd_setImageWithURL:[NSURL URLWithString:self.product.imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
}

-(NSAttributedString *)addCrossingLineToString:(NSString *)string{
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attributeString addAttribute:NSStrikethroughStyleAttributeName
                            value:@2
                            range:NSMakeRange(0, [attributeString length])];
    
    return attributeString;
}

- (IBAction)addToCartButton:(id)sender {
    if ([self.addToCartButton.currentTitle isEqualToString:@"Add To Cart"]){
        
        [self.delegate addToCartWithProductDictionary:self.productDictionary];
    }else{
        
        [self.delegate goToWebsiteWithProductDictionary:self.productDictionary];

    }
}


@end
