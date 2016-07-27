//
//  ProductCollectionViewCell.m
//  Spree
//
//  Created by Rush on 10/5/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "ProductCollectionViewCell.h"
#import "UIColor+CustomColors.h"
#import "Product.h"
//#import <AFNetworking.h>
//#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ServiceLayer.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProductCollectionViewCell() {
//    UIImage *placeholderImage;
}

//@property (weak) id <SDWebImageOperation> imageOperation;

@end

@implementation ProductCollectionViewCell

-(void)awakeFromNib {
    self.mainImageView.layer.borderColor = [UIColor borderColor].CGColor;
    self.mainImageView.layer.borderWidth = 1.0f;
    
    self.productNameLabel.textColor = [UIColor lightGrayColor];
    self.priceLabel.textColor = [UIColor themeColor];
    self.salePriceLabel.textColor = [UIColor themeColor];
    
    self.checkBoxImageView.tintColor = [UIColor lightGrayColor];
    self.deleteButton.hidden = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeTapped:)];
    [self.checkBoxImageView addGestureRecognizer:tapGesture];
    self.checkBoxImageView.userInteractionEnabled = YES;
    
//    UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
//    [self.mainImageView addGestureRecognizer:tapGesture];
//    self.mainImageView.userInteractionEnabled = YES;
    
//    AFImageResponseSerializer *serializer = [[AFImageResponseSerializer alloc] init];
//    serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"image/pjpeg"];
//    self.mainImageView.imageResponseSerializer = serializer;
    
//    placeholderImage = [UIImage imageNamed:@"placeholder"];
}

-(void) setupCell {
    self.mainImageView.image = nil;
    
//    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:self.product.imageUrl]];
    
    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:self.product.imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            self.mainImageView.image = image;
            //            NSLog(@"SETTING - IDP:%tu", indexPath.row);
        } else {
//            NSLog(@"ERROR:%@", [error localizedDescription]);
            self.mainImageView.image = [UIImage imageNamed:@"image_unavailable"];
        }
    }];

    //Used in MDP
    if (self.showDeleteButton) {
        if (self.product.isMine) {
            self.deleteButton.hidden = NO;
        } else {
            self.deleteButton.hidden = YES;
        }
    }
    
    self.brandLabel.text = self.product.brand.name;
    
    //User seller name if brand is unavailable
    if (!self.product.brand) {
        self.brandLabel.text = self.product.seller.name;
    }
    
    self.productNameLabel.text = self.product.name;
    
//    NSLog(@"FP:%tu: IN STOCK -- %i", self.product.finalPrice, self.product.inStock);
//    NSLog(@"IN STOCK -- %i", self.product.inStock);
    
    
    if (self.product.inStock) {
        [self setupInStockCell];
    } else {
        [self setupOutOfStockCellWithPrice:self.product.finalPrice];
    }
    
    [self setLikedImage];
}

-(void) setupInStockCell {
    self.priceLabel.textColor = [UIColor themeColor];
    self.salePriceLabel.textColor = [UIColor themeColor];
    
    NSString *priceText = [NSNumberFormatter localizedStringFromNumber:@(self.product.price) numberStyle:NSNumberFormatterCurrencyStyle];
    self.priceLabel.text = priceText;
    
    NSString *salePriceText = [NSNumberFormatter localizedStringFromNumber:@(self.product.finalPrice) numberStyle:NSNumberFormatterCurrencyStyle];
    self.salePriceLabel.text = salePriceText;
    
    if (self.product.shopperPoints == 0) {
        self.lineLable.hidden = YES;
        self.pointsLabel.hidden = YES;
    }else{
        self.lineLable.hidden = NO;
        self.pointsLabel.hidden = NO;
        if (self.product.shopperPoints>10000) {
            NSString *pointsString = [NSString stringWithFormat:@"Earn %@ points",[self abbreviateNumber:self.product.shopperPoints withDecimal:2]];
            NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:pointsString];
            [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:@"#f46d15"] range:NSMakeRange(4, pointsString.length-10)];
            self.pointsLabel.attributedText = attriString;
        }else{
            NSString *pointsString = [NSString stringWithFormat:@"Earn %@ points",[self addCommas:self.product.shopperPoints]];
            NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:pointsString];
            [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHexString:@"#f46d15"] range:NSMakeRange(4, pointsString.length-10)];
            self.pointsLabel.attributedText = attriString;
        }
    }
    
    if (self.product.finalPrice == self.product.price || self.product.finalPrice == 0.0) {
        
        self.salePriceLabel.hidden = YES;
        //self.salePriceLabel.text = nil;
        
    }else{
        //Sale price is lower than price
        self.salePriceLabel.hidden = NO;
        
        self.priceLabel.attributedText = [self addStrikethroughToString:priceText];
    }
}

-(void) setupOutOfStockCellWithPrice:(CGFloat) price {
    self.lineLable.hidden = YES;
    self.pointsLabel.hidden = YES;
    self.priceLabel.textColor = [UIColor grayFontColor];
    
    NSString *priceText = [NSNumberFormatter localizedStringFromNumber:@(price) numberStyle:NSNumberFormatterCurrencyStyle];
    
    self.priceLabel.attributedText = [self addStrikethroughToString:priceText];
    
    self.salePriceLabel.hidden = NO;
    self.salePriceLabel.textColor = [UIColor grayFontColor];
    self.salePriceLabel.text = @"Out of stock";
}

-(NSAttributedString *) addStrikethroughToString:(NSString *) string {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attributeString addAttribute:NSStrikethroughStyleAttributeName
                            value:@2
                            range:NSMakeRange(0, [attributeString length])];
    
    return attributeString;
}

- (IBAction)deleteButtonClicked:(UIButton *)sender {
    [self.delegate deleteProduct:self.tag];
}

#pragma mark - Tap Gesture
-(void) likeTapped:(UITapGestureRecognizer *) recognizer {
    if (self.product.liked) {
        [[[ServiceLayer alloc] init] unlikeProductWithProductId:self.product.productId completion:^(NSDictionary *dictionary) {
            self.product.liked = !self.product.liked;
            [self.checkBoxImageView setImage:[UIImage imageNamed:@"likes"]];
        }];
    } else {
        [[[ServiceLayer alloc] init] likeProductWithProductId:self.product.productId completion:^(NSDictionary *dictionary) {
            self.product.liked = !self.product.liked;
            [self.checkBoxImageView setImage:[UIImage imageNamed:@"likesfilled"]];
        }];
    }
}

#pragma mark - Helper Methods
-(void) setLikedImage {
    
    if (self.showCheck) {
        
        if (self.product.selected) {
            self.checkBoxImageView.image = [[UIImage imageNamed:@"checkbox_checked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        } else {
            self.checkBoxImageView.image = [[UIImage imageNamed:@"checkbox_unchecked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
    } else {
    
        if (self.product.liked) {
            [self.checkBoxImageView setImage:[UIImage imageNamed:@"likesfilled"]];
        } else {
            [self.checkBoxImageView setImage:[UIImage imageNamed:@"likes"]];
        }
    }
}

#pragma mark - Format the Number
-(NSString *) addCommas:(NSUInteger) numberToFormat {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *numberAsString = [formatter stringFromNumber:[NSNumber numberWithInteger:numberToFormat]];
    NSString *newString = [NSString stringWithFormat:@"%@", numberAsString];
    
    return newString;
}

-(NSString *)abbreviateNumber:(NSInteger)num withDecimal:(NSInteger)dec {
    
    NSString *abbrevNum;
    CGFloat number = (CGFloat)num;
    if(num > 1000){
        NSArray *abbrev = [[NSArray alloc]initWithObjects:@"K", @"M", @"B",nil];
        
        for (NSInteger i=(NSInteger)abbrev.count-1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            NSInteger size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Here, we multiply by decPlaces, round, and then divide by decPlaces.
                // This gives us nice rounding to a particular decimal place.
                //number = round(number*dec/size)/dec;
                number = number/size;
                
                //NSString *numberString = [self floatToString:number];
                NSString *numberString = [self notRounding:number afterPoint:1];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
                
                //                NSLog(@"%@", abbrevNum);
                
            }
            
        }
    }
    
    return abbrevNum;
}


-(NSString *)notRounding:(float)price afterPoint:(int)position{
    
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    NSDecimalNumber *ouncesDecimal;
    
    NSDecimalNumber *roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    return [NSString stringWithFormat:@"%@",roundedOunces];
    
}


@end
