//
//  Product.h
//  Spree
//
//  Created by Rush on 9/17/15.
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import "BaseModel.h"
#import "Brand.h"
#import "Seller.h"
#import "User.h"

@class Seller;
@class Brand;
@class User;

@protocol Product

@end

@interface Product : BaseModel

@property (nonatomic, strong) Brand *brand;
@property (nonatomic, strong) Seller *seller;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *productDescription;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, assign) CGFloat salePrice;
@property (nonatomic, assign) CGFloat finalPrice;

@property (nonatomic, strong) NSString *buyURL;
@property (nonatomic, assign) NSInteger sale;
@property (nonatomic, strong) NSString *creationDate;

//@property (nonatomic, assign) CGFloat retailPrice;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) BOOL inStock;
@property (nonatomic, assign) BOOL isMine;
@property (nonatomic, assign) BOOL liked;

@property (nonatomic, assign) NSUInteger productId;
@property (nonatomic, assign) NSUInteger shoppingCartId;

@property (nonatomic, assign) NSUInteger visualTagId;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) User *productTagger;

@property (nonatomic, strong) NSString *TTPrice;
@property (nonatomic, strong) NSString *TTOriginalPrice;

@property (nonatomic, assign) NSUInteger shopperPoints;

@property (nonatomic, strong) NSDictionary *twoTapDictionary;
@property (nonatomic, strong) NSString *shippingOption;

//@property (nonatomic, strong) NSDictionary *visualTagDataDictionary;
//@property (nonatomic, strong) NSDictionary *productDataDictionary;

@end
