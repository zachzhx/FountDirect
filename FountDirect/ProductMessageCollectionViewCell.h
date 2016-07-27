//
//  ProductMessageCollectionViewCell.h
//  Fount
//
//  Created by Zhang Xu on 7/12/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Product;

@protocol ProductMessageCellDelegate <NSObject>

-(void)addToCartWithProductDictionary:(NSDictionary *)dictionary;

-(void)goToWebsiteWithProductDictionary:(NSDictionary *)dictionary;

@end

@interface ProductMessageCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *bigView;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *salePrice;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UIView *productInfoView;

@property (nonatomic, strong) NSDictionary *productDictionary;

@property (nonatomic, strong) Product *product;

@property (nonatomic, weak) id<ProductMessageCellDelegate> delegate;

-(void)setupCell;

@end
