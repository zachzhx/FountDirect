//
//  ShoppingCartProduct.h
//  Spree
//
//  Created by Rush on 10/30/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "BaseModel.h"
#import "Product.h"
#import "ProductMetadata.h"

@protocol ShoppingCartProduct <NSObject>

@end

@interface ShoppingCartProduct : BaseModel

@property (nonatomic, strong) Product *product;
@property (nonatomic, strong) ProductMetadata *productMetadata;
@property (nonatomic, assign) NSUInteger shoppingCartProductId;
@property (nonatomic, assign) NSUInteger quantity;
@property (nonatomic, strong) NSString *shippingMethod;

@end
